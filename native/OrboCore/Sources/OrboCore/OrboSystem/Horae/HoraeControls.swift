/// The role one coordinate plays during a Horae control action.
public enum HoraeCoordinateRole: String, Hashable, Sendable {
    case driven
    case pinned
    case resolved
}

/// A control gesture could not resolve one real OrboSpine address.
public enum HoraeControlError: Error, Equatable {
    case noOccurrence(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree
    )
    case ambiguousOccurrence(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree
    )
}

/// One presentation-neutral address on the OrboSpine.
///
/// Body, directional degree, and UT are three grips on one valid Spine point,
/// not three independent sources of truth.
public struct HoraeAddress: Hashable, Sendable {
    public let body: MundaneBody
    public let directionalDegree: OrboSpineDirectionalDegree
    public let julianDay: JulianDay

    public init(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        julianDay: JulianDay
    ) {
        self.body = body
        self.directionalDegree = directionalDegree
        self.julianDay = julianDay
    }
}

/// Neutral control/readout metadata carried inside the single Horae signal.
///
/// Exactly one coordinate is driven during one control action. The other two
/// coordinates may be pinned or resolved. This type describes control state;
/// later stages own the behavior that changes a Spine address.
public struct HoraeControlState: Hashable, Sendable {
    public let address: HoraeAddress
    public let bodyRole: HoraeCoordinateRole
    public let directionalDegreeRole: HoraeCoordinateRole
    public let julianDayRole: HoraeCoordinateRole

    public init?(
        address: HoraeAddress,
        bodyRole: HoraeCoordinateRole,
        directionalDegreeRole: HoraeCoordinateRole,
        julianDayRole: HoraeCoordinateRole
    ) {
        let roles = [bodyRole, directionalDegreeRole, julianDayRole]
        guard roles.filter({ $0 == .driven }).count == 1 else {
            return nil
        }

        self.address = address
        self.bodyRole = bodyRole
        self.directionalDegreeRole = directionalDegreeRole
        self.julianDayRole = julianDayRole
    }
}
