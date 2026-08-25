/// Which wall of the finite OrboSpine Bone one exact celestial anchor closes.
public enum OrboSpineBoundaryAnchorKind: String, Codable, Hashable, Sendable {
    case start
    case endExclusive = "end-exclusive"
}

/// One exact forged celestial state at a commissioned Bone boundary.
/// Boundary anchors are neither degree-lattice supports nor stations.
public struct OrboSpineBoundaryAnchor: Hashable, Sendable {
    public let body: MundaneBody
    public let boundary: OrboSpineBoundaryAnchorKind
    public let julianDay: JulianDay
    public let directionalDegree: OrboSpineDirectionalDegree

    public init?(
        body: MundaneBody,
        boundary: OrboSpineBoundaryAnchorKind,
        julianDay: JulianDay,
        physicalDegrees: Double,
        motion: Motion
    ) {
        guard let directionalDegree = OrboSpineDirectionalDegree(
            physicalDegrees: physicalDegrees,
            motion: motion
        ) else { return nil }

        self.body = body
        self.boundary = boundary
        self.julianDay = julianDay
        self.directionalDegree = directionalDegree
    }

    public var physicalDegrees: Double { directionalDegree.physicalDegrees }
    public var motion: Motion { directionalDegree.motion }
    public var navigationCell: Int { directionalDegree.navigationCell }
}
