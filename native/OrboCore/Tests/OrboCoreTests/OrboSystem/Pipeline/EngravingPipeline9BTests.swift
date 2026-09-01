import XCTest
@testable import OrboCore

final class EngravingPipeline9BTests: XCTestCase {
    private struct Position {
        let degrees: Double
        let motion: Motion
    }

    private struct PortIStub: ClothoPortI {
        let output: HoraeOutput

        mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
            output
        }
    }

    func testMoiraiReturnsSamePackageWithCanonicalSealButEngravingRemainsUnfinished() throws {
        let commissioned = initialPackage()
        let atlasResolved = try atlasResolvedPackage(from: commissioned)
        var portI = PortIStub(output: try slice(for: atlasResolved.contents))

        let worked = try Moirai.process(atlasResolved, through: &portI)
        let seal = try XCTUnwrap(worked.contents.tapestry)

        XCTAssertEqual(worked.packageID, commissioned.packageID)
        XCTAssertEqual(worked.subjectID, commissioned.subjectID)
        XCTAssertEqual(worked.sender, commissioned.sender)
        XCTAssertEqual(worked.kind, commissioned.kind)
        XCTAssertEqual(worked.addresses, commissioned.addresses)
        XCTAssertNotNil(worked.contents.astroDNA)
        XCTAssertEqual(seal.tapestry.degrees.count, DegreeAddress.count)
        XCTAssertEqual(seal.tapestry.degrees.map(\.address), DegreeAddress.canonicalOrder)
        XCTAssertFalse(worked.contents.engraved)
    }

    func testHestiaRejectsWrongPackageBeforeInspectingContents() throws {
        let commissioned = initialPackage()
        let wrongKind = HermesPackageKind(rawValue: "orbo.not-an-engraving")!
        let wrongPackage = try XCTUnwrap(
            HermesPackage(
                packageID: commissioned.packageID,
                subjectID: commissioned.subjectID,
                sender: commissioned.sender,
                kind: wrongKind,
                addresses: commissioned.addresses,
                contents: commissioned.contents
            )
        )
        var hestia = Hestia(nativeSubjectID: commissioned.subjectID)

        XCTAssertThrowsError(try hestia.receive(wrongPackage)) { error in
            XCTAssertEqual(error as? Hestia.Failure, .unexpectedEngravingPackage)
        }
        XCTAssertFalse(hestia.hearthLit)
        XCTAssertNil(hestia.nativeEngraving())
    }

    func testHestiaReceivingContractNamesEachMissingResolution() throws {
        let commissioned = initialPackage()
        let atlasResolved = try atlasResolvedPackage(from: commissioned)
        let topos = try XCTUnwrap(atlasResolved.contents.topos)
        let onlyTopos = commissioned.contents.resolving(topos: topos)
        let toposOnlyPackage = repack(commissioned, contents: onlyTopos)

        var portI = PortIStub(output: try slice(for: atlasResolved.contents))
        let clotho = try Clotho.spin(atlasResolved.contents, through: &portI)
        let astroDNAOnlyPackage = repack(commissioned, contents: clotho.engraving)

        var hestia = Hestia(nativeSubjectID: commissioned.subjectID)

        XCTAssertThrowsError(try hestia.receive(commissioned)) { error in
            XCTAssertEqual(error as? Hestia.Failure, .missingTopos)
        }
        XCTAssertThrowsError(try hestia.receive(toposOnlyPackage)) { error in
            XCTAssertEqual(error as? Hestia.Failure, .missingTempus)
        }
        XCTAssertThrowsError(try hestia.receive(atlasResolved)) { error in
            XCTAssertEqual(error as? Hestia.Failure, .missingAstroDNA)
        }
        XCTAssertThrowsError(try hestia.receive(astroDNAOnlyPackage)) { error in
            XCTAssertEqual(error as? Hestia.Failure, .missingSect)
        }

        XCTAssertFalse(hestia.hearthLit)
        XCTAssertNil(hestia.nativeEngraving())
        XCTAssertNil(hestia.canonicalTapestry(for: commissioned.subjectID))
    }

    func testHestiaHangsEngravingAndLightsHearthAtomically() throws {
        let worked = try canonicalMoiraiPackage()
        let incomingSeal = try XCTUnwrap(worked.contents.tapestry)
        var hestia = Hestia(nativeSubjectID: worked.subjectID)

        XCTAssertFalse(worked.contents.engraved)
        XCTAssertFalse(hestia.hearthLit)
        XCTAssertNil(hestia.nativeEngraving())

        let finished = try hestia.receive(worked)

        XCTAssertTrue(finished.engraved)
        XCTAssertTrue(hestia.hearthLit)
        XCTAssertEqual(hestia.nativeEngraving(), finished)
        XCTAssertEqual(hestia.canonicalTapestry(for: worked.subjectID), incomingSeal)
        XCTAssertEqual(hestia.nativeEngraving()?.tapestry, incomingSeal)

        XCTAssertThrowsError(try hestia.receive(worked)) { error in
            XCTAssertEqual(error as? Hestia.Failure, .nativeAlreadyEstablished)
        }
    }

    func testHestiaCannotSendHearthLitNoticeBeforeHearthIsLit() throws {
        let worked = try canonicalMoiraiPackage()
        var hestia = Hestia(nativeSubjectID: worked.subjectID)
        var hermes = HermesCourier()
        let beforeLit = AbsoluteInstant(unixSecondsSince1970: 1_777_000_400)!
        let afterLit = AbsoluteInstant(unixSecondsSince1970: 1_777_000_420)!
        let deliveredAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_480)!
        let receivedAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_540)!

        XCTAssertThrowsError(
            try hestia.sendHearthLitNotice(
                to: OrboOnboarding.orboAddress,
                via: &hermes,
                occurredAt: beforeLit
            )
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .hearthUnlit)
        }

        _ = try hestia.receive(worked)
        let notice = try hestia.sendHearthLitNotice(
            to: OrboOnboarding.orboAddress,
            via: &hermes,
            occurredAt: afterLit
        )

        XCTAssertEqual(notice.package.sender, Hestia.address)
        XCTAssertEqual(notice.package.kind, Hestia.hearthLitNoticeKind)
        XCTAssertEqual(notice.package.addresses, [OrboOnboarding.orboAddress])
        XCTAssertEqual(notice.package.subjectID, worked.subjectID)
        XCTAssertEqual(notice.package.contents.subjectID, worked.subjectID)
        XCTAssertTrue(notice.package.contents.hearthLit)
        XCTAssertEqual(
            hermes.manifest.events(for: notice.ticketID).map(\.kind),
            [.ticketOpened]
        )

        let recipient = try hermes.deliverNext(
            ticketID: notice.ticketID,
            occurredAt: deliveredAt
        )
        XCTAssertEqual(recipient, OrboOnboarding.orboAddress)

        try hermes.recordReceipt(
            ticketID: notice.ticketID,
            packageID: notice.package.packageID,
            recipient: recipient,
            receivedAt: receivedAt
        )
        XCTAssertEqual(
            hermes.manifest.events(for: notice.ticketID).map(\.kind),
            [.ticketOpened, .deliveredToAddressee, .receiptRecorded, .resolved]
        )
    }

    func testFullOnboardingEndsOnlyAfterHestiaLightsHearthAndHermesTellsOrbo() throws {
        var orbo = try completedTraveler()
        let commissioned = try orbo.commissionEngraving(
            subjectID: OrboPipelineFixture.subjectID,
            packageID: OrboPipelineFixture.packageID
        )
        var hermes = HermesCourier()
        let ticketID = try orbo.entrustEngraving(
            to: &hermes,
            occurredAt: OrboPipelineFixture.handoffAt
        )

        XCTAssertEqual(
            try hermes.deliverNext(
                ticketID: ticketID,
                occurredAt: OrboPipelineFixture.atlasDeliveryAt
            ),
            OrboOnboarding.engravingItinerary[0]
        )

        let atlasResolved = try atlasResolvedPackage(from: commissioned)
        try hermes.recover(
            ticketID: ticketID,
            package: atlasResolved,
            occurredAt: OrboPipelineFixture.atlasRecoveryAt
        )

        XCTAssertEqual(
            try hermes.deliverNext(
                ticketID: ticketID,
                occurredAt: OrboPipelineFixture.moiraiDeliveryAt
            ),
            OrboOnboarding.engravingItinerary[1]
        )

        var portI = PortIStub(output: try slice(for: atlasResolved.contents))
        let moiraiWorked = try Moirai.process(atlasResolved, through: &portI)
        XCTAssertEqual(moiraiWorked.packageID, commissioned.packageID)
        XCTAssertFalse(moiraiWorked.contents.engraved)

        let moiraiRecoveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_240)!
        let hestiaDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_300)!
        let hestiaReceiptAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_360)!
        let noticeEntrustedAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_420)!
        let noticeDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_480)!
        let noticeReceiptAt = AbsoluteInstant(unixSecondsSince1970: 1_777_000_540)!

        try hermes.recover(
            ticketID: ticketID,
            package: moiraiWorked,
            occurredAt: moiraiRecoveryAt
        )
        XCTAssertEqual(
            try hermes.deliverNext(ticketID: ticketID, occurredAt: hestiaDeliveryAt),
            Hestia.address
        )

        var hestia = Hestia(nativeSubjectID: commissioned.subjectID)
        XCTAssertFalse(hestia.hearthLit)
        XCTAssertNil(hestia.nativeEngraving())
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertFalse(orbo.canEnterBigThree)

        let finished = try hestia.receive(moiraiWorked)
        XCTAssertTrue(finished.engraved)
        XCTAssertTrue(hestia.hearthLit)
        XCTAssertEqual(hestia.nativeEngraving(), finished)

        // Lighting the Hearth does not magically mutate Orbo. Hermes still has
        // to carry Hestia's news across the system boundary.
        XCTAssertEqual(orbo.backOfHouse, .engravingInProgress)
        XCTAssertFalse(orbo.canEnterBigThree)

        try hermes.recordReceipt(
            ticketID: ticketID,
            packageID: commissioned.packageID,
            recipient: Hestia.address,
            receivedAt: hestiaReceiptAt
        )

        let notice = try hestia.sendHearthLitNotice(
            to: OrboOnboarding.orboAddress,
            via: &hermes,
            occurredAt: noticeEntrustedAt
        )
        XCTAssertEqual(
            try hermes.deliverNext(
                ticketID: notice.ticketID,
                occurredAt: noticeDeliveryAt
            ),
            OrboOnboarding.orboAddress
        )

        try orbo.receiveHearthLitNotice(notice.package)
        XCTAssertEqual(orbo.backOfHouse, .nativeReady)
        XCTAssertTrue(orbo.canEnterBigThree)

        try hermes.recordReceipt(
            ticketID: notice.ticketID,
            packageID: notice.package.packageID,
            recipient: OrboOnboarding.orboAddress,
            receivedAt: noticeReceiptAt
        )

        XCTAssertEqual(moiraiWorked.packageID, commissioned.packageID)
        XCTAssertEqual(moiraiWorked.subjectID, commissioned.subjectID)
        XCTAssertEqual(moiraiWorked.sender, commissioned.sender)
        XCTAssertEqual(moiraiWorked.kind, commissioned.kind)
        XCTAssertEqual(moiraiWorked.addresses, commissioned.addresses)
        XCTAssertEqual(
            hermes.manifest.events(for: ticketID).map(\.kind),
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
        XCTAssertEqual(
            hermes.manifest.events(for: notice.ticketID).map(\.kind),
            [.ticketOpened, .deliveredToAddressee, .receiptRecorded, .resolved]
        )
    }

    private func initialPackage() -> HermesPackage<Engraving> {
        OrboOnboarding.complete(
            subjectID: OrboPipelineFixture.subjectID,
            name: OrboPipelineFixture.name,
            birthDate: OrboPipelineFixture.birthDate,
            birthTime: OrboPipelineFixture.birthTime,
            birthLocation: OrboPipelineFixture.birthLocation,
            packageID: OrboPipelineFixture.packageID
        )
    }

    private func atlasResolvedPackage(
        from package: HermesPackage<Engraving>
    ) throws -> HermesPackage<Engraving> {
        guard case let .found(engraving) = Atlas().resolve(package.contents) else {
            XCTFail("Expected Atlas to resolve canonical pipeline Engraving")
            throw TestError.unexpectedAtlasResolution
        }
        return repack(package, contents: engraving)
    }

    private func canonicalMoiraiPackage() throws -> HermesPackage<Engraving> {
        let commissioned = initialPackage()
        let atlasResolved = try atlasResolvedPackage(from: commissioned)
        var portI = PortIStub(output: try slice(for: atlasResolved.contents))
        return try Moirai.process(atlasResolved, through: &portI)
    }

    private func repack(
        _ package: HermesPackage<Engraving>,
        contents: Engraving
    ) -> HermesPackage<Engraving> {
        HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: contents
        )!
    }

    private func completedTraveler() throws -> Orbo {
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

    private func slice(for engraving: Engraving) throws -> HoraeOutput {
        let positions: [MundaneBody: Position] = [
            .sun: Position(degrees: 20, motion: .direct),
            .moon: Position(degrees: 280, motion: .direct),
            .mercury: Position(degrees: 10, motion: .retrograde),
            .venus: Position(degrees: 40, motion: .retrograde),
            .mars: Position(degrees: 50, motion: .direct),
            .jupiter: Position(degrees: 100, motion: .direct),
            .saturn: Position(degrees: 150, motion: .retrograde),
            .uranus: Position(degrees: 200, motion: .retrograde),
            .neptune: Position(degrees: 250, motion: .retrograde),
            .pluto: Position(degrees: 300, motion: .retrograde),
            .trueNorthNode: Position(degrees: 60, motion: .retrograde),
        ]

        let topos = try XCTUnwrap(engraving.topos)
        let julianDay = JulianDay(2_446_166.5)!
        let terra = TerraMarrowSample(
            turnDegrees: CelestialLongitude(-topos.place.longitude.degrees)!.degrees,
            tiltDegrees: 23.44,
            julianDay: julianDay
        )!

        let celestial = try MundaneBody.canonicalOrder.map { body in
            let position = try XCTUnwrap(positions[body])
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: try XCTUnwrap(
                    OrboSpineDirectionalDegree(
                        physicalDegrees: position.degrees,
                        motion: position.motion
                    )
                ),
                julianDay: julianDay
            )
        }

        return HoraeOutput(
            julianDay: julianDay,
            celestial: celestial,
            terra: terra
        )
    }

    private enum TestError: Error {
        case unexpectedAtlasResolution
    }
}
