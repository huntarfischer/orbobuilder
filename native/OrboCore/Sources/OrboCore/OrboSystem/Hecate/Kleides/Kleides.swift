import Foundation

/// The first three shelves of Hecate's Kleides.
/// AstroDNA remains independent unless a truer family is established later.
public enum KleisFamily: String, CaseIterable, Codable, Hashable, Sendable {
    case astroDNA
    case lots
    case parts
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
/// Stage 0 names resources only; later stages attach the lawful values required by real casts.
public struct HecateResourceKey: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

/// One spell declaration in the Kleides.
/// A kleis owns its recipe requirements, not the truth of the resources supplied to it.
public struct Kleis: Hashable, Codable, Sendable {
    public let id: KleisID
    public let family: KleisFamily
    public let requiredResources: [HecateResourceKey]

    public init?(
        id: KleisID,
        family: KleisFamily,
        requiredResources: [HecateResourceKey]
    ) {
        guard !requiredResources.isEmpty,
              Set(requiredResources).count == requiredResources.count else {
            return nil
        }

        self.id = id
        self.family = family
        self.requiredResources = requiredResources
    }
}

/// Hecate's spellbook.
/// Stage 0 is only a registry: it knows which kleis exist and what each requires.
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
