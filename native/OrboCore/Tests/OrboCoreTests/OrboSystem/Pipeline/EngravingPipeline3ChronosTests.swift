import XCTest
@testable import OrboCore

final class EngravingPipeline3ChronosTests: XCTestCase {
    func testMoiraiEngravingResolvesCivilMomentThroughChronosAndStopsBeforeHorae() throws {
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

        // Proven Pipeline 1: Atlas resolves only Topos and Hermes recovers the same package.
        _ = try hermes.deliverNext(
            ticketID: ticketID,
            occurredAt: OrboPipelineFixture.atlasDeliveryAt
        )

        let atlasResolvedEngraving: Engraving
        switch Atlas().resolve(commissionedPackage.contents) {
        case let .found(engraving):
            atlasResolvedEngraving = engraving
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
                contents: atlasResolvedEngraving
            )
        )

        try hermes.recover(
            ticketID: ticketID,
            package: atlasResolvedPackage,
            occurredAt: OrboPipelineFixture.atlasRecoveryAt
        )

        // Proven Pipeline 2: Hermes delivers the Atlas-resolved Engraving to Moirai.
        let moiraiAddress = try hermes.deliverNext(
            ticketID: ticketID,
            occurredAt: OrboPipelineFixture.moiraiDeliveryAt
        )
        XCTAssertEqual(moiraiAddress, OrboOnboarding.engravingItinerary[1])

        let manifestAtMoirai = hermes.manifest.events(for: ticketID)
        XCTAssertEqual(
            manifestAtMoirai.map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop, .deliveredToStop]
        )

        // Pipeline 3: Clotho asks Chronos to resolve only the civil birth moment.
        let timezone = try XCTUnwrap(atlasResolvedPackage.contents.topos?.place.timezone)
        let answer = try resolved(
            Clotho.resolveCivilMoment(for: atlasResolvedPackage.contents)
        )

        XCTAssertEqual(answer.hits.count, 1)
        let hit = try XCTUnwrap(answer.hits.first)
        guard case let .moment(julianDay) = hit.address else {
            return XCTFail("Expected one Chronos moment address")
        }

        XCTAssertEqual(julianDay.value, 2_448_029.313888889, accuracy: 0.000_000_01)
        XCTAssertEqual(
            hit.fact,
            .civilMoment(
                date: OrboPipelineFixture.birthDate,
                time: OrboPipelineFixture.birthTime,
                timezone: timezone
            )
        )
        XCTAssertEqual(hit.source?.rawValue, "civil-time")

        // Pipeline 3 does not mutate the Engraving or advance any downstream work.
        XCTAssertEqual(atlasResolvedPackage.contents, atlasResolvedEngraving)
        XCTAssertNotNil(atlasResolvedPackage.contents.topos)
        XCTAssertNil(atlasResolvedPackage.contents.astroDNA)
        XCTAssertNil(atlasResolvedPackage.contents.tapestry)
        XCTAssertFalse(atlasResolvedPackage.contents.engraved)

        XCTAssertEqual(hermes.manifest.events(for: ticketID), manifestAtMoirai)
        XCTAssertEqual(hermes.manifest.currentState(for: ticketID), .unresolved)
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

    private func resolved(
        _ resolution: ChronosResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> ChronosAnswer {
        guard case let .resolved(answer) = resolution else {
            XCTFail("Expected resolved Chronos answer, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return answer
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
