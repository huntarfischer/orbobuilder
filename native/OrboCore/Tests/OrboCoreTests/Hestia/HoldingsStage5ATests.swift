import XCTest
@testable import OrboCore

final class HoldingsStage5ATests: XCTestCase {
    private func subject(_ rawValue: String) throws -> HermesSubjectID {
        try XCTUnwrap(HermesSubjectID(rawValue: rawValue))
    }

    private func astroDNA(rawValue: Int) throws -> AstroDNA {
        try XCTUnwrap(
            AstroDNA(rawSequence: Array(repeating: rawValue, count: AstroDNA.geneCount))
        )
    }

    func testFreshHoldingsIsEmpty() {
        let holdings = Holdings()

        XCTAssertTrue(holdings.holdings.isEmpty)
    }

    func testFirstHoldingCanBeAdmitted() throws {
        let saved = try subject("saved-person")
        let dna = try astroDNA(rawValue: 1)
        var holdings = Holdings()

        try holdings.admit(Holding(subjectID: saved, astroDNA: dna))

        XCTAssertEqual(holdings.holdings.count, 1)
    }

    func testMultipleDifferentSubjectsCanBeAdmitted() throws {
        let first = try subject("first")
        let second = try subject("second")
        let firstDNA = try astroDNA(rawValue: 1)
        let secondDNA = try astroDNA(rawValue: 2)
        var holdings = Holdings()

        try holdings.admit(Holding(subjectID: first, astroDNA: firstDNA))
        try holdings.admit(Holding(subjectID: second, astroDNA: secondDNA))

        XCTAssertEqual(holdings.holdings.count, 2)
        XCTAssertEqual(holdings.holdings.map(\.subjectID), [first, second])
    }

    func testHoldingPreservesExactSubjectIDAndAstroDNA() throws {
        let saved = try subject("saved-person")
        let dna = try astroDNA(rawValue: 1)
        let holding = Holding(subjectID: saved, astroDNA: dna)

        XCTAssertEqual(holding.subjectID, saved)
        XCTAssertEqual(holding.astroDNA, dna)
    }

    func testDuplicateSubjectIsRejected() throws {
        let saved = try subject("saved-person")
        let firstDNA = try astroDNA(rawValue: 1)
        let secondDNA = try astroDNA(rawValue: 2)
        var holdings = Holdings()

        try holdings.admit(Holding(subjectID: saved, astroDNA: firstDNA))

        XCTAssertThrowsError(
            try holdings.admit(Holding(subjectID: saved, astroDNA: secondDNA))
        ) { error in
            XCTAssertEqual(error as? Holdings.Failure, .duplicateSubject)
        }
    }

    func testFailedDuplicateAdmissionLeavesOriginalUnchanged() throws {
        let saved = try subject("saved-person")
        let firstDNA = try astroDNA(rawValue: 1)
        let secondDNA = try astroDNA(rawValue: 2)
        var holdings = Holdings()

        let original = Holding(subjectID: saved, astroDNA: firstDNA)
        try holdings.admit(original)

        XCTAssertThrowsError(
            try holdings.admit(Holding(subjectID: saved, astroDNA: secondDNA))
        )
        XCTAssertEqual(holdings.holdings, [original])
    }

    func testLookupBySubjectIDReturnsExactHolding() throws {
        let first = try subject("first")
        let second = try subject("second")
        let firstHolding = Holding(subjectID: first, astroDNA: try astroDNA(rawValue: 1))
        let secondHolding = Holding(subjectID: second, astroDNA: try astroDNA(rawValue: 2))
        var holdings = Holdings()

        try holdings.admit(firstHolding)
        try holdings.admit(secondHolding)

        XCTAssertEqual(holdings.holding(for: first), firstHolding)
        XCTAssertEqual(holdings.holding(for: second), secondHolding)
    }
}
