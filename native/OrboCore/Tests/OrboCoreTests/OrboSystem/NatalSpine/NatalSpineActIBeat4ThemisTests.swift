import XCTest
@testable import OrboCore

final class NatalSpineActIBeat4ThemisTests: XCTestCase {
    private struct Crossing: Sendable {
        let body: MundaneBody
        let directionalDegree: OrboSpineDirectionalDegree
        let julianDay: JulianDay
    }

    private struct IntervalState: Sendable {
        let body: MundaneBody
        let start: Double
        let end: Double
        let physicalDegrees: Double
        let motion: Motion
    }

    private struct Port: NatalSpineTimespinePort {
        let crossings: [Crossing]
        let states: [IntervalState]
        let fallbackDegree: Double

        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            let state = states.first {
                $0.body == body
                    && julianDay.value >= $0.start
                    && julianDay.value < $0.end
            }
            let physical = state?.physicalDegrees ?? fallbackDegree
            let motion = state?.motion ?? .direct
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: physical,
                    motion: motion
                )!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            crossings
                .filter {
                    $0.body == body
                        && abs($0.directionalDegree.degrees - directionalDegree.degrees) < 1e-12
                }
                .map {
                    OrboSpineCelestialCoordinate(
                        body: body,
                        directionalDegree: $0.directionalDegree,
                        julianDay: $0.julianDay
                    )
                }
        }
    }

    func testOneBodyPreservesDirectRetrogradeAndDirectRecrossings() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let start = bounds.bone.start.value
        let end = bounds.bone.end.value
        let first = JulianDay(start + 10)!
        let second = JulianDay(start + 20)!
        let third = JulianDay(start + 30)!
        let directTaurus = OrboSpineDirectionalDegree(
            physicalDegrees: 30,
            motion: .direct
        )!
        let retrogradeTaurus = OrboSpineDirectionalDegree(
            physicalDegrees: 30,
            motion: .retrograde
        )!
        let port = Port(
            crossings: [
                Crossing(body: .mercury, directionalDegree: directTaurus, julianDay: first),
                Crossing(body: .mercury, directionalDegree: retrogradeTaurus, julianDay: second),
                Crossing(body: .mercury, directionalDegree: directTaurus, julianDay: third),
            ],
            states: [
                IntervalState(body: .mercury, start: start, end: first.value, physicalDegrees: 15, motion: .direct),
                IntervalState(body: .mercury, start: first.value, end: second.value, physicalDegrees: 45, motion: .direct),
                IntervalState(body: .mercury, start: second.value, end: third.value, physicalDegrees: 15, motion: .retrograde),
                IntervalState(body: .mercury, start: third.value, end: end, physicalDegrees: 45, motion: .direct),
            ],
            fallbackDegree: 15
        )

        let spans = try Themis.traceNatalSpineBody(
            .mercury,
            native: truth,
            bounds: bounds,
            through: port
        )

        let ariesHouse = try house(for: .aries, in: truth)
        let taurusHouse = try house(for: .taurus, in: truth)
        XCTAssertEqual(spans.map(\.house), [ariesHouse, taurusHouse, ariesHouse, taurusHouse])
        XCTAssertEqual(spans.map(\.start), [bounds.bone.start, first, second, third])
        XCTAssertEqual(spans.map(\.end), [first, second, third, bounds.bone.end])
    }

    func testOneBodySpansCoverEntireBoundedLifeWithoutGapsOrOverlaps() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let port = Port(crossings: [], states: [], fallbackDegree: 15)

        let spans = try Themis.traceNatalSpineBody(
            .saturn,
            native: truth,
            bounds: bounds,
            through: port
        )

        XCTAssertEqual(spans.count, 1)
        XCTAssertEqual(spans[0].start, bounds.bone.start)
        XCTAssertEqual(spans[0].end, bounds.bone.end)
        XCTAssertEqual(spans[0].house, try house(for: .aries, in: truth))
    }

    func testCompleteThemisTableBuildsEachCanonicalBodyIndependently() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let port = Port(crossings: [], states: [], fallbackDegree: 15)

        let table = try Themis.traceNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )

        XCTAssertEqual(table.subjectID, truth.subjectID)
        XCTAssertEqual(table.bounds, bounds)
        XCTAssertEqual(table.declaredCount, table.spans.count)
        XCTAssertEqual(table.declaredCount, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(
            Set(table.spans.map(\.body)),
            Set(MundaneBody.canonicalOrder)
        )

        for body in MundaneBody.canonicalOrder {
            let spans = table.spans(for: body)
            XCTAssertEqual(spans.count, 1, "\(body.displayName) should have one static proof span")
            XCTAssertEqual(spans.first?.start, bounds.bone.start)
            XCTAssertEqual(spans.first?.end, bounds.bone.end)
        }
    }

    func testThemisRejectsBoundsForAnotherNative() throws {
        let truth = try nativeTruth()
        let lawful = try Clotho.boundNatalSpine(truth)
        let other = HermesSubjectID(rawValue: "natal-spine.other-native")!
        let wrongBounds = NatalSpineBounds(
            subjectID: other,
            start: lawful.start,
            natal: lawful.natal,
            end: lawful.end
        )!
        let port = Port(crossings: [], states: [], fallbackDegree: 15)

        XCTAssertThrowsError(
            try Themis.traceNatalSpineBody(
                .sun,
                native: truth,
                bounds: wrongBounds,
                through: port
            )
        ) { error in
            XCTAssertEqual(error as? NatalSpineThemisFailure, .subjectMismatch)
        }
    }

    private func nativeTruth() throws -> NatalSpineNativeTruth {
        try NatalSpineTestFixture.litHestia().natalSpineNativeTruth(
            for: NatalSpineTestFixture.subjectID
        )
    }

    private func house(
        for sign: Sign,
        in truth: NatalSpineNativeTruth
    ) throws -> House {
        let address = DegreeAddress(rawValue: sign.rawValue * 30)!
        guard let house = truth.tapestry.tapestry.degrees[address.rawValue].tympan.house else {
            throw TestError.missingHouse
        }
        return house
    }

    private enum TestError: Error {
        case missingHouse
    }
}
