import XCTest
import OrboCore
@testable import OrboIris

final class IrisZodiacExpressionTests: XCTestCase {
    func testCanonicalRimUsesAllTwelveOrboSignsWithoutChangingTheirDegrees() {
        let sectors = IrisZodiacRimSector.canonical
        XCTAssertEqual(sectors.count, 12)
        XCTAssertEqual(sectors.map(\.sign), Sign.canonicalOrder)
        XCTAssertEqual(sectors.first?.startDegrees, 0.0)
        XCTAssertEqual(sectors.first?.endDegrees, 30.0)
        XCTAssertEqual(sectors.last?.startDegrees, 330.0)
        XCTAssertEqual(sectors.last?.endDegrees, 360.0)
        for pair in zip(sectors, sectors.dropFirst()) {
            XCTAssertEqual(pair.0.endDegrees, pair.1.startDegrees)
        }
    }

    func testElementFamiliesKeepThreeRelatedSignShades() {
        XCTAssertEqual(
            Sign.canonicalOrder.map { IrisZodiacAppearance(sign: $0).family },
            [.fire, .earth, .air, .water, .fire, .earth,
             .air, .water, .fire, .earth, .air, .water]
        )
        XCTAssertEqual(IrisZodiacAppearance(sign: .aries).shade, .light)
        XCTAssertEqual(IrisZodiacAppearance(sign: .leo).shade, .middle)
        XCTAssertEqual(IrisZodiacAppearance(sign: .sagittarius).shade, .deep)
        XCTAssertEqual(IrisZodiacAppearance(sign: .taurus).shade, .light)
        XCTAssertEqual(IrisZodiacAppearance(sign: .virgo).shade, .middle)
        XCTAssertEqual(IrisZodiacAppearance(sign: .capricorn).shade, .deep)
    }

    func testMercuryChangesFromLightFireToLightEarthAtThirtyDegrees() throws {
        let ariesSource = coordinate(.mercury, 29.999, .direct)
        let taurusSource = coordinate(.mercury, 30.0, .direct)
        let aries = IrisZodiacPlacement(source: ariesSource)
        let taurus = IrisZodiacPlacement(source: taurusSource)
        XCTAssertEqual(aries.source, ariesSource)
        XCTAssertEqual(taurus.source, taurusSource)
        XCTAssertEqual(aries.longitude, CelestialLongitude(29.999))
        XCTAssertEqual(aries.sign, .aries)
        XCTAssertEqual(aries.appearance.family, .fire)
        XCTAssertEqual(aries.appearance.shade, .light)
        XCTAssertEqual(taurus.longitude, CelestialLongitude(30.0))
        XCTAssertEqual(taurus.sign, .taurus)
        XCTAssertEqual(taurus.degreeInSign.value, 0.0, accuracy: 1e-10)
        XCTAssertEqual(taurus.appearance.family, .earth)
        XCTAssertEqual(taurus.appearance.shade, .light)
    }

    func testPlacementReadoutUsesCanonicalSignDegreeAndMotion() {
        let source = coordinate(.mercury, 29.5, .retrograde)
        let placement = IrisZodiacPlacement(source: source)
        XCTAssertEqual(placement.source, source)
        XCTAssertEqual(placement.displayText, "Mercury 29°30′ Aries ℞")
    }

    func testZodiacalOrientationPlacesCardinalLongitudesAtOrboClockPositions() throws {
        let aries = try orientedPoint(at: 0.0)
        let cancer = try orientedPoint(at: 90.0)
        let libra = try orientedPoint(at: 180.0)
        let capricorn = try orientedPoint(at: 270.0)

        XCTAssertEqual(aries.x, -1.0, accuracy: 0.000_001)
        XCTAssertEqual(aries.y, 0.0, accuracy: 0.000_001)

        XCTAssertEqual(cancer.x, 0.0, accuracy: 0.000_001)
        XCTAssertEqual(cancer.y, -1.0, accuracy: 0.000_001)

        XCTAssertEqual(libra.x, 1.0, accuracy: 0.000_001)
        XCTAssertEqual(libra.y, 0.0, accuracy: 0.000_001)

        XCTAssertEqual(capricorn.x, 0.0, accuracy: 0.000_001)
        XCTAssertEqual(capricorn.y, 1.0, accuracy: 0.000_001)
    }

    func testZodiacalOrientationPreservesCanonicalSourceAndRadius() throws {
        let source = coordinate(.mercury, 42.0, .retrograde)
        let scene = IrisScene3D(coordinates: [source])
        let point = try XCTUnwrap(scene.points.first)
        let oriented = IrisOrientationExpression.placement(
            x: point.x,
            y: point.y,
            mode: .zodiacal
        )

        XCTAssertEqual(point.source, source)
        XCTAssertEqual(IrisZodiacPlacement(source: point.source).longitude, CelestialLongitude(42.0))
        XCTAssertEqual(hypot(oriented.x, oriented.y), hypot(point.x, point.y), accuracy: 0.000_001)
        XCTAssertEqual(oriented.x, -point.x, accuracy: 0.000_001)
        XCTAssertEqual(oriented.y, -point.y, accuracy: 0.000_001)
        XCTAssertEqual(scene.coordinates, [source])
    }

    func testSceneOrientationIsIdentity() throws {
        let source = coordinate(.venus, 123.0, .direct)
        let point = try XCTUnwrap(IrisScene3D(coordinates: [source]).points.first)
        let oriented = IrisOrientationExpression.placement(
            x: point.x,
            y: point.y,
            mode: .scene
        )

        XCTAssertEqual(oriented.x, point.x, accuracy: 0.000_001)
        XCTAssertEqual(oriented.y, point.y, accuracy: 0.000_001)
        XCTAssertEqual(point.source, source)
    }

    func testCelestialAstrolabeFaceRequiresFlatOrthographicZodiacalFaceState() {
        let face = IrisChart3DPresentation(
            cameraProjection: .orthographic,
            cameraMode: .celestialFace,
            orientationMode: .zodiacal,
            timeExpansion: 0.0
        )
        XCTAssertTrue(face.isCelestialAstrolabeFace)

        XCTAssertFalse(IrisChart3DPresentation(
            cameraProjection: .perspective,
            cameraMode: .celestialFace,
            orientationMode: .zodiacal,
            timeExpansion: 0.0
        ).isCelestialAstrolabeFace)

        XCTAssertFalse(IrisChart3DPresentation(
            cameraProjection: .orthographic,
            cameraMode: .free3D,
            orientationMode: .zodiacal,
            timeExpansion: 0.0
        ).isCelestialAstrolabeFace)

        XCTAssertFalse(IrisChart3DPresentation(
            cameraProjection: .orthographic,
            cameraMode: .celestialFace,
            orientationMode: .scene,
            timeExpansion: 0.0
        ).isCelestialAstrolabeFace)

        XCTAssertFalse(IrisChart3DPresentation(
            cameraProjection: .orthographic,
            cameraMode: .celestialFace,
            orientationMode: .zodiacal,
            timeExpansion: 0.1
        ).isCelestialAstrolabeFace)
    }

    private func orientedPoint(at physicalDegrees: Double) throws -> IrisPlanarPlacement {
        let source = coordinate(.sun, physicalDegrees, .direct)
        let point = try XCTUnwrap(IrisScene3D(coordinates: [source]).points.first)
        return IrisOrientationExpression.placement(
            x: point.x,
            y: point.y,
            mode: .zodiacal
        )
    }

    private func coordinate(_ body: MundaneBody, _ physicalDegrees: Double, _ motion: Motion) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(physicalDegrees: physicalDegrees, motion: motion)!,
            julianDay: JulianDay(2_461_000.5)!
        )
    }
}
