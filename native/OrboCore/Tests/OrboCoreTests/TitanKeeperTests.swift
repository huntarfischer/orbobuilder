import XCTest
@testable import OrboCore

final class TitanKeeperTests: XCTestCase {
    func testThemisSetsOnlyExistingTympanTruth() {
        let direct = Tympan.imprint(for: .scorpio)
        let kept = Themis.set(.scorpio)

        XCTAssertEqual(kept.risingSign, direct.risingSign)
        XCTAssertEqual(kept.houses, direct.houses)
        XCTAssertEqual(kept.traditionalGovernanceLattice, direct.traditionalGovernanceLattice)
        XCTAssertEqual(kept.modernGovernance, direct.modernGovernance)
        XCTAssertEqual(kept.houseGovernance, direct.houseGovernance)
    }

    func testRheaBearsOnlyExistingMaterTruth() {
        let longitudes = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.enumerated().map { index, planet in
                (planet, CelestialLongitude(Double(index * 30 + 5))!)
            }
        )

        let direct = Mater.qualifyField(longitudes, sect: .day)
        let kept = Rhea.bear(longitudes, sect: .day)

        XCTAssertEqual(kept.longitudes, direct.longitudes)
        XCTAssertEqual(kept.sect, direct.sect)
        XCTAssertEqual(kept.tempers, direct.tempers)
        XCTAssertEqual(kept.byPlanet, direct.byPlanet)
    }

    func testOceanusEncirclesOnlyExistingRingTruth() throws {
        let direct = try XCTUnwrap(Ring.template(forDegree: 137))
        let kept = try XCTUnwrap(Oceanus.encircle(degree: 137))

        XCTAssertEqual(kept, direct)
    }

    func testAsteriaRefractsOnlyExistingArcTruth() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 17, minute: 23, second: 41))
        let partner = try XCTUnwrap(ArcCoordinate(degree: 221, minute: 4, second: 9))

        XCTAssertEqual(Asteria.refract(anchor), Arc.cast(anchor))
        XCTAssertEqual(
            Asteria.refract(anchor, with: partner),
            Arc.compose(anchor, partner)
        )

        let first = ArcSubject(identity: "first", provenance: "test", coordinate: anchor)
        let second = ArcSubject(identity: "second", provenance: "test", coordinate: partner)
        let subjects = [first, second]

        XCTAssertEqual(Asteria.refract(first), Arc.cast(first))
        XCTAssertEqual(Asteria.refract(subjects), Arc.cast(subjects))
        XCTAssertEqual(
            Asteria.refract(first, with: second),
            Arc.compose(first, second)
        )

        let field = Asteria.refract(anchor)
        XCTAssertEqual(Asteria.project(field), Arc.project(field))
    }
}
