import Foundation
import XCTest
@testable import OrboCore

final class MundaneTimespineForgeTests: XCTestCase {
    private struct LinearReference: ForgeEphemerisReference {
        let origin: Double
        let baseLongitude: Double
        let speed: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
            MundaneForgeState(
                longitudeDegrees: baseLongitude + speed * (julianDay.value - origin),
                longitudinalSpeedDegreesPerDay: speed
            )!
        }
    }

    private struct TurningReference: ForgeEphemerisReference {
        let origin: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
            let t = julianDay.value - origin
            let x = t - 2
            return MundaneForgeState(
                longitudeDegrees: 10 + x * x,
                longitudinalSpeedDegreesPerDay: 2 * x
            )!
        }
    }

    private enum LinearHephaestusRecipe: HephaestusTimespineRecipe {
        static var start: JulianDay { JulianDay(1_000)! }
        static var end: JulianDay { JulianDay(1_010)! }
        static var recipeIdentifier: String { "xctest-linear-timespine" }
        static var recipeVersion: UInt16 { 1 }
        static var artifactContract: HephaestusTimespineArtifactContract {
            HephaestusTimespineArtifactContract(
                bodyCount: 1,
                bodyOccurrenceCount: 10,
                relationshipCount: 0,
                eclipseCount: 0
            )!
        }

        static func forgePlan(
            astronomicalSourceVersion: String
        ) -> MundaneTimespineForgePlan {
            let contract = MundaneTimespineBodyContract(
                body: .sun,
                celestialResolutionDegrees: 1,
                markerBodies: [],
                constructionRecordCount: 10
            )!
            let bodyPlan = MundaneTimespineForgeBodyPlan(
                contract: contract,
                scanStepDays: 0.5
            )!
            return MundaneTimespineForgePlan(
                spanName: "Hephaestus linear fixture",
                astronomicalSource: "deterministic XCTest sky",
                astronomicalSourceVersion: astronomicalSourceVersion,
                supportedStart: start,
                supportedEnd: end,
                bodyPlans: [bodyPlan],
                verifiesConstructionRecordCounts: true,
                verifiesMarkerUniqueness: true
            )!
        }
    }

    private enum MissingRelationshipHephaestusRecipe: HephaestusTimespineRecipe {
        static var recipeIdentifier: String { "xctest-incomplete-timespine" }
        static var recipeVersion: UInt16 { 1 }
        static var artifactContract: HephaestusTimespineArtifactContract {
            HephaestusTimespineArtifactContract(
                bodyCount: 1,
                bodyOccurrenceCount: 10,
                relationshipCount: 1,
                eclipseCount: 0
            )!
        }

        static func forgePlan(
            astronomicalSourceVersion: String
        ) -> MundaneTimespineForgePlan {
            LinearHephaestusRecipe.forgePlan(
                astronomicalSourceVersion: astronomicalSourceVersion
            )
        }
    }

    func testP22RecipeOwnsP22PlanAndCelestialBoundaryLaw() {
        let plan = MundaneTimespineP22ForgeRecipe.plan(astronomicalSourceVersion: "test")

        XCTAssertEqual(plan.spanName, MundaneTimespineP22.spanName)
        XCTAssertEqual(plan.supportedStart, MundaneTimespineP22.startJulianDay)
        XCTAssertEqual(plan.supportedEnd, MundaneTimespineP22.endJulianDay)
        XCTAssertEqual(plan.bodyPlans.map { $0.contract.body }, MundaneBody.canonicalOrder)
        XCTAssertEqual(
            plan.bodyPlans.map { $0.contract.celestialResolutionDegrees },
            MundaneTimespineP22.profiles.map(\.celestialResolutionDegrees)
        )
        XCTAssertTrue(plan.verifiesConstructionRecordCounts)
        XCTAssertTrue(plan.verifiesMarkerUniqueness)
        XCTAssertFalse(MundaneTimespineP22ForgeRecipe.astronomicalSource.contains("DE441"))
        XCTAssertEqual(AstroDNA.codec, 4)
    }

    func testP22RecipeDeclaresCompleteHephaestusCandidateContract() {
        let contract = MundaneTimespineP22ForgeRecipe.artifactContract

        XCTAssertEqual(MundaneTimespineP22ForgeRecipe.recipeIdentifier, "p22-pluto-zeitgeist")
        XCTAssertEqual(MundaneTimespineP22ForgeRecipe.recipeVersion, 1)
        XCTAssertEqual(contract.bodyCount, 11)
        XCTAssertEqual(contract.bodyOccurrenceCount, 1_811_967)
        XCTAssertEqual(contract.relationshipCount, 770_298)
        XCTAssertEqual(contract.eclipseCount, 1_133)
    }

    func testGenericForgeManufacturesArbitraryDirectCelestialSpanBoundToCivicUT() throws {
        let start = JulianDay(1_000)!
        let end = JulianDay(1_010)!
        let contract = MundaneTimespineBodyContract(
            body: .sun,
            celestialResolutionDegrees: 1,
            markerBodies: [],
            constructionRecordCount: 10
        )!
        let bodyPlan = MundaneTimespineForgeBodyPlan(contract: contract, scanStepDays: 0.5)!
        let plan = MundaneTimespineForgePlan(
            spanName: "Forge linear fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodyPlans: [bodyPlan],
            verifiesConstructionRecordCounts: true,
            verifiesMarkerUniqueness: true
        )!

        let product = try MundaneTimespineForge.manufacture(
            plan: plan,
            reference: LinearReference(origin: start.value, baseLongitude: 0, speed: 1)
        )
        let body = try XCTUnwrap(product.body(.sun))

        XCTAssertEqual(product.spanName, "Forge linear fixture")
        XCTAssertEqual(product.totalOccurrenceCount, 10)
        XCTAssertEqual(body.occurrences.map(\.focalCelestialTick), Array(0..<10))
        XCTAssertTrue(body.occurrences.allSatisfy { $0.sequenceDirection == .increasing })
        XCTAssertEqual(body.occurrences.first?.civicOffsetSeconds, 0)
        XCTAssertEqual(body.occurrences.last?.civicOffsetSeconds, 9 * 86_400)
        XCTAssertEqual(body.stations.count, 0)
        XCTAssertEqual(body.retrogradePassages.count, 0)
    }

    func testForgeStationsAreTurnsInCelestialTimeMapping() throws {
        let start = JulianDay(2_000)!
        let end = JulianDay(2_004)!
        let contract = MundaneTimespineBodyContract(
            body: .mercury,
            celestialResolutionDegrees: 1,
            markerBodies: [],
            constructionRecordCount: 8
        )!
        let bodyPlan = MundaneTimespineForgeBodyPlan(contract: contract, scanStepDays: 0.5)!
        let plan = MundaneTimespineForgePlan(
            spanName: "Forge station fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodyPlans: [bodyPlan],
            verifiesConstructionRecordCounts: true,
            verifiesMarkerUniqueness: false
        )!

        let product = try MundaneTimespineForge.manufacture(
            plan: plan,
            reference: TurningReference(origin: start.value)
        )
        let body = try XCTUnwrap(product.body(.mercury))
        let station = try XCTUnwrap(body.stations.first)

        XCTAssertEqual(body.occurrences.count, 8)
        XCTAssertEqual(body.stations.count, 1)
        XCTAssertEqual(station.julianDay.value, start.value + 2, accuracy: 1e-10)
        XCTAssertEqual(station.celestialTimeDegrees, 10, accuracy: 1e-10)
        XCTAssertEqual(station.sequenceBefore, .decreasing)
        XCTAssertEqual(station.sequenceAfter, .increasing)
        XCTAssertEqual(station.motionAfter, .direct)
        XCTAssertEqual(body.retrogradePassages.count, 1)
        XCTAssertEqual(body.retrogradeCrossingCount, 5)
    }

    func testP22RecipeRejectsFalsePlutoZeroAriesBoundaryBeforeManufacture() {
        let reference = LinearReference(
            origin: MundaneTimespineP22.startJulianDay.value,
            baseLongitude: 20,
            speed: 1
        )

        XCTAssertThrowsError(
            try MundaneTimespineP22ForgeRecipe.manufacture(
                astronomicalSourceVersion: "test",
                reference: reference
            )
        ) { error in
            XCTAssertEqual(error as? MundaneTimespineP22ForgeRecipeError, .boundaryMismatch)
        }
    }

    func testHephaestusMintsDeterministicCelestialFirstCandidateForArbitraryRecipe() throws {
        let reference = LinearReference(
            origin: LinearHephaestusRecipe.start.value,
            baseLongitude: 0,
            speed: 1
        )

        let first = try Hephaestus.manufactureCandidate(
            recipe: LinearHephaestusRecipe.self,
            astronomicalSourceVersion: "fixture-1",
            reference: reference
        )
        let second = try Hephaestus.manufactureCandidate(
            recipe: LinearHephaestusRecipe.self,
            astronomicalSourceVersion: "fixture-1",
            reference: reference
        )

        XCTAssertTrue(Hephaestus.celestialTimeFirst)
        XCTAssertEqual(Hephaestus.candidateIdentityAlgorithm, "SHA-256")
        XCTAssertEqual(Hephaestus.runtimeRole, "none")
        XCTAssertEqual(MundaneTimespineStorageFormat.identifier, "ORBOTS01")
        XCTAssertEqual(first.artifactData, second.artifactData)
        XCTAssertEqual(first.identity, second.identity)
        XCTAssertEqual(first.identity.sha256.count, 64)
        XCTAssertEqual(first.forgeRecord.candidateSHA256, first.identity.sha256)
        XCTAssertEqual(first.forgeRecord.recipeIdentifier, LinearHephaestusRecipe.recipeIdentifier)
        XCTAssertEqual(first.forgeRecord.recipeVersion, LinearHephaestusRecipe.recipeVersion)
        XCTAssertEqual(first.forgeRecord.storageFamily, "ORBOTS01")
        XCTAssertEqual(first.forgeRecord.storageVersion, 1)
        XCTAssertTrue(first.forgeRecord.celestialTimeFirst)
        XCTAssertEqual(first.forgeRecord.bodyCount, 1)
        XCTAssertEqual(first.forgeRecord.bodyOccurrenceCount, 10)
        XCTAssertEqual(first.forgeRecord.relationshipCount, 0)
        XCTAssertEqual(first.forgeRecord.eclipseCount, 0)
        XCTAssertEqual(first.forgeRecord.artifactByteCount, first.artifactData.count)

        let decoded = try first.artifact.storageImage()
        XCTAssertEqual(decoded.spanName, "Hephaestus linear fixture")
        XCTAssertEqual(decoded.astronomicalSource, "deterministic XCTest sky")
        XCTAssertEqual(decoded.astronomicalSourceVersion, "fixture-1")
        XCTAssertEqual(decoded.bodies.count, 1)
        XCTAssertEqual(decoded.bodies[0].occurrences.count, 10)
    }

    func testHephaestusCandidateIdentityChangesWhenArtifactBytesChange() throws {
        let reference = LinearReference(
            origin: LinearHephaestusRecipe.start.value,
            baseLongitude: 0,
            speed: 1
        )
        let candidate = try Hephaestus.manufactureCandidate(
            recipe: LinearHephaestusRecipe.self,
            astronomicalSourceVersion: "fixture-1",
            reference: reference
        )

        var mutated = candidate.artifactData
        let index = mutated.index(before: mutated.endIndex)
        mutated[index] = mutated[index] ^ 0x01
        let mutatedIdentity = TimespineCandidateIdentity.hash(artifactData: mutated)

        XCTAssertNotEqual(mutatedIdentity, candidate.identity)
    }

    func testHephaestusRefusesIncompleteRecipePayload() {
        let reference = LinearReference(
            origin: LinearHephaestusRecipe.start.value,
            baseLongitude: 0,
            speed: 1
        )

        XCTAssertThrowsError(
            try Hephaestus.manufactureCandidate(
                recipe: MissingRelationshipHephaestusRecipe.self,
                astronomicalSourceVersion: "fixture-1",
                reference: reference
            )
        ) { error in
            XCTAssertEqual(
                error as? HephaestusError,
                .artifactContractMismatch(component: "relationships", expected: 1, actual: 0)
            )
        }
    }

    func testHephaestusRunsP22PreflightBeforeCandidateMinting() {
        let reference = LinearReference(
            origin: MundaneTimespineP22.startJulianDay.value,
            baseLongitude: 20,
            speed: 1
        )

        XCTAssertThrowsError(
            try Hephaestus.manufactureCandidate(
                recipe: MundaneTimespineP22ForgeRecipe.self,
                astronomicalSourceVersion: "fixture-1",
                reference: reference
            )
        ) { error in
            XCTAssertEqual(error as? MundaneTimespineP22ForgeRecipeError, .boundaryMismatch)
        }
    }
}
