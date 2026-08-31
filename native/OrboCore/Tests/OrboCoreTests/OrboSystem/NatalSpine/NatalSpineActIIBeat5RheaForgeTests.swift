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
}
