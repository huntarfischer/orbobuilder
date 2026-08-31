import XCTest
@testable import OrboCore

final class NatalSpineActIBeat2HearthIntakeTests: XCTestCase {
    func testUnlitHearthCannotSupplyNatalSpineTruth() {
        let hestia = Hestia(nativeSubjectID: NatalSpineTestFixture.subjectID)

        XCTAssertThrowsError(
            try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        ) { error in
            XCTAssertEqual(
                error as? NatalSpineHearthIntakeFailure,
                .hearthUnlit
            )
        }
    }

    func testHearthRejectsDifferentSubjectAtNatalSpineIntake() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let other = HermesSubjectID(rawValue: "natal-spine.fixture.other")!

        XCTAssertThrowsError(
            try hestia.natalSpineNativeTruth(for: other)
        ) { error in
            XCTAssertEqual(
                error as? NatalSpineHearthIntakeFailure,
                .wrongSubject
            )
        }
    }

    func testLitHearthSuppliesExactKeptTempusTapestryAndPreservedSect() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let engraving = try XCTUnwrap(hestia.nativeEngraving())
        let expectedTapestry = try XCTUnwrap(engraving.tapestry)
        let expectedTempus = try XCTUnwrap(engraving.tempus)

        let truth = try hestia.natalSpineNativeTruth(
            for: NatalSpineTestFixture.subjectID
        )

        XCTAssertEqual(truth.subjectID, NatalSpineTestFixture.subjectID)
        XCTAssertEqual(truth.tempus, expectedTempus)
        XCTAssertEqual(truth.tapestry, expectedTapestry)

        let conditions = expectedTapestry.tapestry.degrees.flatMap { $0.mater.conditions }
        XCTAssertFalse(conditions.isEmpty)
        switch truth.sect {
        case .day:
            XCTAssertTrue(conditions.allSatisfy { $0.sectDay && !$0.sectNight })
        case .night:
            XCTAssertTrue(conditions.allSatisfy { !$0.sectDay && $0.sectNight })
        }
    }

    func testHearthPersistenceRoundTripPreservesNatalSpineIntakeExactly() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let before = try hestia.natalSpineNativeTruth(
            for: NatalSpineTestFixture.subjectID
        )

        let restored = try HestiaPersistence.decode(
            HestiaPersistence.encode(hestia)
        )
        let after = try restored.natalSpineNativeTruth(
            for: NatalSpineTestFixture.subjectID
        )

        XCTAssertEqual(after, before)
    }

    func testHearthIntakeDoesNotAlterCanonicalTapestry() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let before = try XCTUnwrap(
            hestia.canonicalTapestry(for: NatalSpineTestFixture.subjectID)
        )

        _ = try hestia.natalSpineNativeTruth(
            for: NatalSpineTestFixture.subjectID
        )

        let after = try XCTUnwrap(
            hestia.canonicalTapestry(for: NatalSpineTestFixture.subjectID)
        )
        XCTAssertEqual(after, before)
    }
}
