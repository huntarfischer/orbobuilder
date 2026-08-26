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
            let appearance = IrisBodyExpression.appearance(
                for: point.source.body,
                sizeMode: presentation.bodySizeMode
            )

            if appearance.form == .sphere {
                PointMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y),
                    z: .value("Julian Day", point.z)
                )
                .symbol(.sphere)
                .symbolSize(CGFloat(appearance.symbolSize))
                .foregroundStyle(zodiacColor(for: point))
            } else {
                PointMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y),
                    z: .value("Julian Day", point.z)
                )
                .symbolSize(CGFloat(appearance.symbolSize))
                .foregroundStyle(zodiacColor(for: point))
            }
        }
        .chart3DPose($pose)
        .chart3DCameraProjection(
            presentation.cameraProjection == .perspective ? .perspective : .orthographic
        )
        .chartXScale(domain: -1.05...1.05)
        .chartYScale(domain: -1.05...1.05)
    }

    private func zodiacColor(for point: IrisScenePoint3D) -> Color {
        let placement = IrisZodiacPlacement(source: point.source)
        return IrisZodiacPalette.color(for: placement.appearance)
    }
}
