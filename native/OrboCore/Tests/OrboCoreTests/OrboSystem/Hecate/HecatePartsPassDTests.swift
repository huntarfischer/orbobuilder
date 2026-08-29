import XCTest
@testable import OrboCore

final class HecatePartsPassDTests: XCTestCase {
    private var canonicalParts: [Kleis] {
        Kleides.canonical.all.filter { $0.family == .parts }
    }

    func testCanonicalKleidesNowContainsAllFrozenParts() {
        XCTAssertEqual(Kleides.canonical.all.count, 320)
        XCTAssertEqual(canonicalParts.count, 155)

        let familyCounts = Dictionary(grouping: Kleides.canonical.all, by: \.family)
            .mapValues(\.count)

        XCTAssertEqual(familyCounts[.astroDNA], 2)
        XCTAssertEqual(familyCounts[.sect], 1)
        XCTAssertEqual(familyCounts[.lots], 162)
        XCTAssertEqual(familyCounts[.parts], 155)
    }

    func testCanonicalPartsExactlyEqualCatalogueDeclarations() {
        XCTAssertEqual(
            Set(canonicalParts),
            Set(PartsKleidesCatalogue.declarations)
        )
        XCTAssertEqual(canonicalParts.count, PartsKleidesCatalogue.declarations.count)
    }

    func testEveryFrozenPartRoundTripsThroughCanonicalKleidesByIdentity() throws {
        for declaration in PartsKleidesCatalogue.declarations {
            let admitted = try XCTUnwrap(Kleides.canonical.kleis(declaration.id))
            XCTAssertEqual(admitted, declaration, declaration.id.rawValue)
        }
    }

    func testCanonicalPartsPreserveFrozenContextCounts() {
        let counts = Dictionary(grouping: canonicalParts, by: \.context)
            .mapValues(\.count)

        XCTAssertEqual(counts[.natal], 97)
        XCTAssertEqual(counts[.annualConjunction], 8)
        XCTAssertEqual(counts[.mundaneWeather], 8)
        XCTAssertEqual(counts[.agricultural], 24)
        XCTAssertEqual(counts[.horary], 18)
    }

    func testCanonicalPartsRemainL3OnlyAndCarryNoOrboDefaults() {
        let l3Only = KleisAvailability(l1: false, l2: false, l3: true)!

        XCTAssertTrue(canonicalParts.allSatisfy { $0.availability == l3Only })
        XCTAssertTrue(canonicalParts.allSatisfy { part in
            part.formulas.allSatisfy { !$0.isOrboDefault }
        })
    }

    func testPartsFreezePreservesDistinctIdentityAndSourceOccurrenceCounts() {
        XCTAssertEqual(Set(canonicalParts.map(\.id)).count, 155)
        XCTAssertEqual(PartsKleidesCatalogue.entries.count, 155)
        XCTAssertEqual(
            PartsKleidesCatalogue.entries.map(\.sourceOccurrenceCount).reduce(0, +),
            156
        )
    }

    func testPartsGraftDoesNotChangeExistingLotsPopulation() {
        let lots = Kleides.canonical.all.filter { $0.family == .lots }

        XCTAssertEqual(lots.count, 162)
        XCTAssertEqual(lots.flatMap(\.formulas).count, 182)
    }
}
