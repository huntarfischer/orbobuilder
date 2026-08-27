import Foundation

/// The first three shelves of Hecate's Kleides.
/// AstroDNA remains independent unless a truer family is established later.
public enum KleisFamily: String, CaseIterable, Codable, Hashable, Sendable {
    case astroDNA
    case lots
    case parts
}

/// The casting context in which one kleis belongs.
public enum KleisContext: String, CaseIterable, Codable, Hashable, Sendable {
    case natal
    case annualConjunction = "annual/conjunction"
    case mundaneWeather = "mundane/weather"
    case agricultural
    case horary
}

/// Explicit L1-L3 availability for one kleis.
/// Availability is cumulative upward: T/T/T, F/T/T, or F/F/T only.
public struct KleisAvailability: Hashable, Codable, Sendable {
    public let l1: Bool
    public let l2: Bool
    public let l3: Bool

    public init?(l1: Bool, l2: Bool, l3: Bool) {
        guard l3, !l1 || l2 else { return nil }
        self.l1 = l1
        self.l2 = l2
        self.l3 = l3
    }
}

/// How one formula responds to Sect.
public enum KleisSectRule: String, CaseIterable, Codable, Hashable, Sendable {
    case same
    case reverse
    case conditional
    case none
    case unresolved
}

/// Source completeness of one formula row.
public enum KleisFormulaStatus: String, CaseIterable, Codable, Hashable, Sendable {
    case complete
    case partial
    case unresolved
}

/// Stable identity of one spell kept in Hecate's Kleides.
public struct KleisID: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

/// Stable identity of one established resource presented to Hecate.
public struct HecateResourceKey: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

/// One formula row attached to a kleis page.
/// Requirements belong here because different traditions may require different matter.
public struct KleisFormula: Hashable, Codable, Sendable {
    public let requiredResources: [HecateResourceKey]
    public let formula: String
    public let tradition: String
    public let sectRule: KleisSectRule
    public let conditions: [String]
    public let isOrboDefault: Bool
    public let sources: [String]
    public let status: KleisFormulaStatus

    public init?(
        requiredResources: [HecateResourceKey],
        formula: String,
        tradition: String,
        sectRule: KleisSectRule,
        conditions: [String] = [],
        isOrboDefault: Bool,
        sources: [String],
        status: KleisFormulaStatus
    ) {
        let cleanedFormula = formula.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedTradition = tradition.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedConditions = conditions.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let cleanedSources = sources.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard !requiredResources.isEmpty,
              Set(requiredResources).count == requiredResources.count,
              !cleanedFormula.isEmpty,
              !cleanedTradition.isEmpty,
              cleanedConditions.allSatisfy({ !$0.isEmpty }),
              Set(cleanedConditions).count == cleanedConditions.count,
              !cleanedSources.isEmpty,
              cleanedSources.allSatisfy({ !$0.isEmpty }),
              Set(cleanedSources).count == cleanedSources.count else {
            return nil
        }

        self.requiredResources = requiredResources
        self.formula = cleanedFormula
        self.tradition = cleanedTradition
        self.sectRule = sectRule
        self.conditions = cleanedConditions
        self.isOrboDefault = isOrboDefault
        self.sources = cleanedSources
        self.status = status
    }
}

/// One spell page in Hecate's Kleides.
public struct Kleis: Hashable, Codable, Sendable {
    public let id: KleisID
    public let aliases: [String]
    public let family: KleisFamily
    public let context: KleisContext
    public let availability: KleisAvailability
    public let formulas: [KleisFormula]

    public init?(
        id: KleisID,
        aliases: [String] = [],
        family: KleisFamily,
        context: KleisContext,
        availability: KleisAvailability,
        formulas: [KleisFormula]
    ) {
        let cleanedAliases = aliases.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard cleanedAliases.allSatisfy({ !$0.isEmpty }),
              Set(cleanedAliases).count == cleanedAliases.count,
              !formulas.isEmpty,
              Set(formulas).count == formulas.count,
              formulas.filter({ $0.isOrboDefault }).count <= 1 else {
            return nil
        }

        self.id = id
        self.aliases = cleanedAliases
        self.family = family
        self.context = context
        self.availability = availability
        self.formulas = formulas
    }

    /// Formula usable by Orbo's existing generic cast gate.
    /// A sole formula needs no doctrinal choice. Multiple formulas require one Orbo default.
    public var operationalFormula: KleisFormula? {
        if let orboDefault = formulas.first(where: { $0.isOrboDefault }) {
            return orboDefault
        }
        return formulas.count == 1 ? formulas[0] : nil
    }
}

/// Hecate's spellbook.
public struct Kleides: Sendable {
    private let entriesByID: [KleisID: Kleis]

    public init?(_ kleis: [Kleis] = []) {
        let ids = kleis.map(\.id)
        guard Set(ids).count == ids.count else { return nil }
        self.entriesByID = Dictionary(uniqueKeysWithValues: kleis.map { ($0.id, $0) })
    }

    public var all: [Kleis] {
        entriesByID.values.sorted { $0.id.rawValue < $1.id.rawValue }
    }

    public func kleis(_ id: KleisID) -> Kleis? {
        entriesByID[id]
    }
}
