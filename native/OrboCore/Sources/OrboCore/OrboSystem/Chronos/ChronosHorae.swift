/// Stage 2 Chronos seam to Horae occurrence availability.
///
/// Chronos asks Horae for every lawful UT at which one exact body/state exists.
/// The occurrence set is preserved as the answer. Chronos never receives Locate,
/// never moves Horae to one occurrence, and never requests a HoraeOutput.
public extension Chronos {
    static func resolveBodyState(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        using horae: Horae
    ) throws -> ChronosResolution {
        let fact = ChronosFactIdentity.bodyState(
            body: body,
            directionalDegree: directionalDegree
        )
        let source = ChronosSourceReference(rawValue: "horae-occurrence")!
        let occurrences = try horae.occurrenceUTs(
            of: body,
            at: directionalDegree
        )

        return .resolved(
            ChronosAnswer(
                hits: occurrences.map { julianDay in
                    ChronosHit(
                        address: .moment(julianDay),
                        fact: fact,
                        source: source
                    )
                }
            )
        )
    }
}
