import XCTest
@testable import OrboCore

final class HermesStage1Tests: XCTestCase {
    private let ticketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000101")!)
    private let secondTicketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000102")!)
    private let parcelID = HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000103")!)
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testManifestAppendsEventsInSequenceOrder() {
        var manifest = HermesManifest()

        XCTAssertTrue(manifest.append(event(sequence: 1, kind: .ticketOpened)))
        XCTAssertTrue(manifest.append(event(sequence: 2, kind: .deliveredToService)))

        XCTAssertEqual(manifest.events(for: ticketID).map(\.sequence), [1, 2])
    }

    func testManifestDoesNotReplaceExistingEvents() {
        var manifest = HermesManifest()
        let original = event(sequence: 1, kind: .ticketOpened)
        let attemptedReplacement = event(sequence: 1, kind: .deliveredToService)

        XCTAssertTrue(manifest.append(original))
        XCTAssertFalse(manifest.append(attemptedReplacement))
        XCTAssertEqual(manifest.events(for: ticketID), [original])
    }

    func testCurrentStateReconstructsDeterministicallyFromHistory() {
        let history = [
            event(sequence: 1, kind: .ticketOpened),
            event(sequence: 2, kind: .deliveredToService),
            event(sequence: 3, kind: .serviceReturnAccepted),
        ]

        var first = HermesManifest()
        var second = HermesManifest()
        history.forEach { XCTAssertTrue(first.append($0)) }
        history.forEach { XCTAssertTrue(second.append($0)) }

        XCTAssertEqual(first.currentState(for: ticketID), .unresolved)
        XCTAssertEqual(first.currentState(for: ticketID), second.currentState(for: ticketID))
        XCTAssertEqual(first.events(for: ticketID), second.events(for: ticketID))
    }

    func testServiceHandoffLeavesTicketUnresolved() {
        var manifest = HermesManifest()
        XCTAssertTrue(manifest.append(event(sequence: 1, kind: .ticketOpened)))
        XCTAssertTrue(manifest.append(event(sequence: 2, kind: .deliveredToService)))

        XCTAssertEqual(manifest.currentState(for: ticketID), .unresolved)
        XCTAssertEqual(manifest.unresolvedTickets(), [ticketID])
    }

    func testReceiptAndResolvedEventCloseTicket() {
        var manifest = HermesManifest()
        XCTAssertTrue(manifest.append(event(sequence: 1, kind: .ticketOpened)))
        XCTAssertTrue(manifest.append(event(sequence: 2, kind: .deliveredToService)))
        XCTAssertTrue(manifest.append(event(sequence: 3, kind: .serviceReturnAccepted)))
        XCTAssertTrue(manifest.append(event(sequence: 4, kind: .deliveredToAddressee, parcelID: parcelID)))
        XCTAssertTrue(manifest.append(event(sequence: 5, kind: .receiptRecorded, parcelID: parcelID)))

        let otherTicketOpened = HermesManifestEvent(
            ticketID: secondTicketID,
            sequence: 1,
            kind: .ticketOpened,
            occurredAt: instant
        )!
        XCTAssertTrue(manifest.append(otherTicketOpened))

        XCTAssertEqual(manifest.currentState(for: ticketID), .unresolved)

        XCTAssertTrue(manifest.append(event(sequence: 6, kind: .resolved, parcelID: parcelID)))
        XCTAssertEqual(manifest.currentState(for: ticketID), .resolved)
        XCTAssertEqual(manifest.unresolvedTickets(), [secondTicketID])
    }

    private func event(
        sequence: Int,
        kind: HermesManifestEventKind,
        parcelID: HermesParcelID? = nil
    ) -> HermesManifestEvent {
        HermesManifestEvent(
            ticketID: ticketID,
            sequence: sequence,
            kind: kind,
            occurredAt: instant,
            parcelID: parcelID
        )!
    }
}
