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

public struct MundaneTimespineBodyContract: Hashable, Sendable {
    public let body: MundaneBody
    public let celestialResolutionDegrees: Double
    public let markerBodies: [MundaneBody]
    public let constructionRecordCount: Int

    public init?(
        body: MundaneBody,
        celestialResolutionDegrees: Double,
        markerBodies: [MundaneBody],
        constructionRecordCount: Int
    ) {
        guard celestialResolutionDegrees.isFinite,
              celestialResolutionDegrees > 0,
              celestialResolutionDegrees <= 360,
              !markerBodies.contains(body),
              Set(markerBodies).count == markerBodies.count,
              constructionRecordCount > 0 else {
            return nil
        }
        self.body = body
        self.celestialResolutionDegrees = celestialResolutionDegrees
        self.markerBodies = markerBodies
        self.constructionRecordCount = constructionRecordCount
    }
}

/// Earned Pass 5 body-substrate contract for the first Orbo 1.0 Mundane Timespine study.
///
/// Celestial time is the focal body's zodiacal position. Civic UT is the chronology
/// attached to each occurrence of that repeating celestial coordinate. P22 supplies
/// the common half-open shipping span for this construction substrate.
///
/// This type deliberately defines no Timespine "codec" number. `AstroDNA.codec == 4`
/// is a separate, already-canonical AstroDNA contract and is not renamed or reused here.
public enum MundaneTimespineP22 {
    public static let spanName = "P22 Pluto Zeitgeist"
    public static let startUTC = "1822-04-16T13:54:20.135Z"
    public static let endUTC = "2066-06-17T15:24:10.695Z"
    public static let startJulianDay = JulianDay(2_386_637.079399706)!
    public static let endJulianDay = JulianDay(2_475_819.1417904524)!
    public static let civicOffsetBitsRequired = 33

    public static let profiles: [MundaneTimespineBodyContract] = [
        .init(body: .sun, celestialResolutionDegrees: 1, markerBodies: [.pluto, .neptune], constructionRecordCount: 87_901)!,
        .init(body: .moon, celestialResolutionDegrees: 1, markerBodies: [.sun, .pluto], constructionRecordCount: 1_175_112)!,
        .init(body: .mercury, celestialResolutionDegrees: 1, markerBodies: [.sun, .pluto, .moon], constructionRecordCount: 108_604)!,
        .init(body: .venus, celestialResolutionDegrees: 1, markerBodies: [.sun, .pluto, .mercury], constructionRecordCount: 92_858)!,
        .init(body: .mars, celestialResolutionDegrees: 1, markerBodies: [.sun, .pluto], constructionRecordCount: 50_512)!,
        .init(body: .jupiter, celestialResolutionDegrees: 0.1, markerBodies: [.sun, .pluto], constructionRecordCount: 118_545)!,
        .init(body: .saturn, celestialResolutionDegrees: 0.1, markerBodies: [.sun, .jupiter], constructionRecordCount: 62_000)!,
        .init(body: .uranus, celestialResolutionDegrees: 0.1, markerBodies: [.sun], constructionRecordCount: 29_923)!,
        .init(body: .neptune, celestialResolutionDegrees: 0.1, markerBodies: [.sun], constructionRecordCount: 18_933)!,
        .init(body: .pluto, celestialResolutionDegrees: 0.1, markerBodies: [.sun], constructionRecordCount: 14_712)!,
        .init(body: .trueNorthNode, celestialResolutionDegrees: 0.1, markerBodies: [.sun, .moon], constructionRecordCount: 52_867)!,
    ]

    public static let sharedMotionTables = [
        "station-table.csv.gz",
        "retrograde-passages.csv.gz",
        "retrograde-crossings.csv.gz",
    ]

    public static var totalConstructionRecords: Int {
        profiles.reduce(0) { $0 + $1.constructionRecordCount }
    }

    public static func profile(for body: MundaneBody) -> MundaneTimespineBodyContract {
        profiles[body.rawValue == MundaneBody.trueNorthNode.rawValue ? 10 : Int(body.rawValue)]
    }

    public static func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= startJulianDay.value && julianDay.value < endJulianDay.value
    }
}
