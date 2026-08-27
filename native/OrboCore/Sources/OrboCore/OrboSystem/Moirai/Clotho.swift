public enum ClothoFailure: Error, Hashable, Sendable {
    case unresolvedTopos
}

/// Clotho receives the Atlas-resolved Engraving and asks Chronos to resolve its
/// civil birth moment. Chronos remains the temporal authority; Clotho preserves
/// the answer exactly and performs no timezone arithmetic, Spine lookup, or
/// natal construction in this stage.
public enum Clotho {
    public static func resolveCivilMoment(
        for engraving: Engraving
    ) throws -> ChronosResolution {
        guard let topos = engraving.topos else {
            throw ClothoFailure.unresolvedTopos
        }

        return Chronos.resolveCivilMoment(
            date: engraving.birthDate,
            time: engraving.birthTime,
            in: topos.place.timezone
        )
    }
}
