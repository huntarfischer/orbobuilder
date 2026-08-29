public enum PartNatalDivision: String, CaseIterable, Codable, Hashable, Sendable {
    case planetary
    case house
    case miscellaneous
}

public struct PartFormulaEntry: Hashable, Codable, Sendable {
    public enum SourceSectMark: String, CaseIterable, Codable, Hashable, Sendable {
        case same = "S"
        case reverse = "R"
    }

    public let kleisFormula: KleisFormula
    public let dayCalculation: String
    public let nightCalculation: String
    public let sourceSectMark: SourceSectMark

    public init?(
        kleisFormula: KleisFormula,
        dayCalculation: String,
        nightCalculation: String,
        sourceSectMark: SourceSectMark
    ) {
        let cleanedDay = dayCalculation.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedNight = nightCalculation.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedDay.isEmpty, !cleanedNight.isEmpty else { return nil }

        self.kleisFormula = kleisFormula
        self.dayCalculation = cleanedDay
        self.nightCalculation = cleanedNight
        self.sourceSectMark = sourceSectMark
    }
}

public struct PartCatalogueEntry: Hashable, Codable, Sendable {
    public let kleis: Kleis
    public let sourceLabel: String
    public let natalDivision: PartNatalDivision?
    public let houseCategory: Int?
    public let sourceOccurrenceCount: Int
    public let formulas: [PartFormulaEntry]

    public init?(
        id: KleisID,
        aliases: [String] = [],
        sourceLabel: String,
        context: KleisContext,
        natalDivision: PartNatalDivision? = nil,
        houseCategory: Int? = nil,
        sourceOccurrenceCount: Int = 1,
        formulas: [PartFormulaEntry]
    ) {
        let cleanedSourceLabel = sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedSourceLabel.isEmpty,
              sourceOccurrenceCount > 0,
              !formulas.isEmpty,
              formulas.allSatisfy({ !$0.kleisFormula.isOrboDefault }) else {
            return nil
        }

        switch context {
        case .natal:
            guard let natalDivision else { return nil }

            switch natalDivision {
            case .house:
                guard let houseCategory, (1...12).contains(houseCategory) else { return nil }
            case .planetary, .miscellaneous:
                guard houseCategory == nil else { return nil }
            }

        case .annualConjunction, .mundaneWeather, .agricultural, .horary:
            guard natalDivision == nil, houseCategory == nil else { return nil }
        }

        let kleisFormulas = formulas.map(\.kleisFormula)
        guard let kleis = Kleis(
            id: id,
            aliases: aliases,
            family: .parts,
            context: context,
            availability: KleisAvailability(l1: false, l2: false, l3: true)!,
            formulas: kleisFormulas
        ) else {
            return nil
        }

        self.kleis = kleis
        self.sourceLabel = cleanedSourceLabel
        self.natalDivision = natalDivision
        self.houseCategory = houseCategory
        self.sourceOccurrenceCount = sourceOccurrenceCount
        self.formulas = formulas
    }
}

/// Static Part pages prepared for Hecate's existing `.parts` shelf.
///
/// Pass A defines machinery only. No historical Part corpus is admitted here yet,
/// and these declarations are intentionally not registered in `Kleides.canonical`.
public enum PartsKleidesCatalogue {
    public static let entries: [PartCatalogueEntry] = []

    public static func declarations(from entries: [PartCatalogueEntry]) -> [Kleis] {
        entries.map(\.kleis)
    }

    public static let declarations: [Kleis] = declarations(from: entries)
}
