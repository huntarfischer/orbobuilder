import XCTest
@testable import OrboCore

final class HoraeStage1Tests: XCTestCase {
    func testHoraeOutputPreservesCanonicalCelestialCoordinatesAndTerra() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_451_545.0))

        let celestial = try OrboSpineContract.canonicalBodies.enumerated().map { index, body in
            let directionalDegree = try XCTUnwrap(
                OrboSpineDirectionalDegree(Double(index) + 0.25)
            )
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: directionalDegree,
                julianDay: julianDay
            )
        }

        let terra = try XCTUnwrap(
            TerraMarrowSample(
                turnDegrees: 280.46061837,
                tiltDegrees: 23.4392911,
                julianDay: julianDay
            )
        )

        let output = HoraeOutput(
            julianDay: julianDay,
            celestial: celestial,
            terra: terra
        )

        XCTAssertEqual(output.julianDay, julianDay)
        XCTAssertEqual(output.celestial, celestial)
        XCTAssertEqual(output.celestial.map(\.body), OrboSpineContract.canonicalBodies)
        XCTAssertEqual(output.terra, terra)
    }

    func testHoraeOutputDoesNotFlattenDirectionalDegreeOrTerraPrecision() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_460_000.123456789))
        let directionalDegree = try XCTUnwrap(OrboSpineDirectionalDegree(379.987654321))
        let coordinate = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: directionalDegree,
            julianDay: julianDay
        )
        let terra = try XCTUnwrap(
            TerraMarrowSample(
                turnDegrees: 359.999876543,
                tiltDegrees: 23.43654321,
                julianDay: julianDay
            )
        )

        let output = HoraeOutput(
            julianDay: julianDay,
            celestial: [coordinate],
            terra: terra
        )

        XCTAssertEqual(output.celestial[0].directionalDegree, directionalDegree)
        XCTAssertEqual(output.celestial[0].directionalDegree.motion, .retrograde)
        XCTAssertEqual(output.celestial[0].directionalDegree.physicalDegrees, 19.987654321, accuracy: 1e-12)
        XCTAssertEqual(output.terra.turnDegrees, terra.turnDegrees)
        XCTAssertEqual(output.terra.tiltDegrees, terra.tiltDegrees)
    }
}
