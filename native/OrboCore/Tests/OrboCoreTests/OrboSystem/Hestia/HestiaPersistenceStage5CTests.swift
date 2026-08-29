import Foundation
import XCTest
@testable import OrboCore

final class HestiaPersistenceStage5CTests: XCTestCase {
    private typealias F = HestiaCanonicalPersistenceFixture

    func testEmptyHouseRoundTripsUnlit() throws {
        let native = try F.subject("native")
        let hestia = Hestia(nativeSubjectID: native)
        let restored = try HestiaPersistence.decode(HestiaPersistence.encode(hestia))

        XCTAssertEqual(restored, hestia)
        XCTAssertEqual(restored.nativeSubjectID, native)
        XCTAssertFalse(restored.hearthLit)
        XCTAssertNil(restored.nativeEngraving())
        XCTAssertNil(restored.canonicalTapestry(for: native))
        XCTAssertTrue(restored.holdings.holdings.isEmpty)
        XCTAssertTrue(restored.hall.residents.isEmpty)
    }

    func testHoldingsRoundTripExactly() throws {
        let native = try F.subject("native")
        let first = try F.subject("first")
        let second = try F.subject("second")
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.hold(subjectID: first, astroDNA: F.astroDNA(rawValue: 0))
        try hestia.hold(subjectID: second, astroDNA: F.astroDNA(rawValue: 3_600))

        let restored = try HestiaPersistence.decode(HestiaPersistence.encode(hestia))

        XCTAssertEqual(restored.holdings, hestia.holdings)
        XCTAssertEqual(restored.holding(first), hestia.holding(first))
        XCTAssertEqual(restored.holding(second), hestia.holding(second))
        XCTAssertFalse(restored.hearthLit)
    }

    func testCanonicalHearthRoundTripsExactFinishedEngravingAndTapestry() throws {
        let native = try F.subject("native")
        let hestia = try F.litHestia(subjectID: native)
        let beforeEngraving = try XCTUnwrap(hestia.nativeEngraving())
        let beforeTapestry = try XCTUnwrap(hestia.canonicalTapestry(for: native))
        let data = try HestiaPersistence.encode(hestia)
        let restored = try HestiaPersistence.decode(data)

        XCTAssertTrue(restored.hearthLit)
        XCTAssertEqual(restored.nativeEngraving(), beforeEngraving)
        XCTAssertEqual(restored.canonicalTapestry(for: native), beforeTapestry)
        XCTAssertEqual(restored.canonicalTapestry(for: native)?.tapestry, beforeTapestry.tapestry)
        XCTAssertEqual(restored, hestia)

        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let hearth = try XCTUnwrap(root["hearth"] as? [String: Any])
        XCTAssertEqual(hearth["hearthLit"] as? Bool, true)
        XCTAssertNotNil(hearth["engraving"])
        XCTAssertNil(hearth["resident"])
    }

    func testCanonicalHallRoundTripsExactlyAndPreservesOrder() throws {
        let native = try F.subject("native")
        let firstID = try F.subject("first")
        let secondID = try F.subject("second")
        let first = try F.canonicalHallResident(subjectID: firstID)
        let second = try F.canonicalHallResident(subjectID: secondID)
        var hestia = Hestia(nativeSubjectID: native)

        try hestia.admit(subjectID: firstID, astroDNA: first.astroDNA, tapestry: first.tapestry)
        try hestia.admit(subjectID: secondID, astroDNA: second.astroDNA, tapestry: second.tapestry)

        let restored = try HestiaPersistence.decode(HestiaPersistence.encode(hestia))

        XCTAssertEqual(restored.hall.residents, hestia.hall.residents)
        XCTAssertEqual(restored.hall.residents.map(\.subjectID), [firstID, secondID])
        XCTAssertEqual(restored.saved(firstID)?.tapestry, first.tapestry)
        XCTAssertEqual(restored.saved(secondID)?.tapestry, second.tapestry)
        XCTAssertFalse(restored.hearthLit)
    }

    func testFullCanonicalHouseRoundTripsExactlyThroughAtomicFileSave() throws {
        let native = try F.subject("native")
        let held = try F.subject("held")
        let savedID = try F.subject("saved")
        let saved = try F.canonicalHallResident(subjectID: savedID)
        var hestia = try F.litHestia(subjectID: native)
        try hestia.hold(subjectID: held, astroDNA: F.astroDNA(rawValue: 3_600))
        try hestia.admit(subjectID: savedID, astroDNA: saved.astroDNA, tapestry: saved.tapestry)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hestia-codec3-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }

        try HestiaPersistence.save(hestia, to: url)
        let restored = try HestiaPersistence.load(from: url)

        XCTAssertEqual(restored, hestia)
        XCTAssertTrue(restored.hearthLit)
        XCTAssertNotNil(restored.holding(held))
        XCTAssertEqual(restored.saved(savedID), saved)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testPreviousPersistenceCodecIsRejectedBeforeSnapshotDecode() throws {
        let native = try F.subject("native")
        let data = try HestiaPersistence.encode(Hestia(nativeSubjectID: native))
        var root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        root["codec"] = 2
        root["hearth"] = ["nativeSubjectID": "old-codec-shape"]
        let changed = try JSONSerialization.data(withJSONObject: root)

        XCTAssertThrowsError(try HestiaPersistence.decode(changed)) { error in
            XCTAssertEqual(error as? HestiaPersistenceFailure, .unsupportedCodec(2))
        }
    }

    func testImpossibleHearthStatesAreRejected() throws {
        let native = try F.subject("native")
        let unlitData = try HestiaPersistence.encode(Hestia(nativeSubjectID: native))
        var unlitRoot = try XCTUnwrap(JSONSerialization.jsonObject(with: unlitData) as? [String: Any])
        var unlitHearth = try XCTUnwrap(unlitRoot["hearth"] as? [String: Any])
        unlitHearth["hearthLit"] = true
        unlitRoot["hearth"] = unlitHearth
        let impossibleLit = try JSONSerialization.data(withJSONObject: unlitRoot)
        XCTAssertThrowsError(try HestiaPersistence.decode(impossibleLit)) { error in
            XCTAssertEqual(error as? HestiaPersistenceFailure, .invalidHearth)
        }

        let litData = try HestiaPersistence.encode(try F.litHestia(subjectID: native))
        var litRoot = try XCTUnwrap(JSONSerialization.jsonObject(with: litData) as? [String: Any])
        var litHearth = try XCTUnwrap(litRoot["hearth"] as? [String: Any])
        litHearth["hearthLit"] = false
        litRoot["hearth"] = litHearth
        let impossibleUnlit = try JSONSerialization.data(withJSONObject: litRoot)
        XCTAssertThrowsError(try HestiaPersistence.decode(impossibleUnlit)) { error in
            XCTAssertEqual(error as? HestiaPersistenceFailure, .invalidHearth)
        }
    }

    func testCorruptCanonicalTapestryAddressIsRejectedStructurally() throws {
        let native = try F.subject("native")
        let data = try HestiaPersistence.encode(try F.litHestia(subjectID: native))
        var root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        var hearth = try XCTUnwrap(root["hearth"] as? [String: Any])
        var engraving = try XCTUnwrap(hearth["engraving"] as? [String: Any])
        var tapestry = try XCTUnwrap(engraving["tapestry"] as? [String: Any])
        var degrees = try XCTUnwrap(tapestry["degrees"] as? [[String: Any]])
        degrees[0]["address"] = 1
        tapestry["degrees"] = degrees
        engraving["tapestry"] = tapestry
        hearth["engraving"] = engraving
        root["hearth"] = hearth
        let corrupted = try JSONSerialization.data(withJSONObject: root)

        XCTAssertThrowsError(try HestiaPersistence.decode(corrupted)) { error in
            XCTAssertEqual(error as? HestiaPersistenceFailure, .invalidTapestry)
        }
    }

    func testHouseOverlapIsRejectedOnRestore() throws {
        let native = try F.subject("native")
        let held = try F.subject("held")
        var hestia = Hestia(nativeSubjectID: native)
        try hestia.hold(subjectID: held, astroDNA: F.astroDNA(rawValue: 3_600))
        let data = try HestiaPersistence.encode(hestia)
        var root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let hearth = try XCTUnwrap(root["hearth"] as? [String: Any])
        let nativeID = try XCTUnwrap(hearth["nativeSubjectID"])
        var holdings = try XCTUnwrap(root["holdings"] as? [[String: Any]])
        holdings[0]["subjectID"] = nativeID
        root["holdings"] = holdings
        let invalid = try JSONSerialization.data(withJSONObject: root)

        XCTAssertThrowsError(try HestiaPersistence.decode(invalid)) { error in
            XCTAssertEqual(error as? HestiaPersistenceFailure, .invalidHouse)
        }
    }
}
