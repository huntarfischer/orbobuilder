import Foundation

public enum MundaneTimespineUniversalEventFamily: String, CaseIterable, Codable, Hashable, Sendable {
    case eclipse
    case exactMajorRelationships = "exact-major-relationships"
    case exactMinorRelationships = "exact-minor-relationships"
}

public struct MundaneTimespineUniversalEventContract: Hashable, Sendable {
    public let family: MundaneTimespineUniversalEventFamily
    public let constructionFileName: String
    public let constructionRecordCount: Int
    public let compressedBytes: Int
    public let sha256: String
    public let ringMarks: [RingMark]

    public init?(
        family: MundaneTimespineUniversalEventFamily,
        constructionFileName: String,
        constructionRecordCount: Int,
        compressedBytes: Int,
        sha256: String,
        ringMarks: [RingMark]
    ) {
        guard !constructionFileName.isEmpty,
              constructionRecordCount > 0,
              compressedBytes > 0,
              sha256.count == 64,
              Set(ringMarks).count == ringMarks.count else {
            return nil
        }
        self.family = family
        self.constructionFileName = constructionFileName
        self.constructionRecordCount = constructionRecordCount
        self.compressedBytes = compressedBytes
        self.sha256 = sha256
        self.ringMarks = ringMarks
    }
}

/// The admitted universal event layer for P22.
///
/// These are universal sky facts, never natal interpretation. Their stored meaning is
/// celestial-time-first: eclipse degree or the two bodies' simultaneous celestial times
/// define the event; civic UT identifies the occurrence of that celestial relationship.
///
/// The construction gzip files remain audit-friendly substrate. They do not declare the
/// final shipping serialization and they do not create a runtime Ephemeris dependency.
extension MundaneTimespineP22 {
    public static let universalEventManifestFileName = "universal-events-manifest.json"
    public static let universalEventsAreCelestialTimeFirst = true

    public static let majorRelationshipMarks: [RingMark] = [
        .conjunction,
        .sextile,
        .square,
        .trine,
        .opposition,
    ]

    public static let minorRelationshipMarks: [RingMark] = [
        .semisextile,
        .semisquare,
        .quintile,
        .sesquiquadrate,
        .biquintile,
        .quincunx,
    ]

    public static let universalEventTables: [MundaneTimespineUniversalEventContract] = [
        .init(
            family: .eclipse,
            constructionFileName: "eclipse-table.csv.gz",
            constructionRecordCount: 1_133,
            compressedBytes: 62_156,
            sha256: "15e13795d8b460782606b3dd3302796633d1229f30f2d397cf228777319e72a8",
            ringMarks: []
        )!,
        .init(
            family: .exactMajorRelationships,
            constructionFileName: "exact-major-mundane-transits.csv.gz",
            constructionRecordCount: 308_474,
            compressedBytes: 8_959_884,
            sha256: "307178a19fc2b7d5ab7364cf73e00f57ca18a7c5693072b81d4cef56f5d3f057",
            ringMarks: majorRelationshipMarks
        )!,
        .init(
            family: .exactMinorRelationships,
            constructionFileName: "exact-minor-mundane-transits.csv.gz",
            constructionRecordCount: 461_824,
            compressedBytes: 17_090_967,
            sha256: "3acbafa92a0a091f125337ab0898c32f1b02be0d88bf0d78415af79ef179ff46",
            ringMarks: minorRelationshipMarks
        )!,
    ]

    public static var totalUniversalEventRecords: Int {
        universalEventTables.reduce(0) { $0 + $1.constructionRecordCount }
    }

    public static func universalEventTable(
        for family: MundaneTimespineUniversalEventFamily
    ) -> MundaneTimespineUniversalEventContract {
        universalEventTables.first { $0.family == family }!
    }
}
