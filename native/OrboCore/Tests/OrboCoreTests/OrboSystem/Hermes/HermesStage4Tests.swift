import XCTest
@testable import OrboCore

final class HermesStage4Tests: XCTestCase {
    private let ticketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000301")!)
    private let initialParcelID = HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000302")!)
    private let returnParcelID = HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000303")!)
    private let subject = HermesSubjectID(rawValue: "subject.ean")!
    private let origin = HermesAddress(rawValue: "orbo.engraving")!
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestia = HermesAddress(rawValue: "orbo.hestia")!
    private let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
    private let atroposPackage = HermesParcelKind(rawValue: "orbo.atropos-package.v1")!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testReceiptResolvesJourney() throws {
        var courier = try courierAfterFinalDelivery()
        let receipt = HermesReceipt(
            ticketID: ticketID,
            parcelID: returnParcelID,
            recipient: hestia,
            receivedAt: instant
        )

        try courier.recordReceipt(receipt)

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).suffix(2).map(\.kind),
            [.receiptRecorded, .resolved]
        )
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .resolved)
        XCTAssertFalse(courier.manifest.unresolvedTickets().contains(ticketID))
    }

    func testDuplicateCallbackCannotCreateDuplicateDelivery() throws {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel()

        try courier.acceptReturn(parcel: returned, occurredAt: instant)

        XCTAssertThrowsError(try courier.acceptReturn(parcel: returned, occurredAt: instant)) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }

        try courier.deliverToFinalAddressee(parcel: returned, occurredAt: instant)

        let kinds = courier.manifest.events(for: ticketID).map(\.kind)
        XCTAssertEqual(kinds.filter { $0 == .serviceReturnAccepted }.count, 1)
        XCTAssertEqual(kinds.filter { $0 == .deliveredToAddressee }.count, 1)
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

    private func courierAfterFinalDelivery() throws -> HermesCourier {
        var courier = try courierAfterServiceHandoff()
        let returned = makeReturnParcel()
        try courier.acceptReturn(parcel: returned, occurredAt: instant)
        try courier.deliverToFinalAddressee(parcel: returned, occurredAt: instant)
        return courier
    }

    private func makeTicket() -> HermesTicket {
        HermesTicket(
            ticketID: ticketID,
            subjectID: subject,
            serviceDestination: moirai,
            finalAddressee: hestia,
            expectedReturnKind: atroposPackage
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

    private func makeReturnParcel() -> HermesParcel<String> {
        HermesParcel(
            parcelID: returnParcelID,
            ticketID: ticketID,
            subjectID: subject,
            sender: moirai,
            kind: atroposPackage,
            finalAddressee: hestia,
            payload: "dummy Atropos package"
        )
    }
}
