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
        public let tympan: Tympan.Imprint
        public let mater: Mater.QualifiedField
        public let ring: [RingObjectTemplate]
        public let arcSubjects: [ArcSubject]
        public let arcCasts: [ArcSubjectCast]
        public let arcGrids: [ArcGrid]

        internal init(
            astroDNA: AstroDNA,
            tympan: Tympan.Imprint,
            mater: Mater.QualifiedField,
            ring: [RingObjectTemplate],
            arcSubjects: [ArcSubject],
            arcCasts: [ArcSubjectCast],
            arcGrids: [ArcGrid]
        ) {
            self.astroDNA = astroDNA
            self.tympan = tympan
            self.mater = mater
            self.ring = ring
            self.arcSubjects = arcSubjects
            self.arcCasts = arcCasts
            self.arcGrids = arcGrids
        }
    }

    public static func run(_ astroDNA: AstroDNA) -> Result {
        // THEMIS keeps TYMPAN: the encoded Ascendant selects the frozen Imprint.
        let ascendant = astroDNA.longitude(of: .ascendant)
        let tympan = Themis.set(ascendant.sign)

        // RHEA keeps MATER: bear the exact ten-planet field already present in AstroDNA.
        // AstroDNA alone does not carry sect, so this proof intentionally supplies nil.
        let planetaryLongitudes = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, astroDNA.longitude(of: gene(for: planet)))
            }
        )
        let mater = Rhea.bear(planetaryLongitudes, sect: nil)

        // OCEANUS keeps RING: preserve the exact object templates for all twelve genes.
        let ring = AstroDNAGene.canonicalOrder.map { gene in
            Oceanus.encircle(gene, in: astroDNA)
        }

        // ASTERIA keeps ARC: copy only lawful coordinate-bearing matter. That means
        // the twelve original AstroDNA coordinates plus Oceanus/Ring exact targets.
        var arcSubjects = AstroDNAGene.canonicalOrder.map { gene in
            ArcSubject(
                identity: gene.displayName,
                provenance: "AstroDNA",
                coordinate: ArcCoordinate(astroDNA[gene].arcsecond)!
            )
        }

        for object in ring {
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

        let arcCasts = Asteria.refract(arcSubjects)
        let arcGrids = arcCasts.map { Asteria.project($0.field) }

        return Result(
            astroDNA: astroDNA,
            tympan: tympan,
            mater: mater,
            ring: ring,
            arcSubjects: arcSubjects,
            arcCasts: arcCasts,
            arcGrids: arcGrids
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
