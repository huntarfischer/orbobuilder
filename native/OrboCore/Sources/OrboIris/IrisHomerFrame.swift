import OrboCore

/// Iris's read-only view of one point-of-view snapshot carried by Homer.
///
/// Iris preserves the exact entity-authored value that crossed Homer's Iris
/// port. Entity-specific manifestation may build from this frame later, but
/// this generic seam performs no domain work or type erasure.
public struct IrisHomerFrame<PointOfView: Hashable & Sendable>: Hashable, Sendable {
    public let pointOfView: PointOfView

    public init(port: IrisPort<PointOfView>) {
        self.pointOfView = port.signal
    }
}
