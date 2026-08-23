import XCTest
@testable import OrboCore

final class HearthStage1Tests: XCTestCase {
    private let nativeSubjectID = HermesSubjectID(rawValue: "native")!
    private let otherSubjectID = HermesSubjectID(rawValue: "other")!

    private func resident(
        subjectID: HermesSubjectID,
        rawValue: Int = 0
    ) throws -> HearthResident {
        let rawSequence = Array(repeating: rawValue, count: AstroDNA.geneCount)
        let astroDNA = try XCTUnwrap(AstroDNA(rawSequence: rawSequence))
        let output = Clotho.gather(from: astroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        let tapestry = try Atropos.inspect(recipe: output.recipe, grid: grid).get()

        return HearthResident(
            subjectID: subjectID,
            astroDNA: astroDNA,
            tapestry: tapestry
        )
    }

    func testFreshHearthIsEmptyAndKnowsNativeSubject() {
        let hearth = Hearth(nativeSubjectID: nativeSubjectID)

        XCTAssertEqual(hearth.nativeSubjectID, nativeSubjectID)
        XCTAssertNil(hearth.resident)
    }

    func testMatchingNativeEstablishesHearthUnchanged() throws {
        var hearth = Hearth(nativeSubjectID: nativeSubjectID)
        let native = try resident(subjectID: nativeSubjectID)

        try hearth.establish(native)

        XCTAssertEqual(hearth.resident, native)
        XCTAssertEqual(hearth.resident?.subjectID, nativeSubjectID)
        XCTAssertEqual(hearth.resident?.astroDNA, native.astroDNA)
        XCTAssertEqual(hearth.resident?.tapestry, native.tapestry)
    }

    func testWrongSubjectIsRejectedAndHearthRemainsEmpty() throws {
        var hearth = Hearth(nativeSubjectID: nativeSubjectID)
        let other = try resident(subjectID: otherSubjectID)

        XCTAssertThrowsError(try hearth.establish(other)) { error in
            XCTAssertEqual(error as? Hearth.Failure, .wrongSubject)
        }
        XCTAssertNil(hearth.resident)
    }

    func testEstablishedHearthRejectsSecondEstablishment() throws {
        var hearth = Hearth(nativeSubjectID: nativeSubjectID)
        let first = try resident(subjectID: nativeSubjectID, rawValue: 0)
        let second = try resident(subjectID: nativeSubjectID, rawValue: 1)

        try hearth.establish(first)

        XCTAssertThrowsError(try hearth.establish(second)) { error in
            XCTAssertEqual(error as? Hearth.Failure, .alreadyEstablished)
        }
    }

    func testRejectedSecondEstablishmentCannotDisplaceNative() throws {
        var hearth = Hearth(nativeSubjectID: nativeSubjectID)
        let first = try resident(subjectID: nativeSubjectID, rawValue: 0)
        let second = try resident(subjectID: nativeSubjectID, rawValue: 1)

        try hearth.establish(first)
        XCTAssertThrowsError(try hearth.establish(second))

        XCTAssertEqual(hearth.resident, first)
        XCTAssertNotEqual(hearth.resident, second)
    }

    func testResidentRetrievalReturnsExactEstablishedResident() throws {
        var hearth = Hearth(nativeSubjectID: nativeSubjectID)
        let native = try resident(subjectID: nativeSubjectID)

        try hearth.establish(native)

        let retrieved = try XCTUnwrap(hearth.resident)
        XCTAssertEqual(retrieved, native)
    }
}
