/// Orbo's universal one-way socket from an entity to Homer.
///
/// The source entity owns the point-of-view snapshot. Homer may carry that
/// snapshot onward, but the port performs no domain work, presentation, or
/// reverse control.
public struct HomerPort<PointOfView: Hashable & Sendable>: Hashable, Sendable {
    public let pointOfView: PointOfView

    public init(pointOfView: PointOfView) {
        self.pointOfView = pointOfView
    }
}
