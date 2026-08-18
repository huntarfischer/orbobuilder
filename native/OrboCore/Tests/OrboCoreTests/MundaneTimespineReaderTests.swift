import XCTest
@testable import OrboCore

final class MundaneTimespineReaderTests: XCTestCase {
    func testCivicReadReturnsAllElevenCelestialClocksSimultaneously() throws {
        let image = try XCTUnwrap(makeImage(bodySeries: MundaneBody.canonicalOrder.map(makeDirectSeries)))
        let reader = MundaneTimespineReader(image: image)
        let moment = try reader.state(at: jd(105))

        XCTAssertEqual(moment.states.count, 11)
        XCTAssertEqual(moment.civicOffsetSeconds, 5 * 86_400)
        for body in MundaneBody.canonicalOrder {
            let state = try XCTUnwrap(moment[body])
            XCTAssertEqual(state.celestialTimeDegrees, 5, accuracy: 1e-12)
            XCTAssertEqual(state.motion, .direct)
            XCTAssertEqual(state.source, .interpolated)
        }
    }

    func testCivicReadUsesStationAsTurnInCelestialTime() throws {
        let mercury = try XCTUnwrap(MundaneTimespineBodySeries(
            body: .mercury,
            celestialResolutionDegrees: 5,
            anchors: [
                anchor(10, 100, .direct),
                anchor(15, 104, .direct),
                anchor(15, 108, .retrograde),
                anchor(10, 112, .retrograde),
            ],
            stations: [station(17, 106, .direct, .retrograde)]
        ))
        let image = try XCTUnwrap(makeImage(bodySeries: [mercury]))
        let reader = MundaneTimespineReader(image: image)

        let before = try reader.state(at: jd(105))[.mercury]
        XCTAssertEqual(try XCTUnwrap(before).celestialTimeDegrees, 16, accuracy: 1e-12)
        XCTAssertEqual(before?.motion, .direct)

        let atStation = try reader.state(at: jd(106))[.mercury]
        XCTAssertEqual(try XCTUnwrap(atStation).celestialTimeDegrees, 17, accuracy: 1e-12)
        XCTAssertEqual(atStation?.motion, .retrograde)
        XCTAssertEqual(atStation?.source, .station)
        XCTAssertTrue(atStation?.isStation == true)

        let after = try reader.state(at: jd(107))[.mercury]
        XCTAssertEqual(try XCTUnwrap(after).celestialTimeDegrees, 16, accuracy: 1e-12)
        XCTAssertEqual(after?.motion, .retrograde)
    }

    func testCelestialTimeReturnsEveryStoredCivicOccurrence() throws {
        let mercury = try XCTUnwrap(MundaneTimespineBodySeries(
            body: .mercury,
            celestialResolutionDegrees: 5,
            anchors: [
                anchor(10, 100, .direct),
                anchor(15, 104, .direct),
                anchor(15, 108, .retrograde),
                anchor(10, 112, .retrograde),
            ],
            stations: [station(17, 106, .direct, .retrograde)]
        ))
        let reader = MundaneTimespineReader(image: try XCTUnwrap(makeImage(bodySeries: [mercury])))

        let occurrences = try reader.occurrences(of: .mercury, at: 10)
        XCTAssertEqual(occurrences.count, 2)
        XCTAssertEqual(occurrences.map(\.ordinal), [1, 2])
        XCTAssertEqual(occurrences.map { $0.julianDay.value }, [100, 112])
        XCTAssertEqual(occurrences.map(\.motion), [.direct, .retrograde])
        XCTAssertEqual(occurrences.map(\.civicOffsetSeconds), [Int64(0), Int64(12 * 86_400)])
    }

    func testCelestialLookupRejectsDegreeOutsideStoredLattice() throws {
        let mercury = try XCTUnwrap(MundaneTimespineBodySeries(
            body: .mercury,
            celestialResolutionDegrees: 5,
            anchors: [anchor(10, 100, .direct), anchor(15, 104, .direct)],
            stations: []
        ))
        let reader = MundaneTimespineReader(image: try XCTUnwrap(makeImage(bodySeries: [mercury])))

        XCTAssertThrowsError(try reader.occurrences(of: .mercury, at: 12)) { error in
            guard case MundaneTimespineReaderError.celestialTimeNotStored = error else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    func testRelationshipAndEclipseReadsAreHalfOpenBinaryWindowsWithReadTimeFilters() throws {
        let relationships = [
            relationship(.sun, .moon, .square, .bodyBAhead, 100),
            relationship(.mercury, .venus, .semisextile, .bodyAAhead, 105),
            relationship(.mars, .jupiter, .trine, .bodyBAhead, 110),
        ]
        let eclipses = [
            eclipse(.solar, .total, 109),
            eclipse(.lunar, .partial, 110),
        ]
        let image = try XCTUnwrap(makeImage(
            bodySeries: [makeDirectSeries(.sun)],
            relationships: relationships,
            eclipses: eclipses
        ))
        let reader = MundaneTimespineReader(image: image)
        let window = try XCTUnwrap(MundaneTimespineCivicWindow(start: jd(100), end: jd(110)))

        XCTAssertEqual(reader.relationships(in: window).count, 2)
        XCTAssertEqual(reader.relationships(in: window, marks: [.square]).map(\.mark), [.square])
        XCTAssertEqual(reader.relationships(in: window, involving: [.mercury]).map(\.mark), [.semisextile])
        XCTAssertEqual(reader.eclipses(in: window).map(\.kind), [.solar])

        let events = reader.events(in: window)
        XCTAssertEqual(events.map { $0.julianDay.value }, [100, 105, 109])
    }

    func testSupportedSpanRemainsHalfOpen() throws {
        let image = try XCTUnwrap(makeImage(bodySeries: [makeDirectSeries(.sun)]))
        let reader = MundaneTimespineReader(image: image)

        XCTAssertNoThrow(try reader.state(at: jd(100)))
        XCTAssertThrowsError(try reader.state(at: image.supportedEnd)) { error in
            guard case MundaneTimespineReaderError.outsideSupportedSpan = error else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    private func makeImage(
        bodySeries: [MundaneTimespineBodySeries],
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) -> MundaneTimespineRuntimeImage? {
        MundaneTimespineRuntimeImage(
            spanName: "reader-test",
            supportedStart: jd(100),
            supportedEnd: jd(121),
            bodySeries: bodySeries,
            relationships: relationships,
            eclipses: eclipses
        )
    }

    private func makeDirectSeries(_ body: MundaneBody) -> MundaneTimespineBodySeries {
        MundaneTimespineBodySeries(
            body: body,
            celestialResolutionDegrees: 10,
            anchors: [
                anchor(0, 100, .direct),
                anchor(10, 110, .direct),
                anchor(20, 120, .direct),
            ],
            stations: []
        )!
    }

    private func anchor(_ degree: Double, _ value: Double, _ motion: Motion) -> MundaneTimespineCelestialAnchor {
        MundaneTimespineCelestialAnchor(
            celestialTimeDegrees: degree,
            julianDay: jd(value),
            motion: motion
        )!
    }

    private func station(
        _ degree: Double,
        _ value: Double,
        _ before: Motion,
        _ after: Motion
    ) -> MundaneTimespineStationAnchor {
        MundaneTimespineStationAnchor(
            celestialTimeDegrees: degree,
            julianDay: jd(value),
            motionBefore: before,
            motionAfter: after
        )!
    }

    private func relationship(
        _ bodyA: MundaneBody,
        _ bodyB: MundaneBody,
        _ mark: RingMark,
        _ orientation: MundaneTimespineRelationshipOrientation,
        _ value: Double
    ) -> MundaneTimespineRelationshipEvent {
        MundaneTimespineRelationshipEvent(
            bodyA: bodyA,
            bodyB: bodyB,
            mark: mark,
            orientation: orientation,
            bodyACelestialTimeDegrees: 10,
            bodyBCelestialTimeDegrees: 10 + Double(mark.rawValue),
            julianDay: jd(value),
            exactAspectResidualArcSeconds: 0
        )!
    }

    private func eclipse(
        _ kind: MundaneTimespineEclipseKind,
        _ type: MundaneTimespineEclipseType,
        _ value: Double
    ) -> MundaneTimespineEclipseEvent {
        MundaneTimespineEclipseEvent(
            kind: kind,
            type: type,
            eclipseDegree: 20,
            julianDay: jd(value)
        )!
    }

    private func jd(_ value: Double) -> JulianDay {
        JulianDay(value)!
    }
}
