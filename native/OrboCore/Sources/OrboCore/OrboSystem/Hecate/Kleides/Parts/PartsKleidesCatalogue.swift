import Foundation

public enum PartNatalDivision: String, CaseIterable, Codable, Hashable, Sendable {
    case planetary
    case house
    case miscellaneous
}

public struct PartFormulaEntry: Hashable, Codable, Sendable {
    public enum SourceSectMark: String, CaseIterable, Codable, Hashable, Sendable {
        case same = "S"
        case reverse = "R"
        case unmarked = "unmarked"
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
public enum PartsKleidesCatalogue {
    static let sourceCitation = "Al-Biruni, Book of Instruction vv.476-479; R. Ramsay Wright translation (1934); Deborah Houlding compilation"

    static func sourceFormula(
        _ requirements: [String],
        day: String,
        night: String,
        mark: PartFormulaEntry.SourceSectMark,
        tradition: String = "al-Biruni / Abu Ma'shar",
        conditions: [String] = [],
        status: KleisFormulaStatus = .complete
    ) -> PartFormulaEntry {
        var required = requirements
        if mark == .reverse, status != .unresolved, !required.contains("Sect") {
            required.append("Sect")
        }

        let sectRule: KleisSectRule
        switch mark {
        case .same:
            sectRule = .same
        case .reverse:
            sectRule = .reverse
        case .unmarked:
            sectRule = .none
        }

        let storedFormula = status == .unresolved ? "source formula unresolved" : day

        let formula = KleisFormula(
            requiredResources: required.map { HecateResourceKey(rawValue: $0)! },
            formula: storedFormula,
            tradition: tradition,
            sectRule: sectRule,
            conditions: conditions,
            isOrboDefault: false,
            sources: [sourceCitation],
            status: status
        )!

        return PartFormulaEntry(
            kleisFormula: formula,
            dayCalculation: day,
            nightCalculation: night,
            sourceSectMark: mark
        )!
    }

    static func natalPage(
        _ id: String,
        sourceLabel: String,
        division: PartNatalDivision,
        houseCategory: Int? = nil,
        sourceOccurrenceCount: Int = 1,
        formulas: [PartFormulaEntry]
    ) -> PartCatalogueEntry {
        PartCatalogueEntry(
            id: KleisID(rawValue: id)!,
            sourceLabel: sourceLabel,
            context: .natal,
            natalDivision: division,
            houseCategory: houseCategory,
            sourceOccurrenceCount: sourceOccurrenceCount,
            formulas: formulas
        )!
    }

    static func natalHouse(
        _ house: Int,
        _ slug: String,
        _ sourceLabel: String,
        _ requirements: [String],
        _ day: String,
        _ night: String,
        _ mark: PartFormulaEntry.SourceSectMark,
        tradition: String = "al-Biruni / Abu Ma'shar",
        status: KleisFormulaStatus = .complete,
        sourceOccurrenceCount: Int = 1
    ) -> PartCatalogueEntry {
        let houseID = house < 10 ? "0\(house)" : "\(house)"
        return natalPage(
            "parts.natal.house\(houseID).\(slug)",
            sourceLabel: sourceLabel,
            division: .house,
            houseCategory: house,
            sourceOccurrenceCount: sourceOccurrenceCount,
            formulas: [
                sourceFormula(
                    requirements,
                    day: day,
                    night: night,
                    mark: mark,
                    tradition: tradition,
                    status: status
                ),
            ]
        )
    }

    static func nonNatalPage(
        _ id: String,
        sourceLabel: String,
        context: KleisContext,
        formulas: [PartFormulaEntry]
    ) -> PartCatalogueEntry {
        PartCatalogueEntry(
            id: KleisID(rawValue: id)!,
            sourceLabel: sourceLabel,
            context: context,
            formulas: formulas
        )!
    }

    public static let entries: [PartCatalogueEntry] =
        natalPlanetary +
        natalHouses01To06 +
        natalHouses07To12 +
        natalMiscellaneous +
        annualConjunction +
        mundaneWeather +
        agricultural +
        horary

    public static func declarations(from entries: [PartCatalogueEntry]) -> [Kleis] {
        entries.map(\.kleis)
    }

    public static let declarations: [Kleis] = declarations(from: entries)
}
