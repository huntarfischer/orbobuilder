import XCTest
@testable import OrboCore

final class HermesStage0Tests: XCTestCase {
    private let ticketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    private let parcelID = HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)
    private let subject = HermesSubjectID(rawValue: "subject.ean")!
    private let origin = HermesAddress(rawValue: "orbo.engraving")!
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestia = HermesAddress(rawValue: "orbo.hestia")!
    private let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
    private let atroposPackage = HermesParcelKind(rawValue: "orbo.atropos-package.v1")!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testHermesIdentifiersRejectBlankValues() {
        XCTAssertNil(HermesSubjectID(rawValue: "   "))
        XCTAssertNil(HermesAddress(rawValue: "\n"))
        XCTAssertNil(HermesParcelKind(rawValue: ""))
    }

    func testTicketPreservesSubjectServiceFinalAddresseeAndExpectation() {
        let ticket = makeTicket()

        XCTAssertEqual(ticket.ticketID, ticketID)
        XCTAssertEqual(ticket.subjectID, subject)
        XCTAssertEqual(ticket.serviceDestination, moirai)
        XCTAssertEqual(ticket.finalAddressee, hestia)
        XCTAssertEqual(ticket.expectedReturnKind, atroposPackage)
    }

    func testTicketRequiresServiceDestinationToDifferFromFinalAddressee() {
        XCTAssertNil(
            HermesTicket(
                ticketID: ticketID,
                subjectID: subject,
                serviceDestination: hestia,
                finalAddressee: hestia,
                expectedReturnKind: atroposPackage
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
        let parcel = HermesParcel(
            parcelID: parcelID,
            ticketID: ticketID,
            subjectID: subject,
            sender: origin,
            kind: natalCommission,
            finalAddressee: hestia,
            payload: "dummy natal commission"
        )

        XCTAssertEqual(parcel.parcelID, parcelID)
        XCTAssertEqual(parcel.ticketID, ticketID)
        XCTAssertEqual(parcel.subjectID, subject)
        XCTAssertEqual(parcel.sender, origin)
        XCTAssertEqual(parcel.kind, natalCommission)
        XCTAssertEqual(parcel.finalAddressee, hestia)
        XCTAssertEqual(parcel.payload, "dummy natal commission")
    }

    func testReceiptIdentifiesTheDeliveryItAcknowledges() {
        let receipt = HermesReceipt(
            ticketID: ticketID,
            parcelID: parcelID,
            recipient: hestia,
            receivedAt: instant
        )

        XCTAssertEqual(receipt.ticketID, ticketID)
        XCTAssertEqual(receipt.parcelID, parcelID)
        XCTAssertEqual(receipt.recipient, hestia)
        XCTAssertEqual(receipt.receivedAt, instant)
    }

    func testManifestEventIdentifiesItsTicketEventAndSequence() {
        let event = HermesManifestEvent(
            ticketID: ticketID,
            sequence: 1,
            kind: .ticketOpened,
            occurredAt: instant
        )!

        XCTAssertEqual(event.ticketID, ticketID)
        XCTAssertEqual(event.sequence, 1)
        XCTAssertEqual(event.kind, .ticketOpened)
        XCTAssertEqual(event.occurredAt, instant)
        XCTAssertNil(event.parcelID)

        XCTAssertNil(
            HermesManifestEvent(
                ticketID: ticketID,
                sequence: 0,
                kind: .ticketOpened,
                occurredAt: instant
            )
        )
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
}
