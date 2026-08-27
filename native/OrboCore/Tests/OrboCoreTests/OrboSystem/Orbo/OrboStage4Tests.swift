import XCTest
@testable import OrboCore

final class OrboStage4Tests: XCTestCase {
    func testEngravingCannotBeEntrustedBeforeItIsCommissioned() {
        var orbo = Orbo()
        var hermes = HermesCourier()

        XCTAssertThrowsError(
            try orbo.entrustEngraving(
                to: &hermes,
                occurredAt: OrboPipelineFixture.handoffAt
            )
        ) { error in
            XCTAssertEqual(error as? OrboHermesFailure, .noEngravingCommission)
        }

        XCTAssertNil(orbo.engravingTicketID)
        XCTAssertEqual(orbo.backOfHouse, .idle)
        XCTAssertTrue(hermes.manifest.unresolvedTickets().isEmpty)
    }

    func testCompletedDummyCommissionIsEntrustedToTheRealHermesCourier() throws {
        var orbo = try completedDummyTraveler()
        let package = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        let originalAddresses = package.addresses
        var hermes = HermesCourier()

        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        let events = hermes.manifest.events(for: ticketID)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.kind, .ticketOpened)
        XCTAssertEqual(events.first?.ticketID, ticketID)
        XCTAssertEqual(events.first?.packageID, OrboPipelineFixture.packageID)
        XCTAssertEqual(events.first?.occurredAt, OrboPipelineFixture.handoffAt)
        XCTAssertNil(events.first?.address)
        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)
        XCTAssertEqual(hermes.manifest.unresolvedTickets(), [ticketID])

        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        XCTAssertEqual(orbo.engravingCommission, package)
        XCTAssertEqual(orbo.engravingCommission?.packageID, OrboPipelineFixture.packageID)
        XCTAssertEqual(orbo.engravingCommission?.subjectID, OrboPipelineFixture.subjectID)
        XCTAssertEqual(orbo.engravingCommission?.addresses, originalAddresses)
        XCTAssertEqual(orbo.engravingCommission?.addresses, OrboOnboarding.engravingItinerary)
    }

    func testEngravingCannotBeEntrustedTwice() throws {
        var orbo = try completedDummyTraveler()
        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        var hermes = HermesCourier()

        let firstTicket = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        XCTAssertThrowsError(
            try orbo.entrustEngraving(
                to: &hermes,
                occurredAt: OrboPipelineFixture.handoffAt
            )
        ) { error in
            XCTAssertEqual(error as? OrboHermesFailure, .alreadyEntrusted)
        }

        XCTAssertEqual(orbo.engravingTicketID, firstTicket)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertEqual(hermes.manifest.events(for: firstTicket).count, 1)
        XCTAssertEqual(hermes.manifest.unresolvedTickets(), [firstTicket])
    }

    private func completedDummyTraveler() throws -> Orbo {
        var orbo = Orbo()

        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name(OrboPipelineFixture.name))
        _ = try orbo.respondToOnboarding(
            .astrologyInterest(OrboPipelineFixture.astrologyInterest)
        )
        _ = try orbo.respondToOnboarding(.birthDate(OrboPipelineFixture.birthDate))
        _ = try orbo.respondToOnboarding(
            .birthLocation(OrboPipelineFixture.birthLocation)
        )
        _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        _ = try orbo.respondToOnboarding(.birthTime(OrboPipelineFixture.birthTime))

        return orbo
    }
}
