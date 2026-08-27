import XCTest
@testable import OrboCore

final class OrboStage3Tests: XCTestCase {
    func testEngravingCannotBeCommissionedBeforeKnownTimeOnboardingIsComplete() throws {
        var orbo = Orbo()

        XCTAssertThrowsError(
            try orbo.commissionEngraving(
                subjectID: OrboPipelineFixture.subjectID,
                packageID: OrboPipelineFixture.packageID
            )
        ) { error in
            XCTAssertEqual(error as? OrboCommissionFailure, .insufficientOnboarding)
        }

        XCTAssertNil(orbo.engravingCommission)
        XCTAssertEqual(orbo.backOfHouse, .idle)
    }

    func testCompletedDummyTravelerProducesTheCanonicalUnfinishedEngraving() throws {
        var orbo = try completedDummyTraveler()

        let package = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )

        XCTAssertEqual(package.packageID, OrboPipelineFixture.packageID)
        XCTAssertEqual(package.subjectID, OrboPipelineFixture.subjectID)
        XCTAssertEqual(package.sender, OrboOnboarding.orboAddress)
        XCTAssertEqual(package.kind, OrboOnboarding.engravingPackageKind)
        XCTAssertEqual(package.addresses, OrboOnboarding.engravingItinerary)
        XCTAssertEqual(
            package.addresses,
            [
                HermesAddress(rawValue: "orbo.atlas")!,
                HermesAddress(rawValue: "orbo.moirai")!,
                HermesAddress(rawValue: "orbo.hestia")!,
            ]
        )

        XCTAssertEqual(package.contents.subjectID, OrboPipelineFixture.subjectID)
        XCTAssertEqual(package.contents.name, OrboPipelineFixture.name)
        XCTAssertEqual(package.contents.birthDate, OrboPipelineFixture.birthDate)
        XCTAssertEqual(package.contents.birthTime, OrboPipelineFixture.birthTime)
        XCTAssertEqual(package.contents.birthLocation, OrboPipelineFixture.birthLocation)
        XCTAssertNil(package.contents.topos)
        XCTAssertNil(package.contents.astroDNA)
        XCTAssertNil(package.contents.tapestry)
        XCTAssertFalse(package.contents.engraved)

        XCTAssertEqual(orbo.engravingCommission, package)
        XCTAssertEqual(orbo.backOfHouse, .engravingCommissioned)
        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        XCTAssertEqual(orbo.onboardingSession?.readingDepth, OrboPipelineFixture.readingDepth)
    }

    func testOneCompletedOnboardingCannotMintASecondIndependentEngraving() throws {
        var orbo = try completedDummyTraveler()

        let first = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )

        XCTAssertThrowsError(
            try orbo.commissionEngraving(
                subjectID: OrboPipelineFixture.subjectID,
                packageID: HermesPackageID()
            )
        ) { error in
            XCTAssertEqual(error as? OrboCommissionFailure, .alreadyCommissioned)
        }

        XCTAssertEqual(orbo.engravingCommission, first)
        XCTAssertEqual(orbo.backOfHouse, .engravingCommissioned)
        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
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
