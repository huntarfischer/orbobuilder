/// Hecate's Sect spell.
///
/// The kleis does not own a second Sect rule. It casts only by the frozen
/// OrboFormulae Sect law from the Ascendant and Sun placed in Hecate's hands.
public enum SectKleis {
    public static let id = KleisID(rawValue: "Sect")!

    static let ascendantResource = HecateResourceKey(rawValue: "Asc")!
    static let sunResource = HecateResourceKey(rawValue: "Su")!

    public static let formula = KleisFormula(
        requiredResources: [ascendantResource, sunResource],
        formula: "OrboFormulae.sect(ascendant:sun:)",
        tradition: "Orbo",
        sectRule: .none,
        isOrboDefault: false,
        sources: ["Orbo canonical Sect law"],
        status: .complete
    )!

    public static let declaration = Kleis(
        id: id,
        family: .lots,
        context: .natal,
        availability: KleisAvailability(l1: true, l2: true, l3: true)!,
        formulas: [formula]
    )!

    static func cast(
        ascendant: CelestialLongitude,
        sun: CelestialLongitude
    ) -> Sect {
        OrboFormulae.sect(ascendant: ascendant, sun: sun)
    }
}
