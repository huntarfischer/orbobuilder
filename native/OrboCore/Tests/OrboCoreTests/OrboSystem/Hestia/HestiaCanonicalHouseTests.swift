import XCTest
@testable import OrboCore

final class HestiaCanonicalHouseTests: XCTestCase {
    private typealias F = HestiaCanonicalPersistenceFixture

    func testFreshHestiaHasEmptyHearthHallAndHoldings() throws {
        let native = try F.subject("native")
        let stranger = try F.subject("stranger")
        let hestia = Hestia(nativeSubjectID: native)

        XCTAssertFalse(hestia.hearthLit)
        XCTAssertNil(hestia.nativeEngraving())
        XCTAssertNil(hestia.canonicalTapestry(for: native))
        XCTAssertNil(hestia.holding(stranger))
        XCTAssertNil(hestia.saved(stranger))
        XCTAssertTrue(hestia.holdings.holdings.isEmpty)
        XCTAssertTrue(hestia.hall.residents.isEmpty)
    }

    func testHallAdmitsDifferentCanonicalSavedSubjects() throws {
        var hall = Hall()
        let first = try F.canonicalHallResident(subjectID: F.subject("saved.one"))
        let second = try F.canonicalHallResident(subjectID: F.subject("saved.two"))

        try hall.admit(first)
        try hall.admit(second)

        XCTAssertEqual(hall.residents, [first, second])
    }

    func testHallPreservesSubjectAstroDNAAndExactCanonicalSeal() throws {
        var hall = Hall()
        let resident = try F.canonicalHallResident(subjectID: F.subject("saved.one"))

        try hall.admit(resident)
        let stored = try XCTUnwrap(hall.resident(for: resident.subjectID))

        XCTAssertEqual(stored.subjectID, resident.subjectID)
        XCTAssertEqual(stored.astroDNA, resident.astroDNA)
        XCTAssertEqual(stored.tapestry, resident.tapestry)
        XCTAssertEqual(stored, resident)
    }

    func testHallRejectsDuplicateSubjectWithoutMutation() throws {
        var hall = Hall()
        let subject = try F.subject("saved.one")
        let first = try F.canonicalHallResident(subjectID: subject)
        let duplicate = try F.canonicalHallResident(subjectID: subject)

        try hall.admit(first)
        XCTAssertThrowsError(try hall.admit(duplicate)) { error in
            XCTAssertEqual(error as? Hall.Failure, .duplicateSubject)
        }

        XCTAssertEqual(hall.residents, [first])
        XCTAssertEqual(hall.resident(for: subject), first)
    }

    func testLightweightSaveGoesToHoldingsOnly() throws {
        let native = try F.subject("native")
        let saved = try F.subject("saved-person")
        let dna = try F.astroDNA(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.hold(subjectID: saved, astroDNA: dna)

        XCTAssertEqual(hestia.holding(saved), Holding(subjectID: saved, astroDNA: dna))
        XCTAssertNil(hestia.saved(saved))
        XCTAssertNil(hestia.nativeEngraving())
    }

    func testNativeCannotEnterHoldings() throws {
        let native = try F.subject("native")
        var hestia = Hestia(nativeSubjectID: native)

        XCTAssertThrowsError(
            try hestia.hold(subjectID: native, astroDNA: F.astroDNA(rawValue: 0))
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .nativeCannotEnterHoldings)
        }

        XCTAssertNil(hestia.holding(native))
        XCTAssertTrue(hestia.holdings.holdings.isEmpty)
    }

    func testHallResidentCannotAlsoEnterHoldings() throws {
        let native = try F.subject("native")
        let saved = try F.subject("saved-person")
        let resident = try F.canonicalHallResident(subjectID: saved)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(
            subjectID: saved,
            astroDNA: resident.astroDNA,
            tapestry: resident.tapestry
        )
        let original = hestia.saved(saved)

        XCTAssertThrowsError(
            try hestia.hold(subjectID: saved, astroDNA: resident.astroDNA)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .savedSubjectAlreadyAdmitted)
        }

        XCTAssertNil(hestia.holding(saved))
        XCTAssertEqual(hestia.saved(saved), original)
    }

    func testHoldingCannotAlsoEnterHall() throws {
        let native = try F.subject("native")
        let saved = try F.subject("saved-person")
        let resident = try F.canonicalHallResident(subjectID: saved)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.hold(subjectID: saved, astroDNA: resident.astroDNA)
        let original = hestia.holding(saved)

        XCTAssertThrowsError(
            try hestia.admit(
                subjectID: saved,
                astroDNA: resident.astroDNA,
                tapestry: resident.tapestry
            )
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .subjectAlreadyInHoldings)
        }

        XCTAssertEqual(hestia.holding(saved), original)
        XCTAssertNil(hestia.saved(saved))
    }

    func testDuplicateHoldingIsRejectedWithoutMutation() throws {
        let native = try F.subject("native")
        let saved = try F.subject("saved-person")
        let firstDNA = try F.astroDNA(rawValue: 1)
        let secondDNA = try F.astroDNA(rawValue: 2)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.hold(subjectID: saved, astroDNA: firstDNA)
        let original = hestia.holding(saved)

        XCTAssertThrowsError(
            try hestia.hold(subjectID: saved, astroDNA: secondDNA)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .subjectAlreadyInHoldings)
        }

        XCTAssertEqual(hestia.holding(saved), original)
        XCTAssertEqual(hestia.holdings.holdings.count, 1)
    }

    func testCanonicalTruthLivesInHearthAndHallButNotHoldings() throws {
        let native = try F.subject("native")
        let held = try F.subject("held-person")
        let saved = try F.subject("hall-person")
        var hestia = try F.litHestia(subjectID: native)
        let hallResident = try F.canonicalHallResident(subjectID: saved)
        let heldDNA = try F.astroDNA(rawValue: 1)

        try hestia.hold(subjectID: held, astroDNA: heldDNA)
        try hestia.admit(
            subjectID: saved,
            astroDNA: hallResident.astroDNA,
            tapestry: hallResident.tapestry
        )

        XCTAssertNotNil(hestia.canonicalTapestry(for: native))
        XCTAssertEqual(hestia.saved(saved)?.tapestry, hallResident.tapestry)
        XCTAssertNil(hestia.saved(held))
        XCTAssertEqual(hestia.holding(held)?.astroDNA, heldDNA)
    }
}
