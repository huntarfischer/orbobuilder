import XCTest
@testable import OrboCore

final class NatalSpineActIIIBeat1DeliveryTests: XCTestCase {
    func testHermesDeliversExactSealedSpineToHoraeUnderOriginalCommission() throws {
        var state = try NatalSpineActIIIFixture.inHermesCustodyAfterHephaestus()
        let address = try state.courier.deliverNext(
            ticketID: state.ticketID,
            occurredAt: NatalSpineActIIIFixture.instant(1_920_000_300)
        )

        XCTAssertEqual(address, NatalSpineCommission.horaeAddress)
        let received = try Horae.receiveNatalSpine(state.package, deliveredTo: address)
        XCTAssertEqual(received, state.package.contents)
        XCTAssertEqual(received.subjectID, state.package.subjectID)
        XCTAssertEqual(received.packageID, state.package.packageID)
        XCTAssertEqual(state.courier.manifest.currentState(for: state.ticketID), .unresolved)
        XCTAssertEqual(
            state.courier.manifest.events(for: state.ticketID).last?.kind,
            .deliveredToStop
        )
        XCTAssertEqual(
            state.courier.manifest.events(for: state.ticketID).last?.address,
            NatalSpineCommission.horaeAddress
        )
    }

    func testHoraeRejectWrongDestination() throws {
        let state = try NatalSpineActIIIFixture.inHermesCustodyAfterHephaestus()
        XCTAssertThrowsError(
            try Horae.receiveNatalSpine(
                state.package,
                deliveredTo: NatalSpineCommission.chronosAddress
            )
        ) { error in
            XCTAssertEqual(error as? NatalSpineHoraeDeliveryFailure, .wrongDestination)
        }
    }

    func testHoraeRejectEnvelopeWhoseNativeWasChanged() throws {
        let state = try NatalSpineActIIIFixture.inHermesCustodyAfterHephaestus()
        let foreign = HermesSubjectID(rawValue: "natal-spine.foreign")!
        let altered = HermesPackage(
            packageID: state.package.packageID,
            subjectID: foreign,
            sender: state.package.sender,
            kind: state.package.kind,
            addresses: state.package.addresses,
            contents: state.package.contents
        )!

        XCTAssertThrowsError(
            try Horae.receiveNatalSpine(
                altered,
                deliveredTo: NatalSpineCommission.horaeAddress
            )
        ) { error in
            XCTAssertEqual(error as? NatalSpineHoraeDeliveryFailure, .subjectMismatch)
        }
    }

    func testOnlySealedNatalSpinePackageCanEnterHoraeDeliveryBoundary() throws {
        let state = try NatalSpineActIIIFixture.inHermesCustodyAfterHephaestus()
        let received: SealedNatalSpine = try Horae.receiveNatalSpine(
            state.package,
            deliveredTo: NatalSpineCommission.horaeAddress
        )
        XCTAssertEqual(received.seal, state.package.contents.seal)
    }
}
