/// Static Lots pages admitted to Hecate's Kleides by the approved Pass 2 catalogue.
///
/// Catalogue data only. These helpers assemble typed page and formula metadata.
/// No Lot arithmetic is implemented here.
public enum LotsKleidesCatalogue {
    static func resources(_ names: [String]) -> [HecateResourceKey] {
        names.map { HecateResourceKey(rawValue: $0)! }
    }

    static func formula(
        _ requirements: [String],
        _ expression: String,
        _ tradition: String,
        _ sectRule: KleisSectRule,
        condition: String? = nil,
        source: String,
        status: KleisFormulaStatus
    ) -> KleisFormula {
        KleisFormula(
            requiredResources: resources(requirements),
            formula: expression,
            tradition: tradition,
            sectRule: sectRule,
            conditions: condition.map { [$0] } ?? [],
            isOrboDefault: false,
            sources: [source],
            status: status
        )!
    }

    static func page(
        _ id: String,
        aliases: [String] = [],
        context: KleisContext,
        l1: Bool,
        l2: Bool,
        formulas: [KleisFormula]
    ) -> Kleis {
        Kleis(
            id: KleisID(rawValue: id)!,
            aliases: aliases,
            family: .lots,
            context: context,
            availability: KleisAvailability(l1: l1, l2: l2, l3: true)!,
            formulas: formulas
        )!
    }

    public static let declarations: [Kleis] =
        natalA + natalB + natalC + natalD +
        annualConjunction +
        mundaneWeather +
        agricultural +
        horary
}
