import Foundation

/// One formula as Hecate can describe it without casting it.
/// Part formulas additionally retain their documentary day/night faces.
public struct HecateFormulaInquiry: Hashable, Codable, Sendable {
    public let formula: KleisFormula
    public let dayCalculation: String?
    public let nightCalculation: String?
    public let sourceSectMark: PartFormulaEntry.SourceSectMark?

    init(
        formula: KleisFormula,
        dayCalculation: String? = nil,
        nightCalculation: String? = nil,
        sourceSectMark: PartFormulaEntry.SourceSectMark? = nil
    ) {
        self.formula = formula
        self.dayCalculation = dayCalculation
        self.nightCalculation = nightCalculation
        self.sourceSectMark = sourceSectMark
    }
}

/// Hecate's read-only answer about one admitted kleis.
/// Generic Kleis matter is shared by every family; Part-only documentary
/// metadata is present only when the key belongs to the `.parts` shelf.
public struct HecateKleisInquiry: Hashable, Codable, Sendable {
    public let kleis: Kleis
    public let sourceLabel: String?
    public let natalDivision: PartNatalDivision?
    public let houseCategory: Int?
    public let sourceOccurrenceCount: Int?
    public let formulas: [HecateFormulaInquiry]
}

/// One formula-level answer, retaining the identity of the key that owns it.
public struct HecateFormulaInquiryMatch: Hashable, Codable, Sendable {
    public let kleisID: KleisID
    public let family: KleisFamily
    public let context: KleisContext
    public let sourceLabel: String?
    public let formula: HecateFormulaInquiry
}

public extension Hecate {
    /// What does Hecate know about this exact key?
    static func inquire(
        _ kleisID: KleisID,
        from kleides: Kleides = .canonical
    ) -> HecateKleisInquiry? {
        guard let kleis = kleides.kleis(kleisID) else { return nil }
        return inquiry(for: kleis)
    }

    /// What keys match this historical/common name?
    /// Matches stable IDs, aliases, and preserved Part source labels.
    static func inquire(
        named name: String,
        family: KleisFamily? = nil,
        from kleides: Kleides = .canonical
    ) -> [HecateKleisInquiry] {
        let needle = normalized(name)
        guard !needle.isEmpty else { return [] }

        return kleides.all
            .filter { family == nil || $0.family == family }
            .compactMap(inquiry(for:))
            .filter { answer in
                normalized(answer.kleis.id.rawValue) == needle ||
                answer.kleis.aliases.contains(where: { normalized($0) == needle }) ||
                answer.sourceLabel.map { normalized($0) == needle } == true
            }
    }

    /// Which keys live on this family shelf, optionally within one context?
    static func inquire(
        family: KleisFamily,
        context: KleisContext? = nil,
        from kleides: Kleides = .canonical
    ) -> [HecateKleisInquiry] {
        kleides.all
            .filter { $0.family == family && (context == nil || $0.context == context) }
            .compactMap(inquiry(for:))
    }

    /// Which preserved Parts belong to this natal division and/or house shelf?
    static func inquireParts(
        natalDivision: PartNatalDivision? = nil,
        houseCategory: Int? = nil
    ) -> [HecateKleisInquiry] {
        PartsKleidesCatalogue.entries
            .filter { natalDivision == nil || $0.natalDivision == natalDivision }
            .filter { houseCategory == nil || $0.houseCategory == houseCategory }
            .map(inquiry(for:))
    }

    /// Which formula rows require this resource?
    static func inquireFormulas(
        requiring resource: HecateResourceKey,
        family: KleisFamily? = nil,
        from kleides: Kleides = .canonical
    ) -> [HecateFormulaInquiryMatch] {
        formulaMatches(family: family, from: kleides) {
            $0.formula.requiredResources.contains(resource)
        }
    }

    /// Which formula rows carry this source-completeness status?
    static func inquireFormulas(
        status: KleisFormulaStatus,
        family: KleisFamily? = nil,
        from kleides: Kleides = .canonical
    ) -> [HecateFormulaInquiryMatch] {
        formulaMatches(family: family, from: kleides) {
            $0.formula.status == status
        }
    }

    /// Which formula rows carry this structured tradition/attribution?
    /// Matching is case-insensitive and substring-based so callers may ask
    /// for `Hermes`, `Valens`, `Egyptians`, etc. without knowing provenance prose.
    static func inquireFormulas(
        attributedTo attribution: String,
        family: KleisFamily? = nil,
        from kleides: Kleides = .canonical
    ) -> [HecateFormulaInquiryMatch] {
        let needle = normalized(attribution)
        guard !needle.isEmpty else { return [] }

        return formulaMatches(family: family, from: kleides) {
            normalized($0.formula.tradition).contains(needle)
        }
    }

    private static func formulaMatches(
        family: KleisFamily?,
        from kleides: Kleides,
        where predicate: (HecateFormulaInquiry) -> Bool
    ) -> [HecateFormulaInquiryMatch] {
        kleides.all
            .filter { family == nil || $0.family == family }
            .compactMap(inquiry(for:))
            .flatMap { answer in
                answer.formulas
                    .filter(predicate)
                    .map {
                        HecateFormulaInquiryMatch(
                            kleisID: answer.kleis.id,
                            family: answer.kleis.family,
                            context: answer.kleis.context,
                            sourceLabel: answer.sourceLabel,
                            formula: $0
                        )
                    }
            }
    }

    private static func inquiry(for kleis: Kleis) -> HecateKleisInquiry {
        if kleis.family == .parts,
           let part = PartsKleidesCatalogue.entries.first(where: { $0.kleis.id == kleis.id }) {
            return inquiry(for: part)
        }

        return HecateKleisInquiry(
            kleis: kleis,
            sourceLabel: nil,
            natalDivision: nil,
            houseCategory: nil,
            sourceOccurrenceCount: nil,
            formulas: kleis.formulas.map { HecateFormulaInquiry(formula: $0) }
        )
    }

    private static func inquiry(for part: PartCatalogueEntry) -> HecateKleisInquiry {
        HecateKleisInquiry(
            kleis: part.kleis,
            sourceLabel: part.sourceLabel,
            natalDivision: part.natalDivision,
            houseCategory: part.houseCategory,
            sourceOccurrenceCount: part.sourceOccurrenceCount,
            formulas: part.formulas.map {
                HecateFormulaInquiry(
                    formula: $0.kleisFormula,
                    dayCalculation: $0.dayCalculation,
                    nightCalculation: $0.nightCalculation,
                    sourceSectMark: $0.sourceSectMark
                )
            }
        )
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
