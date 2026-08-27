import XCTest
@testable import OrboCore

final class EngravingPipeline2MoiraiTests: XCTestCase {
    func testAtlasResolvedEngravingIsDeliveredToMoiraiAndCannotSkipAhead() throws {
        var orbo = try completedDummyTraveler()
        let commissionedPackage = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )

        var hermes = HermesCourier()
        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        // Run the proven Pipeline 1 path rather than substituting an Atlas fixture.
        let atlasAddress = try hermes.deliverNext(
            ticketID: ticketID,
            occurredAt: OrboPipelineFixture.atlasDeliveryAt
        )
        XCTAssertEqual(atlasAddress, OrboOnboarding.engravingItinerary[0])

        let resolvedEngraving: Engraving
        switch Atlas().resolve(commissionedPackage.contents) {
        case let .found(engraving):
            resolvedEngraving = engraving
        case let .ambiguous(topoi):
            XCTFail("Canonical Madison native unexpectedly resolved ambiguously: \(topoi)")
            return
        case .notFound:
            XCTFail("Canonical Madison native unexpectedly failed Atlas resolution")
            return
        }

        let atlasResolvedPackage = try XCTUnwrap(
            HermesPackage(
                packageID: commissionedPackage.packageID,
                subjectID: commissionedPackage.subjectID,
                sender: commissionedPackage.sender,
                kind: commissionedPackage.kind,
                addresses: commissionedPackage.addresses,
                contents: resolvedEngraving
            )
        )

        try hermes.recover(
            ticketID: ticketID,
            package: atlasResolvedPackage,
            occurredAt: OrboPipelineFixture.atlasRecoveryAt
        )

        let afterPipeline1 = hermes.manifest.events(for: ticketID)
        XCTAssertEqual(afterPipeline1.count, 3)
        XCTAssertEqual(
            afterPipeline1.map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop]
        )

        // Pipeline 2: Hermes follows the second printed address and stops.
        let moiraiAddress = try hermes.deliverNext(
            ticketID: ticketID,
            occurredAt: OrboPipelineFixture.moiraiDeliveryAt
        )

        XCTAssertEqual(moiraiAddress, OrboOnboarding.engravingItinerary[1])
        XCTAssertEqual(moiraiAddress.rawValue, "orbo.moirai")

        let deliveredEvents = hermes.manifest.events(for: ticketID)
        XCTAssertEqual(deliveredEvents.count, 4)
        XCTAssertEqual(
            deliveredEvents.map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop, .deliveredToStop]
        )
        XCTAssertEqual(deliveredEvents[3].packageID, commissionedPackage.packageID)
        XCTAssertEqual(deliveredEvents[3].address, moiraiAddress)
        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)

        // The exact Atlas-resolved package is what has arrived at the Moirai.
        let topos = try XCTUnwrap(atlasResolvedPackage.contents.topos)
        XCTAssertEqual(topos.place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(topos.place.latitude.degrees, 43.07, accuracy: 0.000_000_1)
        XCTAssertEqual(topos.place.longitude.degrees, -89.40, accuracy: 0.000_000_1)
        XCTAssertEqual(topos.place.timezone.rawValue, "America/Chicago")
        XCTAssertEqual(topos.provenance.version, GeoplacementAtlas.version)
        XCTAssertEqual(topos.provenance.sourceDescription, GeoplacementAtlas.sourceDescription)

        XCTAssertEqual(atlasResolvedPackage.packageID, commissionedPackage.packageID)
        XCTAssertEqual(atlasResolvedPackage.subjectID, commissionedPackage.subjectID)
        XCTAssertEqual(atlasResolvedPackage.sender, commissionedPackage.sender)
        XCTAssertEqual(atlasResolvedPackage.kind, commissionedPackage.kind)
        XCTAssertEqual(atlasResolvedPackage.addresses, commissionedPackage.addresses)
        XCTAssertEqual(atlasResolvedPackage.contents.name, commissionedPackage.contents.name)
        XCTAssertEqual(atlasResolvedPackage.contents.birthDate, commissionedPackage.contents.birthDate)
        XCTAssertEqual(atlasResolvedPackage.contents.birthTime, commissionedPackage.contents.birthTime)
        XCTAssertEqual(atlasResolvedPackage.contents.birthLocation, commissionedPackage.contents.birthLocation)
        XCTAssertNil(atlasResolvedPackage.contents.astroDNA)
        XCTAssertNil(atlasResolvedPackage.contents.tapestry)
        XCTAssertFalse(atlasResolvedPackage.contents.engraved)

        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertFalse(orbo.canEnterBigThree)

        // Hermes must wait for recovery from the Moirai; Hestia cannot be skipped to.
        XCTAssertThrowsError(
            try hermes.deliverNext(
                ticketID: ticketID,
                occurredAt: OrboPipelineFixture.moiraiDeliveryAt
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }
        XCTAssertEqual(hermes.manifest.events(for: ticketID), deliveredEvents)
    }

    private func completedDummyTraveler() throws -> Orbo {
        var orbo = Orbo()

        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name(OrboPipelineFixture.name))
        _ = try orbo.respondToOnboarding(
            .astrologyInterest(OrboPipelineFixture.astrologyInterest)
        )
        _ = try orbo.respondToOnboarding(.birthDate(OrboPipelineFixture.birthDate))
        _ = try orbo.respondToOnboarding(
            .birthLocation(OrboPipelineFixture.birthLocation)
        )
        _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        _ = try orbo.respondToOnboarding(.birthTime(OrboPipelineFixture.birthTime))

        return orbo
    }
}
