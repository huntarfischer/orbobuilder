import XCTest
@testable import OrboCore

final class SynchronicSpinePassATests: XCTestCase {
    func testCommissionOpensOneUnresolvedHermesJourneyToClotho() throws {
        let subject = HermesSubjectID(rawValue: "native-pass-a")!
        let natal = instant(year: 1985, month: 4, day: 10, hour: 20, minute: 16)
        var starter = SynchronicSpineActIStarter()

        let foundation = try starter.start(
            subjectID: subject,
            natal: natal,
            occurredAt: natal
        )

        XCTAssertEqual(foundation.commission.subjectID, subject)
        XCTAssertEqual(foundation.commission.packageKind.rawValue, "synchronic-spine-schematic")
        XCTAssertEqual(
            foundation.commission.addresses,
            [
                SynchronicSpineActIStarter.clotho,
                SynchronicSpineActIStarter.hephaestus,
                SynchronicSpineActIStarter.timeGarden,
            ]
        )

        let events = starter.courier.manifest.events(for: foundation.commission.ticketID)
        XCTAssertEqual(events.map(\.kind), [.ticketOpened, .deliveredToStop])
        XCTAssertEqual(events.last?.address, SynchronicSpineActIStarter.clotho)
        XCTAssertEqual(
            starter.courier.manifest.currentState(for: foundation.commission.ticketID),
            .unresolved
        )
        XCTAssertEqual(
            starter.courier.manifest.unresolvedTickets(),
            [foundation.commission.ticketID]
        )
    }

    func testDuplicateCommissionForSameNativeIsRejected() throws {
        let subject = HermesSubjectID(rawValue: "native-duplicate")!
        let natal = instant(year: 2000, month: 1, day: 1)
        var starter = SynchronicSpineActIStarter()

        _ = try starter.start(subjectID: subject, natal: natal, occurredAt: natal)

        XCTAssertThrowsError(
            try starter.start(subjectID: subject, natal: natal, occurredAt: natal)
        ) { error in
            XCTAssertEqual(error as? SynchronicSpinePassAFailure, .duplicateCommission)
        }

        XCTAssertEqual(starter.courier.manifest.unresolvedTickets().count, 1)
    }

    func testPatternRequiresExactlyOneTwelveSevenThreeTwelve() throws {
        let foundation = try makeFoundation(subject: "native-pattern")
        let pattern = foundation.pattern

        XCTAssertTrue(
            pattern.matchesInventory(
                boneCount: 1,
                asteriaPassCount: 12,
                themisImprintCount: 7,
                oceanusTideCount: 3,
                rheaQualifierCount: 12
            )
        )

        XCTAssertFalse(pattern.matchesInventory(boneCount: 0, asteriaPassCount: 12, themisImprintCount: 7, oceanusTideCount: 3, rheaQualifierCount: 12))
        XCTAssertFalse(pattern.matchesInventory(boneCount: 2, asteriaPassCount: 12, themisImprintCount: 7, oceanusTideCount: 3, rheaQualifierCount: 12))

        for count in [11, 13] {
            XCTAssertFalse(pattern.matchesInventory(boneCount: 1, asteriaPassCount: count, themisImprintCount: 7, oceanusTideCount: 3, rheaQualifierCount: 12))
        }
        for count in [6, 8] {
            XCTAssertFalse(pattern.matchesInventory(boneCount: 1, asteriaPassCount: 12, themisImprintCount: count, oceanusTideCount: 3, rheaQualifierCount: 12))
        }
        for count in [2, 4] {
            XCTAssertFalse(pattern.matchesInventory(boneCount: 1, asteriaPassCount: 12, themisImprintCount: 7, oceanusTideCount: count, rheaQualifierCount: 12))
        }
        for count in [11, 13] {
            XCTAssertFalse(pattern.matchesInventory(boneCount: 1, asteriaPassCount: 12, themisImprintCount: 7, oceanusTideCount: 3, rheaQualifierCount: count))
        }
    }

    func testClothoCutsExactGregorianBoneAroundNatalInstant() throws {
        let subject = HermesSubjectID(rawValue: "native-bone")!
        let natal = instant(year: 1985, month: 4, day: 10, hour: 20, minute: 16)
        var starter = SynchronicSpineActIStarter()

        let foundation = try starter.start(subjectID: subject, natal: natal, occurredAt: natal)

        XCTAssertEqual(foundation.bone.start, instant(year: 1984, month: 4, day: 10, hour: 20, minute: 16))
        XCTAssertEqual(foundation.bone.natal, natal)
        XCTAssertEqual(foundation.bone.end, instant(year: 2085, month: 4, day: 10, hour: 20, minute: 16))
        XCTAssertLessThan(foundation.bone.start.unixSecondsSince1970, natal.unixSecondsSince1970)
        XCTAssertLessThan(natal.unixSecondsSince1970, foundation.bone.end.unixSecondsSince1970)
    }

    func testBoneContainsOnlyItsClosedTemporalDomain() throws {
        let foundation = try makeFoundation(subject: "native-domain")
        let bone = foundation.bone

        XCTAssertTrue(bone.contains(bone.start))
        XCTAssertTrue(bone.contains(bone.natal))
        XCTAssertTrue(bone.contains(bone.end))
        XCTAssertFalse(bone.contains(AbsoluteInstant(unixSecondsSince1970: bone.start.unixSecondsSince1970 - 1)!))
        XCTAssertFalse(bone.contains(AbsoluteInstant(unixSecondsSince1970: bone.end.unixSecondsSince1970 + 1)!))
    }

    func testLachesisRejectsFoundationWhoseNativeIdentityDoesNotMatch() throws {
        let foundation = try makeFoundation(subject: "native-lawful")
        let wrongSubject = HermesSubjectID(rawValue: "native-wrong")!
        let wrongPattern = SynchronicSpinePattern(
            subjectID: wrongSubject,
            ticketID: foundation.commission.ticketID
        )
        let mismatched = SynchronicSpineFoundation(
            commission: foundation.commission,
            pattern: wrongPattern,
            bone: foundation.bone
        )

        XCTAssertThrowsError(try Lachesis.receiveSynchronicSpineFoundation(mismatched)) { error in
            XCTAssertEqual(error as? SynchronicSpinePassAFailure, .mismatchedFoundation)
        }
    }

    func testPassAIntegrationPreservesCommissionPatternAndBoneIdentityIntoLachesis() throws {
        let subject = HermesSubjectID(rawValue: "native-integration")!
        let natal = instant(year: 1992, month: 7, day: 19, hour: 6, minute: 30)
        var starter = SynchronicSpineActIStarter()

        let ready = try starter.start(subjectID: subject, natal: natal, occurredAt: natal)

        XCTAssertEqual(ready.commission.subjectID, subject)
        XCTAssertEqual(ready.pattern.subjectID, subject)
        XCTAssertEqual(ready.bone.subjectID, subject)
        XCTAssertEqual(ready.pattern.ticketID, ready.commission.ticketID)
        XCTAssertEqual(ready.bone.ticketID, ready.commission.ticketID)
        XCTAssertEqual(ready.bone.natal, natal)
        XCTAssertEqual(starter.courier.manifest.unresolvedTickets(), [ready.commission.ticketID])
    }

    private func makeFoundation(subject: String) throws -> SynchronicSpineFoundation {
        let subjectID = HermesSubjectID(rawValue: subject)!
        let natal = instant(year: 2001, month: 6, day: 15, hour: 12)
        var starter = SynchronicSpineActIStarter()
        return try starter.start(subjectID: subjectID, natal: natal, occurredAt: natal)
    }

    private func instant(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0
    ) -> AbsoluteInstant {
        let date = CivilDate(year: year, month: month, day: day)!
        let time = CivilClockTime(hour: hour, minute: minute, second: second)!
        let offset = UTCOffset(secondsEast: 0)!

        switch CivilTime.resolve(date: date, time: time, fixedOffset: offset) {
        case .resolved(let match):
            return match.instant
        default:
            XCTFail("Expected resolvable Gregorian UTC instant")
            return AbsoluteInstant(unixSecondsSince1970: 0)!
        }
    }
}
