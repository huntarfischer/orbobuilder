import XCTest
@testable import OrboCore

final class OrboStage5Tests: XCTestCase {
    func testAstrosphereIntroductionCannotBeginBeforeEngravingIsInProgress() throws {
        var orbo = try completedDummyTraveler()
        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )

        XCTAssertThrowsError(
            try orbo.beginAstrosphereIntroduction()
        ) { error in
            XCTAssertEqual(
                error as? OrboFrontOfHouseFailure,
                .engravingNotInProgress
            )
        }

        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        XCTAssertEqual(orbo.backOfHouse, .engravingCommissioned)
        XCTAssertNil(orbo.astrosphereIntroductionProgress)
    }

    func testFOHAdvancesFromAstrosphereToLayoutWhileBOHAndHermesRemainStill() throws {
        var orbo = try completedDummyTraveler()
        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        var hermes = HermesCourier()
        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )
        let manifestBeforeFOH = hermes.manifest.events(for: ticketID)

        let introduction = try orbo.beginAstrosphereIntroduction()

        XCTAssertEqual(introduction.progress, .astrosphereIntroduction)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(hermes.manifest.events(for: ticketID), manifestBeforeFOH)
        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)

        let layout = try orbo.advanceAstrosphereIntroduction()

        XCTAssertEqual(layout.progress, .layoutIntroduction)
        XCTAssertEqual(orbo.astrosphereIntroductionProgress, .layoutIntroduction)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(hermes.manifest.events(for: ticketID), manifestBeforeFOH)
        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)
    }

    func testFOHIntroductionBeatCarriesNoBackOfHousePayload() {
        let beat = OrboAstrosphereIntroductionBeat(progress: .astrosphereIntroduction)
        let children = Array(Mirror(reflecting: beat).children)

        XCTAssertEqual(children.count, 1)
        XCTAssertEqual(children.first?.label, "progress")
        XCTAssertTrue(children.first?.value is OrboAstrosphereIntroductionProgress)
    }

    func testStage5StopsAtLayoutAndDoesNotAdvanceIntoBigThree() throws {
        var orbo = try completedDummyTraveler()
        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        var hermes = HermesCourier()
        _ = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        _ = try orbo.beginAstrosphereIntroduction()
        _ = try orbo.advanceAstrosphereIntroduction()

        XCTAssertThrowsError(
            try orbo.advanceAstrosphereIntroduction()
        ) { error in
            XCTAssertEqual(
                error as? OrboFrontOfHouseFailure,
                .astrosphereIntroductionComplete
            )
        }

        XCTAssertEqual(orbo.astrosphereIntroductionProgress, .layoutIntroduction)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
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
