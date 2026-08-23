import Foundation
import XCTest
@testable import OrboCore

final class HestiaRestartStage5DTests: XCTestCase {
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestiaAddress = HermesAddress(rawValue: "orbo.hestia")!
    private let atroposPackage = HermesParcelKind(rawValue: "orbo.atropos-package.v1")!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

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

    private func parcel(
        subjectID: HermesSubjectID,
        tapestry: AtroposPackage,
        ticketUUID: String,
        parcelUUID: String
    ) -> HermesParcel<AtroposPackage> {
        HermesParcel(
            parcelID: HermesParcelID(UUID(uuidString: parcelUUID)!),
            ticketID: HermesTicketID(UUID(uuidString: ticketUUID)!),
            subjectID: subjectID,
            sender: moirai,
            kind: atroposPackage,
            finalAddressee: hestiaAddress,
            payload: tapestry
        )
    }

    private func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("hestia-stage5d-\(UUID().uuidString).json")
    }

    func testFullHouseSurvivesSaveDiscardAndLoadThroughHestiaQueries() throws {
        let native = try subject("native")
        let heldA = try subject("held-a")
        let heldB = try subject("held-b")
        let savedC = try subject("saved-c")
        let savedD = try subject("saved-d")

        let nativeDNA = try astroDNA(rawValue: 0)
        let heldADNA = try astroDNA(rawValue: 3_600)
        let heldBDNA = try astroDNA(rawValue: 7_200)
        let savedCDNA = try astroDNA(rawValue: 10_800)
        let savedDDNA = try astroDNA(rawValue: 14_400)

        let nativeTapestry = try tapestry(for: nativeDNA)
        let savedCTapestry = try tapestry(for: savedCDNA)
        let savedDTapestry = try tapestry(for: savedDDNA)

        var house: Hestia? = Hestia(nativeSubjectID: native)
        try house?.hold(subjectID: heldA, astroDNA: heldADNA)
        try house?.hold(subjectID: heldB, astroDNA: heldBDNA)
        try house?.admit(
            subjectID: native,
            astroDNA: nativeDNA,
            tapestry: nativeTapestry
        )
        try house?.admit(
            subjectID: savedC,
            astroDNA: savedCDNA,
            tapestry: savedCTapestry
        )
        try house?.admit(
            subjectID: savedD,
            astroDNA: savedDDNA,
            tapestry: savedDTapestry
        )

        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try HestiaPersistence.save(try XCTUnwrap(house), to: url)

        house = nil
        var restored = try HestiaPersistence.load(from: url)

        XCTAssertEqual(restored.nativeSubjectID, native)
        XCTAssertEqual(
            restored.native(),
            HearthResident(
                subjectID: native,
                astroDNA: nativeDNA,
                tapestry: nativeTapestry
            )
        )
        XCTAssertEqual(
            restored.holding(heldA),
            Holding(subjectID: heldA, astroDNA: heldADNA)
        )
        XCTAssertEqual(
            restored.holding(heldB),
            Holding(subjectID: heldB, astroDNA: heldBDNA)
        )
        XCTAssertEqual(
            restored.saved(savedC),
            HallResident(
                subjectID: savedC,
                astroDNA: savedCDNA,
                tapestry: savedCTapestry
            )
        )
        XCTAssertEqual(
            restored.saved(savedD),
            HallResident(
                subjectID: savedD,
                astroDNA: savedDDNA,
                tapestry: savedDTapestry
            )
        )
        XCTAssertEqual(restored.tapestry(for: native), nativeTapestry)
        XCTAssertEqual(restored.tapestry(for: savedC), savedCTapestry)
        XCTAssertEqual(restored.tapestry(for: savedD), savedDTapestry)
        XCTAssertEqual(restored.holdings.holdings.map(\.subjectID), [heldA, heldB])
        XCTAssertEqual(restored.hall.residents.map(\.subjectID), [savedC, savedD])

        // Keep `restored` mutable so this test proves a live keeper was reconstructed,
        // rather than merely decoding records for inspection.
        let extra = try subject("extra")
        try restored.hold(subjectID: extra, astroDNA: try astroDNA(rawValue: 18_000))
        XCTAssertNotNil(restored.holding(extra))
    }

    func testRestoredHestiaStillEnforcesHouseBoundaries() throws {
        let native = try subject("native")
        let held = try subject("held")
        let saved = try subject("saved")
        let nativeDNA = try astroDNA(rawValue: 0)
        let heldDNA = try astroDNA(rawValue: 3_600)
        let savedDNA = try astroDNA(rawValue: 7_200)
        let heldTapestry = try tapestry(for: heldDNA)
        let savedTapestry = try tapestry(for: savedDNA)

        var original = Hestia(nativeSubjectID: native)
        try original.hold(subjectID: held, astroDNA: heldDNA)
        try original.admit(subjectID: saved, astroDNA: savedDNA, tapestry: savedTapestry)

        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try HestiaPersistence.save(original, to: url)
        var restored = try HestiaPersistence.load(from: url)

        XCTAssertThrowsError(
            try restored.hold(subjectID: native, astroDNA: nativeDNA)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .nativeCannotEnterHoldings)
        }

        let heldParcel = parcel(
            subjectID: held,
            tapestry: heldTapestry,
            ticketUUID: "00000000-0000-0000-0000-0000000005D1",
            parcelUUID: "00000000-0000-0000-0000-0000000005D2"
        )
        XCTAssertThrowsError(
            try restored.receive(
                heldParcel,
                astroDNA: heldDNA,
                receivedAt: instant
            )
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .subjectAlreadyInHoldings)
        }

        XCTAssertThrowsError(
            try restored.hold(subjectID: saved, astroDNA: savedDNA)
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .savedSubjectAlreadyAdmitted)
        }

        XCTAssertNotNil(restored.holding(held))
        XCTAssertNotNil(restored.saved(saved))
        XCTAssertNil(restored.holding(native))
    }

    func testRestoredHestiaHandbackLeavesHouseUnchanged() throws {
        let native = try subject("native")
        let held = try subject("held")
        let saved = try subject("saved")
        let stranger = try subject("stranger")

        let nativeDNA = try astroDNA(rawValue: 0)
        let heldDNA = try astroDNA(rawValue: 3_600)
        let savedDNA = try astroDNA(rawValue: 7_200)
        let strangerDNA = try astroDNA(rawValue: 10_800)
        let wrongDNA = try astroDNA(rawValue: 14_400)

        var original = Hestia(nativeSubjectID: native)
        try original.hold(subjectID: held, astroDNA: heldDNA)
        try original.admit(
            subjectID: native,
            astroDNA: nativeDNA,
            tapestry: try tapestry(for: nativeDNA)
        )
        try original.admit(
            subjectID: saved,
            astroDNA: savedDNA,
            tapestry: try tapestry(for: savedDNA)
        )

        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try HestiaPersistence.save(original, to: url)
        var restored = try HestiaPersistence.load(from: url)
        let beforeHandback = restored

        let badParcel = parcel(
            subjectID: stranger,
            tapestry: try tapestry(for: wrongDNA),
            ticketUUID: "00000000-0000-0000-0000-0000000005D3",
            parcelUUID: "00000000-0000-0000-0000-0000000005D4"
        )

        let disposition = try restored.receive(
            badParcel,
            astroDNA: strangerDNA,
            receivedAt: instant
        )
        guard case let .rejected(receipt, correction) = disposition else {
            return XCTFail("Expected Handback")
        }

        XCTAssertEqual(receipt.ticketID, badParcel.ticketID)
        XCTAssertEqual(receipt.parcelID, badParcel.parcelID)
        XCTAssertEqual(correction.subjectID, stranger)
        XCTAssertEqual(correction.rejectedTapestry, badParcel.payload)
        XCTAssertEqual(restored, beforeHandback)
        XCTAssertNil(restored.holding(stranger))
        XCTAssertNil(restored.saved(stranger))
        XCTAssertNil(restored.tapestry(for: stranger))
    }
}
