import Foundation
import XCTest
@testable import OrboCore

final class HestiaRestartStage5DTests: XCTestCase {
    private typealias F = HestiaCanonicalPersistenceFixture

    private func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("hestia-restart-codec2-\(UUID().uuidString).json")
    }

    func testFullHouseSurvivesSaveDiscardAndLoadThroughCanonicalNativeQueries() throws {
        let native = try F.subject("native")
        let heldA = try F.subject("held-a")
        let heldB = try F.subject("held-b")
        let savedC = try F.subject("saved-c")
        let savedD = try F.subject("saved-d")
        let savedCDNA = try F.astroDNA(rawValue: 10_800)
        let savedDDNA = try F.astroDNA(rawValue: 14_400)

        var house: Hestia? = try F.litHestia(subjectID: native)
        try house?.hold(subjectID: heldA, astroDNA: F.astroDNA(rawValue: 3_600))
        try house?.hold(subjectID: heldB, astroDNA: F.astroDNA(rawValue: 7_200))
        try house?.admit(subjectID: savedC, astroDNA: savedCDNA, tapestry: F.legacyTapestry(for: savedCDNA))
        try house?.admit(subjectID: savedD, astroDNA: savedDDNA, tapestry: F.legacyTapestry(for: savedDDNA))

        let before = try XCTUnwrap(house)
        let beforeEngraving = try XCTUnwrap(before.nativeEngraving())
        let beforeTapestry = try XCTUnwrap(before.canonicalTapestry(for: native))
        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try HestiaPersistence.save(before, to: url)

        house = nil
        var restored = try HestiaPersistence.load(from: url)

        XCTAssertEqual(restored, before)
        XCTAssertTrue(restored.hearthLit)
        XCTAssertEqual(restored.nativeEngraving(), beforeEngraving)
        XCTAssertEqual(restored.canonicalTapestry(for: native), beforeTapestry)
        XCTAssertEqual(restored.holdings.holdings.map(\.subjectID), [heldA, heldB])
        XCTAssertEqual(restored.hall.residents.map(\.subjectID), [savedC, savedD])

        let extra = try F.subject("extra")
        try restored.hold(subjectID: extra, astroDNA: F.astroDNA(rawValue: 18_000))
        XCTAssertNotNil(restored.holding(extra))
    }

    func testRestoredHestiaStillEnforcesHouseBoundaries() throws {
        let native = try F.subject("native")
        let held = try F.subject("held")
        let saved = try F.subject("saved")
        let heldDNA = try F.astroDNA(rawValue: 3_600)
        let savedDNA = try F.astroDNA(rawValue: 7_200)
        var original = try F.litHestia(subjectID: native)
        try original.hold(subjectID: held, astroDNA: heldDNA)
        try original.admit(subjectID: saved, astroDNA: savedDNA, tapestry: F.legacyTapestry(for: savedDNA))

        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try HestiaPersistence.save(original, to: url)
        var restored = try HestiaPersistence.load(from: url)

        XCTAssertThrowsError(
            try restored.hold(subjectID: native, astroDNA: F.astroDNA(rawValue: 0))
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .nativeCannotEnterHoldings)
        }
        XCTAssertThrowsError(
            try restored.hold(subjectID: saved, astroDNA: savedDNA)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .savedSubjectAlreadyAdmitted)
        }
        XCTAssertNotNil(restored.holding(held))
        XCTAssertNotNil(restored.saved(saved))
        XCTAssertNil(restored.holding(native))
        XCTAssertTrue(restored.hearthLit)
    }

    func testRestartRestoresLitStateWithoutManufacturingHermesHistory() throws {
        let native = try F.subject("native")
        let original = try F.litHestia(subjectID: native)
        let restored = try HestiaPersistence.decode(HestiaPersistence.encode(original))
        var hermes = HermesCourier()
        let noticeAt = AbsoluteInstant(unixSecondsSince1970: 1_777_100_000)!

        XCTAssertTrue(restored.hearthLit)
        XCTAssertNotNil(restored.nativeEngraving())

        let notice = try restored.sendHearthLitNotice(
            to: OrboOnboarding.orboAddress,
            via: &hermes,
            occurredAt: noticeAt
        )
        XCTAssertEqual(
            hermes.manifest.events(for: notice.ticketID).map(\.kind),
            [.ticketOpened]
        )
    }
}
