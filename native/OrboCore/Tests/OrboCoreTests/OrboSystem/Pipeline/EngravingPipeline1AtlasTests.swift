import XCTest
@testable import OrboCore

final class EngravingPipeline1AtlasTests: XCTestCase {
    func testCanonicalEngravingTravelsToAtlasAndReturnsWithOnlyToposResolved() throws {
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

        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertFalse(orbo.canEnterBigThree)
        XCTAssertNil(commissionedPackage.contents.topos)
        XCTAssertNil(commissionedPackage.contents.astroDNA)
        XCTAssertNil(commissionedPackage.contents.tapestry)
        XCTAssertFalse(commissionedPackage.contents.engraved)

        let atlasAddress = try hermes.deliverNext(
            ticketID: ticketID,
            occurredAt: OrboPipelineFixture.atlasDeliveryAt
        )

        XCTAssertEqual(atlasAddress, OrboOnboarding.engravingItinerary[0])
        XCTAssertEqual(atlasAddress.rawValue, "orbo.atlas")

        let afterDelivery = hermes.manifest.events(for: ticketID)
        XCTAssertEqual(afterDelivery.count, 2)
        XCTAssertEqual(afterDelivery.map(\.kind), [.ticketOpened, .deliveredToStop])
        XCTAssertEqual(afterDelivery[1].packageID, OrboPipelineFixture.packageID)
        XCTAssertEqual(afterDelivery[1].address, atlasAddress)

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

        let topos = try XCTUnwrap(resolvedEngraving.topos)
        XCTAssertEqual(topos.place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(topos.place.latitude.degrees, 43.07, accuracy: 0.000_000_1)
        XCTAssertEqual(topos.place.longitude.degrees, -89.40, accuracy: 0.000_000_1)
        XCTAssertEqual(topos.place.timezone.rawValue, "America/Chicago")
        XCTAssertEqual(topos.provenance.version, GeoplacementAtlas.version)
        XCTAssertEqual(topos.provenance.sourceDescription, GeoplacementAtlas.sourceDescription)

        XCTAssertEqual(resolvedEngraving.subjectID, commissionedPackage.contents.subjectID)
        XCTAssertEqual(resolvedEngraving.name, commissionedPackage.contents.name)
        XCTAssertEqual(resolvedEngraving.birthDate, commissionedPackage.contents.birthDate)
        XCTAssertEqual(resolvedEngraving.birthTime, commissionedPackage.contents.birthTime)
        XCTAssertEqual(resolvedEngraving.birthLocation, commissionedPackage.contents.birthLocation)
        XCTAssertNil(resolvedEngraving.astroDNA)
        XCTAssertNil(resolvedEngraving.tapestry)
        XCTAssertFalse(resolvedEngraving.engraved)

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

        let recoveredEvents = hermes.manifest.events(for: ticketID)
        XCTAssertEqual(recoveredEvents.count, 3)
        XCTAssertEqual(
            recoveredEvents.map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop]
        )
        XCTAssertEqual(recoveredEvents[2].packageID, commissionedPackage.packageID)
        XCTAssertEqual(recoveredEvents[2].address, atlasAddress)
        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)

        XCTAssertEqual(atlasResolvedPackage.packageID, commissionedPackage.packageID)
        XCTAssertEqual(atlasResolvedPackage.subjectID, commissionedPackage.subjectID)
        XCTAssertEqual(atlasResolvedPackage.sender, commissionedPackage.sender)
        XCTAssertEqual(atlasResolvedPackage.kind, commissionedPackage.kind)
        XCTAssertEqual(atlasResolvedPackage.addresses, commissionedPackage.addresses)
        XCTAssertEqual(atlasResolvedPackage.addresses[1].rawValue, "orbo.moirai")

        XCTAssertEqual(orbo.engravingTicketID, ticketID)
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertFalse(orbo.canEnterBigThree)
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
