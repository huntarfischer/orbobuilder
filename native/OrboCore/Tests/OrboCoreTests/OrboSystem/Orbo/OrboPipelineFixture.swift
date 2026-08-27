@testable import OrboCore

enum OrboPipelineFixture {
    static let subjectID = HermesSubjectID(rawValue: "orbo.pipeline.native-001")!
    static let name = "Traveler"
    static let birthDate = CivilDate(year: 1990, month: 5, day: 17)!
    static let birthTime = CivilClockTime(hour: 14, minute: 32)!
    static let birthLocation = "Madison, WI"
    static let astrologyInterest: OrboAstrologyInterest = .interested
    static let readingDepth: OrboReadingDepth = .l2
}
