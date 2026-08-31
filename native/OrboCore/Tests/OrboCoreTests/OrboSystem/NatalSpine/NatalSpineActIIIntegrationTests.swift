import XCTest
@testable import OrboCore

final class NatalSpineActIIIntegrationTests: XCTestCase {
    func testCertifiedSchematicsBecomeOneSealedSpineAndReturnToHermesCustody() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let request = NatalSpineCommission.package(
            subjectID: commission.subjectID,
            packageID: commission.packageID
        )
        let certifiedPackage = HermesPackage(
            packageID: request.packageID,
            subjectID: request.subjectID,
            sender: request.sender,
            kind: request.kind,
            addresses: request.addresses,
            contents: commission.schematics
        )!

        var hermes = HermesCourier()
        let ticketID = try hermes.accept(
            package: request,
            occurredAt: instant(1_910_000_000)
        )
        XCTAssertEqual(
            try hermes.deliverNext(ticketID: ticketID, occurredAt: instant(1_910_000_060)),
            NatalSpineCommission.moiraiAddress
        )
        try hermes.recover(
            ticketID: ticketID,
            package: certifiedPackage,
            occurredAt: instant(1_910_000_120)
        )
        XCTAssertEqual(
            try hermes.deliverNext(ticketID: ticketID, occurredAt: instant(1_910_000_180)),
            NatalSpineCommission.hephaestusAddress
        )

        let substrate = NatalSpineActIIFixture.navigableSubstrate(for: commission)
        let parent = NatalSpineActIIFixture.parentSource(for: substrate)
        let themis = try Hephaestus.forgeNatalSpineThemis(for: commission, on: substrate)
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        let rhea = try Hephaestus.forgeNatalSpineRhea(on: oceanus)
        let candidate = try Hephaestus.forgeNatalSpineAddressability(on: rhea)
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: commission.schematics,
            parent: parent
        ).get()
        let sealed = Hephaestus.sealNatalSpine(approval)
        let released = Hephaestus.releaseNatalSpine(sealed)

        XCTAssertEqual(released.packageID, request.packageID)
        XCTAssertEqual(released.subjectID, request.subjectID)
        XCTAssertEqual(released.sender, request.sender)
        XCTAssertEqual(released.kind, request.kind)
        XCTAssertEqual(released.addresses, request.addresses)
        XCTAssertEqual(released.contents, sealed)
        XCTAssertEqual(released.contents.candidate, candidate)

        try hermes.recover(
            ticketID: ticketID,
            package: released,
            occurredAt: instant(1_910_000_240)
        )

        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)
        XCTAssertEqual(
            hermes.manifest.events(for: ticketID).map(\.kind),
            [
                .ticketOpened,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToStop,
                .recoveredFromStop,
            ]
        )
        XCTAssertEqual(
            hermes.manifest.events(for: ticketID).last?.address,
            NatalSpineCommission.hephaestusAddress
        )
    }

    private func instant(_ seconds: Double) -> AbsoluteInstant {
        AbsoluteInstant(unixSecondsSince1970: seconds)!
    }
}
