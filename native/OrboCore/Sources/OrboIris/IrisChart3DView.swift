import SwiftUI
import Charts

@available(iOS 26.0, macOS 26.0, *)
public struct IrisChart3DView: View {
    public let scene: IrisScene3D
    public let presentation: IrisChart3DPresentation

    @State private var pose: Chart3DPose

    public init(
        scene: IrisScene3D,
        presentation: IrisChart3DPresentation = IrisChart3DPresentation()
    ) {
        self.scene = scene
        self.presentation = presentation
        _pose = State(
            initialValue: Chart3DPose(
                azimuth: .degrees(presentation.azimuthDegrees),
                inclination: .degrees(presentation.inclinationDegrees)
            )
        )
    }

    public var body: some View {
        Chart3D(scene.points, id: \.self) { point in
            let bodyAppearance = IrisBodyExpression.appearance(
                for: point.source.body,
                sizeMode: presentation.bodySizeMode
            )
            let trackPlacement = IrisTrackExpression.placement(
                for: point,
                order: presentation.trackOrder,
                expansion: presentation.trackExpansion
            )

            if bodyAppearance.form == .sphere {
                PointMark(
                    x: .value("X", trackPlacement.x),
                    y: .value("Y", trackPlacement.y),
                    z: .value("Julian Day", trackPlacement.z)
                )
                .symbol(.sphere)
                .symbolSize(CGFloat(bodyAppearance.symbolSize))
                .foregroundStyle(zodiacColor(for: point))
            } else {
                PointMark(
                    x: .value("X", trackPlacement.x),
                    y: .value("Y", trackPlacement.y),
                    z: .value("Julian Day", trackPlacement.z)
                )
                .symbolSize(CGFloat(bodyAppearance.symbolSize))
                .foregroundStyle(zodiacColor(for: point))
            }
        }
        .chart3DPose($pose)
        .chart3DCameraProjection(
            presentation.cameraProjection == .perspective ? .perspective : .orthographic
        )
        .chartXScale(domain: -chartExtent...chartExtent)
        .chartYScale(domain: -chartExtent...chartExtent)
    }

    private var chartExtent: Double {
        IrisTrackExpression.maximumRadius(
            order: presentation.trackOrder,
            expansion: presentation.trackExpansion
        ) * 1.05
    }

    private func zodiacColor(for point: IrisScenePoint3D) -> Color {
        let placement = IrisZodiacPlacement(source: point.source)
        return IrisZodiacPalette.color(for: placement.appearance)
    }
}
