public struct NatalSpineHoraePosition: Hashable, Sendable {
    public let julianDay: JulianDay
    public let addresses: [NatalSpineAddress]

    public init(julianDay: JulianDay, addresses: [NatalSpineAddress]) {
        self.julianDay = julianDay
        self.addresses = addresses
    }
}

public extension Horae {
    /// ACT III Beat 2. Horae traverse the finished Natal Spine by asking the
    /// already-forged candidate for its existing UT addresses. They add no
    /// chronology and perform no astrological calculation.
    static func locateNatalSpine(
        _ spine: SealedNatalSpine,
        at julianDay: JulianDay
    ) throws -> NatalSpineHoraePosition {
        let addresses = try MundaneBody.canonicalOrder.map { body in
            try spine.candidate.address(of: body, at: julianDay)
        }
        return NatalSpineHoraePosition(
            julianDay: julianDay,
            addresses: addresses
        )
    }

    /// Celestial time -> every UT occurrence already forged for one body/state.
    static func locateNatalSpine(
        _ spine: SealedNatalSpine,
        body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [NatalSpineAddress] {
        try spine.candidate.addresses(of: body, at: directionalDegree)
    }

    /// Mounted-artifact UT traversal. This path reads only the finished Natal
    /// Spine and performs no forge or parent-Timespine fallback.
    static func locateNatalSpine(
        _ spine: NatalSpineRuntime,
        at julianDay: JulianDay
    ) throws -> [NatalSpineRuntimeAddress] {
        try MundaneBody.canonicalOrder.map {
            try spine.address(of: $0, at: julianDay)
        }
    }

    static func locateNatalSpine(
        _ spine: NatalSpineRuntime,
        body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [NatalSpineRuntimeAddress] {
        try spine.addresses(of: body, at: directionalDegree)
    }
}
