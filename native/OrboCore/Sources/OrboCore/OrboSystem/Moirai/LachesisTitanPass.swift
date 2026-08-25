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

public extension Lachesis {
    /// Conducts the Titan's Pass over one already-cast AstroDNA.
    ///
    /// Lachesis petitions each keeper and gathers the resulting testimonies.
    /// She does not set, bear, encircle, refract, reinterpret, or merge their
    /// truths. Asteria receives only lawful coordinate-bearing matter.
    static func petition(
        _ astroDNA: AstroDNA,
        sect: Sect?
    ) -> LachesisTitanPass {
        let ascendant = astroDNA.longitude(of: .ascendant)
        let themis = Themis.testify(ascendant.sign)

        let planetaryLongitudes = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, astroDNA.longitude(of: gene(for: planet)))
            }
        )
        let rhea = Rhea.testify(planetaryLongitudes, sect: sect)

        let oceanus = Oceanus.testify(astroDNA)

        var arcSubjects = AstroDNAGene.canonicalOrder.map { gene in
            ArcSubject(
                identity: gene.displayName,
                provenance: "AstroDNA",
                coordinate: ArcCoordinate(astroDNA[gene].arcsecond)!
            )
        }

        for object in oceanus.objectTemplates {
            for mark in object.marks {
                arcSubjects.append(
                    ArcSubject(
                        identity: "\(object.gene.displayName):\(mark.mark.rawValue):\(mark.targetArcsecond)",
                        provenance: "Ring",
                        coordinate: ArcCoordinate(mark.targetArcsecond)!
                    )
                )
            }
        }

        let asteria = Asteria.testify(arcSubjects)

        return LachesisTitanPass(
            themis: themis,
            rhea: rhea,
            oceanus: oceanus,
            asteria: asteria
        )
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
