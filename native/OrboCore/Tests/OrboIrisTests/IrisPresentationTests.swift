import XCTest
import OrboCore
@testable import OrboIris

final class IrisPresentationTests: XCTestCase {
    func testPresentationChoicesDoNotAlterSceneTruth() throws {
        let source = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 19.372, motion: .retrograde)
            ),
            julianDay: try XCTUnwrap(JulianDay(2_461_000.5))
        )
        let scene = IrisScene3D(coordinates: [source])
        let originalCoordinates = scene.coordinates
        let originalPoints = scene.points

        let orthographic = IrisChart3DPresentation(
            azimuthDegrees: 20,
            inclinationDegrees: 7,
            cameraProjection: .orthographic
        )
        let perspective = IrisChart3DPresentation(
            azimuthDegrees: 65,
            inclinationDegrees: 28,
            cameraProjection: .perspective
        )

        XCTAssertNotEqual(orthographic, perspective)
        XCTAssertEqual(scene.coordinates, originalCoordinates)
        XCTAssertEqual(scene.points, originalPoints)
        XCTAssertEqual(scene.coordinates, [source])
    }
}
