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
            cameraProjection: .orthographic,
            bodySizeMode: .equal
        )
        let perspective = IrisChart3DPresentation(
            azimuthDegrees: 65,
            inclinationDegrees: 28,
            cameraProjection: .perspective,
            bodySizeMode: .planetSized
        )

        XCTAssertNotEqual(orthographic, perspective)
        XCTAssertEqual(scene.coordinates, originalCoordinates)
        XCTAssertEqual(scene.points, originalPoints)
        XCTAssertEqual(scene.coordinates, [source])
    }

    func testBodyExpressionUsesSpheresForPhysicalBodiesAndPointForNode() {
        for body in MundaneBody.canonicalOrder {
            let appearance = IrisBodyExpression.appearance(
                for: body,
                sizeMode: .planetSized
            )

            if body == .trueNorthNode {
                XCTAssertEqual(appearance.form, .point)
            } else {
                XCTAssertEqual(appearance.form, .sphere)
            }
        }
    }

    func testEqualBodySizeModeUsesOnePhysicalSizeAndLeavesNodeFixed() {
        let physicalBodies = MundaneBody.canonicalOrder.filter { $0 != .trueNorthNode }
        let physicalSizes = Set(physicalBodies.map {
            IrisBodyExpression.appearance(for: $0, sizeMode: .equal).symbolSize
        })

        XCTAssertEqual(physicalSizes, [IrisBodyExpression.equalPhysicalSymbolSize])

        let equalNode = IrisBodyExpression.appearance(
            for: .trueNorthNode,
            sizeMode: .equal
        )
        let planetSizedNode = IrisBodyExpression.appearance(
            for: .trueNorthNode,
            sizeMode: .planetSized
        )

        XCTAssertEqual(equalNode, planetSizedNode)
        XCTAssertEqual(equalNode.form, .point)
        XCTAssertEqual(equalNode.symbolSize, IrisBodyExpression.nodeSymbolSize)
    }

    func testPlanetSizedBodyHierarchyIsDeterministic() {
        let expected: [(MundaneBody, Double)] = [
            (.sun, 0.075),
            (.moon, 0.034),
            (.mercury, 0.036),
            (.venus, 0.043),
            (.mars, 0.039),
            (.jupiter, 0.065),
            (.saturn, 0.060),
            (.uranus, 0.052),
            (.neptune, 0.050),
            (.pluto, 0.030),
        ]

        for (body, symbolSize) in expected {
            let appearance = IrisBodyExpression.appearance(
                for: body,
                sizeMode: .planetSized
            )
            XCTAssertEqual(appearance.form, .sphere)
            XCTAssertEqual(appearance.symbolSize, symbolSize, accuracy: 0.000_001)
        }
    }

    func testBodySizeModeIsPresentationOnly() throws {
        let source = OrboSpineCelestialCoordinate(
            body: .jupiter,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 133.25, motion: .direct)
            ),
            julianDay: try XCTUnwrap(JulianDay(2_461_010.25))
        )
        let scene = IrisScene3D(coordinates: [source])
        let originalPoint = try XCTUnwrap(scene.points.first)

        let equal = IrisBodyExpression.appearance(for: source.body, sizeMode: .equal)
        let planetSized = IrisBodyExpression.appearance(for: source.body, sizeMode: .planetSized)

        XCTAssertNotEqual(equal.symbolSize, planetSized.symbolSize)
        XCTAssertEqual(scene.coordinates, [source])
        XCTAssertEqual(scene.points, [originalPoint])
        XCTAssertEqual(originalPoint.source, source)
    }

    func testPlanetSizedModeIsDefaultPresentation() {
        XCTAssertEqual(IrisChart3DPresentation().bodySizeMode, .planetSized)
    }
}
