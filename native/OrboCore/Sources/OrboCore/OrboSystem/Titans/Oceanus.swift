/// Immutable testimony returned by Oceanus.
public struct OceanusPass: Sendable {
    public let objectTemplates: [RingObjectTemplate]

    internal init(objectTemplates: [RingObjectTemplate]) {
        self.objectTemplates = objectTemplates
    }
}

/// Keeper of Ring and Oceanus's whole-degree water-table geometry.
///
/// Oceanus does not reimplement Ring angular relation. He remains the
/// authoritative entrance to frozen Ring law while separately exposing the
/// approved ASC/Sun geometric water table.
public enum Oceanus {
    /// Reads the existing Ring measurement for two supplied coordinates.
    public static func separation(from a: CelestialLongitude, to b: CelestialLongitude) -> RingSeparation {
        Ring.separation(from: a, to: b)
    }

    public static func encircle(degree: Int) -> RingTemplate? {
        Ring.template(forDegree: degree)
    }

    public static func encircle(
        _ gene: AstroDNAGene,
        in dna: AstroDNA
    ) -> RingObjectTemplate {
        Ring.objectTemplate(for: gene, in: dna)
    }

    public static func testify(_ dna: AstroDNA) -> OceanusPass {
        OceanusPass(
            objectTemplates: AstroDNAGene.canonicalOrder.map { gene in
                encircle(gene, in: dna)
            }
        )
    }

    /// Reads the frozen whole-degree ASC/Sun geometry table.
    ///
    /// The table contains only ABOVE / BELOW / TIE geometry. Sect remains
    /// owned by Hecate and is neither stored nor derived here.
    public static func waterRelation(
        ascendantDegree: Int,
        sunDegree: Int
    ) -> OceanusWaterRelation? {
        OceanusWaterTable.relation(
            ascendantDegree: ascendantDegree,
            sunDegree: sunDegree
        )
    }
}
