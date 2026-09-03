import Foundation

public extension Artemis {
    static func relations(_ chart: AstrolabeChart, settings: ApolloAspectSettings) throws -> ArtemisLunarReading {
        let rows = Apollo.contacts(in: chart, settings: settings).map {
            LunarRow.relation(left: $0.left.displayName, mark: String(describing: $0.mark), right: $0.right.displayName, orb: $0.residual)
        }
        return try pass(LunarTicket(plate: .relation, subject: LunarSubject(chart: chart, course: .relations), rows: rows, doctrine: [.oceanus]))
    }
    /// Artemis owns lunar techniques. This standing read uses the accepted Aegis only.
    static func moon(_ aegis: ApolloAegis) throws -> ArtemisLunarReading {
        let phase = aegis.lunarSeparation.degrees
        let names = ["New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"]
        let moon = aegis.sky.placement(.moon)!
        let mansionNames = ["Al Sharatain", "Al Butain", "Al Thurayya", "Al Dabaran", "Al Haq'ah", "Al Han'ah", "Al Dhira",
            "Al Nathrah", "Al Tarf", "Al Jabhah", "Al Zubrah", "Al Sarfah", "Al Awwa", "Al Simak", "Al Ghafr", "Al Zubana",
            "Al Iklil", "Al Qalb", "Al Shaula", "Al Na'am", "Al Baldah", "Sa'd al Dhabih", "Sa'd Bula", "Sa'd al Su'ud",
            "Sa'd al Akhbiya", "Al Fargh al Mukdim", "Al Fargh al Thani", "Batn al Hut"]
        let mansion = Int(moon.longitude.degrees / (360.0 / 28))
        let rows: [LunarRow] = [
            .fact(key: "Phase", value: names[Int((phase / 45).rounded()) % 8], qualified: nil),
            .fact(key: "Illumination", value: String(format: "%.0f%% · %@", (1 - cos(phase * .pi / 180)) * 50, phase < 180 ? "waxing" : "waning"), qualified: nil),
            .fact(key: "Moon", value: String(format: "%.4f°", moon.longitude.degrees), qualified: LunarQualifiedValue(body: .moon, longitude: moon.longitude)),
            .fact(key: "Mansion", value: "\(mansion + 1) · \(mansionNames[mansion])", qualified: nil)
        ]
        return try pass(LunarTicket(plate: .fact, subject: LunarSubject(chart: aegis.sky, course: .moon), rows: rows, doctrine: [.spine, .oceanus, .artemis]))
    }
    static func lunarEvents(_ chart: AstrolabeChart, using horae: Horae, library: OrboSpineLibraryCatalog) throws -> ArtemisLunarReading {
        guard let moon = chart.placement(.moon) else { throw ApolloAegisFailure.missingPlacement(.moon) }
        let degree = OrboSpineDirectionalDegree(Double((moon.longitude.sign.rawValue + 1) % 12 * 30))!
        let ingress = try horae.occurrenceUTs(of: .moon, at: degree).first { $0.value > chart.julianDay.value }
        var rows: [LunarRow] = []
        if let ingress { rows.append(.ledger(mark: "☽", what: "Next sign ingress", when: ingress, track: nil)) }
        let end = ingress?.value ?? chart.julianDay.value + 3
        let traditional: Set<MundaneBody> = [.sun, .mercury, .venus, .mars, .jupiter, .saturn]
        let majors: Set<RingMark> = [.conjunction, .sextile, .square, .trine, .opposition]
        for event in library.ringOccurrences where event.julianDay.value > chart.julianDay.value && event.julianDay.value < end {
            let other = event.bodyA == .moon ? event.bodyB : event.bodyA
            guard (event.bodyA == .moon || event.bodyB == .moon), traditional.contains(other), majors.contains(event.mark) else { continue }
            rows.append(.ledger(mark: "☽", what: "\(String(describing: event.mark)) \(other.displayName)", when: event.julianDay, track: nil))
        }
        // No void-of-course claim from an empty prepared set: absence needs a complete windowed reader.
        if let eclipse = library.eclipses.first(where: { $0.julianDay.value > chart.julianDay.value }) {
            rows.append(.ledger(mark: "◐", what: "\(eclipse.kind.rawValue) \(eclipse.type.rawValue) eclipse", when: eclipse.julianDay, track: nil))
        }
        rows.sort { lhs, rhs in
            if case let .ledger(_, _, a, _) = lhs, case let .ledger(_, _, b, _) = rhs { return a.value < b.value }
            return false
        }
        return try pass(LunarTicket(plate: .ledger, subject: LunarSubject(chart: chart, course: .moon), rows: rows, doctrine: [.spine, .artemis]))
    }
}
