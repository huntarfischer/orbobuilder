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
    public let sect: Sect
    public let fortune: CelestialLongitude
    public let spirit: CelestialLongitude
    public let eros: CelestialLongitude
    public let necessity: CelestialLongitude

    public init(
        pattern: Pattern,
        astroDNA: AstroDNA,
        sect: Sect,
        fortune: CelestialLongitude,
        spirit: CelestialLongitude,
        eros: CelestialLongitude,
        necessity: CelestialLongitude
    ) {
        self.pattern = pattern
        self.astroDNA = astroDNA
        self.sect = sect
        self.fortune = fortune
        self.spirit = spirit
        self.eros = eros
        self.necessity = necessity
    }
}
