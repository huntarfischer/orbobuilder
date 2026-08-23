import XCTest
@testable import OrboCore

final class HermesStage3Tests: XCTestCase {
    private let ticketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000201")!)
    private let returnParcelID = HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000202")!)
    private let subject = HermesSubjectID(rawValue: "subject.ean")!
    private let otherSubject = HermesSubjectID(rawValue: "subject.other")!
    private let origin = HermesAddress(rawValue: "orbo.engraving")!
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestia = HermesAddress(rawValue: "orbo.hestia")!
    private let otherAddress = HermesAddress(rawValue: "orbo.other")!
    private let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
    private let moiraiPackage = HermesParcelKind(rawValue: "orbo.moirai-package.v1")!
    private let wrongKind = HermesParcelKind(rawValue: "orbo.wrong.v1")!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testValidCommissionCanBeAccepted() throws {
        var courier = HermesCourier()

        try courier.accept(
            ticket: makeTicket(),
            parcel: makeInitialParcel(),
            occurredAt: instant
        )

        XCTAssertEqual(courier.manifest.events(for: ticketID).map(\.kind), [.ticketOpened])
    }

    func testServiceHandoffAppendsCorrectManifestEvent() throws {
        var courier = try courierAfterServiceHandoff()

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).map(\.kind),
            [.ticketOpened, .deliveredToService]
        )
    }

    func testMatchingReturnIsAccepted() throws {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel()

        try courier.acceptReturn(parcel: returned, occurredAt: instant)

        XCTAssertEqual(courier.manifest.events(for: ticketID).last?.kind, .serviceReturnAccepted)
        XCTAssertEqual(courier.manifest.events(for: ticketID).last?.parcelID, returnParcelID)
    }

    func testWrongTicketIsRejected() throws {
        var courier = try courierAfterServiceHandoff()
        let wrongTicketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000299")!)
        let returned = makeReturnParcel(ticketID: wrongTicketID)

        XCTAssertThrowsError(try courier.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .unknownTicket)
        }
    }

    func testWrongSubjectIsRejected() throws {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel(subjectID: otherSubject)

        XCTAssertThrowsError(try courier.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .subjectMismatch)
        }
    }

    func testWrongSenderIsRejected() throws {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel(sender: otherAddress)

        XCTAssertThrowsError(try courier.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .senderMismatch)
        }
    }

    func testWrongParcelKindIsRejected() throws {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel(kind: wrongKind)

        XCTAssertThrowsError(try courier.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .parcelKindMismatch)
        }
    }

    func testChangedFinalAddresseeIsRejected() throws {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel(finalAddressee: otherAddress)

        XCTAssertThrowsError(try courier.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .finalAddresseeMismatch)
        }
    }

    func testValidReturnedParcelCanBeDeliveredToHestia() throws {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel()

        try courier.acceptReturn(parcel: returned, occurredAt: instant)
        try courier.deliverToFinalAddressee(parcel: returned, occurredAt: instant)

        XCTAssertEqual(courier.manifest.events(for: ticketID).last?.kind, .deliveredToAddressee)
        XCTAssertEqual(courier.manifest.events(for: ticketID).last?.parcelID, returnParcelID)
    }

    private func courierAfterServiceHandoff() throws -> HermesCourier {
        var courier = HermesCourier()
        try courier.accept(
            ticket: makeTicket(),
            parcel: makeInitialParcel(),
            occurredAt: instant
        )
        try courier.deliverToService(ticketID: ticketID, occurredAt: instant)
        return courier
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
            parcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000203")!),
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
