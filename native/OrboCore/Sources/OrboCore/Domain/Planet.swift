public enum Planet: String, CaseIterable, Codable, Hashable, Sendable {
    case sun = "Sun"
    case moon = "Moon"
    case mercury = "Mercury"
    case venus = "Venus"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case pluto = "Pluto"

    /// Canonical Orbo ordering for the planetary bodies admitted at this layer.
    /// Never depend on dictionary ordering for structural identity.
    public static let canonicalOrder: [Planet] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
        .uranus, .neptune, .pluto,
    ]

    /// The closed traditional set that can act as classical dispositors and
    /// participate in the classical essential-dignity ladder.
    public static let classicalSeven: [Planet] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
    ]

    public var isClassical: Bool {
        switch self {
        case .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn:
            return true
        case .uranus, .neptune, .pluto:
            return false
        }
    }
}
