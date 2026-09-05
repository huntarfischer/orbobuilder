import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat5RheaForgeTests: XCTestCase {
    func testHephaestusAttachesEveryCertifiedRheaQualificationExactlyOnce() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let rheaLayer = try forgeRheaLayer(for: commission)
        let source = commission.schematics.rhea.qualifications

        XCTAssertEqual(rheaLayer.subjectID, commission.subjectID)
        XCTAssertEqual(rheaLayer.bounds, commission.schematics.bounds)
        XCTAssertEqual(rheaLayer.rhea.count, source.count)
        XCTAssertEqual(rheaLayer.rhea.map(\.sourceRow), Array(source.indices))
        XCTAssertEqual(rheaLayer.rhea.map(\.qualification), source)
    }

    func testRheaQualificationsReferenceTheExistingTemporalFactsTheyQualify() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let layer = try forgeRheaLayer(for: commission)

        for forged in layer.rhea {
            switch (forged.qualification.source, forged.fact) {
            case let (.houseCrossing(crossing), .themisCrossing(previousRow, nextRow)):
                let previous = try XCTUnwrap(layer.themis.first { $0.sourceRow == previousRow })
                let next = try XCTUnwrap(layer.themis.first { $0.sourceRow == nextRow })
                XCTAssertEqual(previous.span.body, crossing.body)
                XCTAssertEqual(next.span.body, crossing.body)
                XCTAssertEqual(previous.span.house, crossing.fromHouse)
                XCTAssertEqual(next.span.house, crossing.toHouse)
                XCTAssertEqual(previous.span.end, crossing.occurrence)
                XCTAssertEqual(next.span.start, crossing.occurrence)

            case let (.ringRealization(realization), .oceanusRealization(sourceRow)):
                let temporalFact = try XCTUnwrap(
                    layer.oceanus.first { $0.sourceRow == sourceRow }
                )
                XCTAssertEqual(temporalFact.realization, realization)

            default:
                XCTFail("Rhea qualification was attached to the wrong temporal fact kind.")
            }
        }
    }

    func testRheaForgePreservesMultipleQualificationsForOneTemporalFact() throws {
        let commission = try commissionWithRepeatedRingQualification()
        let layer = try forgeRheaLayer(for: commission)
        let ringRows = layer.rhea.filter { forged in
            if case .ringRealization = forged.qualification.source { return true }
            return false
        }

        XCTAssertEqual(ringRows.count, 2)
        XCTAssertEqual(Set(ringRows.map(\.fact)).count, 1)
        XCTAssertEqual(ringRows.map(\.sourceRow), [1, 2])
    }

    func testRheaForgePreservesMaterRelationshipAndPriorForgeLayersUnchanged() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = NatalSpineActIIFixture.substrate(for: commission)
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        let rhea = try Hephaestus.forgeNatalSpineRhea(on: oceanus)

        XCTAssertEqual(rhea.substrate, oceanus.substrate)
        XCTAssertEqual(rhea.themis, oceanus.themis)
        XCTAssertEqual(rhea.oceanus, oceanus.oceanus)

        for forged in rhea.rhea {
            let source = commission.schematics.rhea.qualifications[forged.sourceRow]
            XCTAssertEqual(forged.qualification.source, source.source)
            XCTAssertEqual(forged.qualification.temper, source.temper)
            XCTAssertEqual(forged.qualification.source.body.planet, source.temper.planet)
        }
    }

    private func forgeRheaLayer(
        for commission: NatalSpineForgeCommission
    ) throws -> NatalSpineRheaForgeLayer {
        let substrate = NatalSpineActIIFixture.substrate(for: commission)
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        return try Hephaestus.forgeNatalSpineRhea(on: oceanus)
    }

    private func commissionWithRepeatedRingQualification() throws -> NatalSpineForgeCommission {
        let base = try NatalSpineActIIFixture.forgeCommission()
        let original = base.schematics.rhea.qualifications
        let ringQualification = try XCTUnwrap(original.first { qualification in
            if case .ringRealization = qualification.source { return true }
            return false
        })
        let rhea = NatalSpineRheaTable(
            subjectID: base.subjectID,
            bounds: base.schematics.bounds,
            qualifications: original + [ringQualification]
        )
        let certified = try Atropos.inspectNatalSpineSchematics(
            bounds: base.schematics.bounds,
            themis: base.schematics.themis,
            oceanus: base.schematics.oceanus,
            rhea: rhea
        ).get()
        let package = HermesPackage(
            packageID: HermesPackageID(),
            subjectID: base.subjectID,
            sender: OrboOnboarding.orboAddress,
            kind: NatalSpineCommission.packageKind,
            addresses: NatalSpineCommission.itinerary,
            contents: certified
        )!
        return try Hephaestus.receiveNatalSpineSchematics(package)
    }
}
