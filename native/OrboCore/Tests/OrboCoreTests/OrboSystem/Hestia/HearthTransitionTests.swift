import XCTest
@testable import OrboCore

final class HearthTransitionTests: XCTestCase {
    private typealias F = HestiaCanonicalPersistenceFixture

    func testHangAuthorsLightingConsequenceFromExactFinishedEngraving() throws {
        let native = try F.subject("native")
        let worked = try F.canonicalWorkedPackage(subjectID: native)
        var hearth = Hearth(nativeSubjectID: native)

        let lighting = try hearth.hang(worked.contents)

        XCTAssertEqual(lighting.subjectID, native)
        XCTAssertEqual(lighting.engraving.subjectID, native)
        XCTAssertTrue(lighting.engraving.engraved)
        XCTAssertEqual(hearth.engraving, lighting.engraving)
        XCTAssertTrue(hearth.hearthLit)
    }

    func testFailedHangCannotProduceLightingOrMutateHearth() throws {
        let native = try F.subject("native")
        let stranger = try F.subject("stranger")
        let worked = try F.canonicalWorkedPackage(subjectID: stranger)
        var hearth = Hearth(nativeSubjectID: native)

        XCTAssertThrowsError(try hearth.hang(worked.contents)) { error in
            XCTAssertEqual(error as? Hearth.Failure, .wrongSubject)
        }

        XCTAssertNil(hearth.engraving)
        XCTAssertFalse(hearth.hearthLit)
    }

    func testLightingCanOccurOnlyOnceForAEstablishedHearth() throws {
        let native = try F.subject("native")
        let worked = try F.canonicalWorkedPackage(subjectID: native)
        var hearth = Hearth(nativeSubjectID: native)

        let firstLighting = try hearth.hang(worked.contents)

        XCTAssertThrowsError(try hearth.hang(worked.contents)) { error in
            XCTAssertEqual(error as? Hearth.Failure, .alreadyEstablished)
        }
        XCTAssertEqual(hearth.engraving, firstLighting.engraving)
        XCTAssertTrue(hearth.hearthLit)
    }

    func testHestiaReceivesLightingWhilePreservingCanonicalReceiveContract() throws {
        let native = try F.subject("native")
        let worked = try F.canonicalWorkedPackage(subjectID: native)
        var hestia = Hestia(nativeSubjectID: native)

        let finished = try hestia.receive(worked)

        XCTAssertTrue(hestia.hearthLit)
        XCTAssertTrue(finished.engraved)
        XCTAssertEqual(hestia.nativeEngraving(), finished)
        XCTAssertEqual(hestia.canonicalTapestry(for: native), finished.tapestry)
    }
}
