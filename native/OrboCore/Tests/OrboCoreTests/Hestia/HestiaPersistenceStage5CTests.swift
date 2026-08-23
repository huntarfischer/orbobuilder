import Foundation
import XCTest
@testable import OrboCore

final class HestiaPersistenceStage5CTests: XCTestCase {
    private func subject(_ rawValue: String) throws -> HermesSubjectID {
        try XCTUnwrap(HermesSubjectID(rawValue: rawValue))
    }

    private func astroDNA(rawValue: Int) throws -> AstroDNA {
        try XCTUnwrap(
            AstroDNA(
                rawSequence: Array(
                    repeating: rawValue,
                    count: AstroDNA.geneCount
                )
            )
        )
    }

    private func tapestry(for astroDNA: AstroDNA) throws -> AtroposPackage {
        let output = Clotho.gather(from: astroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        return try Atropos.inspect(recipe: output.recipe, grid: grid).get()
    }

    private func sealed(rawValue: Int) throws -> (AstroDNA, AtroposPackage) {
        let dna = try astroDNA(rawValue: rawValue)
        return (dna, try tapestry(for: dna))
    }

    func testEmptyHouseRoundTrips() throws {
        let native = try subject("native")
        let hestia = Hestia(nativeSubjectID: native)

        let restored = try HestiaPersistence.decode(
            HestiaPersistence.encode(hestia)
        )

        XCTAssertEqual(restored.nativeSubjectID, native)
        XCTAssertNil(restored.native())
        XCTAssertTrue(restored.holdings.holdings.isEmpty)
        XCTAssertTrue(restored.hall.residents.isEmpty)
    }

    func testHoldingsRoundTripExactly() throws {
        let native = try subject("native")
        let first = try subject("first")
        let second = try subject("second")
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.hold(subjectID: first, astroDNA: astroDNA(rawValue: 0))
        try hestia.hold(subjectID: second, astroDNA: astroDNA(rawValue: 3600))

        let restored = try HestiaPersistence.decode(
            HestiaPersistence.encode(hestia)
        )

        XCTAssertEqual(restored.holdings, hestia.holdings)
        XCTAssertEqual(restored.holding(first), hestia.holding(first))
        XCTAssertEqual(restored.holding(second), hestia.holding(second))
    }

    func testHearthRoundTripsExactlyWithoutDuplicatingNativeIdentity() throws {
        let native = try subject("native")
        let (dna, tapestry) = try sealed(rawValue: 0)
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.admit(subjectID: native, astroDNA: dna, tapestry: tapestry)

        let data = try HestiaPersistence.encode(hestia)
        let restored = try HestiaPersistence.decode(data)

        XCTAssertEqual(restored.nativeSubjectID, native)
        XCTAssertEqual(restored.native(), hestia.native())
        XCTAssertEqual(restored.tapestry(for: native), tapestry)

        let root = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        XCTAssertNil(root["nativeSubjectID"])
        let hearth = try XCTUnwrap(root["hearth"] as? [String: Any])
        let resident = try XCTUnwrap(hearth["resident"] as? [String: Any])
        XCTAssertNil(resident["subjectID"])
    }

    func testHallRoundTripsExactlyAndPreservesOrder() throws {
        let native = try subject("native")
        let first = try subject("first")
        let second = try subject("second")
        let (firstDNA, firstTapestry) = try sealed(rawValue: 3600)
        let (secondDNA, secondTapestry) = try sealed(rawValue: 7200)
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.admit(subjectID: first, astroDNA: firstDNA, tapestry: firstTapestry)
        try hestia.admit(subjectID: second, astroDNA: secondDNA, tapestry: secondTapestry)

        let restored = try HestiaPersistence.decode(
            HestiaPersistence.encode(hestia)
        )

        XCTAssertEqual(restored.hall.residents, hestia.hall.residents)
        XCTAssertEqual(restored.hall.residents.map(\.subjectID), [first, second])
    }

    func testTapestriesRestoreExactlyWithoutReweaving() throws {
        let native = try subject("native")
        let saved = try subject("saved")
        let (nativeDNA, nativeTapestry) = try sealed(rawValue: 0)
        let (savedDNA, savedTapestry) = try sealed(rawValue: 3600)
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.admit(
            subjectID: native,
            astroDNA: nativeDNA,
            tapestry: nativeTapestry
        )
        try hestia.admit(
            subjectID: saved,
            astroDNA: savedDNA,
            tapestry: savedTapestry
        )

        let restored = try HestiaPersistence.decode(
            HestiaPersistence.encode(hestia)
        )

        XCTAssertEqual(restored.tapestry(for: native), nativeTapestry)
        XCTAssertEqual(restored.tapestry(for: saved), savedTapestry)
        XCTAssertEqual(
            restored.tapestry(for: native)?.grid.cells,
            nativeTapestry.grid.cells
        )
        XCTAssertEqual(
            restored.tapestry(for: saved)?.grid.cells,
            savedTapestry.grid.cells
        )
    }

    func testUnsupportedPersistenceCodecIsRejected() throws {
        let native = try subject("native")
        let data = try HestiaPersistence.encode(Hestia(nativeSubjectID: native))
        var root = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        root["codec"] = 999
        let changed = try JSONSerialization.data(withJSONObject: root)

        XCTAssertThrowsError(try HestiaPersistence.decode(changed)) { error in
            XCTAssertEqual(
                error as? HestiaPersistenceFailure,
                .unsupportedCodec(999)
            )
        }
    }

    func testInvalidHouseAndMismatchedTapestryAreRejected() throws {
        let native = try subject("native")
        let saved = try subject("saved")
        let (nativeDNA, nativeTapestry) = try sealed(rawValue: 0)
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.hold(subjectID: saved, astroDNA: astroDNA(rawValue: 3600))
        try hestia.admit(
            subjectID: native,
            astroDNA: nativeDNA,
            tapestry: nativeTapestry
        )

        let data = try HestiaPersistence.encode(hestia)

        var invalidHouseRoot = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let houseHearth = try XCTUnwrap(
            invalidHouseRoot["hearth"] as? [String: Any]
        )
        let nativeID = try XCTUnwrap(houseHearth["nativeSubjectID"])
        var holdings = try XCTUnwrap(
            invalidHouseRoot["holdings"] as? [[String: Any]]
        )
        var firstHolding = holdings[0]
        firstHolding["subjectID"] = nativeID
        holdings[0] = firstHolding
        invalidHouseRoot["holdings"] = holdings
        let invalidHouseData = try JSONSerialization.data(
            withJSONObject: invalidHouseRoot
        )

        XCTAssertThrowsError(
            try HestiaPersistence.decode(invalidHouseData)
        ) { error in
            XCTAssertEqual(error as? HestiaPersistenceFailure, .invalidHouse)
        }

        var mismatchRoot = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        var mismatchHearth = try XCTUnwrap(
            mismatchRoot["hearth"] as? [String: Any]
        )
        var resident = try XCTUnwrap(
            mismatchHearth["resident"] as? [String: Any]
        )
        var dna = try XCTUnwrap(resident["astroDNA"] as? [String: Any])
        dna["sequence"] = Array(
            repeating: 3600,
            count: AstroDNA.geneCount
        )
        resident["astroDNA"] = dna
        mismatchHearth["resident"] = resident
        mismatchRoot["hearth"] = mismatchHearth
        let mismatchData = try JSONSerialization.data(withJSONObject: mismatchRoot)

        XCTAssertThrowsError(try HestiaPersistence.decode(mismatchData)) { error in
            XCTAssertEqual(
                error as? HestiaPersistenceFailure,
                .invalidTapestry
            )
        }
    }

    func testAtomicFileSaveAndLoadRoundTripsHouse() throws {
        let native = try subject("native")
        let held = try subject("held")
        let saved = try subject("saved")
        let (nativeDNA, nativeTapestry) = try sealed(rawValue: 0)
        let (savedDNA, savedTapestry) = try sealed(rawValue: 3600)
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.hold(subjectID: held, astroDNA: astroDNA(rawValue: 7200))
        try hestia.admit(
            subjectID: native,
            astroDNA: nativeDNA,
            tapestry: nativeTapestry
        )
        try hestia.admit(
            subjectID: saved,
            astroDNA: savedDNA,
            tapestry: savedTapestry
        )

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hestia-stage5c-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }

        try HestiaPersistence.save(hestia, to: url)
        let restored = try HestiaPersistence.load(from: url)

        XCTAssertEqual(restored, hestia)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
}
