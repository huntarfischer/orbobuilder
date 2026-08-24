/// A deliberately temporary integration proof that sends one AstroDNA strand
/// through the four frozen foundational laws without changing Clotho, Lachesis,
/// or any Titan implementation.
///
/// This is not the Titan's Pass. AstroDNA stands in for already-cast chart
/// matter only so Orbo can observe the existing Tympan → Mater → Ring → Arc
/// surfaces together before the Titans are personified or Lachesis is rebuilt.
public enum TitanTransitProbe {
    public struct Result: Sendable {
        public let astroDNA: AstroDNA
        public let tympan: Tympan.Imprint
        public let mater: Mater.QualifiedField
        public let ring: [RingObjectTemplate]
        public let arcSubjects: [ArcSubject]
        public let arcCasts: [ArcSubjectCast]

        internal init(
            astroDNA: AstroDNA,
            tympan: Tympan.Imprint,
            mater: Mater.QualifiedField,
            ring: [RingObjectTemplate],
            arcSubjects: [ArcSubject],
            arcCasts: [ArcSubjectCast]
        ) {
            self.astroDNA = astroDNA
            self.tympan = tympan
            self.mater = mater
            self.ring = ring
            self.arcSubjects = arcSubjects
            self.arcCasts = arcCasts
        }
    }

    public static func run(_ astroDNA: AstroDNA) -> Result {
        // TYMPAN: the encoded Ascendant selects the already-frozen whole-sign Imprint.
        let ascendant = astroDNA.longitude(of: .ascendant)
        let tympan = Tympan.imprint(for: ascendant.sign)

        // MATER: qualify the exact ten-planet field already present in AstroDNA.
        // AstroDNA alone does not carry sect, so this proof intentionally supplies nil.
        let planetaryLongitudes = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, astroDNA.longitude(of: gene(for: planet)))
            }
        )
        let mater = Mater.qualifyField(planetaryLongitudes, sect: nil)

        // RING: preserve the existing exact object templates for all twelve genes.
        let ring = AstroDNAGene.canonicalOrder.map { gene in
            Ring.objectTemplate(for: gene, in: astroDNA)
        }

        // ARC: copy only lawful coordinate-bearing matter. In this first proof that
        // means the twelve original AstroDNA coordinates plus Ring's exact targets.
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

        let arcCasts = Arc.cast(arcSubjects)

        return Result(
            astroDNA: astroDNA,
            tympan: tympan,
            mater: mater,
            ring: ring,
            arcSubjects: arcSubjects,
            arcCasts: arcCasts
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
