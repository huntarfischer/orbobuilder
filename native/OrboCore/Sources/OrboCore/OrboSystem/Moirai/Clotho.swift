public enum ClothoFailure: Error, Hashable, Sendable {
    case unresolvedTopos
    case astroDNAAlreadyResolved
    case missingNatalGene(AstroDNAGene)
    case invalidAstroDNA
}

/// Door One is the single OrboSpine doorway Clotho uses for natal work.
///
/// Clotho supplies birth date, birth time, and Topos. The query returns the
/// twelve natal node states derived from the OrboSpine, including Terra's
/// contribution. Door One does not construct AstroDNA.
public protocol ClothoPortI {
    mutating func queryNatalState(
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        topos: Topos
    ) throws -> [AstroDNAGene: RingFineState]
}

public struct ClothoOutput: Hashable, Sendable {
    public let engraving: Engraving
    public let packet: PatternPacket

    fileprivate init(
        engraving: Engraving,
        packet: PatternPacket
    ) {
        self.engraving = engraving
        self.packet = packet
    }
}

/// Clotho receives the commission, queries Door One with birth date, birth time,
/// and Topos, gathers the returned natal states, asks Hecate to cast AstroDNA,
/// resolves the Engraving, and hands Pattern + AstroDNA forward for Lachesis.
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

        let nodeStates = try portI.queryNatalState(
            birthDate: engraving.birthDate,
            birthTime: engraving.birthTime,
            topos: topos
        )

        for gene in AstroDNAGene.canonicalOrder where nodeStates[gene] == nil {
            throw ClothoFailure.missingNatalGene(gene)
        }

        let astroDNA: AstroDNA
        do {
            astroDNA = try Hecate.castAstroDNA(using: nodeStates)
        } catch {
            throw ClothoFailure.invalidAstroDNA
        }

        let resolvedEngraving = engraving.resolving(astroDNA: astroDNA)
        let packet = PatternPacket(
            pattern: .engraving,
            astroDNA: astroDNA
        )

        return ClothoOutput(
            engraving: resolvedEngraving,
            packet: packet
        )
    }
}
