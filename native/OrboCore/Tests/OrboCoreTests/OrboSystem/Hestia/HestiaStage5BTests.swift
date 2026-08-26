import XCTest
@testable import OrboCore

final class HestiaStage5BTests: XCTestCase {
    private func subject(_ rawValue: String) throws -> HermesSubjectID {
        try XCTUnwrap(HermesSubjectID(rawValue: rawValue))
    }

    private func astroDNA(rawValue: Int) throws -> AstroDNA {
        try XCTUnwrap(
            AstroDNA(
                rawSequence: Array(repeating: rawValue, count: AstroDNA.geneCount)
            )
        )
    }

    private func sealedTapestry(rawValue: Int) throws -> (AstroDNA, AtroposPackage) {
        let astroDNA = try astroDNA(rawValue: rawValue)
        let output = LegacyMoiraiBridge.gather(from: astroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        let tapestry = try Atropos.inspect(recipe: output.recipe, grid: grid).get()
        return (astroDNA, tapestry)
    }

    func testFreshHestiaHasThreeEmptyKeptPlaces() throws {
        let native = try subject("native")
        let stranger = try subject("stranger")
        let hestia = Hestia(nativeSubjectID: native)

        XCTAssertNil(hestia.native())
        XCTAssertNil(hestia.holding(stranger))
        XCTAssertNil(hestia.saved(stranger))
        XCTAssertNil(hestia.tapestry(for: native))
        XCTAssertNil(hestia.tapestry(for: stranger))
    }

    func testLightweightSaveGoesToHoldingsOnly() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let dna = try astroDNA(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.hold(subjectID: saved, astroDNA: dna)

        XCTAssertEqual(
            hestia.holding(saved),
            Holding(subjectID: saved, astroDNA: dna)
        )
        XCTAssertNil(hestia.saved(saved))
        XCTAssertNil(hestia.tapestry(for: saved))
        XCTAssertNil(hestia.native())
    }

    func testNativeCannotEnterHoldings() throws {
        let native = try subject("native")
        let dna = try astroDNA(rawValue: 0)
        var hestia = Hestia(nativeSubjectID: native)

        XCTAssertThrowsError(
            try hestia.hold(subjectID: native, astroDNA: dna)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .nativeCannotEnterHoldings)
        }

        XCTAssertNil(hestia.holding(native))
        XCTAssertTrue(hestia.holdings.holdings.isEmpty)
    }

    func testHallResidentCannotAlsoEnterHoldings() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (dna, tapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: saved, astroDNA: dna, tapestry: tapestry)
        let originalResident = hestia.saved(saved)

        XCTAssertThrowsError(
            try hestia.hold(subjectID: saved, astroDNA: dna)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .savedSubjectAlreadyAdmitted)
        }

        XCTAssertNil(hestia.holding(saved))
        XCTAssertEqual(hestia.saved(saved), originalResident)
    }

    func testHoldingCannotAlsoEnterHall() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (dna, tapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.hold(subjectID: saved, astroDNA: dna)
        let originalHolding = hestia.holding(saved)

        XCTAssertThrowsError(
            try hestia.admit(subjectID: saved, astroDNA: dna, tapestry: tapestry)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .subjectAlreadyInHoldings)
        }

        XCTAssertEqual(hestia.holding(saved), originalHolding)
        XCTAssertNil(hestia.saved(saved))
        XCTAssertNil(hestia.tapestry(for: saved))
    }

    func testDuplicateHoldingIsRejectedThroughHestiaWithoutMutation() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let firstDNA = try astroDNA(rawValue: 1)
        let secondDNA = try astroDNA(rawValue: 2)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.hold(subjectID: saved, astroDNA: firstDNA)
        let originalHolding = hestia.holding(saved)

        XCTAssertThrowsError(
            try hestia.hold(subjectID: saved, astroDNA: secondDNA)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .subjectAlreadyInHoldings)
        }

        XCTAssertEqual(hestia.holding(saved), originalHolding)
        XCTAssertEqual(hestia.holdings.holdings.count, 1)
    }

    func testHestiaQueriesTapestriesAcrossHearthAndHallButNotHoldings() throws {
        let native = try subject("native")
        let held = try subject("held-person")
        let hallSubject = try subject("hall-person")
        let (nativeDNA, nativeTapestry) = try sealedTapestry(rawValue: 0)
        let heldDNA = try astroDNA(rawValue: 1)
        let (hallDNA, hallTapestry) = try sealedTapestry(rawValue: 2)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.hold(subjectID: held, astroDNA: heldDNA)
        try hestia.admit(
            subjectID: native,
            astroDNA: nativeDNA,
            tapestry: nativeTapestry
        )
        try hestia.admit(
            subjectID: hallSubject,
            astroDNA: hallDNA,
            tapestry: hallTapestry
        )

        XCTAssertEqual(hestia.tapestry(for: native), nativeTapestry)
        XCTAssertEqual(hestia.tapestry(for: hallSubject), hallTapestry)
        XCTAssertNil(hestia.tapestry(for: held))
        XCTAssertEqual(hestia.holding(held)?.astroDNA, heldDNA)
        XCTAssertEqual(hestia.saved(hallSubject)?.astroDNA, hallDNA)
    }
}
