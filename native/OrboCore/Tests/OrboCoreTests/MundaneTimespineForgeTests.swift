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

    func testForgeP22PlanRestoresNativeOwnerAroundCelestialTimeLaw() {
        let plan = MundaneTimespineForge.p22Plan(astronomicalSourceVersion: "test")

        XCTAssertEqual(plan.spanName, MundaneTimespineP22.spanName)
        XCTAssertEqual(plan.supportedStart, MundaneTimespineP22.startJulianDay)
        XCTAssertEqual(plan.supportedEnd, MundaneTimespineP22.endJulianDay)
        XCTAssertEqual(plan.bodyPlans.map { $0.contract.body }, MundaneBody.canonicalOrder)
        XCTAssertEqual(
            plan.bodyPlans.map { $0.contract.celestialResolutionDegrees },
            MundaneTimespineP22.profiles.map(\.celestialResolutionDegrees)
        )
        XCTAssertTrue(plan.validatesP22Boundaries)
        XCTAssertTrue(plan.verifiesConstructionRecordCounts)
        XCTAssertTrue(plan.verifiesMarkerUniqueness)
        XCTAssertEqual(AstroDNA.codec, 4)
    }

    func testForgeManufacturesDirectCelestialOccurrencesBoundToCivicUT() throws {
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

    func testForgeRejectsFalseP22BoundaryBeforeManufacture() {
        let reference = LinearReference(
            origin: MundaneTimespineP22.startJulianDay.value,
            baseLongitude: 20,
            speed: 1
        )

        XCTAssertThrowsError(
            try MundaneTimespineForge.manufactureP22(
                astronomicalSourceVersion: "test",
                reference: reference
            )
        ) { error in
            XCTAssertEqual(error as? MundaneTimespineForgeError, .p22BoundaryMismatch)
        }
    }
}
