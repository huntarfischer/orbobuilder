/// The role one coordinate plays during a Horae control action.
public enum HoraeCoordinateRole: String, Hashable, Sendable {
    case driven
    case pinned
    case resolved
}

/// Direction through the ordered UT occurrence set for one pinned body/state pair.
public enum HoraeOccurrenceDirection: String, Hashable, Sendable {
    case previous
    case next
}

/// Presentation-neutral displacement along the UT Bone.
///
/// The consumer chooses how an interaction produces this offset. Horae only
/// apply the requested temporal displacement; this type carries no playback or
/// planetary-rate semantics.
public struct HoraeUTOffset: Hashable, Sendable {
    public let seconds: Double

    public init?(seconds: Double) {
        guard seconds.isFinite else { return nil }
        self.seconds = seconds
    }

    public init?(minutes: Double) {
        self.init(seconds: minutes * 60)
    }

    public init?(hours: Double) {
        self.init(seconds: hours * 3_600)
    }

    public init?(days: Double) {
        self.init(seconds: days * 86_400)
    }

    var julianDays: Double {
        seconds / 86_400
    }
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
    case constraintUnsatisfied(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        julianDay: JulianDay
    )
    case noOccurrenceInDirection(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        from: JulianDay,
        direction: HoraeOccurrenceDirection
    )
}

/// Presentation-neutral control intent accepted by Horae.
///
/// Iris may produce these intents from any visual or gestural form. The intent
/// describes only which already-proven Horae control path the user is asking to
/// move through. It contains no rendering or gesture semantics.
public enum HoraeControlIntent: Hashable, Sendable {
    case seekUT(
        to: JulianDay
    )
    case shiftUT(
        from: JulianDay,
        by: HoraeUTOffset
    )
    case driveUT(
        to: JulianDay,
        body: MundaneBody
    )
    case driveConstrainedUT(
        to: JulianDay,
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree
    )
    case driveDirectionalDegree(
        to: OrboSpineDirectionalDegree,
        body: MundaneBody,
        from: JulianDay
    )
    case driveBody(
        to: MundaneBody,
        at: JulianDay
    )
    case driveBodyAtDegree(
        to: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        from: JulianDay
    )
    case driveConstrainedBody(
        to: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        at: JulianDay
    )
    case navigateOccurrence(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        from: JulianDay,
        direction: HoraeOccurrenceDirection
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
