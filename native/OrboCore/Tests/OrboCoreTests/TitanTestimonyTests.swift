import XCTest
@testable import OrboCore

final class TitanTestimonyTests: XCTestCase {
    func testThemisPassContainsOnlyHerExistingImprintTruth() {
        let direct = Themis.set(.leo)
        let pass = Themis.testify(.leo)

        XCTAssertEqual(pass.imprint.risingSign, direct.risingSign)
        XCTAssertEqual(pass.imprint.houses, direct.houses)
        XCTAssertEqual(
            pass.imprint.traditionalGovernanceLattice,
            direct.traditionalGovernanceLattice
        )
        XCTAssertEqual(pass.imprint.modernGovernance, direct.modernGovernance)
        XCTAssertEqual(pass.imprint.houseGovernance, direct.houseGovernance)
    }

    func testRheaPassContainsOnlyHerExistingQualifiedFieldTruth() {
        let longitudes = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.enumerated().map { index, planet in
                (planet, CelestialLongitude(Double(index * 30 + 7))!)
            }
        )
        let direct = Rhea.bear(longitudes, sect: .night)
        let pass = Rhea.testify(longitudes, sect: .night)

        XCTAssertEqual(pass.field.longitudes, direct.longitudes)
        XCTAssertEqual(pass.field.sect, direct.sect)
        XCTAssertEqual(pass.field.tempers, direct.tempers)
        XCTAssertEqual(pass.field.byPlanet, direct.byPlanet)
    }

    func testOceanusPassContainsTheCanonicalObjectTemplatesFromTheTransit() throws {
        let dna = try makeSyntheticDNA()
        let direct = AstroDNAGene.canonicalOrder.map { gene in
            Oceanus.encircle(gene, in: dna)
        }
        let pass = Oceanus.testify(dna)

        XCTAssertEqual(pass.objectTemplates, direct)
        XCTAssertEqual(pass.objectTemplates.map(\.gene), AstroDNAGene.canonicalOrder)
    }

    func testAsteriaPassContainsOnlyRefractionsAndTheirProjections() throws {
        let first = ArcSubject(
            identity: "first",
            provenance: "test",
            coordinate: try XCTUnwrap(ArcCoordinate(degree: 31, minute: 12, second: 5))
        )
        let second = ArcSubject(
            identity: "second",
            provenance: "test",
            coordinate: try XCTUnwrap(ArcCoordinate(degree: 203, minute: 44, second: 19))
        )
        let subjects = [first, second]
        let directRefractions = Asteria.refract(subjects)
        let directProjections = directRefractions.map { Asteria.project($0.field) }
        let pass = Asteria.testify(subjects)

        XCTAssertEqual(pass.refractions, directRefractions)
        XCTAssertEqual(pass.projections, directProjections)
        XCTAssertEqual(pass.refractions.map(\.subject), subjects)
    }

    private func makeSyntheticDNA() throws -> AstroDNA {
        let sequence = try (0..<AstroDNAGene.canonicalOrder.count).map { index -> RingFineState in
            let arcsecond = (index * 29 + 11) * Ring.arcsecondsPerDegree + index * 37
            return try XCTUnwrap(RingFineState(arcsecond))
        }
        return try XCTUnwrap(AstroDNA(sequence: sequence))
    }
}
