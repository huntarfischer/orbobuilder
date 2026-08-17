import XCTest
@testable import OrboCore

final class CelestialTimeTests: XCTestCase {
    private struct AnalyticReference: ForgeEphemerisReference {
        let epoch = 2_451_545.0

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState {
            let t = julianDay.value - epoch
            let ordinal = Double(body.rawValue + 1)
            let base = 358.7 + ordinal * 0.07
            let linear = body == .trueNorthNode ? -0.32 : 0.35 + ordinal * 0.013
            let quadratic = (ordinal.truncatingRemainder(dividingBy: 3) - 1) * 0.0008
            let cubic = (ordinal.truncatingRemainder(dividingBy: 2) == 0 ? 1 : -1) * 0.00001
            return MundaneCelestialState(
                longitude: CelestialLongitude(base + linear * t + quadratic * t * t + cubic * t * t * t)!,
                longitudinalSpeedDegreesPerDay: linear + 2 * quadratic * t + 3 * cubic * t * t
            )!
        }
    }

    private func celestialPlan() -> MundaneCelestialForgePlan {
        let start = MundaneCelestialAnchor(
            body: .sun,
            longitude: CelestialLongitude(358.77)!,
            motion: .direct,
            julianDay: JulianDay(2_451_545.0)!
        )
        let end = MundaneCelestialAnchor(
            body: .sun,
            longitude: CelestialLongitude(1.67)!,
            motion: .direct,
            julianDay: JulianDay(2_451_553.0)!
        )
        let span = MundaneCelestialSpan(start: start, end: end)!
        return MundaneCelestialForgePlan(
            version: "celestial-time-fixture",
            astronomicalSource: "analytic-test-reference",
            astronomicalSourceVersion: "1",
            span: span,
            profiles: MundaneTimespineForge.candidateProfiles
        )!
    }

    func testCelestialForgePlanMakesCelestialConditionPrimary() {
        let plan = celestialPlan()
        XCTAssertEqual(plan.span.start.body, .sun)
        XCTAssertEqual(plan.span.start.longitude.degrees, 358.77, accuracy: 1e-12)
        XCTAssertEqual(plan.span.end.longitude.degrees, 1.67, accuracy: 1e-12)
        XCTAssertEqual(plan.storagePlan.supportedStart, plan.span.start.julianDay)
        XCTAssertEqual(plan.storagePlan.supportedEnd, plan.span.end.julianDay)
    }

    func testCrossSectionReadsAllUniversalTractsAtOneAddress() throws {
        let timespine = try MundaneTimespineForge.manufacture(
            plan: celestialPlan(),
            reference: AnalyticReference()
        )
        let address = JulianDay(2_451_548.25)!
        let section = try timespine.crossSection(at: address)

        XCTAssertEqual(section.julianDay, address)
        XCTAssertEqual(section.states.count, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(Set(section.states.keys), Set(MundaneBody.canonicalOrder))
    }

    func testLongitudeNerveFindsCelestialTimeThenRecoversWholeSky() throws {
        let timespine = try MundaneTimespineForge.manufacture(
            plan: celestialPlan(),
            reference: AnalyticReference()
        )
        let index = try MundaneLongitudeIndex(timespine: timespine)
        let zeroAries = CelestialLongitude(0)!

        let candidates = index.candidateIntervals(
            of: .sun,
            at: zeroAries,
            motion: .direct
        )
        XCTAssertFalse(candidates.isEmpty)

        let occurrences = try index.occurrences(
            of: .sun,
            at: zeroAries,
            motion: .direct,
            in: timespine
        )
        XCTAssertEqual(occurrences.count, 1)

        let occurrence = try XCTUnwrap(occurrences.first)
        let sun = try timespine.state(of: .sun, at: occurrence.julianDay)
        XCTAssertLessThan(min(sun.longitude.degrees, 360 - sun.longitude.degrees), 0.00001)
        XCTAssertEqual(sun.motion, .direct)

        let section = try timespine.crossSection(at: occurrence.julianDay)
        XCTAssertEqual(section.states.count, MundaneBody.canonicalOrder.count)
        XCTAssertNotNil(section[.mercury])
        XCTAssertNotNil(section[.pluto])
        XCTAssertNotNil(section[.trueNorthNode])
    }
}