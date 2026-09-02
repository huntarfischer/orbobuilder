import XCTest
@testable import OrboCore

final class BirthToHearthRedPassTests: XCTestCase {
    func testFullKnownBirthOnboardingReachesHearthWithCanonicalTapestry() throws {
        let subjectID = HermesSubjectID(rawValue: "orbo.birth-to-hearth.ean")!
        let handoffAt = AbsoluteInstant(unixSecondsSince1970: 1_777_100_000)!
        let atlasDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_100_060)!
        let atlasRecoveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_100_120)!
        let moiraiDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_100_180)!

        var orbo = Orbo()
        var hermes = HermesCourier()
        let atlas = Atlas()
        let hestia = Hestia(nativeSubjectID: subjectID)

        // The proof begins at the actual player-facing entrance, not at a
        // preconstructed birth input or backstage object.
        XCTAssertEqual(orbo.frontOfHouse, .resting)
        XCTAssertEqual(orbo.backOfHouse, .idle)
        XCTAssertFalse(hestia.hearthLit)

        var beat = orbo.beginOnboarding()
        XCTAssertEqual(beat.progress, .requestingName)
        XCTAssertEqual(
            beat.orboLines,
            [
                "Welcome, traveler.",
                "My name is Orbo. What's yours?",
            ]
        )

        beat = try orbo.respondToOnboarding(.name("Ean"))
        XCTAssertEqual(beat.progress, .requestingReadingDepth)

        beat = try orbo.respondToOnboarding(.astrologyInterest(.interested))
        XCTAssertEqual(beat.progress, .requestingBirthDate)

        beat = try orbo.respondToOnboarding(
            .birthDate(CivilDate(year: 1985, month: 4, day: 10)!)
        )
        XCTAssertEqual(beat.progress, .requestingBirthLocation)

        beat = try orbo.respondToOnboarding(.birthLocation("Madison, WI"))
        XCTAssertEqual(beat.progress, .requestingBirthTimeKnowledge)

        beat = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        XCTAssertEqual(beat.progress, .requestingBirthTime)

        beat = try orbo.respondToOnboarding(
            .birthTime(CivilClockTime(hour: 20, minute: 16)!)
        )
        XCTAssertEqual(beat.progress, .readyForEngraving)
        XCTAssertTrue(orbo.onboardingSession?.readyForEngraving == true)
        XCTAssertEqual(orbo.onboardingSession?.name, "Ean")
        XCTAssertEqual(
            orbo.onboardingSession?.birthDate,
            CivilDate(year: 1985, month: 4, day: 10)!
        )
        XCTAssertEqual(
            orbo.onboardingSession?.birthTime,
            CivilClockTime(hour: 20, minute: 16)!
        )
        XCTAssertEqual(orbo.onboardingSession?.birthLocation, "Madison, WI")

        // Orbo authors only the unresolved Engraving commission from the real
        // onboarding state. No chart matter is supplied by this test.
        let commissionedPackage = try orbo.commissionEngraving(subjectID: subjectID)
        XCTAssertEqual(commissionedPackage.subjectID, subjectID)
        XCTAssertEqual(commissionedPackage.contents.name, "Ean")
        XCTAssertNil(commissionedPackage.contents.topos)
        XCTAssertNil(commissionedPackage.contents.tempus)
        XCTAssertNil(commissionedPackage.contents.astroDNA)
        XCTAssertNil(commissionedPackage.contents.sect)
        XCTAssertNil(commissionedPackage.contents.tapestry)
        XCTAssertFalse(commissionedPackage.contents.engraved)

        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: handoffAt
        )
        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertEqual(
            hermes.manifest.events(for: ticketID).map(\.kind),
            [.ticketOpened]
        )

        // Test-only witness of already-living owner seams. This is not a
        // production orchestrator: Hermes still carries, Atlas still resolves,
        // and package identity remains unchanged.
        let atlasAddress = try hermes.deliverNext(
            ticketID: ticketID,
            occurredAt: atlasDeliveryAt
        )
        XCTAssertEqual(atlasAddress, OrboOnboarding.engravingItinerary[0])

        guard case let .found(atlasResolvedEngraving) = atlas.resolve(
            commissionedPackage.contents
        ) else {
            XCTFail("Ean's Madison birth input did not resolve through the living Atlas")
            return
        }

        let topos = try XCTUnwrap(atlasResolvedEngraving.topos)
        XCTAssertEqual(topos.place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(topos.place.timezone.rawValue, "America/Chicago")
        XCTAssertNotNil(atlasResolvedEngraving.tempus)
        XCTAssertNil(atlasResolvedEngraving.astroDNA)
        XCTAssertNil(atlasResolvedEngraving.tapestry)

        let atlasResolvedPackage = try XCTUnwrap(
            HermesPackage(
                packageID: commissionedPackage.packageID,
                subjectID: commissionedPackage.subjectID,
                sender: commissionedPackage.sender,
                kind: commissionedPackage.kind,
                addresses: commissionedPackage.addresses,
                contents: atlasResolvedEngraving
            )
        )

        try hermes.recover(
            ticketID: ticketID,
            package: atlasResolvedPackage,
            occurredAt: atlasRecoveryAt
        )

        let moiraiAddress = try hermes.deliverNext(
            ticketID: ticketID,
            occurredAt: moiraiDeliveryAt
        )
        XCTAssertEqual(moiraiAddress, OrboOnboarding.engravingItinerary[1])
        XCTAssertEqual(moiraiAddress.rawValue, "orbo.moirai")
        XCTAssertEqual(
            hermes.manifest.events(for: ticketID).map(\.kind),
            [
                .ticketOpened,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToStop,
            ]
        )

        // RED ACCEPTANCE BOUNDARY
        //
        // Do not satisfy this assertion with a Port I stub, handcrafted sky,
        // synthetic OrboSpineLocate, prebuilt AstroDNA/Tapestry, direct Hearth
        // insertion, fake nativeTruthReady result, or supplied Big Three truth.
        // The living system must continue this same Engraving through Moirai's
        // real Clotho -> Horae -> Locate path, Lachesis/Titans, Atropos, Hermes,
        // and Hestia until the Hearth owns the canonical sealed Tapestry.
        let tapestry = hestia.canonicalTapestry(for: subjectID)
        XCTAssertNotNil(
            tapestry,
            "RED: full Orbo onboarding reaches the real Moirai stop, but Ean's canonical Tapestry does not yet reach Hestia's Hearth without synthetic middle matter."
        )

        // These become reachable only when the end-to-end acceptance path is real.
        if tapestry != nil {
            XCTAssertTrue(hestia.hearthLit)
            let native = try XCTUnwrap(hestia.nativeEngraving())
            XCTAssertTrue(native.engraved)
            XCTAssertEqual(native.subjectID, subjectID)
            XCTAssertEqual(native.tapestry, tapestry)
        }
    }
}
