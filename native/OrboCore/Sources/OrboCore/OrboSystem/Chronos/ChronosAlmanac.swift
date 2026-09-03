import Foundation

public extension Chronos {
    /// Almanac's first prepared chronology: all bodies, or one selected rail.
    static func almanac(after moment: JulianDay, body: MundaneBody?, using library: OrboSpineLibraryCatalog, limit: Int = 30) -> ChronosAnswer {
        let bodies = body.map { [$0] } ?? MundaneBody.canonicalOrder
        let hits = bodies.flatMap { body -> [ChronosHit] in
            guard case let .resolved(answer) = resolveStations(body: body, using: library) else { return [] }
            return answer.hits.filter { $0.address.start.value > moment.value }
        }
        return ChronosAnswer(hits: Array(ChronosAnswer(hits: hits).hits.prefix(max(0, limit))))
    }
}
public extension Artemis {
    static func chronology(_ answer: ChronosAnswer, chart: AstrolabeChart, course: LunarCourse) throws -> ArtemisLunarReading {
        let rows = answer.hits.map { hit -> LunarRow in
            let what: String
            switch hit.fact {
            case let .station(body): what = "\(body.displayName) station"
            case let .bodyState(body, degree): what = "\(body.displayName) · \(degree.physicalDegrees)° · \(degree.motion.rawValue)"
            default: what = String(describing: hit.fact)
            }
            return .ledger(mark: "•", what: what, when: hit.address.start, track: nil)
        }
        return try pass(LunarTicket(plate: .ledger, subject: LunarSubject(chart: chart, course: course), rows: rows,
            doctrine: course == .timing ? [.pythia, .chronos, .spine] : [.chronos, .spine]))
    }
}

public enum ChronosAlmanacStream: String, CaseIterable, Hashable, Sendable {
    case stations, contacts, eclipses
}
public enum ChronosPreparedEvent: Hashable, Sendable {
    case station(OrboSpineStation)
    case contact(OrboSpineRingOccurrence)
    case eclipse(OrboSpineEclipseOccurrence)
    public var moment: JulianDay {
        switch self { case let .station(x): return x.julianDay; case let .contact(x): return x.julianDay; case let .eclipse(x): return x.julianDay }
    }
}
public extension Chronos {
    static func almanacEvents(after moment: JulianDay, body: MundaneBody?, streams: Set<ChronosAlmanacStream>, using library: OrboSpineLibraryCatalog, limit: Int = 30) -> [ChronosPreparedEvent] {
        guard limit > 0 else { return [] }
        var result: [ChronosPreparedEvent] = []
        if streams.contains(.stations) {
            let bodies = body.map { [$0] } ?? MundaneBody.canonicalOrder
            for body in bodies {
                result += library.stations(for: body).lazy.filter { $0.julianDay.value > moment.value }.prefix(limit).map { .station($0) }
            }
        }
        if streams.contains(.contacts) {
            result += library.ringOccurrences.lazy.filter {
                $0.julianDay.value > moment.value && (body == nil || $0.bodyA == body || $0.bodyB == body)
            }.prefix(limit).map { .contact($0) }
        }
        if streams.contains(.eclipses), body == nil || body == .sun || body == .moon {
            result += library.eclipses.lazy.filter { $0.julianDay.value > moment.value }.prefix(limit).map { .eclipse($0) }
        }
        return Array(result.sorted { $0.moment.value < $1.moment.value }.prefix(limit))
    }
}
public extension Artemis {
    static func almanac(_ events: [ChronosPreparedEvent], chart: AstrolabeChart, body: MundaneBody?) throws -> ArtemisLunarReading {
        let rows = events.map { event -> LunarRow in
            let mark: String
            let what: String
            switch event {
            case let .station(station):
                mark = "•"; what = "\(station.body.displayName) · \(lunarPosition(station.physicalDegrees)) · station to \(station.laneAfter.rawValue)"
            case let .contact(contact):
                mark = "◇"; what = "\(contact.bodyA.displayName) \(lunarPosition(contact.bodyADirectionalDegree.physicalDegrees)) · \(String(describing: contact.mark)) · \(contact.bodyB.displayName) \(lunarPosition(contact.bodyBDirectionalDegree.physicalDegrees))"
            case let .eclipse(eclipse):
                mark = "◐"; what = "\(lunarPosition(eclipse.eclipseDegree)) · \(eclipse.kind.rawValue) \(eclipse.type.rawValue) eclipse"
            }
            return .ledger(mark: mark, what: what, when: event.moment, track: nil)
        }
        let gene = body.flatMap { $0 == .trueNorthNode ? AstroDNAGene.northNode : AstroDNAGene(rawValue: $0.displayName) }
        return try pass(LunarTicket(plate: .ledger, subject: LunarSubject(chart: chart, course: .almanac, body: gene), rows: rows, doctrine: [.chronos, .spine]))
    }
}

extension Artemis {
    static func lunarPosition(_ degrees: Double) -> String {
        guard let longitude = CelestialLongitude(degrees) else { return "Unresolved degree" }
        return String(format: "%.2f° %@", longitude.degreeInSign.value, String(describing: longitude.sign).capitalized)
    }
}
