/// A deliberately temporary integration proof that sends one AstroDNA strand
/// through the four keepers and their frozen foundational laws without changing
/// Clotho, Lachesis, or any law implementation.
///
/// This is not the Titan's Pass. AstroDNA stands in for already-cast chart
/// matter only so Orbo can observe the keeper-routed
/// Themis → Rhea → Oceanus → Asteria transit before Lachesis is rebuilt.
public enum TitanTransitProbe {
    public struct Result: Sendable {
        public let astroDNA: AstroDNA
        public let themis: ThemisPass
        public let rhea: RheaPass
        public let oceanus: OceanusPass
        public let asteria: AsteriaPass

        // Archaeological aliases preserve the original proof surface while the
        // keeper testimonies become explicit.
        public var tympan: Tympan.Imprint { themis.imprint }
        public var mater: Mater.QualifiedField { rhea.field }
        public var ring: [RingObjectTemplate] { oceanus.objectTemplates }
        public var arcSubjects: [ArcSubject] { asteria.refractions.map(\.subject) }
        public var arcCasts: [ArcSubjectCast] { asteria.refractions }
        public var arcGrids: [ArcGrid] { asteria.projections }

        internal init(
            astroDNA: AstroDNA,
            themis: ThemisPass,
            rhea: RheaPass,
            oceanus: OceanusPass,
            asteria: AsteriaPass
        ) {
            self.astroDNA = astroDNA
            self.themis = themis
            self.rhea = rhea
            self.oceanus = oceanus
            self.asteria = asteria
        }
    }

    public static func run(_ astroDNA: AstroDNA) -> Result {
        // THEMIS keeps TYMPAN: the encoded Ascendant selects the frozen Imprint.
        let ascendant = astroDNA.longitude(of: .ascendant)
        let themis = Themis.testify(ascendant.sign)

        // RHEA keeps MATER: bear the exact ten-planet field already present in AstroDNA.
        // AstroDNA alone does not carry sect, so this proof intentionally supplies nil.
        let planetaryLongitudes = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, astroDNA.longitude(of: gene(for: planet)))
            }
        )
        let rhea = Rhea.testify(planetaryLongitudes, sect: nil)

        // OCEANUS keeps RING: preserve the exact object templates for all twelve genes.
        let oceanus = Oceanus.testify(astroDNA)

        // ASTERIA keeps ARC: copy only lawful coordinate-bearing matter. That means
        // the twelve original AstroDNA coordinates plus Oceanus/Ring exact targets.
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

        return Result(
            astroDNA: astroDNA,
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
