import XCTest
import OrboCore
@testable import OrboIris

final class IrisScene3DTests: XCTestCase {
    func testScenePreservesCanonicalCoordinatesExactly() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_461_000.5))
        let coordinates = [
            OrboSpineCelestialCoordinate(
                body: .sun,
                directionalDegree: try XCTUnwrap(
                    OrboSpineDirectionalDegree(physicalDegrees: 21.25, motion: .direct)
                ),
                julianDay: julianDay
            ),
            OrboSpineCelestialCoordinate(
                body: .mercury,
                directionalDegree: try XCTUnwrap(
                    OrboSpineDirectionalDegree(physicalDegrees: 8.5, motion: .retrograde)
                ),
                julianDay: julianDay
            ),
        ]

        let scene = IrisScene3D(coordinates: coordinates)

        XCTAssertEqual(scene.coordinates, coordinates)
        XCTAssertEqual(IrisScene3D(coordinates: coordinates), scene)
    }

    func testScenePreservesDirectionalDistinctionAtSamePhysicalDegree() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_461_000.5))
        let direct = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 19.372, motion: .direct)
            ),
            julianDay: julianDay
        )
        let retrograde = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 19.372, motion: .retrograde)
            ),
            julianDay: julianDay
        )

        let scene = IrisScene3D(coordinates: [direct, retrograde])

        XCTAssertEqual(scene.coordinates, [direct, retrograde])
        XCTAssertNotEqual(scene.coordinates[0].directionalDegree, scene.coordinates[1].directionalDegree)
        XCTAssertEqual(
            scene.coordinates[0].directionalDegree.physicalDegrees,
            scene.coordinates[1].directionalDegree.physicalDegrees,
            accuracy: 1e-12
        )
    }

    func testScenePreservesRepeatedLongitudeAtDifferentTimes() throws {
        let firstTime = try XCTUnwrap(JulianDay(2_461_000.5))
        let secondTime = try XCTUnwrap(JulianDay(2_461_001.5))
        let degree = try XCTUnwrap(
            OrboSpineDirectionalDegree(physicalDegrees: 120.0, motion: .direct)
        )
        let first = OrboSpineCelestialCoordinate(
            body: .jupiter,
            directionalDegree: degree,
            julianDay: firstTime
        )
        let second = OrboSpineCelestialCoordinate(
            body: .jupiter,
            directionalDegree: degree,
            julianDay: secondTime
        )

        let scene = IrisScene3D(coordinates: [first, second])

        XCTAssertEqual(scene.coordinates, [first, second])
        XCTAssertNotEqual(scene.coordinates[0], scene.coordinates[1])
    }
}
