import SwiftUI
import Charts

@available(iOS 26.0, macOS 26.0, *)
public struct IrisChart3DView: View {
    public let scene: IrisScene3D

    public init(scene: IrisScene3D) {
        self.scene = scene
    }

    public var body: some View {
        Chart3D(scene.points, id: \.self) { point in
            PointMark(
                x: .value("X", point.x),
                y: .value("Y", point.y),
                z: .value("Julian Day", point.z)
            )
            .foregroundStyle(by: .value("Body", point.source.body.displayName))
        }
        .chartXScale(domain: -1.05...1.05)
        .chartYScale(domain: -1.05...1.05)
    }
}
