import Foundation
import XCTest
@testable import OrboCore

final class HestiaHermesStage4Tests: XCTestCase {
    private let origin = HermesAddress(rawValue: "orbo.engraving")!
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestiaAddress = HermesAddress(rawValue: "orbo.hestia")!
    private let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
    private let moiraiPackage = HermesParcelKind(rawValue: "orbo.moirai-package.v1")!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    private func subject(_ rawValue: String) -> HermesSubjectID {
        HermesSubjectID(rawValue: rawValue)!
    }

    private func astroDNA(rawValue: Int) -> AstroDNA {
        AstroDNA(rawSequence: Array(repeating: rawValue, count: AstroDNA.geneCount))!
    }

    private func tapestry(for astroDNA: AstroDNA) throws -> AtroposPackage {
        let output = Clotho.gather(from: astroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        return try Atropos.inspect(recipe: output.recipe, grid: grid).get()
    }

    private func deliveredParcel(
        subjectID: HermesSubjectID,
        sourceAstroDNA: AstroDNA,
        returnedTapestry: AtroposPackage? = nil,
        ticketID: HermesTicketID,
        initialParcelID: HermesParcelID,
        returnParcelID: HermesParcelID,
        courier: inout HermesCourier
    ) throws -> HermesParcel<MoiraiPackage> {
        let ticket = HermesTicket(
            ticketID: ticketID,
            subjectID: subjectID,
            serviceDestination: moirai,
            finalAddressee: hestiaAddress,
            expectedReturnKind: moiraiPackage
        )!
        let commission = HermesParcel(
            parcelID: initialParcelID,
            ticketID: ticketID,
            subjectID: subjectID,
            sender: origin,
            kind: natalCommission,
            finalAddressee: hestiaAddress,
            payload: sourceAstroDNA
        )

        try courier.accept(ticket: ticket, parcel: commission, occurredAt: instant)
        try courier.deliverToService(ticketID: ticketID, occurredAt: instant)

        let returned = HermesParcel(
            parcelID: returnParcelID,
            ticketID: ticketID,
            subjectID: subjectID,
            sender: moirai,
            kind: moiraiPackage,
            finalAddressee: hestiaAddress,
            payload: MoiraiPackage(
                astroDNA: sourceAstroDNA,
                tapestry: try returnedTapestry ?? tapestry(for: sourceAstroDNA)
            )
        )

        try courier.acceptReturn(parcel: returned, occurredAt: instant)
        try courier.deliverToFinalAddressee(parcel: returned, occurredAt: instant)
        return returned
    }

    func testHermesDeliveryImmediatelyEstablishesNativeHearth() throws {
        let native = subject("native")
        let dna = astroDNA(rawValue: 0)
        var courier = HermesCourier()
        var hestia = Hestia(nativeSubjectID: native)
        let returned = try deliveredParcel(
            subjectID: native,
            sourceAstroDNA: dna,
            ticketID: HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000401")!),
            initialParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000402")!),
            returnParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000403")!),
            courier: &courier
        )

        let disposition = try hestia.receive(returned, receivedAt: instant)
        guard case let .accepted(destination, receipt) = disposition else {
            return XCTFail("Expected accepted delivery")
        }
        XCTAssertEqual(destination, .hearth)
        try courier.recordReceipt(receipt)

        XCTAssertEqual(hestia.native()?.subjectID, native)
        XCTAssertEqual(hestia.native()?.astroDNA, dna)
        XCTAssertEqual(hestia.native()?.tapestry, returned.payload.tapestry)
        XCTAssertTrue(hestia.hall.residents.isEmpty)
        XCTAssertEqual(courier.manifest.currentState(for: returned.ticketID), .resolved)
    }

    func testHermesDeliveryImmediatelyAdmitsSavedSubjectToHall() throws {
        let native = subject("native")
        let saved = subject("saved-person")
        let dna = astroDNA(rawValue: 1)
        var courier = HermesCourier()
        var hestia = Hestia(nativeSubjectID: native)
        let returned = try deliveredParcel(
            subjectID: saved,
            sourceAstroDNA: dna,
            ticketID: HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000411")!),
            initialParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000412")!),
            returnParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000413")!),
            courier: &courier
        )

        let disposition = try hestia.receive(returned, receivedAt: instant)
        guard case let .accepted(destination, receipt) = disposition else {
            return XCTFail("Expected accepted delivery")
        }
        XCTAssertEqual(destination, .hall)
        try courier.recordReceipt(receipt)

        XCTAssertNil(hestia.native())
        XCTAssertEqual(hestia.saved(saved)?.subjectID, saved)
        XCTAssertEqual(hestia.saved(saved)?.astroDNA, dna)
        XCTAssertEqual(hestia.saved(saved)?.tapestry, returned.payload.tapestry)
        XCTAssertEqual(courier.manifest.currentState(for: returned.ticketID), .resolved)
    }

    func testMismatchedTapestryIsImmediatelyRejectedAndKeptNowhere() throws {
        let native = subject("native")
        let sourceDNA = astroDNA(rawValue: 0)
        let wrongTapestry = try tapestry(for: astroDNA(rawValue: 1))
        var courier = HermesCourier()
        var hestia = Hestia(nativeSubjectID: native)
        let returned = try deliveredParcel(
            subjectID: native,
            sourceAstroDNA: sourceDNA,
            returnedTapestry: wrongTapestry,
            ticketID: HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000421")!),
            initialParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000422")!),
            returnParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000423")!),
            courier: &courier
        )

        let disposition = try hestia.receive(returned, receivedAt: instant)
        guard case let .rejected(receipt, correction) = disposition else {
            return XCTFail("Expected rejection")
        }
        try courier.recordReceipt(receipt)

        XCTAssertNil(hestia.native())
        XCTAssertTrue(hestia.hall.residents.isEmpty)
        XCTAssertEqual(correction.originalTicketID, returned.ticketID)
        XCTAssertEqual(correction.originalParcelID, returned.parcelID)
        XCTAssertEqual(correction.subjectID, native)
        XCTAssertEqual(correction.astroDNA, sourceDNA)
        XCTAssertEqual(correction.rejectedTapestry, wrongTapestry)
        XCTAssertEqual(correction.serviceDestination, moirai)
        XCTAssertEqual(correction.finalAddressee, hestiaAddress)
        XCTAssertEqual(courier.manifest.currentState(for: returned.ticketID), .resolved)
    }

    func testRejectedTapestryCanOpenNewLinkedHermesJourneyBackToMoirai() throws {
        let native = subject("native")
        let sourceDNA = astroDNA(rawValue: 0)
        let wrongTapestry = try tapestry(for: astroDNA(rawValue: 1))
        let originalTicketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000431")!)
        let correctionTicketID = HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000451")!)
        var courier = HermesCourier()
        var hestia = Hestia(nativeSubjectID: native)
        let returned = try deliveredParcel(
            subjectID: native,
            sourceAstroDNA: sourceDNA,
            returnedTapestry: wrongTapestry,
            ticketID: originalTicketID,
            initialParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000432")!),
            returnParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000433")!),
            courier: &courier
        )

        let disposition = try hestia.receive(returned, receivedAt: instant)
        guard case let .rejected(receipt, correction) = disposition else {
            return XCTFail("Expected rejection")
        }
        try courier.recordReceipt(receipt)

        let correctionTicket = HermesTicket(
            ticketID: correctionTicketID,
            subjectID: correction.subjectID,
            serviceDestination: correction.serviceDestination,
            finalAddressee: correction.finalAddressee,
            expectedReturnKind: moiraiPackage
        )!
        let correctionParcel = HermesParcel(
            parcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000452")!),
            ticketID: correctionTicketID,
            subjectID: correction.subjectID,
            sender: hestiaAddress,
            kind: natalCommission,
            finalAddressee: correction.finalAddressee,
            payload: correction
        )

        try courier.accept(
            ticket: correctionTicket,
            parcel: correctionParcel,
            occurredAt: instant
        )
        try courier.deliverToService(ticketID: correctionTicketID, occurredAt: instant)

        XCTAssertEqual(courier.manifest.currentState(for: originalTicketID), .resolved)
        XCTAssertEqual(courier.manifest.currentState(for: correctionTicketID), .unresolved)
        XCTAssertEqual(
            courier.manifest.events(for: correctionTicketID).last?.kind,
            .deliveredToService
        )
        XCTAssertNil(hestia.native())
        XCTAssertTrue(hestia.hall.residents.isEmpty)
    }

    func testDispositionReceiptAlwaysMatchesDeliveredParcel() throws {
        let native = subject("native")
        let dna = astroDNA(rawValue: 0)
        var courier = HermesCourier()
        var hestia = Hestia(nativeSubjectID: native)
        let returned = try deliveredParcel(
            subjectID: native,
            sourceAstroDNA: dna,
            ticketID: HermesTicketID(UUID(uuidString: "00000000-0000-0000-0000-000000000461")!),
            initialParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000462")!),
            returnParcelID: HermesParcelID(UUID(uuidString: "00000000-0000-0000-0000-000000000463")!),
            courier: &courier
        )

        let disposition = try hestia.receive(returned, receivedAt: instant)

        XCTAssertEqual(disposition.receipt.ticketID, returned.ticketID)
        XCTAssertEqual(disposition.receipt.parcelID, returned.parcelID)
        XCTAssertEqual(disposition.receipt.recipient, hestiaAddress)
    }

    func testHestiaDeliveryVocabularyIncludesHoldingsAsDistinctDestination() {
        XCTAssertNotEqual(HestiaDestination.holdings, .hearth)
        XCTAssertNotEqual(HestiaDestination.holdings, .hall)
    }
}
