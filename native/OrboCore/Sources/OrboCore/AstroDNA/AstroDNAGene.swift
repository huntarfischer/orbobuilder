public enum AstroDNAMotionPolicy: String, Codable, Hashable, Sendable {
    case fixedDirect
    case variable
}

/// The twelve canonical AstroDNA genes in their persisted positional order.
///
/// `northNode` intentionally preserves the prototype storage key `Node` while
/// naming the native concept precisely. In codec 4 it is the true/osculating
/// north node and therefore may occupy either motion half of the Ring.
public enum AstroDNAGene: String, CaseIterable, Codable, Hashable, Sendable {
    case ascendant = "Ascendant"
    case moon = "Moon"
    case sun = "Sun"
    case mercury = "Mercury"
    case venus = "Venus"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case pluto = "Pluto"
    case northNode = "Node"

    public static let canonicalOrder: [AstroDNAGene] = [
        .ascendant,
        .moon,
        .sun,
        .mercury,
        .venus,
        .mars,
        .jupiter,
        .saturn,
        .uranus,
        .neptune,
        .pluto,
        .northNode,
    ]

    public var displayName: String {
        self == .northNode ? "North Node" : rawValue
    }

    public var ordinal: Int {
        switch self {
        case .ascendant: return 0
        case .moon: return 1
        case .sun: return 2
        case .mercury: return 3
        case .venus: return 4
        case .mars: return 5
        case .jupiter: return 6
        case .saturn: return 7
        case .uranus: return 8
        case .neptune: return 9
        case .pluto: return 10
        case .northNode: return 11
        }
    }

    /// Motion participation in the codec-4 identity.
    ///
    /// The Ascendant is an angle and cannot station. The geocentric luminaries
    /// are never encoded retrograde. The eight planetary genes and the
    /// true/osculating North Node may occupy either half of the Ring fine
    /// address space.
    public var motionPolicy: AstroDNAMotionPolicy {
        switch self {
        case .ascendant, .moon, .sun:
            return .fixedDirect
        case .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto, .northNode:
            return .variable
        }
    }
}
