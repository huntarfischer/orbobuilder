import Foundation

/// Phase 9's six row axes. TRACK is a nested measurement; PROSE expands an address.
public enum LunarPlate: String, CaseIterable, Hashable, Sendable {
    case fact, relation, ledger, span, track, prose
}
public enum LunarArrangement: String, Hashable, Sendable { case flat, railed, stepped }
public enum LunarRest: String, Hashable, Sendable { case facts, pager, raised }
public enum LunarCourse: String, CaseIterable, Hashable, Sendable {
    case natal, sky, relations, moon, almanac, timing
    public var title: String {
        switch self {
        case .natal: return "NATAL"
        case .sky: return "THE SKY"
        case .relations: return "CONTACTS"
        case .moon: return "MOON"
        case .almanac: return "ALMANAC"
        case .timing: return "TIMING"
        }
    }
    public var arrangement: LunarArrangement { self == .almanac ? .railed : .flat }
}
/// Registry keys, not reader-authored credits. Names identify the actual native benches.
public enum LunarDoctrine: String, CaseIterable, Hashable, Sendable {
    case spine, hecate, themis, rhea, oceanus, chronos, pythia, artemis, hestia
    public var credit: String {
        switch self {
        case .spine: return "OrboSpine · Horae"
        case .hecate: return "Hecate · local horizon"
        case .themis: return "Themis · whole-sign houses"
        case .rhea: return "Rhea · condition"
        case .oceanus: return "Oceanus · Ring"
        case .chronos: return "Chronos · prepared chronology"
        case .pythia: return "Pythia · timing"
        case .artemis: return "Artemis · lunar reading"
        case .hestia: return "Hestia · kept Tapestry"
        }
    }
}
public struct LunarHouse: Hashable, Sendable {
    public let native: AstrolabeSubjectIdentity
    public let number: House
    public init(native: AstrolabeSubjectIdentity, number: House) { self.native = native; self.number = number }
}
public struct LunarQualifiedValue: Hashable, Sendable {
    public let body: AstroDNAGene
    public let longitude: CelestialLongitude
    public let house: LunarHouse?
    public let motion: Motion
    public init(body: AstroDNAGene, longitude: CelestialLongitude, house: LunarHouse? = nil, motion: Motion = .direct) {
        self.body = body; self.longitude = longitude; self.house = house; self.motion = motion
    }
}
public struct LunarTrack: Hashable, Sendable {
    public let value: Double
    public let minimum: Double
    public let maximum: Double
    public let unit: String
    public init(value: Double, minimum: Double, maximum: Double, unit: String) {
        self.value = value; self.minimum = minimum; self.maximum = maximum; self.unit = unit
    }
    /// The raw measurement survives; only the drawn fill is bounded.
    public var fill: Double { min(1, max(0, (value - minimum) / (maximum - minimum))) }
}
public struct LunarSpan: Hashable, Sendable {
    public let glyph: String
    public let level: Int
    public let start: JulianDay
    public let end: JulianDay
    public let children: [LunarSpan]
    public let track: LunarTrack?
    public init(glyph: String, level: Int, start: JulianDay, end: JulianDay, children: [LunarSpan] = [], track: LunarTrack? = nil) {
        self.glyph = glyph; self.level = level; self.start = start; self.end = end; self.children = children; self.track = track
    }
}
public enum LunarRow: Hashable, Sendable {
    case fact(key: String, value: String, qualified: LunarQualifiedValue?)
    case relation(left: String, mark: String, right: String, orb: Double?)
    case ledger(mark: String, what: String, when: JulianDay, track: LunarTrack?)
    case span(LunarSpan)
    /// Text can only enter from the owner's addressed shelf through expand().
    case prose(address: String, text: String, source: String)
    public var plate: LunarPlate {
        switch self { case .fact: return .fact; case .relation: return .relation; case .ledger: return .ledger; case .span: return .span; case .prose: return .prose }
    }
}
public struct LunarSubject: Hashable, Sendable {
    public let chart: AstrolabeChart
    public let course: LunarCourse
    public let body: AstroDNAGene?
    public init(chart: AstrolabeChart, course: LunarCourse, body: AstroDNAGene? = nil) {
        self.chart = chart; self.course = course; self.body = body
    }
}
public struct LunarTicket: Hashable, Sendable {
    public let plate: LunarPlate
    public let subject: LunarSubject
    public let rows: [LunarRow]
    public let doctrine: [LunarDoctrine]
    public init(plate: LunarPlate, subject: LunarSubject, rows: [LunarRow], doctrine: [LunarDoctrine]) {
        self.plate = plate; self.subject = subject; self.rows = rows; self.doctrine = doctrine
    }
}
/// Only Artemis's pass can produce a reading. Iris renders these accepted rows.
public struct ArtemisLunarReading: Hashable, Sendable {
    public let ticket: LunarTicket
    public let caption: String
    public let rest: LunarRest
    public let provenance: [String]
    public var arrangement: LunarArrangement { ticket.subject.course.arrangement }
    fileprivate init(ticket: LunarTicket, caption: String, rest: LunarRest) {
        self.ticket = ticket; self.caption = caption; self.rest = rest
        self.provenance = Array(Set(ticket.doctrine)).sorted { $0.rawValue < $1.rawValue }.map(\.credit)
    }
}
public enum LunarPortFailure: Error, Equatable {
    case noDoctrine, wrongPlate, invalidRow, invalidTrack, invalidSpan, wrongHouseSubject, proseRequiresAddress
}
public extension Artemis {
    static func pass(_ ticket: LunarTicket) throws -> ArtemisLunarReading {
        guard !ticket.doctrine.isEmpty else { throw LunarPortFailure.noDoctrine }
        guard ticket.plate != .track else { throw LunarPortFailure.wrongPlate }
        guard ticket.plate != .prose else { throw LunarPortFailure.proseRequiresAddress }
        for row in ticket.rows {
            guard row.plate == ticket.plate else { throw LunarPortFailure.wrongPlate }
            switch row {
            case let .fact(key, value, qualified):
                guard !key.isEmpty, !value.isEmpty else { throw LunarPortFailure.invalidRow }
                if let house = qualified?.house, house.native != ticket.subject.chart.subject {
                    throw LunarPortFailure.wrongHouseSubject
                }
            case let .relation(left, mark, right, orb):
                guard !left.isEmpty, !mark.isEmpty, !right.isEmpty,
                      orb.map({ $0.isFinite && $0 >= 0 }) ?? true else { throw LunarPortFailure.invalidRow }
            case let .ledger(mark, what, _, track):
                guard !mark.isEmpty, !what.isEmpty else { throw LunarPortFailure.invalidRow }
                try checkTrack(track)
            case let .span(span): try checkSpan(span)
            case .prose: throw LunarPortFailure.proseRequiresAddress
            }
        }
        let subject = ticket.subject
        let caption: String
        switch subject.course {
        case .natal: caption = subject.body.map { "natal \($0.displayName)" } ?? "my natal chart"
        case .sky: caption = subject.body.map { "the sky · \($0.displayName)" } ?? "the sky of this moment"
        case .relations: caption = "contacts · \(subject.chart.name)"
        case .moon: caption = "the Moon of this moment"
        case .almanac: caption = "almanac · prepared stations"
        case .timing: caption = "timing · next returns to this degree"
        }
        return ArtemisLunarReading(ticket: ticket, caption: caption, rest: .facts)
    }
    static func pass(_ fact: ArtemisFactReading) throws -> ArtemisLunarReading {
        let rows = fact.rows.map { placement in
            LunarRow.fact(key: placement.gene.displayName,
                value: String(format: "%.4f°", placement.longitude.degrees),
                qualified: LunarQualifiedValue(body: placement.gene, longitude: placement.longitude,
                    house: placement.house.map { LunarHouse(native: fact.subject, number: $0) }, motion: placement.motion))
        }
        return try pass(LunarTicket(plate: .fact,
            subject: LunarSubject(chart: fact.chart, course: fact.chart.kind == .natal ? .natal : .sky, body: fact.selectedGene),
            rows: rows, doctrine: [fact.chart.kind == .natal ? .hestia : .spine, .hecate, .themis, .rhea]))
    }
    /// A shelf entry is keyed to an accepted parent row, never arbitrary ticket prose.
    static func expand(_ parent: ArtemisLunarReading, row index: Int, shelf: [String: String], source: String) throws -> ArtemisLunarReading? {
        guard parent.ticket.rows.indices.contains(index), !source.isEmpty else { throw LunarPortFailure.proseRequiresAddress }
        let address = "\(parent.ticket.subject.chart.subject)/\(parent.ticket.subject.course.rawValue)/\(index)"
        guard let text = shelf[address], !text.isEmpty else { return nil }
        let ticket = LunarTicket(plate: .prose, subject: parent.ticket.subject,
            rows: [.prose(address: address, text: text, source: source)], doctrine: parent.ticket.doctrine)
        return ArtemisLunarReading(ticket: ticket, caption: parent.caption, rest: .pager)
    }
    private static func checkTrack(_ track: LunarTrack?) throws {
        guard let track else { return }
        guard track.value.isFinite, track.minimum.isFinite, track.maximum.isFinite,
              track.minimum < track.maximum else { throw LunarPortFailure.invalidTrack }
    }
    private static func checkSpan(_ span: LunarSpan) throws {
        guard span.start.value < span.end.value, !span.glyph.isEmpty, span.level >= 0 else { throw LunarPortFailure.invalidSpan }
        try checkTrack(span.track)
        for child in span.children {
            // Valens overflow is preserved. Only the child's start must lie in the parent.
            guard child.start.value >= span.start.value, child.start.value < span.end.value else { throw LunarPortFailure.invalidSpan }
            try checkSpan(child)
        }
    }
}
