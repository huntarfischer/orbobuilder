import Foundation

public struct ChronosInterval: Hashable, Sendable {
    public let start: JulianDay
    public let endExclusive: JulianDay

    public init?(start: JulianDay, endExclusive: JulianDay) {
        guard start.value < endExclusive.value else { return nil }
        self.start = start
        self.endExclusive = endExclusive
    }
}

public enum ChronosAddress: Hashable, Sendable {
    case moment(JulianDay)
    case interval(ChronosInterval)

    public var start: JulianDay {
        switch self {
        case let .moment(julianDay):
            return julianDay
        case let .interval(interval):
            return interval.start
        }
    }

    public var endExclusive: JulianDay? {
        switch self {
        case .moment:
            return nil
        case let .interval(interval):
            return interval.endExclusive
        }
    }
}

public struct ChronosSourceReference: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

/// Selection over explicit booleans already present on Mater.QualifiedTemper.
/// Chronos never derives condition here; it only selects a condition Rhea already recorded.
public enum NatalSpineMaterCondition: String, CaseIterable, Hashable, Sendable {
    case sectDay
    case sectNight
    case traditionalDomicile
    case modernDomicile
    case traditionalDetriment
    case modernDetriment
    case exaltation
    case atExaltationDegree
    case triplicity
    case bound
    case face
    case fall
    case peregrine
    case mutualReception

    public func matches(_ temper: Mater.QualifiedTemper) -> Bool {
        switch self {
        case .sectDay: return temper.sectDay
        case .sectNight: return temper.sectNight
        case .traditionalDomicile: return temper.traditionalDomicile
        case .modernDomicile: return temper.modernDomicile
        case .traditionalDetriment: return temper.traditionalDetriment
        case .modernDetriment: return temper.modernDetriment
        case .exaltation: return temper.exaltation
        case .atExaltationDegree: return temper.atExaltationDegree
        case .triplicity: return temper.triplicity
        case .bound: return temper.bound
        case .face: return temper.face
        case .fall: return temper.fall
        case .peregrine: return temper.peregrine
        case .mutualReception: return temper.mutualReception
        }
    }
}

public enum ChronosFactIdentity: Hashable, Sendable {
    case civilMoment(
        date: CivilDate,
        time: CivilClockTime,
        timezone: TimezoneIdentifier
    )
    case bodyState(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree
    )
    case station(body: MundaneBody)
    case shell(OrboSpineShellID)
    case natalHousePassage(body: MundaneBody, house: House)
    case natalRingRealization(
        mundaneBody: MundaneBody?,
        natalGene: AstroDNAGene?,
        relation: RingMark?
    )
    case natalHouseCrossing(
        body: MundaneBody?,
        fromHouse: House?,
        toHouse: House?
    )
    case natalMaterCondition(
        condition: NatalSpineMaterCondition,
        body: MundaneBody?
    )
}

public struct ChronosHit: Hashable, Sendable {
    public let address: ChronosAddress
    public let fact: ChronosFactIdentity
    public let source: ChronosSourceReference?

    public init(
        address: ChronosAddress,
        fact: ChronosFactIdentity,
        source: ChronosSourceReference? = nil
    ) {
        self.address = address
        self.fact = fact
        self.source = source
    }
}

public enum ChronosOrder: String, CaseIterable, Hashable, Sendable {
    case ascending
    case descending
}

public struct ChronosAnswer: Hashable, Sendable {
    public let hits: [ChronosHit]
    public let order: ChronosOrder

    public init(
        hits: [ChronosHit],
        order: ChronosOrder = .ascending
    ) {
        self.order = order
        self.hits = hits.enumerated().sorted { lhs, rhs in
            let comparison = Self.compare(lhs.element.address, rhs.element.address)
            if comparison == 0 {
                return lhs.offset < rhs.offset
            }
            return order == .ascending ? comparison < 0 : comparison > 0
        }.map(\.element)
    }

    private static func compare(_ lhs: ChronosAddress, _ rhs: ChronosAddress) -> Int {
        if lhs.start.value < rhs.start.value { return -1 }
        if lhs.start.value > rhs.start.value { return 1 }

        let lhsEnd = lhs.endExclusive?.value ?? lhs.start.value
        let rhsEnd = rhs.endExclusive?.value ?? rhs.start.value
        if lhsEnd < rhsEnd { return -1 }
        if lhsEnd > rhsEnd { return 1 }
        return 0
    }
}

public enum ChronosPredicate: Hashable, Sendable {
    case civilMoment(
        date: CivilDate,
        time: CivilClockTime,
        timezone: TimezoneIdentifier
    )
    case bodyState(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree
    )
    case station(body: MundaneBody)
    case shell(OrboSpineShellID)
    case natalHousePassage(body: MundaneBody, house: House)
    case natalRingRealization(
        mundaneBody: MundaneBody?,
        natalGene: AstroDNAGene?,
        relation: RingMark?
    )
    case natalHouseCrossing(
        body: MundaneBody?,
        fromHouse: House?,
        toHouse: House?
    )
    case natalMaterCondition(
        condition: NatalSpineMaterCondition,
        body: MundaneBody?
    )
}

public enum ChronosScope: Hashable, Sendable {
    case all
    case range(ChronosInterval)
}

public enum ChronosRelation: String, CaseIterable, Hashable, Sendable {
    case all
    case before
    case after
    case previous
    case next
    case nearest
    case containing
}

public struct ChronosQuery: Hashable, Sendable {
    public let predicate: ChronosPredicate
    public let scope: ChronosScope
    public let relation: ChronosRelation
    public let anchor: JulianDay?
    public let order: ChronosOrder
    public let limit: Int?

    public init?(
        predicate: ChronosPredicate,
        scope: ChronosScope = .all,
        relation: ChronosRelation = .all,
        anchor: JulianDay? = nil,
        order: ChronosOrder = .ascending,
        limit: Int? = nil
    ) {
        if relation == .all {
            guard anchor == nil else { return nil }
        } else {
            guard anchor != nil else { return nil }
        }
        if let limit {
            guard limit > 0 else { return nil }
        }

        self.predicate = predicate
        self.scope = scope
        self.relation = relation
        self.anchor = anchor
        self.order = order
        self.limit = limit
    }
}

public enum ChronosUnresolved: Hashable, Sendable {
    case nonexistentCivilTime
    case unknownTimeZone(TimezoneIdentifier)
    case unsupportedYear(Int)
    case unsupportedCalendar(CivilCalendar)
}

public enum ChronosResolution: Hashable, Sendable {
    case resolved(ChronosAnswer)
    case unresolved(ChronosUnresolved)
}
