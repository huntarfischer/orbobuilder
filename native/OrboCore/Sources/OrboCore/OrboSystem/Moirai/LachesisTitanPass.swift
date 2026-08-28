/// The four immutable testimonies gathered by Lachesis during the Titan's Pass.
///
/// Lachesis owns their collection, not their contents. Each testimony remains
/// the authoritative witness of its keeper and frozen foundational law.
public struct LachesisTitanPass: Sendable {
    public let themis: ThemisPass
    public let rhea: RheaPass
    public let oceanus: OceanusPass
    public let asteria: AsteriaPass

    internal init(
        themis: ThemisPass,
        rhea: RheaPass,
        oceanus: OceanusPass,
        asteria: AsteriaPass
    ) {
        self.themis = themis
        self.rhea = rhea
        self.oceanus = oceanus
        self.asteria = asteria
    }
}

/// The canonical Lachesis intake result.
///
/// Lachesis preserves Clotho's complete sister-to-sister packet while gathering
/// four independent Titan testimonies from the authoritative matter it contains.
public struct LachesisOutput: Sendable {
    public let packet: PatternPacket
    public let titanPass: LachesisTitanPass

    internal init(
        packet: PatternPacket,
        titanPass: LachesisTitanPass
    ) {
        self.packet = packet
        self.titanPass = titanPass
    }
}

public extension Lachesis {
    /// Receives Clotho's complete PatternPacket without altering its contents.
    static func receive(_ packet: PatternPacket) -> LachesisOutput {
        LachesisOutput(
            packet: packet,
            titanPass: petition(packet)
        )
    }

    /// Conducts the canonical Titan's Pass from one complete PatternPacket.
    ///
    /// The audiences are synchronous and deliberately ordered:
    /// Themis returns before Rhea is petitioned; Rhea returns before Oceanus;
    /// Oceanus returns before Asteria. The order is Lachesis's meter only.
    /// No Titan testimony is ever supplied to another Titan.
    static func petition(_ packet: PatternPacket) -> LachesisTitanPass {
        conductTitanPass(
            astroDNA: packet.astroDNA,
            sect: packet.sect,
            asteriaSubjects: asteriaSubjects(from: packet)
        )
    }

    /// Compatibility petition for callers that possess only AstroDNA and Sect.
    ///
    /// It preserves the same independent, synchronous Titan order but can
    /// present only AstroDNA coordinates to Asteria because no Hecate Lots were
    /// supplied. Canonical Clotho intake uses `petition(_ packet:)` above.
    static func petition(
        _ astroDNA: AstroDNA,
        sect: Sect?
    ) -> LachesisTitanPass {
        conductTitanPass(
            astroDNA: astroDNA,
            sect: sect,
            asteriaSubjects: astroDNASubjects(from: astroDNA)
        )
    }

    private static func conductTitanPass(
        astroDNA: AstroDNA,
        sect: Sect?,
        asteriaSubjects: [ArcSubject]
    ) -> LachesisTitanPass {
        // First audience: Themis must return before Lachesis proceeds.
        let ascendant = astroDNA.longitude(of: .ascendant)
        let themis = Themis.testify(ascendant.sign)

        // Second audience: Rhea receives only planetary matter and Sect.
        let planetaryLongitudes = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, astroDNA.longitude(of: gene(for: planet)))
            }
        )
        let rhea = Rhea.testify(planetaryLongitudes, sect: sect)

        // Third audience: Oceanus receives AstroDNA only.
        let oceanus = Oceanus.testify(astroDNA)

        // Fourth audience: Asteria receives source coordinates directly from
        // Lachesis, never Oceanus's Ring testimony.
        let asteria = Asteria.testify(asteriaSubjects)

        return LachesisTitanPass(
            themis: themis,
            rhea: rhea,
            oceanus: oceanus,
            asteria: asteria
        )
    }

    private static func asteriaSubjects(from packet: PatternPacket) -> [ArcSubject] {
        var subjects = astroDNASubjects(from: packet.astroDNA)
        subjects.append(
            ArcSubject(
                identity: "Fortune",
                provenance: "Hecate",
                coordinate: arcCoordinate(for: packet.fortune)
            )
        )
        subjects.append(
            ArcSubject(
                identity: "Spirit",
                provenance: "Hecate",
                coordinate: arcCoordinate(for: packet.spirit)
            )
        )
        subjects.append(
            ArcSubject(
                identity: "Eros",
                provenance: "Hecate",
                coordinate: arcCoordinate(for: packet.eros)
            )
        )
        subjects.append(
            ArcSubject(
                identity: "Necessity",
                provenance: "Hecate",
                coordinate: arcCoordinate(for: packet.necessity)
            )
        )
        return subjects
    }

    private static func astroDNASubjects(from astroDNA: AstroDNA) -> [ArcSubject] {
        AstroDNAGene.canonicalOrder.map { gene in
            ArcSubject(
                identity: gene.displayName,
                provenance: "AstroDNA",
                coordinate: ArcCoordinate(astroDNA[gene].arcsecond)!
            )
        }
    }

    private static func arcCoordinate(for longitude: CelestialLongitude) -> ArcCoordinate {
        let arcsecond = Int(
            (longitude.degrees * Double(Arc.arcsecondsPerDegree)).rounded(.down)
        )
        return ArcCoordinate(arcsecond)!
    }

    private static func gene(for planet: Planet) -> AstroDNAGene {
        switch planet {
        case .sun: return .sun
        case .moon: return .moon
        case .mercury: return .mercury
        case .venus: return .venus
        case .mars: return .mars
        case .jupiter: return .jupiter
        case .saturn: return .saturn
        case .uranus: return .uranus
        case .neptune: return .neptune
        case .pluto: return .pluto
        }
    }
}
