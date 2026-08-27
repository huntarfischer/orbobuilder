import XCTest
@testable import OrboCore

final class EngravingAtlasBoundaryStage2Tests: XCTestCase {
    private let subjectID = HermesSubjectID(rawValue: "atlas-boundary-stage-2")!
    private let packageID = HermesPackageID(UUID(uuidString: "00000000-0000-0000-0000-000000000620")!)
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testHermesRejectsAtlasRecoveryWithToposButNoTempus() throws {
        let original = makeEngraving()
        let topos = try madisonTopos()
        let incomplete = original.resolving(topos: topos)
        var (courier, ticketID) = try courierWaitingAtAtlas(for: original)

        XCTAssertNotNil(incomplete.topos)
        XCTAssertNil(incomplete.tempus)

        XCTAssertThrowsError(
            try courier.recover(
                ticketID: ticketID,
                package: package(contents: incomplete),
                occurredAt: instant
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .incompleteAtlasEngraving)
        }

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).map(\.kind),
            [.ticketOpened, .deliveredToStop]
        )
        XCTAssertThrowsError(
            try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }
    }

    func testHermesRejectsAtlasRecoveryWithTempusButNoTopos() throws {
        let original = makeEngraving()
        let incomplete = original.resolving(tempus: testTempus())
        var (courier, ticketID) = try courierWaitingAtAtlas(for: original)

        XCTAssertNil(incomplete.topos)
        XCTAssertNotNil(incomplete.tempus)

        XCTAssertThrowsError(
            try courier.recover(
                ticketID: ticketID,
                package: package(contents: incomplete),
                occurredAt: instant
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .incompleteAtlasEngraving)
        }

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).map(\.kind),
            [.ticketOpened, .deliveredToStop]
        )
        XCTAssertThrowsError(
            try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }
    }

    func testCompleteAtlasEngravingRecoversAndAdvancesToMoirai() throws {
        let original = makeEngraving()
        guard case let .found(resolved) = Atlas().resolve(original) else {
            XCTFail("Expected canonical Madison Engraving to resolve completely")
            return
        }
        var (courier, ticketID) = try courierWaitingAtAtlas(for: original)
        let resolvedPackage = package(contents: resolved)

        let topos = try XCTUnwrap(resolvedPackage.contents.topos)
        let tempus = try XCTUnwrap(resolvedPackage.contents.tempus)

        try courier.recover(
            ticketID: ticketID,
            package: resolvedPackage,
            occurredAt: instant
        )

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop]
        )
        XCTAssertEqual(
            try courier.deliverNext(ticketID: ticketID, occurredAt: instant),
            OrboOnboarding.engravingItinerary[1]
        )
        XCTAssertEqual(resolvedPackage.contents.topos, topos)
        XCTAssertEqual(resolvedPackage.contents.tempus, tempus)
    }

    private func makeEngraving() -> Engraving {
        Engraving(
            subjectID: subjectID,
            name: "Stage Two",
            birthDate: CivilDate(year: 1985, month: 4, day: 10)!,
            birthTime: CivilClockTime(hour: 20, minute: 16)!,
            birthLocation: "Madison, WI"
        )
    }

    private func package(contents: Engraving) -> HermesPackage<Engraving> {
        HermesPackage(
            packageID: packageID,
            subjectID: subjectID,
            sender: OrboOnboarding.orboAddress,
            kind: OrboOnboarding.engravingPackageKind,
            addresses: OrboOnboarding.engravingItinerary,
            contents: contents
        )!
    }

    private func courierWaitingAtAtlas(
        for original: Engraving
    ) throws -> (HermesCourier, HermesTicketID) {
        var courier = HermesCourier()
        let ticketID = try courier.accept(
            package: package(contents: original),
            occurredAt: instant
        )
        XCTAssertEqual(
            try courier.deliverNext(ticketID: ticketID, occurredAt: instant),
            OrboOnboarding.engravingItinerary[0]
        )
        return (courier, ticketID)
    }

    private func madisonTopos() throws -> Topos {
        guard case let .found(topos) = Atlas().resolve("Madison, WI") else {
            XCTFail("Expected Madison Topos")
            throw TestError.unexpectedResolution
        }
        return topos
    }

    private func testTempus() -> Tempus {
        Tempus(
            absoluteInstant: instant,
            provenance: TempusProvenance(
                source: .timeZoneDatabase,
                timeZoneDataVersion: CivilTime.timeZoneDataVersion
            )
        )
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
