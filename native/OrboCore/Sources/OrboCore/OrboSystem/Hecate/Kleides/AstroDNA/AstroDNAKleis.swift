/// Hecate's AstroDNA spell.
///
/// The kleis is defined entirely by the existing AstroDNAGene contract:
/// twelve canonical genes, in canonical order, validated by AstroDNA.
public enum AstroDNAKleis {
    public static let id = KleisID(rawValue: "AstroDNA")!
    public static let requiredGenes = AstroDNAGene.canonicalOrder

    public static func resourceKey(for gene: AstroDNAGene) -> HecateResourceKey {
        HecateResourceKey(rawValue: "AstroDNA.\(gene.rawValue)")!
    }

    public static let declaration = Kleis(
        id: id,
        family: .astroDNA,
        requiredResources: requiredGenes.map(resourceKey(for:))
    )!

    static func cast(
        using suppliedGenes: [AstroDNAGene: RingFineState]
    ) -> AstroDNA? {
        let sequence = requiredGenes.compactMap { suppliedGenes[$0] }
        guard sequence.count == requiredGenes.count else { return nil }
        return AstroDNA(sequence: sequence)
    }
}

public extension Kleides {
    /// Hecate's live spellbook at Stage 1.
    static let canonical = Kleides([
        AstroDNAKleis.declaration,
    ])!
}
