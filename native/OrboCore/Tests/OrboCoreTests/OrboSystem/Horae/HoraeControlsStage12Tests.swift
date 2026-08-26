import XCTest
@testable import OrboCore

final class HoraeControlsStage12Tests: XCTestCase {
    func testPlanetaryScrubCrossesDirectStationRetrogradeWithoutLeavingTract() throws {
        let locate = try XCTUnwrap(makeStationLocate())
        let horae = Horae(locate: locate)
        let start = locate.bone.start.value

        let direct = degree(20.75, .direct)
        let station = degree(21.0, .retrograde)
        let retrograde = degree(20.75, .retrograde)

        let directOutput = try horae.driveDirectionalDegree(
            to: direct,
            body: .mercury,
            from: try XCTUnwrap(JulianDay(start + 0.70))
        )
        let stationOutput = try horae.driveDirectionalDegree(
            to: station,
            body: .mercury,
            from: directOutput.julianDay
        )
        let retrogradeOutput = try horae.driveDirectionalDegree(
            to: retrograde,
            body: .mercury,
            from: stationOutput.julianDay
        )

        XCTAssertEqual(directOutput.julianDay.value, start + 0.75, accuracy: 1e-10)
        XCTAssertEqual(stationOutput.julianDay.value, start + 1.00, accuracy: 1e-10)
        XCTAssertEqual(retrogradeOutput.julianDay.value, start + 1.25, accuracy: 1e-10)

        let stationMercury = try selectedCoordinate(stationOutput, body: .mercury)
        XCTAssertEqual(stationMercury.directionalDegree.motion, .retrograde)
        XCTAssertEqual(stationMercury.directionalDegree.physicalDegrees, 21.0, accuracy: 1e-10)

        try assertPlanetaryScrubOutput(directOutput, body: .mercury, degree: direct, horae: horae)
        try assertPlanetaryScrubOutput(stationOutput, body: .mercury, degree: station, horae: horae)
        try assertPlanetaryScrubOutput(retrogradeOutput, body: .mercury, degree: retrograde, horae: horae)
    }

    func testSamePhysicalDegreeOnOppositeMotionLanesResolvesDistinctOccurrences() throws {
        let locate = try XCTUnwrap(makeStationLocate())
        let horae = Horae(locate: locate)
        let start = locate.bone.start.value
        let direct = degree(20.5, .direct)
        let retrograde = degree(20.5, .retrograde)

        let directOutput = try horae.driveDirectionalDegree(
            to: direct,
            body: .mercury,
            from: try XCTUnwrap(JulianDay(start + 0.4))
        )
        let retrogradeOutput = try horae.driveDirectionalDegree(
            to: retrograde,
            body: .mercury,
            from: try XCTUnwrap(JulianDay(start + 1.4))
        )

        XCTAssertEqual(directOutput.julianDay.value, start + 0.5, accuracy: 1e-10)
        XCTAssertEqual(retrogradeOutput.julianDay.value, start + 1.5, accuracy: 1e-10)
        XCTAssertEqual(try selectedCoordinate(directOutput, body: .mercury).directionalDegree.motion, .direct)
        XCTAssertEqual(try selectedCoordinate(retrogradeOutput, body: .mercury).directionalDegree.motion, .retrograde)
    }

    func testDirectZodiacWrapRemainsContinuousInUT() throws {
        let locate = try XCTUnwrap(makeWrapLocate(motion: .direct))
        let horae = Horae(locate: locate)
        let start = locate.bone.start.value
        let beforeWrap = degree(359.75, .direct)
        let afterWrap = degree(0.25, .direct)

        let before = try horae.driveDirectionalDegree(
            to: beforeWrap,
            body: .mercury,
            from: try XCTUnwrap(JulianDay(start + 0.75))
        )
        let after = try horae.driveDirectionalDegree(
            to: afterWrap,
            body: .mercury,
            from: before.julianDay
        )

        XCTAssertEqual(before.julianDay.value, start + 0.75, accuracy: 1e-10)
        XCTAssertEqual(after.julianDay.value, start + 1.25, accuracy: 1e-10)
        XCTAssertGreaterThan(after.julianDay.value, before.julianDay.value)
        try assertPlanetaryScrubOutput(before, body: .mercury, degree: beforeWrap, horae: horae)
        try assertPlanetaryScrubOutput(after, body: .mercury, degree: afterWrap, horae: horae)
    }

    func testRetrogradeZodiacWrapRemainsContinuousInUT() throws {
        let locate = try XCTUnwrap(makeWrapLocate(motion: .retrograde))
        let horae = Horae(locate: locate)
        let start = locate.bone.start.value
        let beforeWrap = degree(0.25, .retrograde)
        let afterWrap = degree(359.75, .retrograde)

        let before = try horae.driveDirectionalDegree(
            to: beforeWrap,
            body: .mercury,
            from: try XCTUnwrap(JulianDay(start + 0.75))
        )
        let after = try horae.driveDirectionalDegree(
            to: afterWrap,
            body: .mercury,
            from: before.julianDay
        )

        XCTAssertEqual(before.julianDay.value, start + 0.75, accuracy: 1e-10)
        XCTAssertEqual(after.julianDay.value, start + 1.25, accuracy: 1e-10)
        XCTAssertGreaterThan(after.julianDay.value, before.julianDay.value)
        try assertPlanetaryScrubOutput(before, body: .mercury, degree: beforeWrap, horae: horae)
        try assertPlanetaryScrubOutput(after, body: .mercury, degree: afterWrap, horae: horae)
    }

    func testRepeatedDirectionalStateUsesExplicitContinuityAnchor() throws {
        let locate = try XCTUnwrap(makeRepeatedMoonLocate())
        let horae = Horae(locate: locate)
        let start = locate.bone.start.value
        let target = degree(20.0, .direct)
        let occurrences = try locate.occurrences(of: .moon, at: target)

        XCTAssertGreaterThanOrEqual(occurrences.count, 2)

        let early = try horae.driveDirectionalDegree(
            to: target,
            body: .moon,
            from: try XCTUnwrap(JulianDay(start + 5.0))
        )
        let late = try horae.driveDirectionalDegree(
            to: target,
            body: .moon,
            from: try XCTUnwrap(JulianDay(start + 75.0))
        )

        XCTAssertEqual(early.julianDay.value, start + 4.0, accuracy: 1e-10)
        XCTAssertEqual(late.julianDay.value, start + 76.0, accuracy: 1e-10)
        try assertPlanetaryScrubOutput(early, body: .moon, degree: target, horae: horae)
        try assertPlanetaryScrubOutput(late, body: .moon, degree: target, horae: horae)
    }

    func testOccurrenceNavigationSeesSameRepeatedStateTruthAsPlanetaryScrub() throws {
        let locate = try XCTUnwrap(makeRepeatedMoonLocate())
        let horae = Horae(locate: locate)
        let start = locate.bone.start.value
        let target = degree(20.0, .direct)

        let first = try horae.driveDirectionalDegree(
            to: target,
            body: .moon,
            from: try XCTUnwrap(JulianDay(start + 5.0))
        )
        let next = try horae.navigateOccurrence(
            of: .moon,
            at: target,
            from: first.julianDay,
            direction: .next
        )
        let scrubbedLate = try horae.driveDirectionalDegree(
            to: target,
            body: .moon,
            from: try XCTUnwrap(JulianDay(start + 75.0))
        )

        XCTAssertEqual(next.julianDay, scrubbedLate.julianDay)
        XCTAssertEqual(next.celestial, scrubbedLate.celestial)
        XCTAssertEqual(next.terra, scrubbedLate.terra)
    }

    private func assertPlanetaryScrubOutput(
        _ output: HoraeOutput,
        body: MundaneBody,
        degree: OrboSpineDirectionalDegree,
        horae: Horae,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let seek = try horae.seek(to: output.julianDay)
        let state = try XCTUnwrap(output.controlState, file: file, line: line)
        let coordinate = try selectedCoordinate(output, body: body, file: file, line: line)

        XCTAssertEqual(output.celestial, seek.celestial, file: file, line: line)
        XCTAssertEqual(output.terra, seek.terra, file: file, line: line)
        XCTAssertEqual(coordinate.directionalDegree, degree, file: file, line: line)
        XCTAssertEqual(state.address.body, body, file: file, line: line)
        XCTAssertEqual(state.address.directionalDegree, degree, file: file, line: line)
        XCTAssertEqual(state.bodyRole, .pinned, file: file, line: line)
        XCTAssertEqual(state.directionalDegreeRole, .driven, file: file, line: line)
        XCTAssertEqual(state.julianDayRole, .resolved, file: file, line: line)
    }

    private func selectedCoordinate(
        _ output: HoraeOutput,
        body: MundaneBody,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> OrboSpineCelestialCoordinate {
        try XCTUnwrap(
            output.celestial.first(where: { $0.body == body }),
            file: file,
            line: line
        )
    }

    private func makeStationLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_700_000.0))
        let stationUT = try XCTUnwrap(JulianDay(start.value + 1.0))
        let end = try XCTUnwrap(JulianDay(start.value + 2.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports = baselineSupports(
            start: start,
            midpoint: stationUT,
            excluding: .mercury
        )
        supports.append(coordinate(.mercury, 20.0, .direct, start))
        supports.append(coordinate(
            .mercury,
            20.5,
            .direct,
            try XCTUnwrap(JulianDay(start.value + 0.5))
        ))
        supports.append(coordinate(
            .mercury,
            20.5,
            .retrograde,
            try XCTUnwrap(JulianDay(start.value + 1.5))
        ))

        let station = try XCTUnwrap(OrboSpineStation(
            body: .mercury,
            physicalDegrees: 21.0,
            julianDay: stationUT,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            stations: [station],
            terraSamples: try terraEndpoints(start: start, end: end)
        )
    }

    private func makeWrapLocate(motion: Motion) throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_710_000.0 + (motion == .retrograde ? 10.0 : 0.0)))
        let midpoint = try XCTUnwrap(JulianDay(start.value + 1.0))
        let end = try XCTUnwrap(JulianDay(start.value + 2.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports = baselineSupports(
            start: start,
            midpoint: midpoint,
            excluding: .mercury
        )

        let physicals: [Double]
        switch motion {
        case .direct:
            physicals = [359.0, 359.5, 0.0, 0.5]
        case .retrograde:
            physicals = [1.0, 0.5, 0.0, 359.5]
        }

        for (index, physical) in physicals.enumerated() {
            let julianDay = try XCTUnwrap(
                JulianDay(start.value + 0.5 * Double(index))
            )
            supports.append(coordinate(.mercury, physical, motion, julianDay))
        }

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: try terraEndpoints(start: start, end: end)
        )
    }

    private func makeRepeatedMoonLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_720_000.0))
        let midpoint = try XCTUnwrap(JulianDay(start.value + 40.0))
        let end = try XCTUnwrap(JulianDay(start.value + 80.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports = baselineSupports(
            start: start,
            midpoint: midpoint,
            excluding: .moon
        )

        for day in 0..<80 {
            let physical = normalized(5.0 * Double(day))
            let julianDay = try XCTUnwrap(JulianDay(start.value + Double(day)))
            supports.append(coordinate(.moon, physical, .direct, julianDay))
        }

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: try terraEndpoints(start: start, end: end)
        )
    }

    private func baselineSupports(
        start: JulianDay,
        midpoint: JulianDay,
        excluding excludedBody: MundaneBody
    ) -> [OrboSpineCelestialCoordinate] {
        var supports: [OrboSpineCelestialCoordinate] = []

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated()
        where body != excludedBody {
            let step = OrboSpineContract.supportDegrees(for: body) * 0.5
            let physical = normalized(Double(index) * 20.0)
            supports.append(coordinate(body, physical, .direct, start))
            supports.append(coordinate(
                body,
                normalized(physical + step),
                .direct,
                midpoint
            ))
        }
        return supports
    }

    private func terraEndpoints(
        start: JulianDay,
        end: JulianDay
    ) throws -> [TerraMarrowSample] {
        [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100.0,
                tiltDegrees: 23.4,
                julianDay: start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110.0,
                tiltDegrees: 23.5,
                julianDay: end
            )),
        ]
    }

    private func degree(
        _ physicalDegrees: Double,
        _ motion: Motion
    ) -> OrboSpineDirectionalDegree {
        OrboSpineDirectionalDegree(
            physicalDegrees: physicalDegrees,
            motion: motion
        )!
    }

    private func coordinate(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        _ motion: Motion,
        _ julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: degree(physicalDegrees, motion),
            julianDay: julianDay
        )
    }

    private func normalized(_ value: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: 360)
        return remainder >= 0 ? remainder : remainder + 360
    }
}
