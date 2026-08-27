import Foundation
@testable import OrboCore

enum OrboPipelineFixture {
    static let subjectID = HermesSubjectID(rawValue: "orbo.pipeline.native-001")!
    static let packageID = HermesPackageID(UUID(uuidString: "11111111-2222-3333-4444-555555555555")!)
    static let handoffAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_000)!
    static let atlasDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_060)!
    static let atlasRecoveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_120)!
    static let moiraiDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_180)!
    static let name = "Traveler"
    static let birthDate = CivilDate(year: 1990, month: 5, day: 17)!
    static let birthTime = CivilClockTime(hour: 14, minute: 32)!
    static let birthLocation = "Madison, WI"
    static let astrologyInterest: OrboAstrologyInterest = .interested
    static let readingDepth: OrboReadingDepth = .l2
    static let bigThreeTruth = OrboEstablishedBigThree(
        ascendantSign: "Gemini",
        moonSign: "Leo",
        sunSign: "Pisces"
    )!
}
