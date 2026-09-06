import XCTest
@testable import OrboCore

final class NatalSpineActIIntegrationTests: XCTestCase {
    private struct PortStub: NatalSpineTimespineSource {
        let bounds: NatalSpineBounds
        let crossing: JulianDay

        var sourceBone: OrboSpineBoneSpan {
            OrboSpineBoneSpan(
                start: JulianDay(bounds.bone.start.value - 1)!,
                end: JulianDay(bounds.bone.end.value + 1)!
            )!
        }
        var sourceStations: [OrboSpineStation] { [] }
        var sourceProvenance: OrboSpineRuntimeProvenance {
            OrboSpineRuntimeProvenance(
                candidateManifestSHA256: String(repeating: "b", count: 64),
                astronomicalAuthority: "integration-parent",
                astronomicalSourceVersion: "test"
            )!
        }

        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            let physical = julianDay.value < crossing.value ? 10.0 : 40.0
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: physical,
                    motion: .direct
                )!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            guard directionalDegree.motion == .direct else { return [] }
            if abs(directionalDegree.physicalDegrees - 30) <= 1e-9 {
                return [OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
                    julianDay: crossing
                )]
            }
            if abs(directionalDegree.physicalDegrees - 10) <= 1e-9 {
                return [OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
                    julianDay: JulianDay(bounds.bone.start.value + 10)!
                )]
            }
            if abs(directionalDegree.physicalDegrees - 20) <= 1e-9 {
                return [OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
                    julianDay: JulianDay(bounds.bone.start.value + 20)!
                )]
            }
            return []
        }
    }

    func testActIFromOrboCommissionToHermesCustodyAtHephaestus() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let crossing = JulianDay(bounds.bone.start.value + 100)!
        let port = PortStub(bounds: bounds, crossing: crossing)

        var orbo = Orbo()
        orbo.transitionBackOfHouse(to: .nativeReady)
        var hermes = HermesCourier()
        let commissionedAt = AbsoluteInstant(unixSecondsSince1970: 1_900_000_000)!
        let moiraiDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_900_000_060)!
        let moiraiRecoveryAt = AbsoluteInstant(unixSecondsSince1970: 1_900_000_120)!
        let hephaestusDeliveryAt = AbsoluteInstant(unixSecondsSince1970: 1_900_000_180)!

        let handle = try orbo.commissionNatalSpine(
            subjectID: NatalSpineTestFixture.subjectID,
            via: &hermes,
            occurredAt: commissionedAt,
            packageID: HermesPackageID(
                UUID(uuidString: "cccccccc-dddd-eeee-ffff-000000000001")!
            )
        )

        XCTAssertEqual(hermes.manifest.currentState(for: handle.ticketID), .unresolved)
        XCTAssertEqual(
            try hermes.deliverNext(ticketID: handle.ticketID, occurredAt: moiraiDeliveryAt),
            NatalSpineCommission.moiraiAddress
        )

        let certified = try Moirai.processNatalSpineSchematics(
            handle.package,
            hearth: hestia,
            through: port
        )

        XCTAssertEqual(certified.packageID, handle.package.packageID)
        XCTAssertEqual(certified.subjectID, handle.package.subjectID)
        XCTAssertEqual(certified.sender, handle.package.sender)
        XCTAssertEqual(certified.kind, handle.package.kind)
        XCTAssertEqual(certified.addresses, handle.package.addresses)
        XCTAssertEqual(certified.contents.bounds, bounds)
        XCTAssertEqual(certified.contents.threads.bounds, bounds)
        XCTAssertEqual(certified.contents.themis.subjectID, truth.subjectID)
        XCTAssertEqual(certified.contents.oceanus.subjectID, truth.subjectID)
        XCTAssertEqual(certified.contents.rhea.subjectID, truth.subjectID)

        let firstExpectedHouse = try XCTUnwrap(
            truth.tapestry.tapestry.degrees.first { $0.address.rawValue == 10 }?.tympan.house
        )
        let secondExpectedHouse = try XCTUnwrap(
            truth.tapestry.tapestry.degrees.first { $0.address.rawValue == 40 }?.tympan.house
        )
        XCTAssertEqual(
            certified.contents.themis.spans(for: .sun).map(\.house),
            [firstExpectedHouse, secondExpectedHouse]
        )
        XCTAssertFalse(certified.contents.rhea.qualifications.isEmpty)

        try hermes.recover(
            ticketID: handle.ticketID,
            package: certified,
            occurredAt: moiraiRecoveryAt
        )
        XCTAssertEqual(
            try hermes.deliverNext(ticketID: handle.ticketID, occurredAt: hephaestusDeliveryAt),
            NatalSpineCommission.hephaestusAddress
        )
        XCTAssertEqual(hermes.manifest.currentState(for: handle.ticketID), .unresolved)
        XCTAssertEqual(
            hermes.manifest.events(for: handle.ticketID).map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop, .deliveredToStop]
        )
    }

    func testMoiraiRejectsACommissionEnvelopeWhoseItineraryWasChanged() throws {
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let original = NatalSpineCommission.package(subjectID: truth.subjectID)
        let altered = HermesPackage(
            packageID: original.packageID,
            subjectID: original.subjectID,
            sender: original.sender,
            kind: original.kind,
            addresses: [NatalSpineCommission.hephaestusAddress],
            contents: original.contents
        )!

        XCTAssertThrowsError(
            try Moirai.processNatalSpineSchematics(
                altered,
                hearth: hestia,
                through: PortStub(
                    bounds: bounds,
                    crossing: JulianDay(bounds.bone.start.value + 100)!
                )
            )
        ) { error in
            XCTAssertEqual(error as? MoiraiNatalSpineFailure, .unexpectedPackage)
        }
    }
}
