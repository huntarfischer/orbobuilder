import XCTest
@testable import OrboCore

final class MundaneTimespineBoundaryTests: XCTestCase {
    func testTerminalBoundaryGuidesDirectWrapWithoutBecomingOccurrence() throws {
        let start = try XCTUnwrap(JulianDay(1_000))
        let end = try XCTUnwrap(JulianDay(1_010))
        let series = try XCTUnwrap(MundaneTimespineBodySeries(
            body: .pluto,
            celestialResolutionDegrees: 0.1,
            anchors: [
                try XCTUnwrap(MundaneTimespineCelestialAnchor(
                    celestialTimeDegrees: 359.8,
                    julianDay: JulianDay(1_006)!,
                    motion: .direct
                )),
                try XCTUnwrap(MundaneTimespineCelestialAnchor(
                    celestialTimeDegrees: 359.9,
                    julianDay: JulianDay(1_008)!,
                    motion: .direct
                )),
            ],
            stations: [],
            initialBoundary: try XCTUnwrap(MundaneTimespineBoundaryAnchor(
                celestialTimeDegrees: 359.5,
                julianDay: start,
                motion: .direct
            )),
            terminalBoundary: try XCTUnwrap(MundaneTimespineBoundaryAnchor(
                celestialTimeDegrees: 0,
                julianDay: end,
                motion: .direct
            ))
        ))
        let image = try XCTUnwrap(MundaneTimespineRuntimeImage(
            spanName: "boundary direct fixture",
            supportedStart: start,
            supportedEnd: end,
            bodySeries: [series]
        ))
        let reader = MundaneTimespineReader(image: image)

        let state = try XCTUnwrap(try reader.state(at: JulianDay(1_009)!)[.pluto])
        XCTAssertEqual(state.source, .interpolated)
        XCTAssertGreaterThanOrEqual(state.celestialTimeDegrees, 359.9)
        XCTAssertLessThan(state.celestialTimeDegrees, 360)

        XCTAssertTrue(try reader.occurrences(of: .pluto, at: 0).isEmpty)
        XCTAssertEqual(try reader.occurrences(of: .pluto, at: 359.9).count, 1)
    }

    func testTerminalBoundaryGuidesRetrogradeWrapWithoutBecomingOccurrence() throws {
        let start = try XCTUnwrap(JulianDay(2_000))
        let end = try XCTUnwrap(JulianDay(2_010))
        let series = try XCTUnwrap(MundaneTimespineBodySeries(
            body: .mercury,
            celestialResolutionDegrees: 0.1,
            anchors: [
                try XCTUnwrap(MundaneTimespineCelestialAnchor(
                    celestialTimeDegrees: 0.2,
                    julianDay: JulianDay(2_006)!,
                    motion: .retrograde
                )),
                try XCTUnwrap(MundaneTimespineCelestialAnchor(
                    celestialTimeDegrees: 0.1,
                    julianDay: JulianDay(2_008)!,
                    motion: .retrograde
                )),
            ],
            stations: [],
            initialBoundary: try XCTUnwrap(MundaneTimespineBoundaryAnchor(
                celestialTimeDegrees: 0.5,
                julianDay: start,
                motion: .retrograde
            )),
            terminalBoundary: try XCTUnwrap(MundaneTimespineBoundaryAnchor(
                celestialTimeDegrees: 359.9,
                julianDay: end,
                motion: .retrograde
            ))
        ))
        let image = try XCTUnwrap(MundaneTimespineRuntimeImage(
            spanName: "boundary retrograde fixture",
            supportedStart: start,
            supportedEnd: end,
            bodySeries: [series]
        ))
        let reader = MundaneTimespineReader(image: image)

        let state = try XCTUnwrap(try reader.state(at: JulianDay(2_009.5)!)[.mercury])
        XCTAssertEqual(state.source, .interpolated)
        XCTAssertGreaterThan(state.celestialTimeDegrees, 359.9)
        XCTAssertLessThan(state.celestialTimeDegrees, 360)

        XCTAssertTrue(try reader.occurrences(of: .mercury, at: 359.9).isEmpty)
        XCTAssertEqual(try reader.occurrences(of: .mercury, at: 0.1).count, 1)
    }
}
