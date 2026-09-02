import XCTest
@testable import OrboCore
@testable import OrboIris

final class OrboHomerPortTests: XCTestCase {
    func testOrboLifecycleTravelsThroughHomerAndIrisExactly() throws {
        var orbo = Orbo()

        let resting = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(resting.pointOfView.frontOfHouse, .resting)
        XCTAssertEqual(resting.pointOfView.backOfHouse, .idle)
        XCTAssertNil(resting.pointOfView.onboardingProgress)
        XCTAssertFalse(resting.pointOfView.engravingCommissioned)
        XCTAssertFalse(resting.pointOfView.engravingEntrusted)
        XCTAssertFalse(resting.pointOfView.canEnterBigThree)

        _ = orbo.beginOnboarding()
        let onboarding = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(onboarding.pointOfView.frontOfHouse, .onboarding)
        XCTAssertEqual(onboarding.pointOfView.onboardingProgress, .requestingName)
        XCTAssertEqual(onboarding.pointOfView.backOfHouse, .idle)
    }

    func testCommissionAndEntrustmentAppearOnlyWhenTheyBecomeTrueForOrbo() throws {
        var orbo = try readyForEngraving()

        let beforeCommission = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertFalse(beforeCommission.pointOfView.engravingCommissioned)
        XCTAssertFalse(beforeCommission.pointOfView.engravingEntrusted)
        XCTAssertEqual(beforeCommission.pointOfView.backOfHouse, .idle)

        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        let commissioned = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertTrue(commissioned.pointOfView.engravingCommissioned)
        XCTAssertFalse(commissioned.pointOfView.engravingEntrusted)
        XCTAssertEqual(commissioned.pointOfView.backOfHouse, .engravingCommissioned)

        var courier = HermesCourier()
        _ = try orbo.entrustEngraving(
            to: &courier,
            occurredAt: OrboPipelineFixture.handoffAt
        )
        let entrusted = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertTrue(entrusted.pointOfView.engravingCommissioned)
        XCTAssertTrue(entrusted.pointOfView.engravingEntrusted)
        XCTAssertEqual(entrusted.pointOfView.backOfHouse, .engravingInProgress)

        XCTAssertFalse(commissioned.pointOfView.engravingEntrusted)
        XCTAssertEqual(commissioned.pointOfView.backOfHouse, .engravingCommissioned)
    }

    func testNativeReadinessChangesOrboPOVWithoutImportingDownstreamTruth() throws {
        var orbo = try entrustedOrbo()
        _ = try orbo.beginAstrosphereIntroduction()

        let beforeReady = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(beforeReady.pointOfView.backOfHouse, .engravingInProgress)
        XCTAssertFalse(beforeReady.pointOfView.canEnterBigThree)

        orbo.receiveBackOfHouseResult(.nativeTruthReady)

        let ready = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(ready.pointOfView.backOfHouse, .nativeReady)
        XCTAssertTrue(ready.pointOfView.canEnterBigThree)
        XCTAssertEqual(ready.pointOfView.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(
            ready.pointOfView.astrosphereIntroductionProgress,
            .astrosphereIntroduction
        )

        XCTAssertEqual(beforeReady.pointOfView.backOfHouse, .engravingInProgress)
        XCTAssertFalse(beforeReady.pointOfView.canEnterBigThree)
    }

    func testBigThreeStillRequiresBothOrboOwnedGates() throws {
        var orbo = try entrustedOrbo()
        orbo.receiveBackOfHouseResult(.nativeTruthReady)

        var beforeLayout = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertTrue(beforeLayout.pointOfView.canEnterBigThree)
        XCTAssertNil(beforeLayout.pointOfView.bigThreeProgress)

        _ = try orbo.beginAstrosphereIntroduction()
        _ = try orbo.advanceAstrosphereIntroduction()
        _ = try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)

        let inBigThree = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(inBigThree.pointOfView.bigThreeProgress, .moment)
        XCTAssertEqual(inBigThree.pointOfView.backOfHouse, .nativeReady)

        beforeLayout = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(beforeLayout.pointOfView.bigThreeProgress, .moment)
    }

    func testCompletedOnboardingProducesReadyFrontOfHouseSnapshot() throws {
        var orbo = try entrustedOrbo()
        _ = try orbo.beginAstrosphereIntroduction()
        _ = try orbo.advanceAstrosphereIntroduction()
        orbo.receiveBackOfHouseResult(.nativeTruthReady)

        var beat = try orbo.beginBigThree(with: OrboPipelineFixture.bigThreeTruth)
        for _ in 0..<6 {
            beat = try orbo.advanceBigThree()
        }
        XCTAssertEqual(beat.progress, .tourChoice)

        _ = try orbo.respondToBigThreeTour(.noThanks)
        let complete = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))

        XCTAssertEqual(complete.pointOfView.frontOfHouse, .ready)
        XCTAssertEqual(complete.pointOfView.backOfHouse, .nativeReady)
        XCTAssertEqual(complete.pointOfView.bigThreeProgress, .complete)
        XCTAssertTrue(complete.pointOfView.canEnterBigThree)
    }

    private func readyForEngraving() throws -> Orbo {
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

    private func entrustedOrbo() throws -> Orbo {
        var orbo = try readyForEngraving()
        _ = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        var courier = HermesCourier()
        _ = try orbo.entrustEngraving(
            to: &courier,
            occurredAt: OrboPipelineFixture.handoffAt
        )
        return orbo
    }
}
