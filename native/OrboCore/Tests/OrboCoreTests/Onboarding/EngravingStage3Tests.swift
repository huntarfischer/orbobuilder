import XCTest
@testable import OrboCore

final class EngravingStage3Tests: XCTestCase {
    private let packageID = HermesPackageID(UUID(uuidString: "00000000-0000-0000-0000-000000000501")!)
    private let subjectID = HermesSubjectID(rawValue: "subject.native")!
    private let birthDate = CivilDate(year: 1985, month: 4, day: 10)!
    private let birthTime = CivilClockTime(hour: 20, minute: 16)!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    func testOrboCompletesOnboardingByCreatingEngravingPackage() {
        let package = makePackage()

        XCTAssertEqual(package.packageID, packageID)
        XCTAssertEqual(package.subjectID, subjectID)
        XCTAssertEqual(package.sender, OrboOnboarding.orboAddress)
        XCTAssertEqual(package.kind, HermesPackageKind(rawValue: "orbo.engraving.v1"))
        XCTAssertEqual(
            package.addresses.map(\.rawValue),
            ["orbo.atlas", "orbo.moirai", "orbo.hestia"]
        )
        XCTAssertEqual(package.contents.name, "Ean")
        XCTAssertEqual(package.contents.birthDate, birthDate)
        XCTAssertEqual(package.contents.birthTime, birthTime)
        XCTAssertEqual(package.contents.birthLocation, "Madison, WI")
    }

    func testAtlasAddsToposWhilePreservingOnboardingFacts() throws {
        let intake = makePackage().contents
        let engraving = try found(Atlas().resolve(intake))

        XCTAssertEqual(engraving.name, intake.name)
        XCTAssertEqual(engraving.birthDate, intake.birthDate)
        XCTAssertEqual(engraving.birthTime, intake.birthTime)
        XCTAssertEqual(engraving.birthLocation, intake.birthLocation)
        XCTAssertEqual(engraving.topos.place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(engraving.topos.place.timezone.rawValue, "America/Chicago")
    }

    func testEngravingPackageTravelsThroughAtlasAndReturnsToHermesOpenForMoirai() throws {
        let package = makePackage()
        var courier = HermesCourier()

        let ticketID = try courier.accept(package: package, occurredAt: instant)
        XCTAssertEqual(
            try courier.deliverNext(ticketID: ticketID, occurredAt: instant),
            HermesAddress(rawValue: "orbo.atlas")
        )

        let atlasEngraving = try found(Atlas().resolve(package.contents))
        let augmentedPackage = HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: atlasEngraving
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
        XCTAssertEqual(augmentedPackage.contents.topos.place.canonicalName, "Madison, WI, USA")
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

    private func makePackage() -> HermesPackage<EngravingIntake> {
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
        _ resolution: AtlasEngravingResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> AtlasEngraving {
        guard case let .found(engraving) = resolution else {
            XCTFail("Expected found engraving resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return engraving
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
