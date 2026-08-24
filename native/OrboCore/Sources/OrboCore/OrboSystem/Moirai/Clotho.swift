public enum ClothoFailure: Error, Hashable, Sendable {
    case unresolvedTopos
    case astroDNAAlreadyResolved
    case missingNatalGene(AstroDNAGene)
    case invalidAstroDNA
}

/// The single Timespine doorway Clotho uses for natal work.
///
/// A natal tap is one operation with two consequences: the delivered Topos is
/// planted into the native Spine and the twelve natal node states are exposed
/// to Clotho. Port I does not construct AstroDNA.
public protocol ClothoPortI {
    mutating func natalTap(
        subjectID: HermesSubjectID,
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        topos: Topos
    ) throws -> [AstroDNAGene: RingFineState]
}

public struct ClothoOutput: Hashable, Sendable {
    public let engraving: Engraving
    public let pattern: Pattern
    public let threads: AstroDNA

    fileprivate init(
        engraving: Engraving,
        pattern: Pattern,
        threads: AstroDNA
    ) {
        self.engraving = engraving
        self.pattern = pattern
        self.threads = threads
    }
}

/// Clotho receives the commission, selects its Pattern, makes one natal tap at
/// Timespine Port I, spins the exposed node states into AstroDNA, and returns
/// Pattern + Threads for Lachesis.
public enum Clotho {
    public static func spin<Port: ClothoPortI>(
        _ engraving: Engraving,
        through portI: inout Port
    ) throws -> ClothoOutput {
        guard let topos = engraving.topos else {
            throw ClothoFailure.unresolvedTopos
        }
        guard engraving.astroDNA == nil else {
            throw ClothoFailure.astroDNAAlreadyResolved
        }

        let nodeStates = try portI.natalTap(
            subjectID: engraving.subjectID,
            birthDate: engraving.birthDate,
            birthTime: engraving.birthTime,
            topos: topos
        )

        let sequence = try AstroDNAGene.canonicalOrder.map { gene -> RingFineState in
            guard let state = nodeStates[gene] else {
                throw ClothoFailure.missingNatalGene(gene)
            }
            return state
        }

        guard let astroDNA = AstroDNA(sequence: sequence) else {
            throw ClothoFailure.invalidAstroDNA
        }

        let resolvedEngraving = engraving.resolving(astroDNA: astroDNA)

        return ClothoOutput(
            engraving: resolvedEngraving,
            pattern: .engraving,
            threads: astroDNA
        )
    }
}
