import XCTest
@testable import OrboCore
@testable import OrboIris

final class OrboHomerDownriverSystemTests: XCTestCase {
    func testRealNativePipelineReturnsLawfulReadinessToOrboAndHomerSeesIt() throws {
        var orbo = try readyForEngraving()
        let commissioned = try orbo.commissionEngraving(
            subjectID: OrboHomerTestFixture.subjectID,
            packageID: OrboHomerTestFixture.packageID
        )

        var courier = HermesCourier()
        let engravingTicketID = try orbo.entrustEngraving(
            to: &courier,
            occurredAt: OrboHomerTestFixture.handoffAt
        )

        let inProgress = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(inProgress.pointOfView.backOfHouse, .engravingInProgress)
        XCTAssertFalse(inProgress.pointOfView.canEnterBigThree)

        XCTAssertEqual(
            try courier.deliverNext(
                ticketID: engravingTicketID,
                occurredAt: instant(60)
            ),
            OrboOnboarding.engravingItinerary[0]
        )

        guard case let .found(resolvedEngraving) = Atlas().resolve(commissioned.contents) else {
            XCTFail("Expected Atlas to resolve the commissioned Engraving")
            return
        }
        let resolvedPackage = try XCTUnwrap(
            HermesPackage(
                packageID: commissioned.packageID,
                subjectID: commissioned.subjectID,
                sender: commissioned.sender,
                kind: commissioned.kind,
                addresses: commissioned.addresses,
                contents: resolvedEngraving
            )
        )
        try courier.recover(
            ticketID: engravingTicketID,
            package: resolvedPackage,
            occurredAt: instant(120)
        )

        XCTAssertEqual(
            try courier.deliverNext(
                ticketID: engravingTicketID,
                occurredAt: instant(180)
            ),
            OrboOnboarding.engravingItinerary[1]
        )

        let tempus = try XCTUnwrap(resolvedEngraving.tempus)
        var horae = Horae(
            locate: try makeLocate(centeredAt: tempus.absoluteInstant.julianDay)
        )
        let workedPackage = try Moirai.process(resolvedPackage, through: &horae)
        try courier.recover(
            ticketID: engravingTicketID,
            package: workedPackage,
            occurredAt: instant(240)
        )

        XCTAssertEqual(
            try courier.deliverNext(
                ticketID: engravingTicketID,
                occurredAt: instant(300)
            ),
            Hestia.address
        )

        var hestia = Hestia(nativeSubjectID: commissioned.subjectID)
        let lightingResult = try hestia.receiveAndAnnounce(
            workedPackage,
            to: OrboOnboarding.orboAddress,
            via: &courier,
            occurredAt: instant(420)
        )
        XCTAssertTrue(hestia.hearthLit)
        XCTAssertEqual(hestia.nativeEngraving(), lightingResult.engraving)
        XCTAssertEqual(lightingResult.package.subjectID, commissioned.subjectID)
        XCTAssertEqual(lightingResult.package.contents.subjectID, commissioned.subjectID)

        let hermesOpened = IrisHomerFrame(
            port: Homer.POV(
                try XCTUnwrap(courier.signalForHomer(ticketID: lightingResult.ticketID))
            )
        )
        XCTAssertEqual(hermesOpened.pointOfView.currentState, .unresolved)
        XCTAssertEqual(hermesOpened.pointOfView.events.map(\.kind), [.ticketOpened])
        XCTAssertEqual(
            hermesOpened.pointOfView.events.first?.packageID,
            lightingResult.package.packageID
        )

        try courier.recordReceipt(
            ticketID: engravingTicketID,
            packageID: commissioned.packageID,
            recipient: Hestia.address,
            receivedAt: instant(360)
        )

        XCTAssertEqual(
            try courier.deliverNext(
                ticketID: lightingResult.ticketID,
                occurredAt: instant(480)
            ),
            OrboOnboarding.orboAddress
        )

        let hermesDelivered = IrisHomerFrame(
            port: Homer.POV(
                try XCTUnwrap(courier.signalForHomer(ticketID: lightingResult.ticketID))
            )
        )
        XCTAssertEqual(
            hermesDelivered.pointOfView.events.map(\.kind),
            [.ticketOpened, .deliveredToAddressee]
        )
        XCTAssertEqual(
            hermesDelivered.pointOfView.events.last?.address,
            OrboOnboarding.orboAddress
        )

        try orbo.receiveHearthLitNotice(lightingResult.package)
        try courier.recordReceipt(
            ticketID: lightingResult.ticketID,
            packageID: lightingResult.package.packageID,
            recipient: OrboOnboarding.orboAddress,
            receivedAt: instant(540)
        )

        let hermesResolved = IrisHomerFrame(
            port: Homer.POV(
                try XCTUnwrap(courier.signalForHomer(ticketID: lightingResult.ticketID))
            )
        )
        XCTAssertEqual(hermesResolved.pointOfView.currentState, .resolved)
        XCTAssertEqual(
            hermesResolved.pointOfView.events.map(\.kind),
            [.ticketOpened, .deliveredToAddressee, .receiptRecorded, .resolved]
        )
        XCTAssertEqual(hermesOpened.pointOfView.events.map(\.kind), [.ticketOpened])
        XCTAssertEqual(
            Mirror(reflecting: hermesResolved.pointOfView).children.compactMap(\.label),
            ["ticketID", "currentState", "events"]
        )

        let returned = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(returned.pointOfView.backOfHouse, .nativeReady)
        XCTAssertTrue(returned.pointOfView.canEnterBigThree)
        XCTAssertTrue(returned.pointOfView.engravingCommissioned)
        XCTAssertTrue(returned.pointOfView.engravingEntrusted)

        XCTAssertEqual(inProgress.pointOfView.backOfHouse, .engravingInProgress)
        XCTAssertFalse(inProgress.pointOfView.canEnterBigThree)
        XCTAssertEqual(
            courier.manifest.currentState(for: engravingTicketID),
            .resolved
        )
        XCTAssertEqual(
            courier.manifest.currentState(for: lightingResult.ticketID),
            .resolved
        )
    }

    func testWithoutHestiasLawfulNoticeOrboRemainsInProgressEvenAfterHearthIsLit() throws {
        var orbo = try readyForEngraving()
        let commissioned = try orbo.commissionEngraving(
            subjectID: OrboHomerTestFixture.subjectID,
            packageID: OrboHomerTestFixture.packageID
        )
        var courier = HermesCourier()
        _ = try orbo.entrustEngraving(
            to: &courier,
            occurredAt: OrboHomerTestFixture.handoffAt
        )

        guard case let .found(resolvedEngraving) = Atlas().resolve(commissioned.contents) else {
            XCTFail("Expected Atlas to resolve the commissioned Engraving")
            return
        }
        let resolvedPackage = try XCTUnwrap(
            HermesPackage(
                packageID: commissioned.packageID,
                subjectID: commissioned.subjectID,
                sender: commissioned.sender,
                kind: commissioned.kind,
                addresses: commissioned.addresses,
                contents: resolvedEngraving
            )
        )
        let tempus = try XCTUnwrap(resolvedEngraving.tempus)
        var horae = Horae(
            locate: try makeLocate(centeredAt: tempus.absoluteInstant.julianDay)
        )
        let workedPackage = try Moirai.process(resolvedPackage, through: &horae)
        var hestia = Hestia(nativeSubjectID: commissioned.subjectID)
        _ = try hestia.receive(workedPackage)

        XCTAssertTrue(hestia.hearthLit)

        let snapshot = IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
        XCTAssertEqual(snapshot.pointOfView.backOfHouse, .engravingInProgress)
        XCTAssertFalse(snapshot.pointOfView.canEnterBigThree)
    }

    private func readyForEngraving() throws -> Orbo {
        var orbo = Orbo()
        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name(OrboHomerTestFixture.name))
        _ = try orbo.respondToOnboarding(
            .astrologyInterest(OrboHomerTestFixture.astrologyInterest)
        )
        _ = try orbo.respondToOnboarding(.birthDate(OrboHomerTestFixture.birthDate))
        _ = try orbo.respondToOnboarding(
            .birthLocation(OrboHomerTestFixture.birthLocation)
        )
        _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        _ = try orbo.respondToOnboarding(.birthTime(OrboHomerTestFixture.birthTime))
        return orbo
    }

    private func instant(_ offset: Double) -> AbsoluteInstant {
        AbsoluteInstant(
            unixSecondsSince1970: OrboHomerTestFixture.handoffAt.unixSecondsSince1970 + offset
        )!
    }

    private func makeLocate(centeredAt center: JulianDay) throws -> OrboSpineLocate {
        let start = try XCTUnwrap(JulianDay(center.value - 1.0))
        let end = try XCTUnwrap(JulianDay(center.value + 1.0))
        let firstUT = try XCTUnwrap(JulianDay(center.value - 0.5))
        let secondUT = try XCTUnwrap(JulianDay(center.value + 0.5))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let base = 10.0 + Double(index * 25)
            let motion: Motion = body == .trueNorthNode ? .retrograde : .direct
            let delta = OrboSpineContract.supportDegrees(for: body) * 0.5
            let firstDegrees = motion == .retrograde ? base + delta : base
            let secondDegrees = motion == .retrograde ? base : base + delta
            supports.append(
                coordinate(
                    body: body,
                    degrees: firstDegrees,
                    motion: motion,
                    julianDay: firstUT
                )
            )
            supports.append(
                coordinate(
                    body: body,
                    degrees: secondDegrees,
                    motion: motion,
                    julianDay: secondUT
                )
            )
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100.0,
                tiltDegrees: 23.4,
                julianDay: start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 102.0,
                tiltDegrees: 23.5,
                julianDay: end
            )),
        ]

        return try XCTUnwrap(
            OrboSpineLocate(
                bone: bone,
                celestialSupports: supports,
                terraSamples: terra
            )
        )
    }

    private func coordinate(
        body: MundaneBody,
        degrees: Double,
        motion: Motion,
        julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: motion
            )!,
            julianDay: julianDay
        )
    }
}
