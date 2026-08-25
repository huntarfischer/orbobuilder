/// Keeper of Ring.
///
/// Oceanus does not reimplement angular relation. He is the authoritative
/// entrance to the frozen Ring law.
public enum Oceanus {
    public static func encircle(degree: Int) -> RingTemplate? {
        Ring.template(forDegree: degree)
    }

    public static func encircle(
        _ gene: AstroDNAGene,
        in dna: AstroDNA
    ) -> RingObjectTemplate {
        Ring.objectTemplate(for: gene, in: dna)
    }
}
