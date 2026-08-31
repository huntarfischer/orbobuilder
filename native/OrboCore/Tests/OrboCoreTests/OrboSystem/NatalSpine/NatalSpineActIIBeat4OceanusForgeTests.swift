import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat4OceanusForgeTests: XCTestCase {
    func testHephaestusForgesEveryCertifiedOceanusRealizationExactlyOnce() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = NatalSpineActIIFixture.substrate(for: commission)
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )

        let layer = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        let source = commission.schematics.oceanus.realizations

        XCTAssertEqual(layer.subjectID, commission.subjectID)
        XCTAssertEqual(layer.bounds, commission.schematics.bounds)
        XCTAssertEqual(layer.oceanus.count, source.count)
        XCTAssertEqual(layer.oceanus.map(\.sourceRow), Array(source.indices))
        XCTAssertEqual(layer.oceanus.map(\.realization), source)
    }

    func testForgedOceanusRealizationPreservesExactRingAndTemporalTruth() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: NatalSpineActIIFixture.substrate(for: commission)
        )
        let layer = try Hephaestus.forgeNatalSpineOceanus(on: themis)

        for forged in layer.oceanus {
            let source = commission.schematics.oceanus.realizations[forged.sourceRow]
            XCTAssertEqual(forged.realization.mundaneBody, source.mundaneBody)
            XCTAssertEqual(forged.realization.natalGene, source.natalGene)
            XCTAssertEqual(forged.realization.natalSource, source.natalSource)
            XCTAssertEqual(forged.realization.relation, source.relation)
            XCTAssertEqual(forged.realization.targetArcsecond, source.targetArcsecond)
            XCTAssertEqual(
                forged.realization.occurrence.directionalDegree,
                source.occurrence.directionalDegree
            )
            XCTAssertEqual(
                forged.realization.occurrence.julianDay,
                source.occurrence.julianDay
            )
            XCTAssertEqual(forged.realization.occurrence, source.occurrence)
        }
    }

    func testOceanusForgePreservesAlreadyForgedThemisLayerAndSubstrate() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = NatalSpineActIIFixture.substrate(for: commission)
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )

        let layer = try Hephaestus.forgeNatalSpineOceanus(on: themis)

        XCTAssertEqual(layer.commission, themis.commission)
        XCTAssertEqual(layer.substrate, themis.substrate)
        XCTAssertEqual(layer.themis, themis.themis)
    }
}
