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
            bodySizeMode: .equal,
            trackOrder: .timespine,
            trackExpansion: 0.0
        )
        let perspective = IrisChart3DPresentation(
            azimuthDegrees: 65,
            inclinationDegrees: 28,
            cameraProjection: .perspective,
            bodySizeMode: .planetSized,
            trackOrder: .astroDNA,
            trackExpansion: 1.0
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

    func testAstroDNAOrderReservesAscendantThenFollowsNativeSequence() {
        XCTAssertEqual(
            IrisTrackExpression.astroDNALanes,
            [
                .reservedAscendant,
                .body(.moon),
                .body(.sun),
                .body(.mercury),
                .body(.venus),
                .body(.mars),
                .body(.jupiter),
                .body(.saturn),
                .body(.uranus),
                .body(.neptune),
                .body(.pluto),
                .body(.trueNorthNode),
            ]
        )
        XCTAssertEqual(IrisTrackExpression.laneIndex(for: .moon, order: .astroDNA), 1)
        XCTAssertEqual(IrisTrackExpression.laneIndex(for: .sun, order: .astroDNA), 2)
        XCTAssertEqual(IrisTrackExpression.laneIndex(for: .trueNorthNode, order: .astroDNA), 11)
    }

    func testTimespineOrderExactlyMatchesCanonicalBodyOrder() {
        XCTAssertEqual(
            IrisTrackExpression.timespineLanes,
            MundaneBody.canonicalOrder.map(IrisTrackLane.body)
        )

        for (index, body) in MundaneBody.canonicalOrder.enumerated() {
            XCTAssertEqual(
                IrisTrackExpression.laneIndex(for: body, order: .timespine),
                index
            )
        }
    }

    func testUnifiedTrackExpansionUsesOneCommonRadiusForEveryBody() {
        for order in [IrisTrackOrder.astroDNA, .timespine] {
            for body in MundaneBody.canonicalOrder {
                XCTAssertEqual(
                    IrisTrackExpression.radius(for: body, order: order, expansion: 0.0),
                    IrisTrackExpression.commonRadius,
                    accuracy: 0.000_001
                )
            }
        }
    }

    func testExpandedAstroDNATracksFollowNativeSequence() {
        let bodyOrder: [MundaneBody] = [
            .moon, .sun, .mercury, .venus, .mars, .jupiter,
            .saturn, .uranus, .neptune, .pluto, .trueNorthNode,
        ]
        let radii = bodyOrder.map {
            IrisTrackExpression.radius(for: $0, order: .astroDNA, expansion: 1.0)
        }

        for pair in zip(radii, radii.dropFirst()) {
            XCTAssertLessThan(pair.0, pair.1)
        }
        XCTAssertEqual(radii.first!, 0.74, accuracy: 0.000_001)
        XCTAssertEqual(radii.last!, 1.64, accuracy: 0.000_001)
    }

    func testTrackExpansionInterpolatesWithoutChangingSourceTruth() throws {
        let source = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(
                OrboSpineDirectionalDegree(physicalDegrees: 42.0, motion: .direct)
            ),
            julianDay: try XCTUnwrap(JulianDay(2_461_020.5))
        )
        let scene = IrisScene3D(coordinates: [source])
        let point = try XCTUnwrap(scene.points.first)

        let unified = IrisTrackExpression.placement(
            for: point,
            order: .astroDNA,
            expansion: 0.0
        )
        let halfway = IrisTrackExpression.placement(
            for: point,
            order: .astroDNA,
            expansion: 0.5
        )
        let expanded = IrisTrackExpression.placement(
            for: point,
            order: .astroDNA,
            expansion: 1.0
        )

        XCTAssertEqual(unified.radius, 1.0, accuracy: 0.000_001)
        XCTAssertEqual(halfway.radius, 0.96, accuracy: 0.000_001)
        XCTAssertEqual(expanded.radius, 0.92, accuracy: 0.000_001)

        for placement in [unified, halfway, expanded] {
            XCTAssertEqual(placement.source, point)
            XCTAssertEqual(placement.z, point.z, accuracy: 0.000_001)
            XCTAssertEqual(placement.x / placement.radius, point.x, accuracy: 0.000_001)
            XCTAssertEqual(placement.y / placement.radius, point.y, accuracy: 0.000_001)
        }

        XCTAssertEqual(scene.coordinates, [source])
        XCTAssertEqual(scene.points, [point])
    }

    func testTrackExpansionClampsAndAstroDNAExpandedTracksAreDefault() {
        XCTAssertEqual(
            IrisTrackExpression.radius(for: .mercury, order: .astroDNA, expansion: -1.0),
            1.0,
            accuracy: 0.000_001
        )
        XCTAssertEqual(
            IrisTrackExpression.radius(for: .mercury, order: .astroDNA, expansion: 2.0),
            0.92,
            accuracy: 0.000_001
        )

        let presentation = IrisChart3DPresentation()
        XCTAssertEqual(presentation.trackOrder, .astroDNA)
        XCTAssertEqual(presentation.trackExpansion, 1.0, accuracy: 0.000_001)
    }
}
