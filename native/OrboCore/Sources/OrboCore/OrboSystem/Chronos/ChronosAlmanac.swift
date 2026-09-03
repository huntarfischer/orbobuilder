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
