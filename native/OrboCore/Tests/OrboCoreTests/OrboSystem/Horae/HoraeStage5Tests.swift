import XCTest
@testable import OrboCore

final class HoraeStage5Tests: XCTestCase {
    func testHoraeMatchesLocateAtExactStationAndKeepsLaneEnteredAfter() throws {
        let locate = try XCTUnwrap(makeStationLocate())
        let horae = Horae(locate: locate)
        let stationUT = try XCTUnwrap(JulianDay(2_500_101.0))

        let output = try assertHoraeMatchesLocate(horae, locate: locate, at: stationUT)
        let mercury = try XCTUnwrap(output.celestial.first { $0.body == .mercury })

        XCTAssertEqual(mercury.directionalDegree.physicalDegrees, 21.0, accuracy: 1e-10)
        XCTAssertEqual(mercury.directionalDegree.motion, .retrograde)
    }

    func testHoraeMatchesLocateAtWholeDegreeCrossing() throws {
        let locate = try XCTUnwrap(makeDegreeCrossingLocate())
        let horae = Horae(locate: locate)
        let crossingUT = try XCTUnwrap(JulianDay(2_500_200.25))

        let output = try assertHoraeMatchesLocate(horae, locate: locate, at: crossingUT)
        let sun = try XCTUnwrap(output.celestial.first { $0.body == .sun })

        XCTAssertEqual(sun.directionalDegree.physicalDegrees, 30.0, accuracy: 1e-10)
        XCTAssertEqual(sun.directionalDegree.navigationCell, 30)
    }

    func testHoraeMatchesLocateAcrossBothTerraSourceSeams() throws {
        for seam in TerraMarrowContract.sourceModelSeamJulianDays {
            let locate = try XCTUnwrap(makeTerraSeamLocate(seam: seam))
            let horae = Horae(locate: locate)

            for value in [seam - 0.25, seam, seam + 0.25] {
                let target = try XCTUnwrap(JulianDay(value))
                _ = try assertHoraeMatchesLocate(horae, locate: locate, at: target)
            }
        }
    }

    func testHoraeMatchesLocateAtBoneStartAndImmediatelyBeforeEnd() throws {
        let locate = try XCTUnwrap(makeSimpleLocate())
        let horae = Horae(locate: locate)

        let start = locate.bone.start
        let nearEnd = try XCTUnwrap(JulianDay(locate.bone.end.value - 0.000_001))

        _ = try assertHoraeMatchesLocate(horae, locate: locate, at: start)
        _ = try assertHoraeMatchesLocate(horae, locate: locate, at: nearEnd)
    }

    func testHoraeAndLocateRejectExactHalfOpenBoneEndTheSameWay() throws {
        let locate = try XCTUnwrap(makeSimpleLocate())
        let horae = Horae(locate: locate)
        let end = locate.bone.end

        XCTAssertThrowsError(try locate.coordinate(of: .sun, at: end)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
        XCTAssertThrowsError(try horae.seek(to: end)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    @discardableResult
    private func assertHoraeMatchesLocate(
        _ horae: Horae,
        locate: OrboSpineLocate,
        at julianDay: JulianDay,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> HoraeOutput {
        let expectedCelestial = try OrboSpineContract.canonicalBodies.map { body in
            try locate.coordinate(of: body, at: julianDay)
        }
        let expectedTerra = try locate.terra(at: julianDay)
        let output = try horae.seek(to: julianDay)

        XCTAssertEqual(output.julianDay, julianDay, file: file, line: line)
        XCTAssertEqual(output.celestial, expectedCelestial, file: file, line: line)
        XCTAssertEqual(output.terra, expectedTerra, file: file, line: line)
        return output
    }

    private func makeSimpleLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_300.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_300.5))
        let end = try XCTUnwrap(JulianDay(2_500_301.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        let supports = directSupports(start: start, midpoint: midpoint)

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: try terraEndpoints(start: start, end: end)
        )
    }

    private func makeStationLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_100.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_101.0))
        let end = try XCTUnwrap(JulianDay(2_500_102.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports = directSupports(start: start, midpoint: midpoint, excluding: .mercury)
        supports.append(coordinate(.mercury, physicalDegrees: 20.0, motion: .direct, at: start))
        supports.append(coordinate(.mercury, physicalDegrees: 20.5, motion: .direct, at: JulianDay(2_500_100.5)!))
        supports.append(coordinate(.mercury, physicalDegrees: 20.5, motion: .retrograde, at: JulianDay(2_500_101.5)!))

        let station = try XCTUnwrap(
            OrboSpineStation(
                body: .mercury,
                physicalDegrees: 21.0,
                julianDay: midpoint,
                laneBefore: .direct,
                laneAfter: .retrograde
            )
        )

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            stations: [station],
            terraSamples: try terraEndpoints(start: start, end: end)
        )
    }

    private func makeDegreeCrossingLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_200.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_200.5))
        let end = try XCTUnwrap(JulianDay(2_500_201.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports = directSupports(start: start, midpoint: midpoint, excluding: .sun)
        supports.append(coordinate(.sun, physicalDegrees: 29.5, motion: .direct, at: start))
        supports.append(coordinate(.sun, physicalDegrees: 30.5, motion: .direct, at: midpoint))

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: try terraEndpoints(start: start, end: end)
        )
    }

    private func makeTerraSeamLocate(seam: Double) throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(seam - 0.5))
        let midpoint = try XCTUnwrap(JulianDay(seam))
        let end = try XCTUnwrap(JulianDay(seam + 0.5))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        let supports = directSupports(start: start, midpoint: midpoint)

        let terra = [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 100.0, tiltDegrees: 23.40, julianDay: start)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 109.0, tiltDegrees: 23.41, julianDay: JulianDay(seam - 0.0001)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 110.0, tiltDegrees: 23.42, julianDay: midpoint)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 200.0, tiltDegrees: 23.43, julianDay: JulianDay(seam + 0.0001)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 210.0, tiltDegrees: 23.44, julianDay: end)),
        ]

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        )
    }

    private func directSupports(
        start: JulianDay,
        midpoint: JulianDay,
        excluding excludedBody: MundaneBody? = nil
    ) -> [OrboSpineCelestialCoordinate] {
        var supports: [OrboSpineCelestialCoordinate] = []

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() where body != excludedBody {
            let physical = Double(index) * 20.0
            let step = OrboSpineContract.supportDegrees(for: body) * 0.5
            supports.append(coordinate(body, physicalDegrees: physical, motion: .direct, at: start))
            supports.append(coordinate(body, physicalDegrees: physical + step, motion: .direct, at: midpoint))
        }

        return supports
    }

    private func terraEndpoints(start: JulianDay, end: JulianDay) throws -> [TerraMarrowSample] {
        [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 100.0, tiltDegrees: 23.4, julianDay: start)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 110.0, tiltDegrees: 23.5, julianDay: end)),
        ]
    }

    private func coordinate(
        _ body: MundaneBody,
        physicalDegrees: Double,
        motion: Motion,
        at julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: julianDay
        )
    }
}
