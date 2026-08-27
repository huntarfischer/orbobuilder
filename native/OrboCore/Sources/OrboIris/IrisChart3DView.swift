import SwiftUI
import Charts
import OrboCore

@available(iOS 26.0, macOS 26.0, *)
public struct IrisChart3DView: View {
    public let scene: IrisScene3D
    public let plane: IrisHoraePlane?
    public let focusedBody: MundaneBody?
    public let presentation: IrisChart3DPresentation

    public init(
        scene: IrisScene3D,
        plane: IrisHoraePlane? = nil,
        focusedBody: MundaneBody? = nil,
        presentation: IrisChart3DPresentation = IrisChart3DPresentation()
    ) {
        self.scene = scene
        self.plane = plane
        self.focusedBody = focusedBody
        self.presentation = presentation
    }

    public var body: some View {
        Chart3D {
            planeSurfaceContent
            zodiacRimContent
            temporalSampleContent
            activeBodyContent
        }
        // Chart3D makes a bound pose user-rotatable by default. Iris supplies a
        // read-only binding instead: our three canonical views may change only
        // when Iris changes cameraMode, never because the user tumbles the chart.
        .chart3DPose(lockedPoseBinding)
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
    private var temporalSampleContent: some Chart3DContent {
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
        let oriented = IrisOrientationExpression.placement(
            x: trackPlacement.x,
            y: trackPlacement.y,
            mode: presentation.orientationMode
        )
        let renderedZ = temporalZ(for: point, fallback: trackPlacement.z)
        let isFocused = active && point.source.body == focusedBody
        let symbolScale = isFocused ? 2.1 : (active ? 1.45 : 1.0)
        let symbolSize = bodyAppearance.symbolSize * symbolScale
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

    /// Orbo's temporal coordinate is Chart3D Z.
    ///
    /// - topDown looks straight along Z, so the temporal depth projects into the
    ///   zodiacal X/Y face.
    /// - vertical looks down Chart3D Y, exposing X/Z with time upright.
    /// - horizontal looks down Chart3D X, exposing Z/Y with time sideways.
    private var lockedPose: Chart3DPose {
        switch presentation.cameraMode {
        case .topDown:
            return .front
        case .vertical:
            return .top
        case .horizontal:
            return Chart3DPose(
                azimuth: .degrees(90),
                inclination: .degrees(0)
            )
        }
    }

    /// Ignore Chart3D's interaction writes. The getter still changes when Iris
    /// switches among the three canonical camera modes.
    private var lockedPoseBinding: Binding<Chart3DPose> {
        Binding(
            get: { lockedPose },
            set: { _ in }
        )
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

    private var chartZDomain: ClosedRange<Double> {
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
