public enum AstroDNAMotionPolicy: String, Codable, Hashable, Sendable {
    case fixedDirect
    case variable
    case fixedRetrograde
}

/// The twelve canonical AstroDNA genes in their persisted positional order.
///
/// `northNode` intentionally preserves the prototype storage key `Node` while
/// naming the native concept precisely. It is the mean north node gene.
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

    /// Motion participation in the codec-3 identity.
    ///
    /// The Ascendant is an angle and cannot station. The geocentric luminaries
    /// are never encoded retrograde. The mean north node is uniformly
    /// retrograde. The remaining eight planetary genes may occupy either half
    /// of the Ring fine address space.
    public var motionPolicy: AstroDNAMotionPolicy {
        switch self {
        case .ascendant, .moon, .sun:
            return .fixedDirect
        case .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto:
            return .variable
        case .northNode:
            return .fixedRetrograde
        }
    }

    public var isMeanNorthNode: Bool {
        self == .northNode
    }
}
