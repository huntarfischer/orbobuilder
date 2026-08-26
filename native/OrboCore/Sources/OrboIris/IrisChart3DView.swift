import SwiftUI
import Charts

@available(iOS 26.0, macOS 26.0, *)
public struct IrisChart3DView: View {
    public let scene: IrisScene3D
    public let plane: IrisHoraePlane?
    public let presentation: IrisChart3DPresentation

    @State private var pose: Chart3DPose

    public init(
        scene: IrisScene3D,
        plane: IrisHoraePlane? = nil,
        presentation: IrisChart3DPresentation = IrisChart3DPresentation()
    ) {
        self.scene = scene
        self.plane = plane
        self.presentation = presentation
        _pose = State(
            initialValue: Chart3DPose(
                azimuth: .degrees(presentation.azimuthDegrees),
                inclination: .degrees(presentation.inclinationDegrees)
            )
        )
    }

    public var body: some View {
        Chart3D {
            planeSurfaceContent
            zodiacRimContent
            tractContent
            activeBodyContent
        }
        .chart3DPose($pose)
        .chart3DCameraProjection(
            presentation.cameraProjection == .perspective ? .perspective : .orthographic
        )
        .chartXScale(domain: -chartExtent...chartExtent)
        .chartYScale(domain: -chartExtent...chartExtent)
    }

    @Chart3DContentBuilder
    private var planeSurfaceContent: some Chart3DContent {
        if let plane {
            RectangleMark(
                x: .value("Horae Plane X", -planeSurfaceExtent..<planeSurfaceExtent),
                y: .value("Horae Plane Y", -planeSurfaceExtent..<planeSurfaceExtent),
                z: .value("Selected Julian Day", plane.julianDay.value)
            )
            .foregroundStyle(Color.secondary.opacity(0.08))
        }
    }

    @Chart3DContentBuilder
    private var zodiacRimContent: some Chart3DContent {
        if let plane {
            ForEach(plane.rimPoints(radius: planeRimRadius), id: \.self) { rimPoint in
                PointMark(
                    x: .value("Zodiac Rim X", rimPoint.x),
                    y: .value("Zodiac Rim Y", rimPoint.y),
                    z: .value("Selected Julian Day", rimPoint.z)
                )
                .symbol(.sphere)
                .symbolSize(0.012)
                .foregroundStyle(IrisZodiacPalette.color(for: rimPoint.appearance))
            }
        }
    }

    @Chart3DContentBuilder
    private var tractContent: some Chart3DContent {
        ForEach(scene.points, id: \.self) { point in
            bodyMark(for: point, active: false)
        }
    }

    @Chart3DContentBuilder
    private var activeBodyContent: some Chart3DContent {
        if let plane {
            ForEach(plane.bodyPoints, id: \.self) { point in
                bodyMark(for: point, active: true)
            }
        }
    }

    @Chart3DContentBuilder
    private func bodyMark(
        for point: IrisScenePoint3D,
        active: Bool
    ) -> some Chart3DContent {
        let bodyAppearance = IrisBodyExpression.appearance(
            for: point.source.body,
            sizeMode: presentation.bodySizeMode
        )
        let trackPlacement = IrisTrackExpression.placement(
            for: point,
            order: presentation.trackOrder,
            expansion: presentation.trackExpansion
        )
        let renderedZ = temporalZ(for: point, fallback: trackPlacement.z)
        let symbolSize = bodyAppearance.symbolSize * (active ? 1.45 : 1.0)
        let xLabel = active ? "Active X" : "X"
        let yLabel = active ? "Active Y" : "Y"
        let zLabel = active ? "Selected Julian Day" : "Julian Day"

        if bodyAppearance.form == .sphere {
            PointMark(
                x: .value(xLabel, trackPlacement.x),
                y: .value(yLabel, trackPlacement.y),
                z: .value(zLabel, renderedZ)
            )
            .symbol(.sphere)
            .symbolSize(CGFloat(symbolSize))
            .foregroundStyle(zodiacColor(for: point))
        } else {
            PointMark(
                x: .value(xLabel, trackPlacement.x),
                y: .value(yLabel, trackPlacement.y),
                z: .value(zLabel, renderedZ)
            )
            .symbolSize(CGFloat(symbolSize))
            .foregroundStyle(zodiacColor(for: point))
        }
    }

    private var maximumTrackRadius: Double {
        IrisTrackExpression.maximumRadius(
            order: presentation.trackOrder,
            expansion: presentation.trackExpansion
        )
    }

    private var planeRimRadius: Double {
        maximumTrackRadius + 0.14
    }

    private var planeSurfaceExtent: Double {
        planeRimRadius + 0.06
    }

    private var chartExtent: Double {
        let extent = plane == nil ? maximumTrackRadius : planeSurfaceExtent
        return extent * 1.05
    }

    private func temporalZ(
        for point: IrisScenePoint3D,
        fallback: Double
    ) -> Double {
        guard let plane else { return fallback }
        return IrisTemporalExpression.renderZ(
            for: point,
            activeJulianDay: plane.julianDay,
            expansion: presentation.timeExpansion
        )
    }

    private func zodiacColor(for point: IrisScenePoint3D) -> Color {
        let placement = IrisZodiacPlacement(source: point.source)
        return IrisZodiacPalette.color(for: placement.appearance)
    }
}
