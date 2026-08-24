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

    func testProjectionMapsCardinalLongitudesOntoUnitZodiacCircle() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_461_000.5))
        let degrees = [0.0, 90.0, 180.0, 270.0]
        let expected = [
            (x: 1.0, y: 0.0),
            (x: 0.0, y: 1.0),
            (x: -1.0, y: 0.0),
            (x: 0.0, y: -1.0),
        ]

        for (index, physicalDegrees) in degrees.enumerated() {
            let source = OrboSpineCelestialCoordinate(
                body: .sun,
                directionalDegree: try XCTUnwrap(
                    OrboSpineDirectionalDegree(
                        physicalDegrees: physicalDegrees,
                        motion: .direct
                    )
                ),
                julianDay: julianDay
            )
            let point = IrisScenePoint3D(source: source)

            XCTAssertEqual(point.x, expected[index].x, accuracy: 1e-12)
            XCTAssertEqual(point.y, expected[index].y, accuracy: 1e-12)
        }
    }

    func testProjectionUsesJulianDayAsZWithoutNormalization() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_461_234.56789))
        let source = OrboSpineCelestialCoordinate(
            body: .saturn,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 312.25, motion: .direct)
            ),
            julianDay: julianDay
        )

        let point = IrisScenePoint3D(source: source)

        XCTAssertEqual(point.z, julianDay.value, accuracy: 0)
    }

    func testProjectionRetainsCanonicalSourceAndBodyIdentity() throws {
        let julianDay = try XCTUnwrap(JulianDay(2_461_000.5))
        let source = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 19.372, motion: .retrograde)
            ),
            julianDay: julianDay
        )

        let point = IrisScenePoint3D(source: source)

        XCTAssertEqual(point.source, source)
        XCTAssertEqual(point.source.body, .mercury)
        XCTAssertEqual(point.source.directionalDegree.motion, .retrograde)
    }

    func testSceneProjectsOnePointPerCanonicalCoordinateInInputOrder() throws {
        let firstTime = try XCTUnwrap(JulianDay(2_461_000.5))
        let secondTime = try XCTUnwrap(JulianDay(2_461_001.5))
        let first = OrboSpineCelestialCoordinate(
            body: .sun,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 10.0, motion: .direct)
            ),
            julianDay: firstTime
        )
        let second = OrboSpineCelestialCoordinate(
            body: .moon,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 200.0, motion: .direct)
            ),
            julianDay: secondTime
        )

        let scene = IrisScene3D(coordinates: [first, second])

        XCTAssertEqual(scene.points.map(\.source), [first, second])
        XCTAssertEqual(scene.points.count, scene.coordinates.count)
    }

    func testSceneCarriesOneBodyAcrossMultipleSuppliedTimesAsDistinctZPositions() throws {
        let values = [2_461_000.5, 2_461_000.75, 2_461_001.0]
        let degrees = [270.0, 266.0, 262.0]
        let coordinates = try zip(values, degrees).map { julianDayValue, degree in
            OrboSpineCelestialCoordinate(
                body: .jupiter,
                directionalDegree: try XCTUnwrap(
                    OrboSpineDirectionalDegree(physicalDegrees: degree, motion: .retrograde)
                ),
                julianDay: try XCTUnwrap(JulianDay(julianDayValue))
            )
        }

        let scene = IrisScene3D(coordinates: coordinates)

        XCTAssertEqual(scene.points.count, 3)
        XCTAssertEqual(scene.points.map(\.source.body), [.jupiter, .jupiter, .jupiter])
        XCTAssertEqual(scene.points.map(\.z), values)
        XCTAssertEqual(scene.points.map(\.source), coordinates)
    }
}
