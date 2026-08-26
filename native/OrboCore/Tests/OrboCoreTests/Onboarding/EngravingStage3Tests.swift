import XCTest
@testable import OrboCore

final class EngravingStage3Tests: XCTestCase {
    private let packageID = HermesPackageID(UUID(uuidString: "00000000-0000-0000-0000-000000000501")!)
    private let subjectID = HermesSubjectID(rawValue: "subject.native")!
    private let birthDate = CivilDate(year: 1985, month: 4, day: 10)!
    private let birthTime = CivilClockTime(hour: 20, minute: 16)!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testOrboCompletesOnboardingByCreatingUnfinishedEngravingPackage() {
        let package = makePackage()

        XCTAssertEqual(package.packageID, packageID)
        XCTAssertEqual(package.subjectID, subjectID)
        XCTAssertEqual(package.sender, OrboOnboarding.orboAddress)
        XCTAssertEqual(package.kind.rawValue, "orbo.engraving.v1")
        XCTAssertEqual(
            package.addresses.map(\.rawValue),
            ["orbo.atlas", "orbo.moirai", "orbo.hestia"]
        )

        XCTAssertEqual(package.contents.subjectID, subjectID)
        XCTAssertEqual(package.contents.name, "Ean")
        XCTAssertEqual(package.contents.birthDate, birthDate)
        XCTAssertEqual(package.contents.birthTime, birthTime)
        XCTAssertEqual(package.contents.birthLocation, "Madison, WI")

        XCTAssertNil(package.contents.topos)
        XCTAssertNil(package.contents.astroDNA)
        XCTAssertNil(package.contents.tapestry)
        XCTAssertFalse(package.contents.engraved)
    }

    func testAtlasResolvesOnlyToposOnTheSameEngravingType() throws {
        let engraving = makePackage().contents
        let resolved = try found(Atlas().resolve(engraving))
        let topos = try XCTUnwrap(resolved.topos)

        XCTAssertEqual(resolved.subjectID, engraving.subjectID)
        XCTAssertEqual(resolved.name, engraving.name)
        XCTAssertEqual(resolved.birthDate, engraving.birthDate)
        XCTAssertEqual(resolved.birthTime, engraving.birthTime)
        XCTAssertEqual(resolved.birthLocation, engraving.birthLocation)
        XCTAssertEqual(topos.place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(topos.place.timezone.rawValue, "America/Chicago")

        XCTAssertNil(resolved.astroDNA)
        XCTAssertNil(resolved.tapestry)
        XCTAssertFalse(resolved.engraved)
    }

    func testEngravingPackageTravelsThroughAtlasAsOneEngravingAndReturnsOpenForMoirai() throws {
        let package = makePackage()
        var courier = HermesCourier()

        let ticketID = try courier.accept(package: package, occurredAt: instant)
        XCTAssertEqual(
            try courier.deliverNext(ticketID: ticketID, occurredAt: instant),
            HermesAddress(rawValue: "orbo.atlas")
        )

        let resolvedEngraving = try found(Atlas().resolve(package.contents))
        let augmentedPackage: HermesPackage<Engraving> = HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: resolvedEngraving
        )!

        try courier.recover(
            ticketID: ticketID,
            package: augmentedPackage,
            occurredAt: instant
        )

        XCTAssertEqual(augmentedPackage.packageID, package.packageID)
        XCTAssertEqual(augmentedPackage.subjectID, package.subjectID)
        XCTAssertEqual(augmentedPackage.sender, package.sender)
        XCTAssertEqual(augmentedPackage.kind, package.kind)
        XCTAssertEqual(augmentedPackage.addresses, package.addresses)
        XCTAssertEqual(augmentedPackage.contents.subjectID, package.contents.subjectID)
        XCTAssertEqual(
            try XCTUnwrap(augmentedPackage.contents.topos).place.canonicalName,
            "Madison, WI, USA"
        )
        XCTAssertNil(augmentedPackage.contents.astroDNA)
        XCTAssertNil(augmentedPackage.contents.tapestry)
        XCTAssertFalse(augmentedPackage.contents.engraved)

        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .unresolved)
        XCTAssertEqual(
            courier.manifest.events(for: ticketID).map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop]
        )
        XCTAssertEqual(courier.manifest.events(for: ticketID).last?.address?.rawValue, "orbo.atlas")

        var probe = courier
        XCTAssertEqual(
            try probe.deliverNext(ticketID: ticketID, occurredAt: instant),
            HermesAddress(rawValue: "orbo.moirai")
        )
        XCTAssertEqual(courier.manifest.events(for: ticketID).last?.kind, .recoveredFromStop)
    }

    private func makePackage() -> HermesPackage<Engraving> {
        OrboOnboarding.complete(
            subjectID: subjectID,
            name: "Ean",
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: "Madison, WI",
            packageID: packageID
        )
    }

    private func found(
        _ resolution: EngravingToposResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Engraving {
        guard case let .found(engraving) = resolution else {
            XCTFail("Expected found Engraving Topos resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return engraving
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
