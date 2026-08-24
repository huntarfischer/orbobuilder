import XCTest
@testable import OrboCore

final class FoundationIntegrationTests: XCTestCase {
    func testRingMaterAndTympanComposeOnOneCanonicalAddress() throws {
        let body = try XCTUnwrap(CelestialLongitude(70))
        let ascendant = try XCTUnwrap(CelestialLongitude(220))

        XCTAssertEqual(body.sign, .gemini)
        XCTAssertEqual(ascendant.sign, .scorpio)
        XCTAssertEqual(Tympan.house(of: body, ascendant: ascendant), .eighth)

        let condition = try XCTUnwrap(
            Mater.essentialCondition(of: .mars, at: body, sect: .day)
        )
        XCTAssertEqual(condition.dignities, [.face])
        XCTAssertFalse(condition.isPeregrine)

        let bodyState = Ring.state(of: body, motion: .direct)
        let ascendantState = Ring.state(of: ascendant, motion: .retrograde)
        XCTAssertEqual(Ring.relation(between: bodyState, and: ascendantState), .quincunx)
    }

    func testTympanConsumesCanonicalMaterWithoutModernContamination() {
        for rising in Sign.canonicalOrder {
            let imprint = Tympan.imprint(for: rising)
            for record in imprint.houses {
                XCTAssertEqual(record.ruler, Mater.domicileRuler(of: record.sign))
            }
        }

        XCTAssertEqual(Mater.domicileRuler(of: .scorpio), .mars)
        XCTAssertEqual(Tympan.modernRuler(of: .scorpio), .pluto)
        XCTAssertEqual(Tympan.modernGovernor(of: .first, rising: .scorpio), .pluto)
        XCTAssertNil(Tympan.TraditionalGovernor(planet: .pluto))
    }

    func testFoundationCanonicalSurfacesRemainClosedAndComplete() {
        XCTAssertEqual(Sign.canonicalOrder.count, 12)
        XCTAssertEqual(House.canonicalOrder.count, 12)
        XCTAssertEqual(Planet.classicalSeven.count, 7)
        XCTAssertEqual(Ring.marks.count, 11)

        for rising in Sign.canonicalOrder {
            let imprint = Tympan.imprint(for: rising)
            XCTAssertEqual(imprint.houses.count, 12)
            XCTAssertEqual(Set(imprint.houses.map(\.house)), Set(House.canonicalOrder))
        }
    }
}
