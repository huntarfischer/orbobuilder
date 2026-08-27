import XCTest
@testable import OrboCore

final class OrboStage2Tests: XCTestCase {
    func testCanonicalDummyTravelerSurvivesTheRealFOHScriptAsCommissionableInput() throws {
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

        let input = try XCTUnwrap(
            orbo.knownBirthInput(subjectID: OrboPipelineFixture.subjectID)
        )

        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        XCTAssertEqual(orbo.backOfHouse, .idle)
        XCTAssertEqual(orbo.onboardingSession?.progress, .readyForEngraving)
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, OrboPipelineFixture.readingDepth)

        XCTAssertEqual(input.subjectID, OrboPipelineFixture.subjectID)
        XCTAssertEqual(input.name, OrboPipelineFixture.name)
        XCTAssertEqual(input.birthDate, OrboPipelineFixture.birthDate)
        XCTAssertEqual(input.birthTime, OrboPipelineFixture.birthTime)
        XCTAssertEqual(input.birthLocation, OrboPipelineFixture.birthLocation)
    }

    func testKnownBirthInputIsUnavailableUntilTheKnownTimePathIsComplete() throws {
        var orbo = Orbo()

        XCTAssertNil(orbo.knownBirthInput(subjectID: OrboPipelineFixture.subjectID))

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

        XCTAssertNil(orbo.knownBirthInput(subjectID: OrboPipelineFixture.subjectID))
        XCTAssertEqual(orbo.backOfHouse, .idle)

        _ = try orbo.respondToOnboarding(.birthTime(OrboPipelineFixture.birthTime))

        XCTAssertNotNil(orbo.knownBirthInput(subjectID: OrboPipelineFixture.subjectID))
        XCTAssertEqual(orbo.backOfHouse, .idle)
    }
}
