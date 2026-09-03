/// Hermes's zodiacal switchboard. Routes preserve the native owners' jurisdictions.
public enum HermesTabulaSeat: Int, CaseIterable, Hashable, Sendable {
    case natal, hereNow, planets, moon, image, aspects, ledger, timing, almanac, gears, archive, composite
    public var title: String {
        ["Natal", "Here · Now", "Planets", "Moon", "Image", "Aspects", "Ledger", "Timing", "Almanac", "Gears", "Hestia", "Composite"][rawValue]
    }
    public var owner: String {
        switch self {
        case .natal, .hereNow, .planets, .aspects, .gears: return "Apollo"
        case .moon: return "Artemis"
        case .image: return "Aether"
        case .ledger, .archive: return "Hestia"
        case .timing: return "Pythia"
        case .almanac: return "Chronos"
        case .composite: return "Hecate"
        }
    }
}
public extension Hermes {
    static var tabulaSeats: [HermesTabulaSeat] { HermesTabulaSeat.allCases }
}
