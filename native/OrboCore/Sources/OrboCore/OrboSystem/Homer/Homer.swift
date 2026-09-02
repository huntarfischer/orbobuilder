/// Homer is Orbo's point-of-view carrier.
///
/// Homer does not discover entities, manufacture their state, or interpret
/// their truth. `POV` accepts one entity-authored HomerPort snapshot and carries
/// that same typed value outward through the standard IrisPort.
public enum Homer {
    public static func POV<PointOfView: Hashable & Sendable>(
        _ port: HomerPort<PointOfView>
    ) -> IrisPort<PointOfView> {
        IrisPort(signal: port.pointOfView)
    }
}
