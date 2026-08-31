/// Stage 4 temporal selection over already-resolved Chronos truth.
///
/// These operators do not discover, calculate, or reinterpret temporal facts.
/// They only select, relate, order, and limit addresses already returned by a
/// lawful source. Scope never clips a canonical address; it selects addresses
/// that intersect the requested half-open temporal domain.
public extension Chronos {
    static func apply(
        _ query: ChronosQuery,
        to resolution: ChronosResolution
    ) -> ChronosResolution {
        switch resolution {
        case let .resolved(answer):
            return .resolved(apply(query, to: answer))
        case let .unresolved(reason):
            return .unresolved(reason)
        }
    }

    static func apply(
        _ query: ChronosQuery,
        to answer: ChronosAnswer
    ) -> ChronosAnswer {
        let requestedFact = factIdentity(for: query.predicate)
        var hits = answer.hits.filter { $0.fact == requestedFact }
        hits = hits.filter { isInScope($0.address, scope: query.scope) }
        hits = applyRelation(
            query.relation,
            anchor: query.anchor,
            to: hits
        )

        var ordered = ChronosAnswer(hits: hits, order: query.order)
        if let limit = query.limit, ordered.hits.count > limit {
            ordered = ChronosAnswer(
                hits: Array(ordered.hits.prefix(limit)),
                order: query.order
            )
        }
        return ordered
    }

    static func factIdentity(
        for predicate: ChronosPredicate
    ) -> ChronosFactIdentity {
        switch predicate {
        case let .civilMoment(date, time, timezone):
            return .civilMoment(date: date, time: time, timezone: timezone)
        case let .bodyState(body, directionalDegree):
            return .bodyState(body: body, directionalDegree: directionalDegree)
        case let .station(body):
            return .station(body: body)
        case let .shell(id):
            return .shell(id)
        case let .natalHousePassage(body, house):
            return .natalHousePassage(body: body, house: house)
        case let .natalRingRealization(mundaneBody, natalGene, relation):
            return .natalRingRealization(
                mundaneBody: mundaneBody,
                natalGene: natalGene,
                relation: relation
            )
        case let .natalHouseCrossing(body, fromHouse, toHouse):
            return .natalHouseCrossing(
                body: body,
                fromHouse: fromHouse,
                toHouse: toHouse
            )
        case let .natalMaterCondition(condition, body):
            return .natalMaterCondition(condition: condition, body: body)
        }
    }

    private static func isInScope(
        _ address: ChronosAddress,
        scope: ChronosScope
    ) -> Bool {
        switch scope {
        case .all:
            return true
        case let .range(range):
            switch address {
            case let .moment(julianDay):
                return julianDay.value >= range.start.value
                    && julianDay.value < range.endExclusive.value
            case let .interval(interval):
                return interval.start.value < range.endExclusive.value
                    && interval.endExclusive.value > range.start.value
            }
        }
    }

    private static func applyRelation(
        _ relation: ChronosRelation,
        anchor: JulianDay?,
        to hits: [ChronosHit]
    ) -> [ChronosHit] {
        switch relation {
        case .all:
            return hits

        case .before:
            guard let anchor else { return [] }
            return hits.filter { isBefore($0.address, anchor: anchor) }

        case .after:
            guard let anchor else { return [] }
            return hits.filter { isAfter($0.address, anchor: anchor) }

        case .containing:
            guard let anchor else { return [] }
            return hits.filter { contains($0.address, anchor: anchor) }

        case .previous:
            guard let anchor else { return [] }
            let candidates = hits.filter { isBefore($0.address, anchor: anchor) }
            guard let boundary = candidates.map({ previousBoundary($0.address) }).max() else {
                return []
            }
            return candidates.filter {
                abs(previousBoundary($0.address) - boundary) <= epsilon
            }

        case .next:
            guard let anchor else { return [] }
            let candidates = hits.filter { isAfter($0.address, anchor: anchor) }
            guard let boundary = candidates.map({ $0.address.start.value }).min() else {
                return []
            }
            return candidates.filter {
                abs($0.address.start.value - boundary) <= epsilon
            }

        case .nearest:
            guard let anchor else { return [] }
            guard let distance = hits.map({ temporalDistance($0.address, to: anchor) }).min() else {
                return []
            }
            return hits.filter {
                abs(temporalDistance($0.address, to: anchor) - distance) <= epsilon
            }
        }
    }

    private static func isBefore(
        _ address: ChronosAddress,
        anchor: JulianDay
    ) -> Bool {
        switch address {
        case let .moment(julianDay):
            return julianDay.value < anchor.value
        case let .interval(interval):
            return interval.endExclusive.value <= anchor.value
        }
    }

    private static func isAfter(
        _ address: ChronosAddress,
        anchor: JulianDay
    ) -> Bool {
        address.start.value > anchor.value
    }

    private static func contains(
        _ address: ChronosAddress,
        anchor: JulianDay
    ) -> Bool {
        switch address {
        case let .moment(julianDay):
            return abs(julianDay.value - anchor.value) <= epsilon
        case let .interval(interval):
            return anchor.value >= interval.start.value
                && anchor.value < interval.endExclusive.value
        }
    }

    private static func previousBoundary(_ address: ChronosAddress) -> Double {
        switch address {
        case let .moment(julianDay):
            return julianDay.value
        case let .interval(interval):
            return interval.endExclusive.value
        }
    }

    private static func temporalDistance(
        _ address: ChronosAddress,
        to anchor: JulianDay
    ) -> Double {
        switch address {
        case let .moment(julianDay):
            return abs(julianDay.value - anchor.value)
        case let .interval(interval):
            if anchor.value < interval.start.value {
                return interval.start.value - anchor.value
            }
            if anchor.value >= interval.endExclusive.value {
                return anchor.value - interval.endExclusive.value
            }
            return 0
        }
    }

    private static let epsilon = 1e-10
}
