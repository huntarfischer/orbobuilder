import Foundation
import XCTest
@testable import OrboCore

final class HestiaRestartStage5DTests: XCTestCase {
    private typealias F = HestiaCanonicalPersistenceFixture

    private func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("hestia-restart-codec3-\(UUID().uuidString).json")
    }

    func testFullHouseSurvivesSaveDiscardAndLoadThroughCanonicalQueries() throws {
        let native = try F.subject("native")
        let heldA = try F.subject("held-a")
        let heldB = try F.subject("held-b")
        let savedCID = try F.subject("saved-c")
        let savedDID = try F.subject("saved-d")
        let savedC = try F.canonicalHallResident(subjectID: savedCID)
        let savedD = try F.canonicalHallResident(subjectID: savedDID)

        var house: Hestia? = try F.litHestia(subjectID: native)
        try house?.hold(subjectID: heldA, astroDNA: F.astroDNA(rawValue: 3_600))
        try house?.hold(subjectID: heldB, astroDNA: F.astroDNA(rawValue: 7_200))
        try house?.admit(subjectID: savedCID, astroDNA: savedC.astroDNA, tapestry: savedC.tapestry)
        try house?.admit(subjectID: savedDID, astroDNA: savedD.astroDNA, tapestry: savedD.tapestry)

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
        XCTAssertEqual(restored.hall.residents.map(\.subjectID), [savedCID, savedDID])
        XCTAssertEqual(restored.saved(savedCID), savedC)
        XCTAssertEqual(restored.saved(savedDID), savedD)

        let extra = try F.subject("extra")
        try restored.hold(subjectID: extra, astroDNA: F.astroDNA(rawValue: 18_000))
        XCTAssertNotNil(restored.holding(extra))
    }

    func testRestoredHestiaStillEnforcesHouseBoundaries() throws {
        let native = try F.subject("native")
        let held = try F.subject("held")
        let savedID = try F.subject("saved")
        let saved = try F.canonicalHallResident(subjectID: savedID)
        var original = try F.litHestia(subjectID: native)
        try original.hold(subjectID: held, astroDNA: F.astroDNA(rawValue: 3_600))
        try original.admit(subjectID: savedID, astroDNA: saved.astroDNA, tapestry: saved.tapestry)

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
            try restored.hold(subjectID: savedID, astroDNA: saved.astroDNA)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .savedSubjectAlreadyAdmitted)
        }
        XCTAssertNotNil(restored.holding(held))
        XCTAssertEqual(restored.saved(savedID), saved)
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
