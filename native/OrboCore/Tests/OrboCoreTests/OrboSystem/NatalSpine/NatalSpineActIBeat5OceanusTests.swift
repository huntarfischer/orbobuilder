import XCTest
@testable import OrboCore

final class NatalSpineActIBeat5OceanusTests: XCTestCase {
    private struct Match: Sendable {
        let body: MundaneBody
        let degree: OrboSpineDirectionalDegree
        let time: JulianDay
    }

    private struct Port: NatalSpineTimespinePort {
        let matches: [Match]

        func coordinate(of body: MundaneBody, at julianDay: JulianDay) throws -> OrboSpineCelestialCoordinate {
            OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(physicalDegrees: 0, motion: .direct)!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            matches.filter {
                $0.body == body && abs($0.degree.degrees - directionalDegree.degrees) < 1e-10
            }.map {
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: $0.degree,
                    julianDay: $0.time
                )
            }
        }
    }

    func testOneBodyKeepsDirectAndRetrogradeExactRingOccurrences() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let target = try XCTUnwrap(ringValues(in: truth).first)
        let physical = Double(target.targetArcsecond) / Double(Ring.arcsecondsPerDegree)
        let direct = OrboSpineDirectionalDegree(physicalDegrees: physical, motion: .direct)!
        let retro = OrboSpineDirectionalDegree(physicalDegrees: physical, motion: .retrograde)!
        let early = JulianDay(bounds.bone.start.value + 10)!
        let late = JulianDay(bounds.bone.start.value + 20)!
        let port = Port(matches: [
            Match(body: .mars, degree: direct, time: late),
            Match(body: .mars, degree: retro, time: early),
        ])

        let table = try Oceanus.traceNatalSpineBody(
            .mars,
            native: truth,
            bounds: bounds,
            through: port
        )
        let matchingNativeValues = ringValues(in: truth).filter {
            $0.targetArcsecond == target.targetArcsecond
        }

        XCTAssertEqual(table.declaredCount, matchingNativeValues.count * 2)
        XCTAssertEqual(table.realizations.first?.occurrence.julianDay, early)
        XCTAssertEqual(table.realizations.last?.occurrence.julianDay, late)
        XCTAssertTrue(table.realizations.allSatisfy {
            $0.targetArcsecond == target.targetArcsecond
                && $0.mundaneBody == .mars
                && abs($0.occurrence.directionalDegree.physicalDegrees - physical) < 1e-10
        })
    }

    func testOceanusKeepsOnlyOccurrencesInsideClothoBounds() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let target = try XCTUnwrap(ringValues(in: truth).first)
        let physical = Double(target.targetArcsecond) / Double(Ring.arcsecondsPerDegree)
        let direct = OrboSpineDirectionalDegree(physicalDegrees: physical, motion: .direct)!
        let inside = JulianDay(bounds.bone.start.value + 1)!
        let port = Port(matches: [
            Match(body: .jupiter, degree: direct, time: JulianDay(bounds.bone.start.value - 1)!),
            Match(body: .jupiter, degree: direct, time: inside),
            Match(body: .jupiter, degree: direct, time: bounds.bone.end),
        ])

        let table = try Oceanus.traceNatalSpineBody(
            .jupiter,
            native: truth,
            bounds: bounds,
            through: port
        )

        XCTAssertFalse(table.realizations.isEmpty)
        XCTAssertTrue(table.realizations.allSatisfy { $0.occurrence.julianDay == inside })
    }

    func testCompleteOceanusTableRetainsEveryBodyWhenThereAreNoRealizations() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let table = try Oceanus.traceNatalSpine(
            native: truth,
            bounds: bounds,
            through: Port(matches: [])
        )

        XCTAssertEqual(table.bodies.map(\.body), MundaneBody.canonicalOrder)
        XCTAssertEqual(table.bodies.count, MundaneBody.canonicalOrder.count)
        XCTAssertTrue(table.bodies.allSatisfy { $0.declaredCount == 0 })
        XCTAssertEqual(table.declaredCount, 0)
        XCTAssertTrue(table.realizations.isEmpty)
    }

    func testCompleteOceanusTableRetainsNativeAndBounds() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let table = try Oceanus.traceNatalSpine(
            native: truth,
            bounds: bounds,
            through: Port(matches: [])
        )

        XCTAssertEqual(table.subjectID, truth.subjectID)
        XCTAssertEqual(table.bounds, bounds)
    }

    private func nativeTruth() throws -> NatalSpineNativeTruth {
        try NatalSpineTestFixture.litHestia().natalSpineNativeTruth(
            for: NatalSpineTestFixture.subjectID
        )
    }

    private func ringValues(in truth: NatalSpineNativeTruth) -> [TapestryRingValue] {
        truth.tapestry.tapestry.degrees.flatMap(\.ring.values)
    }
}
