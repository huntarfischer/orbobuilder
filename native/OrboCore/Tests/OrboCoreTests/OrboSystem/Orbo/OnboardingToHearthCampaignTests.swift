import XCTest
@testable import OrboCore

final class OnboardingToHearthCampaignTests: XCTestCase {
    private struct DeterministicPortI: ClothoPortI {
        let output: HoraeOutput
        var requestedTempus: [Tempus] = []

        mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
            requestedTempus.append(tempus)
            guard output.julianDay == tempus.absoluteInstant.julianDay else {
                throw CampaignError.unexpectedTempus
            }
            return output
        }
    }

    func testKnownTravelerRunsFromOnboardingThroughRealPipelineToLitHearthAndNativeReady() throws {
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

        XCTAssertEqual(orbo.onboardingSession?.progress, .readyForEngraving)

        let commission = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        XCTAssertEqual(commission.addresses.count, 3)
        XCTAssertNil(commission.contents.topos)
        XCTAssertNil(commission.contents.tempus)
        XCTAssertNil(commission.contents.astroDNA)
        XCTAssertNil(commission.contents.tapestry)
        XCTAssertFalse(commission.contents.engraved)

        var hermes = HermesCourier()
        let engravingTicketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        let atlasAddress = try hermes.deliverNext(
            ticketID: engravingTicketID,
            occurredAt: OrboPipelineFixture.atlasDeliveryAt
        )
        XCTAssertEqual(atlasAddress, commission.addresses[0])

        let atlasEngraving: Engraving
        switch Atlas().resolve(commission.contents) {
        case let .found(resolved):
            atlasEngraving = resolved
        default:
            XCTFail("Campaign expected Atlas to resolve the fixture's Topos and Tempus")
            return
        }
        XCTAssertNotNil(atlasEngraving.topos)
        XCTAssertNotNil(atlasEngraving.tempus)

        let atlasPackage = try XCTUnwrap(
            HermesPackage(
                packageID: commission.packageID,
                subjectID: commission.subjectID,
                sender: commission.sender,
                kind: commission.kind,
                addresses: commission.addresses,
                contents: atlasEngraving
            )
        )
        try hermes.recover(
            ticketID: engravingTicketID,
            package: atlasPackage,
            occurredAt: OrboPipelineFixture.atlasRecoveryAt
        )

        let moiraiAddress = try hermes.deliverNext(
            ticketID: engravingTicketID,
            occurredAt: OrboPipelineFixture.moiraiDeliveryAt
        )
        XCTAssertEqual(moiraiAddress, commission.addresses[1])

        let sourceSlice = try deterministicSlice(for: atlasEngraving)
        var portI = DeterministicPortI(output: sourceSlice)
        let moiraiPackage = try Moirai.process(atlasPackage, through: &portI)

        XCTAssertEqual(portI.requestedTempus, [try XCTUnwrap(atlasEngraving.tempus)])
        XCTAssertEqual(moiraiPackage.packageID, commission.packageID)
        XCTAssertEqual(moiraiPackage.subjectID, commission.subjectID)
        XCTAssertEqual(moiraiPackage.addresses, commission.addresses)
        XCTAssertNotNil(moiraiPackage.contents.topos)
        XCTAssertNotNil(moiraiPackage.contents.tempus)
        XCTAssertNotNil(moiraiPackage.contents.astroDNA)
        XCTAssertNotNil(moiraiPackage.contents.tapestry)
        XCTAssertFalse(moiraiPackage.contents.engraved)

        try hermes.recover(
            ticketID: engravingTicketID,
            package: moiraiPackage,
            occurredAt: instant(1_777_000_240)
        )

        let hestiaAddress = try hermes.deliverNext(
            ticketID: engravingTicketID,
            occurredAt: instant(1_777_000_300)
        )
        XCTAssertEqual(hestiaAddress, Hestia.address)
        XCTAssertEqual(hestiaAddress, commission.addresses[2])

        var hestia = Hestia(nativeSubjectID: OrboPipelineFixture.subjectID)
        let finishedEngraving = try hestia.receive(moiraiPackage)

        XCTAssertTrue(hestia.hearthLit)
        XCTAssertTrue(finishedEngraving.engraved)
        XCTAssertEqual(hestia.nativeEngraving(), finishedEngraving)
        XCTAssertEqual(hestia.canonicalTapestry(for: OrboPipelineFixture.subjectID), finishedEngraving.tapestry)

        try hermes.recordReceipt(
            ticketID: engravingTicketID,
            packageID: commission.packageID,
            recipient: hestiaAddress,
            receivedAt: instant(1_777_000_360)
        )
        XCTAssertEqual(hermes.manifest.currentState(for: engravingTicketID), .resolved)
        XCTAssertEqual(
            hermes.manifest.events(for: engravingTicketID).map(\.kind),
            [
                .ticketOpened,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToAddressee,
                .receiptRecorded,
                .resolved,
            ]
        )

        let hearthNotice = try hestia.sendHearthLitNotice(
            to: OrboOnboarding.orboAddress,
            via: &hermes,
            occurredAt: instant(1_777_000_420)
        )
        let noticeAddress = try hermes.deliverNext(
            ticketID: hearthNotice.ticketID,
            occurredAt: instant(1_777_000_480)
        )
        XCTAssertEqual(noticeAddress, OrboOnboarding.orboAddress)

        try orbo.receiveHearthLitNotice(hearthNotice.package)
        try hermes.recordReceipt(
            ticketID: hearthNotice.ticketID,
            packageID: hearthNotice.package.packageID,
            recipient: noticeAddress,
            receivedAt: instant(1_777_000_540)
        )

        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertTrue(orbo.canEnterBigThree)
        XCTAssertEqual(hermes.manifest.currentState(for: hearthNotice.ticketID), .resolved)
        XCTAssertTrue(hermes.manifest.unresolvedTickets().isEmpty)
    }

    private func deterministicSlice(for engraving: Engraving) throws -> HoraeOutput {
        let positions: [MundaneBody: (degrees: Double, motion: Motion)] = [
            .sun: (20, .direct),
            .moon: (280, .direct),
            .mercury: (10, .retrograde),
            .venus: (40, .retrograde),
            .mars: (50, .direct),
            .jupiter: (100, .direct),
            .saturn: (150, .retrograde),
            .uranus: (200, .retrograde),
            .neptune: (250, .retrograde),
            .pluto: (300, .retrograde),
            .trueNorthNode: (60, .retrograde),
        ]
        let topos = try XCTUnwrap(engraving.topos)
        let tempus = try XCTUnwrap(engraving.tempus)
        let julianDay = tempus.absoluteInstant.julianDay
        let turn = try XCTUnwrap(
            CelestialLongitude(-topos.place.longitude.degrees)
        )
        let terra = try XCTUnwrap(
            TerraMarrowSample(
                turnDegrees: turn.degrees,
                tiltDegrees: 23.44,
                julianDay: julianDay
            )
        )

        let celestial = try MundaneBody.canonicalOrder.map { body in
            let position = try XCTUnwrap(positions[body])
            let directionalDegree = try XCTUnwrap(
                OrboSpineDirectionalDegree(
                    physicalDegrees: position.degrees,
                    motion: position.motion
                )
            )
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: directionalDegree,
                julianDay: julianDay
            )
        }

        return HoraeOutput(
            julianDay: julianDay,
            celestial: celestial,
            terra: terra
        )
    }

    private func instant(_ unixSeconds: Double) -> AbsoluteInstant {
        AbsoluteInstant(unixSecondsSince1970: unixSeconds)!
    }

    private enum CampaignError: Error {
        case unexpectedTempus
    }
}
