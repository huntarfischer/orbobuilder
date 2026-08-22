import Foundation

public enum MundaneBody: UInt8, CaseIterable, Codable, Hashable, Sendable {
    case sun = 0
    case moon = 1
    case mercury = 2
    case venus = 3
    case mars = 4
    case jupiter = 5
    case saturn = 6
    case uranus = 7
    case neptune = 8
    case pluto = 9
    case trueNorthNode = 10

    public static let canonicalOrder: [MundaneBody] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
        .uranus, .neptune, .pluto, .trueNorthNode,
    ]

    public var displayName: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .uranus: return "Uranus"
        case .neptune: return "Neptune"
        case .pluto: return "Pluto"
        case .trueNorthNode: return "True North Node"
        }
    }

    public var constructionDataName: String {
        switch self {
        case .trueNorthNode: return "NorthNode"
        default: return displayName
        }
    }

    public var constructionBodyFileName: String {
        "\(constructionDataName).csv.gz"
    }

    public var planet: Planet? {
        switch self {
        case .sun: return .sun
        case .moon: return .moon
        case .mercury: return .mercury
        case .venus: return .venus
        case .mars: return .mars
        case .jupiter: return .jupiter
        case .saturn: return .saturn
        case .uranus: return .uranus
        case .neptune: return .neptune
        case .pluto: return .pluto
        case .trueNorthNode: return nil
        }
    }
}
