import XCTest
@testable import OrboCore

final class HestiaStage3Tests: XCTestCase {
    private func sealedTapestry(rawValue: Int) throws -> (AstroDNA, AtroposPackage) {
        let rawSequence = Array(repeating: rawValue, count: AstroDNA.geneCount)
        let astroDNA = try XCTUnwrap(AstroDNA(rawSequence: rawSequence))
        let output = Clotho.gather(from: astroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        let tapestry = try Atropos.inspect(recipe: output.recipe, grid: grid).get()
        return (astroDNA, tapestry)
    }

    private func subject(_ rawValue: String) throws -> HermesSubjectID {
        try XCTUnwrap(HermesSubjectID(rawValue: rawValue))
    }

    func testFreshHestiaHasEmptyHearthAndHall() throws {
        let native = try subject("native")
        let hestia = Hestia(nativeSubjectID: native)

        XCTAssertEqual(hestia.nativeSubjectID, native)
        XCTAssertNil(hestia.native())
        XCTAssertTrue(hestia.hall.residents.isEmpty)
    }

    func testNativeAdmissionEstablishesHearthOnly() throws {
        let native = try subject("native")
        let (astroDNA, tapestry) = try sealedTapestry(rawValue: 0)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: native, astroDNA: astroDNA, tapestry: tapestry)

        XCTAssertEqual(hestia.native()?.subjectID, native)
        XCTAssertEqual(hestia.native()?.astroDNA, astroDNA)
        XCTAssertEqual(hestia.native()?.tapestry, tapestry)
        XCTAssertTrue(hestia.hall.residents.isEmpty)
    }

    func testSavedAdmissionGoesToHallOnly() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (astroDNA, tapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: saved, astroDNA: astroDNA, tapestry: tapestry)

        XCTAssertNil(hestia.native())
        XCTAssertEqual(hestia.saved(saved)?.subjectID, saved)
        XCTAssertEqual(hestia.saved(saved)?.astroDNA, astroDNA)
        XCTAssertEqual(hestia.saved(saved)?.tapestry, tapestry)
    }

    func testNativeNeverAppearsInHall() throws {
        let native = try subject("native")
        let (astroDNA, tapestry) = try sealedTapestry(rawValue: 0)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: native, astroDNA: astroDNA, tapestry: tapestry)

        XCTAssertNil(hestia.saved(native))
        XCTAssertFalse(hestia.hall.residents.contains { $0.subjectID == native })
    }

    func testSavedResidentNeverAppearsInHearth() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (astroDNA, tapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: saved, astroDNA: astroDNA, tapestry: tapestry)

        XCTAssertNil(hestia.native())
    }

    func testHallAdmissionCannotAlterHearth() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (nativeDNA, nativeTapestry) = try sealedTapestry(rawValue: 0)
        let (savedDNA, savedTapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: native, astroDNA: nativeDNA, tapestry: nativeTapestry)
        let originalNative = hestia.native()
        try hestia.admit(subjectID: saved, astroDNA: savedDNA, tapestry: savedTapestry)

        XCTAssertEqual(hestia.native(), originalNative)
    }

    func testHearthAdmissionCannotAlterHall() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (nativeDNA, nativeTapestry) = try sealedTapestry(rawValue: 0)
        let (savedDNA, savedTapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: saved, astroDNA: savedDNA, tapestry: savedTapestry)
        let originalSaved = hestia.saved(saved)
        try hestia.admit(subjectID: native, astroDNA: nativeDNA, tapestry: nativeTapestry)

        XCTAssertEqual(hestia.saved(saved), originalSaved)
    }

    func testDuplicateNativeAdmissionIsRejectedWithoutChangingHearth() throws {
        let native = try subject("native")
        let (firstDNA, firstTapestry) = try sealedTapestry(rawValue: 0)
        let (secondDNA, secondTapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: native, astroDNA: firstDNA, tapestry: firstTapestry)
        let originalNative = hestia.native()

        XCTAssertThrowsError(
            try hestia.admit(subjectID: native, astroDNA: secondDNA, tapestry: secondTapestry)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .nativeAlreadyEstablished)
        }
        XCTAssertEqual(hestia.native(), originalNative)
    }

    func testDuplicateSavedSubjectIsRejectedWithoutChangingHall() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (firstDNA, firstTapestry) = try sealedTapestry(rawValue: 1)
        let (secondDNA, secondTapestry) = try sealedTapestry(rawValue: 2)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: saved, astroDNA: firstDNA, tapestry: firstTapestry)
        let originalSaved = hestia.saved(saved)

        XCTAssertThrowsError(
            try hestia.admit(subjectID: saved, astroDNA: secondDNA, tapestry: secondTapestry)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .savedSubjectAlreadyAdmitted)
        }
        XCTAssertEqual(hestia.saved(saved), originalSaved)
        XCTAssertEqual(hestia.hall.residents.count, 1)
    }

    func testNativeAndSavedRetrievalReturnExactResidents() throws {
        let native = try subject("native")
        let saved = try subject("saved-person")
        let (nativeDNA, nativeTapestry) = try sealedTapestry(rawValue: 0)
        let (savedDNA, savedTapestry) = try sealedTapestry(rawValue: 1)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: native, astroDNA: nativeDNA, tapestry: nativeTapestry)
        try hestia.admit(subjectID: saved, astroDNA: savedDNA, tapestry: savedTapestry)

        XCTAssertEqual(
            hestia.native(),
            HearthResident(subjectID: native, astroDNA: nativeDNA, tapestry: nativeTapestry)
        )
        XCTAssertEqual(
            hestia.saved(saved),
            HallResident(subjectID: saved, astroDNA: savedDNA, tapestry: savedTapestry)
        )
    }
}
