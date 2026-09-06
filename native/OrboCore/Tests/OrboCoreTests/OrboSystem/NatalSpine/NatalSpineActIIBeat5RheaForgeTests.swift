import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat5RheaForgeTests: XCTestCase {
    func testHephaestusTranscribesEveryCertifiedRheaQualificationExactlyOnce() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let rheaLayer = try forgeRheaLayer(for: commission)
        let source = commission.schematics.rhea.qualifications

        XCTAssertEqual(rheaLayer.subjectID, commission.subjectID)
        XCTAssertEqual(rheaLayer.bounds, commission.schematics.bounds)
        XCTAssertEqual(rheaLayer.rhea.count, source.count)
        XCTAssertEqual(rheaLayer.rhea.map(\.sourceRow), Array(source.indices))
        XCTAssertEqual(rheaLayer.rhea.map(\.qualification), source)
    }

    func testRheaForgeDoesNotRequireThemisOrOceanusFactAttachment() throws {
        let commission = try commissionWithIndependentMaterMoment()
        let layer = try forgeRheaLayer(for: commission)
        let added = try XCTUnwrap(layer.rhea.last)

        XCTAssertEqual(added.qualification, commission.schematics.rhea.qualifications.last)
        XCTAssertFalse(layer.themis.contains {
            abs($0.span.start.value - added.qualification.source.julianDay.value) <= 1e-9
                || abs($0.span.end.value - added.qualification.source.julianDay.value) <= 1e-9
        })
        XCTAssertFalse(layer.oceanus.contains {
            abs($0.realization.occurrence.julianDay.value
                - added.qualification.source.julianDay.value) <= 1e-9
        })
    }

    func testRheaForgePreservesRepeatedIndependentQualificationsAsSeparateRows() throws {
        let base = try NatalSpineActIIFixture.forgeCommission()
        let original = base.schematics.rhea.qualifications
        let repeated = try XCTUnwrap(original.first)
        let commission = try commission(base: base, qualifications: original + [repeated])
        let layer = try forgeRheaLayer(for: commission)

        XCTAssertEqual(layer.rhea.count, 3)
        XCTAssertEqual(layer.rhea.map(\.sourceRow), [0, 1, 2])
        XCTAssertEqual(layer.rhea[0].qualification, layer.rhea[2].qualification)
    }

    func testRheaForgePreservesMaterRelationshipAndPriorForgeLayersUnchanged() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = NatalSpineActIIFixture.substrate(for: commission)
        let themis = try Hephaestus.forgeNatalSpineThemis(for: commission, on: substrate)
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
        let themis = try Hephaestus.forgeNatalSpineThemis(for: commission, on: substrate)
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        return try Hephaestus.forgeNatalSpineRhea(on: oceanus)
    }

    private func commissionWithIndependentMaterMoment() throws -> NatalSpineForgeCommission {
        let base = try NatalSpineActIIFixture.forgeCommission()
        let day = JulianDay(base.schematics.bounds.bone.start.value + 15)!
        let field = Rhea.bear(
            Dictionary(uniqueKeysWithValues: Planet.canonicalOrder.enumerated().map { index, planet in
                (planet, CelestialLongitude(Double(index * 29 + 4))!)
            }),
            sect: .day
        )
        let extra = NatalSpineMaterQualification(
            source: NatalSpineRheaSource(body: .mars, julianDay: day)!,
            temper: field.temper(for: .mars)
        )!
        return try commission(
            base: base,
            qualifications: base.schematics.rhea.qualifications + [extra]
        )
    }

    private func commission(
        base: NatalSpineForgeCommission,
        qualifications: [NatalSpineMaterQualification]
    ) throws -> NatalSpineForgeCommission {
        let rhea = NatalSpineRheaTable(
            subjectID: base.subjectID,
            bounds: base.schematics.bounds,
            qualifications: qualifications
        )
        let certified = try Atropos.inspectNatalSpineSchematics(
            threads: base.schematics.threads,
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
