import XCTest
@testable import OrboCore

final class NatalSpineActIIIBeat5HermesClosureTests: XCTestCase {
    func testHecateReceiptClosesTheOriginalCommissionExactlyOnce() throws {
        var ready = try readyForHecateReceipt()
        let availability = try ready.courier.closeNatalSpineCommission(
            ticketID: ready.ticketID,
            blessing: ready.blessing,
            receivedAt: NatalSpineActIIIFixture.instant(1_920_000_600)
        )

        XCTAssertEqual(availability.ticketID, ready.ticketID)
        XCTAssertEqual(availability.packageID, ready.spine.packageID)
        XCTAssertEqual(availability.subjectID, ready.spine.subjectID)
        XCTAssertEqual(availability.bounds, ready.spine.bounds)
        XCTAssertEqual(ready.courier.manifest.currentState(for: ready.ticketID), .resolved)
        XCTAssertEqual(
            Array(ready.courier.manifest.events(for: ready.ticketID).suffix(3)).map(\.kind),
            [.deliveredToAddressee, .receiptRecorded, .resolved]
        )

        XCTAssertThrowsError(
            try ready.courier.closeNatalSpineCommission(
                ticketID: ready.ticketID,
                blessing: ready.blessing,
                receivedAt: NatalSpineActIIIFixture.instant(1_920_000_660)
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }
    }

    func testCommissionCannotCloseBeforeHecateIsTheDeliveredFinalAddress() throws {
        var state = try NatalSpineActIIIFixture.inHermesCustodyAfterHephaestus()
        let spine = state.package.contents
        let blessing = try Hecate.blessNatalSpine(
            spine,
            indexedBy: Chronos.indexNatalSpine(spine)
        )

        XCTAssertThrowsError(
            try state.courier.closeNatalSpineCommission(
                ticketID: state.ticketID,
                blessing: blessing,
                receivedAt: NatalSpineActIIIFixture.instant(1_920_000_300)
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }
        XCTAssertEqual(state.courier.manifest.currentState(for: state.ticketID), .unresolved)
    }

    func testBlessingForAnotherCommissionCannotCloseThisTicket() throws {
        var ready = try readyForHecateReceipt()
        var other = try NatalSpineActIIIFixture.sealedSpine()
        while other.packageID == ready.spine.packageID {
            other = try NatalSpineActIIIFixture.sealedSpine()
        }
        let wrongBlessing = try Hecate.blessNatalSpine(
            other,
            indexedBy: Chronos.indexNatalSpine(other)
        )

        XCTAssertThrowsError(
            try ready.courier.closeNatalSpineCommission(
                ticketID: ready.ticketID,
                blessing: wrongBlessing,
                receivedAt: NatalSpineActIIIFixture.instant(1_920_000_600)
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .packageMismatch)
        }
        XCTAssertEqual(ready.courier.manifest.currentState(for: ready.ticketID), .unresolved)
    }

    func testSameOriginalTicketSurvivesHoraeChronosAndHecate() throws {
        var ready = try readyForHecateReceipt()
        let eventsBeforeReceipt = ready.courier.manifest.events(for: ready.ticketID)

        XCTAssertEqual(eventsBeforeReceipt.first?.kind, .ticketOpened)
        XCTAssertEqual(eventsBeforeReceipt.last?.kind, .deliveredToAddressee)
        XCTAssertEqual(eventsBeforeReceipt.last?.address, NatalSpineCommission.hecateAddress)
        XCTAssertEqual(ready.courier.manifest.unresolvedTickets(), [ready.ticketID])

        _ = try ready.courier.closeNatalSpineCommission(
            ticketID: ready.ticketID,
            blessing: ready.blessing,
            receivedAt: NatalSpineActIIIFixture.instant(1_920_000_600)
        )
        XCTAssertEqual(ready.courier.manifest.currentState(for: ready.ticketID), .resolved)
    }

    private struct Ready {
        var courier: HermesCourier
        let ticketID: HermesTicketID
        let package: HermesPackage<SealedNatalSpine>
        let spine: SealedNatalSpine
        let index: NatalSpineChronosIndex
        let blessing: NatalSpineHecateBlessing
    }

    private func readyForHecateReceipt() throws -> Ready {
        var state = try NatalSpineActIIIFixture.inHermesCustodyAfterHephaestus()

        let horaeAddress = try state.courier.deliverNext(
            ticketID: state.ticketID,
            occurredAt: NatalSpineActIIIFixture.instant(1_920_000_300)
        )
        let spine = try Horae.receiveNatalSpine(state.package, deliveredTo: horaeAddress)
        _ = try Horae.locateNatalSpine(spine, at: spine.bounds.natal.julianDay)
        try state.courier.recover(
            ticketID: state.ticketID,
            package: state.package,
            occurredAt: NatalSpineActIIIFixture.instant(1_920_000_360)
        )

        let chronosAddress = try state.courier.deliverNext(
            ticketID: state.ticketID,
            occurredAt: NatalSpineActIIIFixture.instant(1_920_000_420)
        )
        XCTAssertEqual(chronosAddress, NatalSpineCommission.chronosAddress)
        let index = Chronos.indexNatalSpine(spine)
        let sample = try XCTUnwrap(spine.candidate.themis.first)
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalHousePassage(
                    body: sample.span.body,
                    house: sample.span.house
                )
            )
        )
        guard case let .resolved(answer) = try Chronos.resolveNatalSpine(query, using: index) else {
            XCTFail("Chronos did not resolve the installed Natal Spine")
            throw HermesCourier.Failure.invalidState
        }
        XCTAssertFalse(answer.hits.isEmpty)
        try state.courier.recover(
            ticketID: state.ticketID,
            package: state.package,
            occurredAt: NatalSpineActIIIFixture.instant(1_920_000_480)
        )

        let hecateAddress = try state.courier.deliverNext(
            ticketID: state.ticketID,
            occurredAt: NatalSpineActIIIFixture.instant(1_920_000_540)
        )
        XCTAssertEqual(hecateAddress, NatalSpineCommission.hecateAddress)
        let blessing = try Hecate.blessNatalSpine(spine, indexedBy: index)

        return Ready(
            courier: state.courier,
            ticketID: state.ticketID,
            package: state.package,
            spine: spine,
            index: index,
            blessing: blessing
        )
    }
}
