import XCTest
@testable import OrboCore

final class HermesMessengerTests: XCTestCase {
    private let ticketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000201")!)
    private let initialParcelID = HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000202")!)
    private let returnParcelID = HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000203")!)
    private let subject = HermesSubjectID(rawValue: "subject.ean")!
    private let otherSubject = HermesSubjectID(rawValue: "subject.other")!
    private let origin = HermesAddress(rawValue: "orbo.engraving")!
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestia = HermesAddress(rawValue: "orbo.hestia")!
    private let otherAddress = HermesAddress(rawValue: "orbo.other")!
    private let unknownService = HermesAddress(rawValue: "orbo.unknown")!
    private let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
    private let moiraiPackage = HermesParcelKind(rawValue: "orbo.moirai-package.v1")!
    private let wrongKind = HermesParcelKind(rawValue: "orbo.wrong.v1")!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testTicketPreservesSubjectServiceFinalAddresseeAndExpectation() {
        let ticket = makeTicket()

        XCTAssertEqual(ticket.ticketID, ticketID)
        XCTAssertEqual(ticket.subjectID, subject)
        XCTAssertEqual(ticket.serviceDestination, moirai)
        XCTAssertEqual(ticket.finalAddressee, hestia)
        XCTAssertEqual(ticket.expectedReturnKind, moiraiPackage)
    }

    func testTicketRequiresServiceDestinationToDifferFromFinalAddressee() {
        XCTAssertNil(
            HermesTicket(
                ticketID: ticketID,
                subjectID: subject,
                serviceDestination: hestia,
                finalAddressee: hestia,
                expectedReturnKind: moiraiPackage
            )
        )
    }

    func testExpectationIsDerivedFromTheOriginalTicket() {
        let ticket = makeTicket()
        let expectation = HermesExpectation(ticket: ticket)

        XCTAssertEqual(expectation.ticketID, ticket.ticketID)
        XCTAssertEqual(expectation.subjectID, ticket.subjectID)
        XCTAssertEqual(expectation.expectedFrom, ticket.serviceDestination)
        XCTAssertEqual(expectation.expectedReturnKind, ticket.expectedReturnKind)
        XCTAssertEqual(expectation.finalAddressee, ticket.finalAddressee)
    }

    func testParcelPreservesTicketSubjectSenderKindAddresseeAndPayload() {
        let parcel = makeInitialParcel()

        XCTAssertEqual(parcel.parcelID, initialParcelID)
        XCTAssertEqual(parcel.ticketID, ticketID)
        XCTAssertEqual(parcel.subjectID, subject)
        XCTAssertEqual(parcel.sender, origin)
        XCTAssertEqual(parcel.kind, natalCommission)
        XCTAssertEqual(parcel.finalAddressee, hestia)
        XCTAssertEqual(parcel.payload, "dummy natal commission")
    }

    func testKnownMessengerServiceContractResolves() {
        let registry = HermesMessengerRouteRegistry()
        let contract = registry.contract(
            for: moirai,
            accepting: natalCommission,
            returning: moiraiPackage
        )

        XCTAssertEqual(contract?.serviceDestination, moirai)
        XCTAssertEqual(contract?.acceptedParcelKind, natalCommission)
        XCTAssertEqual(contract?.expectedReturnKind, moiraiPackage)
    }

    func testMessengerRouteRejectsWrongAcceptedParcelKind() {
        let registry = HermesMessengerRouteRegistry()
        XCTAssertNil(
            registry.contract(
                for: moirai,
                accepting: wrongKind,
                returning: moiraiPackage
            )
        )
    }

    func testMessengerRouteRejectsWrongExpectedReturnKind() {
        let registry = HermesMessengerRouteRegistry()
        XCTAssertNil(
            registry.contract(
                for: moirai,
                accepting: natalCommission,
                returning: wrongKind
            )
        )
    }

    func testKnownFinalAddresseeAcceptsExpectedMessengerReturnKind() {
        let registry = HermesMessengerRouteRegistry()
        XCTAssertTrue(registry.finalAddressee(hestia, accepts: moiraiPackage))
        XCTAssertFalse(registry.finalAddressee(hestia, accepts: natalCommission))
    }

    func testUnknownMessengerRouteDoesNotResolve() {
        let registry = HermesMessengerRouteRegistry()
        XCTAssertNil(
            registry.contract(
                for: unknownService,
                accepting: natalCommission,
                returning: moiraiPackage
            )
        )
    }

    func testValidCommissionCanBeAccepted() throws {
        var messenger = HermesMessenger()

        try messenger.accept(
            ticket: makeTicket(),
            parcel: makeInitialParcel(),
            occurredAt: instant
        )

        XCTAssertEqual(messenger.manifest.events(for: ticketID).map(\.kind), [.ticketOpened])
    }

    func testServiceHandoffAppendsCorrectManifestEvent() throws {
        let messenger = try messengerAfterServiceHandoff()

        XCTAssertEqual(
            messenger.manifest.events(for: ticketID).map(\.kind),
            [.ticketOpened, .deliveredToService]
        )
    }

    func testMatchingReturnIsAccepted() throws {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel()

        try messenger.acceptReturn(parcel: returned, occurredAt: instant)

        XCTAssertEqual(messenger.manifest.events(for: ticketID).last?.kind, .serviceReturnAccepted)
        XCTAssertEqual(messenger.manifest.events(for: ticketID).last?.parcelID, returnParcelID)
    }

    func testWrongTicketIsRejected() throws {
        var messenger = try messengerAfterServiceHandoff()
        let wrongTicketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000299")!)
        let returned = makeReturnParcel(ticketID: wrongTicketID)

        XCTAssertThrowsError(try messenger.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesMessenger.Failure, .unknownTicket)
        }
    }

    func testWrongSubjectIsRejected() throws {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel(subjectID: otherSubject)

        XCTAssertThrowsError(try messenger.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesMessenger.Failure, .subjectMismatch)
        }
    }

    func testWrongSenderIsRejected() throws {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel(sender: otherAddress)

        XCTAssertThrowsError(try messenger.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesMessenger.Failure, .senderMismatch)
        }
    }

    func testWrongParcelKindIsRejected() throws {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel(kind: wrongKind)

        XCTAssertThrowsError(try messenger.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesMessenger.Failure, .parcelKindMismatch)
        }
    }

    func testChangedFinalAddresseeIsRejected() throws {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel(finalAddressee: otherAddress)

        XCTAssertThrowsError(try messenger.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesMessenger.Failure, .finalAddresseeMismatch)
        }
    }

    func testValidReturnedParcelCanBeDeliveredToHestia() throws {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel()

        try messenger.acceptReturn(parcel: returned, occurredAt: instant)
        try messenger.deliverToFinalAddressee(parcel: returned, occurredAt: instant)

        XCTAssertEqual(messenger.manifest.events(for: ticketID).last?.kind, .deliveredToAddressee)
        XCTAssertEqual(messenger.manifest.events(for: ticketID).last?.parcelID, returnParcelID)
    }

    func testReceiptResolvesJourney() throws {
        var messenger = try messengerAfterFinalDelivery()
        let receipt = HermesReceipt(
            ticketID: ticketID,
            parcelID: returnParcelID,
            recipient: hestia,
            receivedAt: instant
        )

        try messenger.recordReceipt(receipt)

        XCTAssertEqual(
            messenger.manifest.events(for: ticketID).suffix(2).map(\.kind),
            [.receiptRecorded, .resolved]
        )
        XCTAssertEqual(messenger.manifest.currentState(for: ticketID), .resolved)
        XCTAssertFalse(messenger.manifest.unresolvedTickets().contains(ticketID))
    }

    func testDuplicateCallbackCannotCreateDuplicateDelivery() throws {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel()

        try messenger.acceptReturn(parcel: returned, occurredAt: instant)

        XCTAssertThrowsError(try messenger.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesMessenger.Failure, .invalidState)
        }

        try messenger.deliverToFinalAddressee(parcel: returned, occurredAt: instant)

        let kinds = messenger.manifest.events(for: ticketID).map(\.kind)
        XCTAssertEqual(kinds.filter { $0 == .serviceReturnAccepted }.count, 1)
        XCTAssertEqual(kinds.filter { $0 == .deliveredToAddressee }.count, 1)
    }

    private func messengerAfterServiceHandoff() throws -> HermesMessenger {
        var messenger = HermesMessenger()
        try messenger.accept(
            ticket: makeTicket(),
            parcel: makeInitialParcel(),
            occurredAt: instant
        )
        try messenger.deliverToService(ticketID: ticketID, occurredAt: instant)
        return messenger
    }

    private func messengerAfterFinalDelivery() throws -> HermesMessenger {
        var messenger = try messengerAfterServiceHandoff()
        let returned = makeReturnParcel()
        try messenger.acceptReturn(parcel: returned, occurredAt: instant)
        try messenger.deliverToFinalAddressee(parcel: returned, occurredAt: instant)
        return messenger
    }

    private func makeTicket() -> HermesTicket {
        HermesTicket(
            ticketID: ticketID,
            subjectID: subject,
            serviceDestination: moirai,
            finalAddressee: hestia,
            expectedReturnKind: moiraiPackage
        )!
    }

    private func makeInitialParcel() -> HermesParcel<String> {
        HermesParcel(
            parcelID: initialParcelID,
            ticketID: ticketID,
            subjectID: subject,
            sender: origin,
            kind: natalCommission,
            finalAddressee: hestia,
            payload: "dummy natal commission"
        )
    }

    private func makeReturnParcel(
        ticketID: HermesTicketID? = nil,
        subjectID: HermesSubjectID? = nil,
        sender: HermesAddress? = nil,
        kind: HermesParcelKind? = nil,
        finalAddressee: HermesAddress? = nil
    ) -> HermesParcel<String> {
        HermesParcel(
            parcelID: returnParcelID,
            ticketID: ticketID ?? self.ticketID,
            subjectID: subjectID ?? subject,
            sender: sender ?? moirai,
            kind: kind ?? moiraiPackage,
            finalAddressee: finalAddressee ?? hestia,
            payload: "dummy Moirai package"
        )
    }
}
