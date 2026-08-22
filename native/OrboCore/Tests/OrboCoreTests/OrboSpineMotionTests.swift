import XCTest
@testable import OrboCore

final class OrboSpineMotionTests: XCTestCase {
    func testDerivesCompleteRetrogradePassageFromStations() throws {
        let span = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(10)!, end: JulianDay(40)!))
        let stations = [
            try XCTUnwrap(OrboSpineStation(
                body: .mercury,
                physicalDegrees: 20,
                julianDay: JulianDay(20)!,
                laneBefore: .direct,
                laneAfter: .retrograde
            )),
            try XCTUnwrap(OrboSpineStation(
                body: .mercury,
                physicalDegrees: 5,
                julianDay: JulianDay(30)!,
                laneBefore: .retrograde,
                laneAfter: .direct
            )),
        ]

        let passages = try XCTUnwrap(OrboSpineMotionBody.retrogradePassages(
            body: .mercury,
            stations: stations,
            span: span
        ))

        XCTAssertEqual(passages.count, 1)
        XCTAssertEqual(passages[0].start.value, 20)
        XCTAssertEqual(passages[0].end.value, 30)
        XCTAssertEqual(passages[0].startStationPhysicalDegrees, 20)
        XCTAssertEqual(passages[0].endStationPhysicalDegrees, 5)
        XCTAssertEqual(passages[0].startBoundary, .station)
        XCTAssertEqual(passages[0].endBoundary, .station)
    }

    func testPreservesRetrogradePassagesAcrossSpineEdges() throws {
        let span = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(10)!, end: JulianDay(40)!))
        let stations = [
            try XCTUnwrap(OrboSpineStation(
                body: .venus,
                physicalDegrees: 15,
                julianDay: JulianDay(20)!,
                laneBefore: .retrograde,
                laneAfter: .direct
            )),
            try XCTUnwrap(OrboSpineStation(
                body: .venus,
                physicalDegrees: 25,
                julianDay: JulianDay(30)!,
                laneBefore: .direct,
                laneAfter: .retrograde
            )),
        ]

        let passages = try XCTUnwrap(OrboSpineMotionBody.retrogradePassages(
            body: .venus,
            stations: stations,
            span: span
        ))

        XCTAssertEqual(passages.count, 2)
        XCTAssertEqual(passages[0].start.value, 10)
        XCTAssertEqual(passages[0].end.value, 20)
        XCTAssertNil(passages[0].startStationPhysicalDegrees)
        XCTAssertEqual(passages[0].endStationPhysicalDegrees, 15)
        XCTAssertEqual(passages[0].startBoundary, .spineStart)
        XCTAssertEqual(passages[0].endBoundary, .station)

        XCTAssertEqual(passages[1].start.value, 30)
        XCTAssertEqual(passages[1].end.value, 40)
        XCTAssertEqual(passages[1].startStationPhysicalDegrees, 25)
        XCTAssertNil(passages[1].endStationPhysicalDegrees)
        XCTAssertEqual(passages[1].startBoundary, .station)
        XCTAssertEqual(passages[1].endBoundary, .spineEnd)
    }

    func testRejectsBrokenStationTopology() throws {
        let span = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(10)!, end: JulianDay(40)!))
        let stations = [
            try XCTUnwrap(OrboSpineStation(
                body: .mars,
                physicalDegrees: 20,
                julianDay: JulianDay(20)!,
                laneBefore: .direct,
                laneAfter: .retrograde
            )),
            try XCTUnwrap(OrboSpineStation(
                body: .mars,
                physicalDegrees: 10,
                julianDay: JulianDay(30)!,
                laneBefore: .direct,
                laneAfter: .retrograde
            )),
        ]

        XCTAssertNil(OrboSpineMotionBody.retrogradePassages(
            body: .mars,
            stations: stations,
            span: span
        ))
        XCTAssertEqual(OrboSpineMotionBody.retrogradePassages(body: .sun, stations: [], span: span), [])
        XCTAssertNil(OrboSpineMotionBody.retrogradePassages(body: .mercury, stations: [], span: span))
    }
}
