import XCTest
import OrboCore
@testable import OrboIris

final class IrisStressTests: XCTestCase {
    func testLargeLawfulSceneRemainsDeterministicAndTraceable() throws {
        let sampleCount = 256
        let baseJulianDay = 2_461_000.5
        let stepDays = 0.125

        var coordinates: [OrboSpineCelestialCoordinate] = []
        coordinates.reserveCapacity(MundaneBody.canonicalOrder.count * sampleCount)

        for sampleIndex in 0..<sampleCount {
            let julianDay = try XCTUnwrap(
                JulianDay(baseJulianDay + (Double(sampleIndex) * stepDays))
            )

            for (bodyIndex, body) in MundaneBody.canonicalOrder.enumerated() {
                let physicalDegrees = (
                    Double(bodyIndex * 29) + (Double(sampleIndex) * 1.375)
                ).truncatingRemainder(dividingBy: 360)
                let motion: Motion = bodyIndex.isMultiple(of: 2) ? .direct : .retrograde
                let directionalDegree = try XCTUnwrap(
                    OrboSpineDirectionalDegree(
                        physicalDegrees: physicalDegrees,
                        motion: motion
                    )
                )

                coordinates.append(
                    OrboSpineCelestialCoordinate(
                        body: body,
                        directionalDegree: directionalDegree,
                        julianDay: julianDay
                    )
                )
            }
        }

        let firstScene = IrisScene3D(coordinates: coordinates)
        let secondScene = IrisScene3D(coordinates: coordinates)
        let firstPoints = firstScene.points
        let secondPoints = secondScene.points

        XCTAssertEqual(coordinates.count, 2_816)
        XCTAssertEqual(firstScene.coordinates, coordinates)
        XCTAssertEqual(secondScene.coordinates, coordinates)
        XCTAssertEqual(firstScene, secondScene)
        XCTAssertEqual(firstPoints, secondPoints)
        XCTAssertEqual(firstPoints.map(\.source), coordinates)

        for point in firstPoints {
            XCTAssertEqual(point.z, point.source.julianDay.value, accuracy: 0)
            XCTAssertEqual((point.x * point.x) + (point.y * point.y), 1, accuracy: 1e-12)
            XCTAssertTrue(point.x.isFinite)
            XCTAssertTrue(point.y.isFinite)
            XCTAssertTrue(point.z.isFinite)
        }
    }
}
