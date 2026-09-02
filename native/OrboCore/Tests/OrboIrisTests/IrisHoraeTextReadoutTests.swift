import XCTest
@testable import OrboCore
@testable import OrboIris

final class IrisHoraeTextReadoutTests: XCTestCase {
    func testTextReadoutPreservesExactHoraeFrame() throws {
        let horae = try makeHorae()
        let requested = try XCTUnwrap(JulianDay(1_001.25))
        let output = try horae.seek(to: requested)
        let frame = IrisHoraeFrame(output: output)
        let readout = IrisHoraeTextReadout(frame: frame)

        XCTAssertEqual(readout.frame, frame)
        XCTAssertEqual(readout.frame.output, output)
        XCTAssertEqual(readout.julianDay, output.julianDay)
        XCTAssertEqual(readout.rows.map(\.source), output.celestial)
        XCTAssertEqual(readout.rows.map(\.body), OrboSpineContract.canonicalBodies)
        XCTAssertEqual(readout.terraReadout.source, output.terra)
        XCTAssertEqual(readout.terraReadout, frame.terraReadout)
    }

    func testTextRowsDescribeCanonicalHoraeCoordinatesWithoutChangingThem() throws {
        let horae = try makeHorae()
        let output = try horae.seek(to: try XCTUnwrap(JulianDay(1_001.25)))
        let readout = IrisHoraeTextReadout(frame: IrisHoraeFrame(output: output))

        for row in readout.rows {
            let expectedLongitude = try XCTUnwrap(
                CelestialLongitude(row.source.directionalDegree.physicalDegrees)
            )

            XCTAssertEqual(row.longitude, expectedLongitude)
            XCTAssertEqual(row.sign, expectedLongitude.sign)
            XCTAssertEqual(row.degreeInSign, expectedLongitude.degreeInSign.value, accuracy: 0.000_001)
            XCTAssertEqual(row.motion, row.source.directionalDegree.motion)
        }

        let mercury = try XCTUnwrap(readout.rows.first(where: { $0.body == .mercury }))
        XCTAssertEqual(mercury.motion, .retrograde)
        XCTAssertTrue(mercury.positionText.hasSuffix(" R"))
    }

    func testTextManifestationFollowsNewFrameOnlyAfterHoraeMovesTime() throws {
        let horae = try makeHorae()
        let initial = try XCTUnwrap(JulianDay(1_001.0))
        let target = try XCTUnwrap(JulianDay(1_001.5))
        var session = try IrisHoraeControlSession(
            horae: horae,
            initialJulianDay: initial
        )

        let before = IrisHoraeTextReadout(frame: session.frame)
        let expected = try horae.respond(to: .seekUT(to: target))

        try session.seek(to: target, through: horae)
        let after = IrisHoraeTextReadout(frame: session.frame)

        XCTAssertEqual(after.frame.output, expected)
        XCTAssertEqual(after.rows.map(\.source), expected.celestial)
        XCTAssertEqual(after.terraReadout.source, expected.terra)
        XCTAssertNotEqual(after.julianDay, before.julianDay)
        XCTAssertNotEqual(after.rows.map(\.source), before.rows.map(\.source))
    }

    private func makeHorae() throws -> Horae {
        let start = try XCTUnwrap(JulianDay(1_000.0))
        let end = try XCTUnwrap(JulianDay(1_003.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        let starts: [MundaneBody: Double] = [
            .sun: 20,
            .moon: 50,
            .mercury: 80,
            .venus: 110,
            .mars: 140,
            .jupiter: 170,
            .saturn: 200,
            .uranus: 230,
            .neptune: 260,
            .pluto: 290,
            .trueNorthNode: 320,
        ]

        let steps: [MundaneBody: Double] = [
            .sun: 1,
            .moon: 1,
            .mercury: -0.5,
            .venus: 0.5,
            .mars: 0.5,
            .jupiter: 0.2,
            .saturn: 0.2,
            .uranus: 0.1,
            .neptune: 0.05,
            .pluto: 0.05,
            .trueNorthNode: -0.05,
        ]

        let supports = OrboSpineContract.canonicalBodies.flatMap { body in
            (0...2).map { index in
                coordinate(
                    body: body,
                    physicalDegrees: starts[body]! + (Double(index) * steps[body]!),
                    motion: steps[body]! < 0 ? .retrograde : .direct,
                    julianDay: 1_000.0 + Double(index)
                )
            }
        }

        let terra = [
            TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: start
            )!,
            TerraMarrowSample(
                turnDegrees: 103,
                tiltDegrees: 23.5,
                julianDay: end
            )!,
        ]

        let locate = try XCTUnwrap(
            OrboSpineLocate(
                bone: bone,
                celestialSupports: supports,
                terraSamples: terra
            )
        )

        return Horae(locate: locate)
    }

    private func coordinate(
        body: MundaneBody,
        physicalDegrees: Double,
        motion: Motion,
        julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }
}
