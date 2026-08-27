import XCTest
@testable import OrboCore

final class OrboStage6Tests: XCTestCase {
    func testBigThreeEligibilityIsUnavailableBeforeNativeTruthReady() throws {
        var (orbo, _, _) = try entrustedDummyTraveler()

        _ = try orbo.beginAstrosphereIntroduction()
        _ = try orbo.advanceAstrosphereIntroduction()

        XCTAssertFalse(orbo.canEnterBigThree)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.astrosphereIntroductionProgress, .layoutIntroduction)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
    }

    func testNativeTruthCanBecomeReadyMidIntroductionWithoutForcingFOHToJump() throws {
        var (orbo, hermes, ticketID) = try entrustedDummyTraveler()
        _ = try orbo.beginAstrosphereIntroduction()
        let manifestBeforeResult = hermes.manifest.events(for: ticketID)
        let frontBeforeResult = orbo.frontOfHouse
        let introductionBeforeResult = orbo.astrosphereIntroductionProgress

        orbo.receiveBackOfHouseResult(.nativeTruthReady)

        XCTAssertTrue(orbo.canEnterBigThree)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertEqual(orbo.frontOfHouse, frontBeforeResult)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.astrosphereIntroductionProgress, introductionBeforeResult)
        XCTAssertEqual(orbo.astrosphereIntroductionProgress, .astrosphereIntroduction)
        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(hermes.manifest.events(for: ticketID), manifestBeforeResult)
    }

    func testNativeTruthReadyDoesNotBlockFOHIfBOHFinishesFirst() throws {
        var (orbo, _, _) = try entrustedDummyTraveler()

        orbo.receiveBackOfHouseResult(.nativeTruthReady)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertTrue(orbo.canEnterBigThree)
        XCTAssertEqual(orbo.frontOfHouse, .onboarding)

        let beat = try orbo.beginAstrosphereIntroduction()

        XCTAssertEqual(beat.progress, .astrosphereIntroduction)
        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertTrue(orbo.canEnterBigThree)
    }

    func testResultFirewallCarriesNoDivineOrCourierPayloadIntoFOH() {
        let result = OrboBackOfHouseResult.nativeTruthReady
        let resultChildren = Array(Mirror(reflecting: result).children)
        XCTAssertTrue(resultChildren.isEmpty)

        let beat = OrboAstrosphereIntroductionBeat(progress: .layoutIntroduction)
        let beatChildren = Array(Mirror(reflecting: beat).children)

        XCTAssertEqual(beatChildren.count, 1)
        XCTAssertEqual(beatChildren.first?.label, "progress")
        XCTAssertTrue(beatChildren.first?.value is OrboAstrosphereIntroductionProgress)
    }

    func testNativeTruthReadyDoesNotFabricateChartOrMutateTheCommission() throws {
        var (orbo, _, _) = try entrustedDummyTraveler()
        let commissionBeforeResult = try XCTUnwrap(orbo.engravingCommission)
        let onboardingBeforeResult = orbo.onboardingSession

        XCTAssertNil(commissionBeforeResult.contents.topos)
        XCTAssertNil(commissionBeforeResult.contents.astroDNA)
        XCTAssertNil(commissionBeforeResult.contents.tapestry)
        XCTAssertFalse(commissionBeforeResult.contents.engraved)

        orbo.receiveBackOfHouseResult(.nativeTruthReady)

        XCTAssertEqual(orbo.engravingCommission, commissionBeforeResult)
        XCTAssertEqual(orbo.onboardingSession, onboardingBeforeResult)
        XCTAssertNil(orbo.engravingCommission?.contents.topos)
        XCTAssertNil(orbo.engravingCommission?.contents.astroDNA)
        XCTAssertNil(orbo.engravingCommission?.contents.tapestry)
        XCTAssertEqual(orbo.engravingCommission?.contents.engraved, false)
        XCTAssertTrue(orbo.canEnterBigThree)
    }

    private func entrustedDummyTraveler() throws -> (Orbo, HermesCourier, HermesTicketID) {
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
        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )

        var hermes = HermesCourier()
        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        return (orbo, hermes, ticketID)
    }
}
