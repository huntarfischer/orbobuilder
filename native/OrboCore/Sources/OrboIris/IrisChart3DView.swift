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
            if let plane {
                RectangleMark(
                    x: .value("Horae Plane X", -planeSurfaceExtent...planeSurfaceExtent),
                    y: .value("Horae Plane Y", -planeSurfaceExtent...planeSurfaceExtent),
                    z: .value("Selected Julian Day", plane.julianDay.value)
                )
                .foregroundStyle(Color.secondary)
                .opacity(0.08)

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

            ForEach(scene.points, id: \.self) { point in
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

            if let plane {
                ForEach(plane.bodyPoints, id: \.self) { point in
                    let bodyAppearance = IrisBodyExpression.appearance(
                        for: point.source.body,
                        sizeMode: presentation.bodySizeMode
                    )
                    let trackPlacement = IrisTrackExpression.placement(
                        for: point,
                        order: presentation.trackOrder,
                        expansion: presentation.trackExpansion
                    )
                    let activeSize = bodyAppearance.symbolSize * 1.45

                    if bodyAppearance.form == .sphere {
                        PointMark(
                            x: .value("Active X", trackPlacement.x),
                            y: .value("Active Y", trackPlacement.y),
                            z: .value("Selected Julian Day", trackPlacement.z)
                        )
                        .symbol(.sphere)
                        .symbolSize(CGFloat(activeSize))
                        .foregroundStyle(zodiacColor(for: point))
                    } else {
                        PointMark(
                            x: .value("Active X", trackPlacement.x),
                            y: .value("Active Y", trackPlacement.y),
                            z: .value("Selected Julian Day", trackPlacement.z)
                        )
                        .symbolSize(CGFloat(activeSize))
                        .foregroundStyle(zodiacColor(for: point))
                    }
                }
            }
        }
        .chart3DPose($pose)
        .chart3DCameraProjection(
            presentation.cameraProjection == .perspective ? .perspective : .orthographic
        )
        .chartXScale(domain: -chartExtent...chartExtent)
        .chartYScale(domain: -chartExtent...chartExtent)
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

    private func zodiacColor(for point: IrisScenePoint3D) -> Color {
        let placement = IrisZodiacPlacement(source: point.source)
        return IrisZodiacPalette.color(for: placement.appearance)
    }
}
