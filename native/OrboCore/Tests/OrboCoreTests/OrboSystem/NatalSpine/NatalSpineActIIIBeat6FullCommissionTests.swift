import XCTest
@testable import OrboCore

final class NatalSpineActIIIBeat6FullCommissionTests: XCTestCase {
    /// Deterministic read-only stand-in for one already-forged universal Timespine.
    /// It conforms to the same production source protocol Hephaestus consumes and
    /// owns no Ephemeris or forge capability.
    private struct SealedTimespineSource: NatalSpineForgeTimespineSource {
        let bounds: NatalSpineBounds
        let sourceBone: OrboSpineBoneSpan
        let sourceStations: [OrboSpineStation] = []
        let sourceProvenance: OrboSpineRuntimeProvenance

        init(bounds: NatalSpineBounds) {
            self.bounds = bounds
            self.sourceBone = OrboSpineBoneSpan(
                start: JulianDay(bounds.bone.start.value - 10)!,
                end: JulianDay(bounds.bone.end.value + 10)!
            )!
            self.sourceProvenance = OrboSpineRuntimeProvenance(
                candidateManifestSHA256: String(repeating: "9", count: 64),
                astronomicalAuthority: "sealed-mundane-timespine-test-surface",
                astronomicalSourceVersion: "three-act-proof-v1"
            )!
        }

        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            guard julianDay.value >= bounds.bone.start.value,
                  julianDay.value <= bounds.bone.end.value else {
                throw OrboSpineLocateError.outsideBone
            }
            let duration = bounds.bone.end.value - bounds.bone.start.value
            let fraction = (julianDay.value - bounds.bone.start.value) / duration
            let physical = min(max(fraction * 360.0, 0), 359.999_999)
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
            let duration = bounds.bone.end.value - bounds.bone.start.value
            let occurrence = JulianDay(
                bounds.bone.start.value
                    + (directionalDegree.physicalDegrees / 360.0) * duration
            )!
            return [
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
                    julianDay: occurrence
                )
            ]
        }
    }

    func testOneCommissionRunsFromOrboToAvailableNatalSpine() throws {
        // Hearth truth establishes the native once.
        let hestia = try NatalSpineTestFixture.litHestia()
        let truth = try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let timespine = SealedTimespineSource(bounds: bounds)

        // ORBO -> one Hermes commission.
        var orbo = Orbo()
        orbo.transitionBackOfHouse(to: .nativeReady)
        var hermes = HermesCourier()
        let originalPackageID = HermesPackageID(
            UUID(uuidString: "77777777-8888-9999-aaaa-bbbbbbbbbbbb")!
        )
        let handle = try orbo.commissionNatalSpine(
            subjectID: truth.subjectID,
            via: &hermes,
            occurredAt: NatalSpineActIIIFixture.instant(1_930_000_000),
            packageID: originalPackageID
        )

        // HERMES -> MOIRAI -> Clotho + Lachesis + Themis/Oceanus/Rhea + Atropos.
        XCTAssertEqual(
            try hermes.deliverNext(
                ticketID: handle.ticketID,
                occurredAt: NatalSpineActIIIFixture.instant(1_930_000_060)
            ),
            NatalSpineCommission.moiraiAddress
        )
        let certified = try Moirai.processNatalSpineSchematics(
            handle.package,
            hearth: hestia,
            through: timespine
        )
        XCTAssertEqual(certified.contents.bounds, bounds)
        XCTAssertFalse(certified.contents.themis.spans.isEmpty)
        XCTAssertFalse(certified.contents.oceanus.realizations.isEmpty)
        XCTAssertFalse(certified.contents.rhea.qualifications.isEmpty)
        try hermes.recover(
            ticketID: handle.ticketID,
            package: certified,
            occurredAt: NatalSpineActIIIFixture.instant(1_930_000_120)
        )

        // HERMES -> HEPHAESTUS -> one child body -> DIOSCURI -> seal.
        XCTAssertEqual(
            try hermes.deliverNext(
                ticketID: handle.ticketID,
                occurredAt: NatalSpineActIIIFixture.instant(1_930_000_180)
            ),
            NatalSpineCommission.hephaestusAddress
        )
        let commission = try Hephaestus.receiveNatalSpineSchematics(certified)
        let substrate = try Hephaestus.forgeNatalSpineSubstrate(
            for: commission,
            from: timespine
        )
        XCTAssertEqual(substrate.parentProvenance, timespine.sourceProvenance)
        let themisLayer = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )
        let oceanusLayer = try Hephaestus.forgeNatalSpineOceanus(on: themisLayer)
        let rheaLayer = try Hephaestus.forgeNatalSpineRhea(on: oceanusLayer)
        let candidate = try Hephaestus.forgeNatalSpineAddressability(on: rheaLayer)
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: certified.contents,
            parent: timespine
        ).get()
        let sealed = Hephaestus.sealNatalSpine(approval)
        XCTAssertEqual(sealed.packageID, originalPackageID)
        XCTAssertEqual(sealed.bounds, bounds)

        // Finished matter is written, reopened, and mounted before downstream use.
        let artifactURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("NatalSpineFullCommission-\(UUID().uuidString).natalspine")
        defer { try? FileManager.default.removeItem(at: artifactURL) }
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: artifactURL)
        let mounted = try NatalSpineRuntime.mount(
            from: artifactURL,
            expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: timespine.sourceProvenance.spineIdentity
        )
        XCTAssertEqual(mounted.subjectID, sealed.subjectID)
        XCTAssertEqual(mounted.packageID, sealed.packageID)
        XCTAssertEqual(mounted.bounds, sealed.bounds)
        XCTAssertEqual(mounted.parentProvenance, sealed.seal.parentProvenance)

        let finishedPackage = Hephaestus.releaseNatalSpine(sealed)
        try hermes.recover(
            ticketID: handle.ticketID,
            package: finishedPackage,
            occurredAt: NatalSpineActIIIFixture.instant(1_930_000_240)
        )

        // HERMES -> HORAE. Courier validates the envelope; mounted matter is traversed.
        let horaeAddress = try hermes.deliverNext(
            ticketID: handle.ticketID,
            occurredAt: NatalSpineActIIIFixture.instant(1_930_000_300)
        )
        let delivered = try Horae.receiveNatalSpine(
            finishedPackage,
            deliveredTo: horaeAddress
        )
        XCTAssertEqual(delivered.subjectID, mounted.subjectID)
        XCTAssertEqual(delivered.packageID, mounted.packageID)
        XCTAssertEqual(delivered.bounds, mounted.bounds)
        XCTAssertEqual(delivered.seal.parentProvenance, mounted.parentProvenance)

        let natalAddresses = try Horae.locateNatalSpine(
            mounted,
            at: mounted.bounds.natal.julianDay
        )
        XCTAssertEqual(natalAddresses.count, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(natalAddresses.map(\.coordinate.body), MundaneBody.canonicalOrder)
        let sunAddress = try XCTUnwrap(natalAddresses.first { $0.coordinate.body == .sun })
        let sunOccurrences = try Horae.locateNatalSpine(
            mounted,
            body: .sun,
            at: sunAddress.coordinate.directionalDegree
        )
        XCTAssertFalse(sunOccurrences.isEmpty)
        try hermes.recover(
            ticketID: handle.ticketID,
            package: finishedPackage,
            occurredAt: NatalSpineActIIIFixture.instant(1_930_000_360)
        )

        // HERMES -> CHRONOS. The mounted index answers from the persisted artifact.
        XCTAssertEqual(
            try hermes.deliverNext(
                ticketID: handle.ticketID,
                occurredAt: NatalSpineActIIIFixture.instant(1_930_000_420)
            ),
            NatalSpineCommission.chronosAddress
        )
        let index = Chronos.indexNatalSpine(mounted)
        let sampleSpan = try XCTUnwrap(mounted.themis.first)
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalHousePassage(
                    body: sampleSpan.body,
                    house: sampleSpan.house
                )
            )
        )
        guard case let .resolved(answer) = try Chronos.resolveNatalSpine(
            query,
            using: index
        ) else {
            XCTFail("Chronos failed to resolve the mounted Natal Spine")
            return
        }
        XCTAssertFalse(answer.hits.isEmpty)
        XCTAssertTrue(answer.hits.allSatisfy {
            $0.source?.rawValue.contains(mounted.artifactSHA256) == true
        })
        try hermes.recover(
            ticketID: handle.ticketID,
            package: finishedPackage,
            occurredAt: NatalSpineActIIIFixture.instant(1_930_000_480)
        )

        // HERMES -> HECATE -> mounted blessing -> same Hermes commission resolves.
        XCTAssertEqual(
            try hermes.deliverNext(
                ticketID: handle.ticketID,
                occurredAt: NatalSpineActIIIFixture.instant(1_930_000_540)
            ),
            NatalSpineCommission.hecateAddress
        )
        let blessing = try Hecate.blessNatalSpine(mounted, indexedBy: index)
        XCTAssertEqual(blessing.parentProvenance, mounted.parentProvenance)
        let availability = try hermes.closeNatalSpineCommission(
            ticketID: handle.ticketID,
            blessing: blessing,
            receivedAt: NatalSpineActIIIFixture.instant(1_930_000_600)
        )

        // One commission in, one available mounted native Spine out.
        XCTAssertEqual(availability.ticketID, handle.ticketID)
        XCTAssertEqual(availability.packageID, originalPackageID)
        XCTAssertEqual(availability.subjectID, truth.subjectID)
        XCTAssertEqual(availability.bounds, bounds)
        XCTAssertEqual(hermes.manifest.currentState(for: handle.ticketID), .resolved)
        XCTAssertTrue(hermes.manifest.unresolvedTickets().isEmpty)

        let events = hermes.manifest.events(for: handle.ticketID)
        XCTAssertEqual(events.count, 12)
        XCTAssertEqual(
            events.map(\.kind),
            [
                .ticketOpened,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToAddressee,
                .receiptRecorded,
                .resolved,
            ]
        )
        XCTAssertTrue(events.allSatisfy { $0.packageID == originalPackageID })
    }
}
