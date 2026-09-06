/// Compatibility name for the bounded celestial matter Hephaestus receives after Moirai.
/// The matter itself is now cut upstream by Clotho as NatalSpineThreads.
public typealias NatalSpineCelestialSubstrate = NatalSpineThreads

/// Compatibility name retained for existing forge-layer callers.
public typealias NatalSpineSubstrateFailure = NatalSpineThreadsFailure

public extension Hephaestus {
    /// Transitional caller retained only until Act II moves the bounded Threads through Moirai.
    /// The gathering law itself now belongs exclusively to Clotho.
    static func forgeNatalSpineSubstrate<Source: NatalSpineTimespineSource>(
        for commission: NatalSpineForgeCommission,
        from source: Source
    ) throws -> NatalSpineCelestialSubstrate {
        try Clotho.gatherNatalSpineThreads(
            subjectID: commission.subjectID,
            bounds: commission.schematics.bounds,
            from: source
        )
    }
}
