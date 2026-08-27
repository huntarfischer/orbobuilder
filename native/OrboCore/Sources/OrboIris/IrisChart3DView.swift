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

        let initialPose: Chart3DPose
        switch presentation.cameraMode {
        case .free3D:
            initialPose = Chart3DPose(
                azimuth: .degrees(presentation.azimuthDegrees),
                inclination: .degrees(presentation.inclinationDegrees)
            )
        case .celestialFace:
            // The Horae plane is X/Y at fixed temporal Z, so front is the
            // framework pose that looks straight along the Timespine Z axis.
            initialPose = .front
        }
        _pose = State(initialValue: initialPose)
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
        .chartZScale(domain: chartZDomain)
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
                let oriented = IrisOrientationExpression.placement(
                    x: rimPoint.x,
                    y: rimPoint.y,
                    mode: presentation.orientationMode
                )
                PointMark(
                    x: .value("Zodiac Rim X", oriented.x),
                    y: .value("Zodiac Rim Y", oriented.y),
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
        // A celestial Astrolabe face is the active Horae plane itself, not the
        // history of every sampled tract painted onto that plane.
        if !presentation.isCelestialAstrolabeFace {
            ForEach(scene.points, id: \.self) { point in
                bodyMark(for: point, active: false)
            }
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
        let oriented = IrisOrientationExpression.placement(
            x: trackPlacement.x,
            y: trackPlacement.y,
            mode: presentation.orientationMode
        )
        let renderedZ = temporalZ(for: point, fallback: trackPlacement.z)
        let symbolSize = bodyAppearance.symbolSize * (active ? 1.45 : 1.0)
        let xLabel = active ? "Active X" : "X"
        let yLabel = active ? "Active Y" : "Y"
        let zLabel = active ? "Selected Julian Day" : "Julian Day"

        if bodyAppearance.form == .sphere {
            PointMark(
                x: .value(xLabel, oriented.x),
                y: .value(yLabel, oriented.y),
                z: .value(zLabel, renderedZ)
            )
            .symbol(.sphere)
            .symbolSize(CGFloat(symbolSize))
            .foregroundStyle(zodiacColor(for: point))
        } else {
            PointMark(
                x: .value(xLabel, oriented.x),
                y: .value(yLabel, oriented.y),
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

    /// Chart3D needs a non-zero domain in every dimension. Once IX9 hides the
    /// sampled tracts, every remaining mark is at one exact Julian Day. Give
    /// that flat face a tiny presentation-only Z window so the renderer does
    /// not collapse its own plot volume. No source UT is changed.
    private var chartZDomain: ClosedRange<Double> {
        if presentation.isCelestialAstrolabeFace, let plane {
            return (plane.julianDay.value - 0.5)...(plane.julianDay.value + 0.5)
        }

        let values = scene.points.map(\.z)
        guard let minimum = values.min(), let maximum = values.max() else {
            let anchor = plane?.julianDay.value ?? 0.0
            return (anchor - 0.5)...(anchor + 0.5)
        }
        guard minimum < maximum else {
            return (minimum - 0.5)...(maximum + 0.5)
        }
        return minimum...maximum
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
