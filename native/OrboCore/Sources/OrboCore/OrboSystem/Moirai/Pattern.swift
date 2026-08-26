/// The project shape Clotho selects before handing work to Lachesis.
///
/// Pattern identifies what is to be woven. Template selection and allotment
/// remain Lachesis's work.
public enum Pattern: String, Codable, Hashable, Sendable {
    case engraving

    public var spanYears: Int {
        switch self {
        case .engraving:
            return 100
        }
    }
}

/// The sister-to-sister handoff from Clotho to Lachesis.
public struct PatternPacket: Hashable, Sendable {
    public let pattern: Pattern
    public let astroDNA: AstroDNA

    public init(pattern: Pattern, astroDNA: AstroDNA) {
        self.pattern = pattern
        self.astroDNA = astroDNA
    }
}
