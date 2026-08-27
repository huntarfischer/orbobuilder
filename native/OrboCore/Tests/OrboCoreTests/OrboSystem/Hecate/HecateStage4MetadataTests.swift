import XCTest
@testable import OrboCore

final class HecateStage4MetadataTests: XCTestCase {
    private let resourceA = HecateResourceKey(rawValue: "resource-a")!
    private let resourceB = HecateResourceKey(rawValue: "resource-b")!

    func testAvailabilityAcceptsOnlyCumulativeL1L2L3States() {
        XCTAssertNotNil(KleisAvailability(l1: true, l2: true, l3: true))
        XCTAssertNotNil(KleisAvailability(l1: false, l2: true, l3: true))
        XCTAssertNotNil(KleisAvailability(l1: false, l2: false, l3: true))

        XCTAssertNil(KleisAvailability(l1: true, l2: false, l3: true))
        XCTAssertNil(KleisAvailability(l1: true, l2: true, l3: false))
        XCTAssertNil(KleisAvailability(l1: true, l2: false, l3: false))
        XCTAssertNil(KleisAvailability(l1: false, l2: true, l3: false))
        XCTAssertNil(KleisAvailability(l1: false, l2: false, l3: false))
    }

    func testFrozenContextsAreRepresentable() {
        XCTAssertEqual(
            KleisContext.allCases,
            [.natal, .annualConjunction, .mundaneWeather, .agricultural, .horary]
        )
    }

    func testKleisStoresPageMetadataAndFormulaRows() throws {
        let formula = makeFormula(
            requiredResources: [resourceA, resourceB],
            formula: "Asc + B - A",
            tradition: "Example",
            sectRule: .reverse,
            conditions: ["night reverses operands"],
            isOrboDefault: true,
            status: .complete
        )
        let availability = KleisAvailability(l1: false, l2: true, l3: true)!
        let kleis = try XCTUnwrap(
            Kleis(
                id: KleisID(rawValue: "example-kleis")!,
                aliases: ["Example alias"],
                family: .lots,
                context: .natal,
                availability: availability,
                formulas: [formula]
            )
        )

        XCTAssertEqual(kleis.aliases, ["Example alias"])
        XCTAssertEqual(kleis.family, .lots)
        XCTAssertEqual(kleis.context, .natal)
        XCTAssertEqual(kleis.availability, availability)
        XCTAssertEqual(kleis.formulas, [formula])
        XCTAssertEqual(kleis.operationalFormula, formula)
    }

    func testKleisAllowsFormulaVariantsButAtMostOneOrboDefault() {
        let first = makeFormula(
            requiredResources: [resourceA],
            formula: "Asc + A",
            tradition: "Tradition A",
            isOrboDefault: true
        )
        let second = makeFormula(
            requiredResources: [resourceB],
            formula: "Asc + B",
            tradition: "Tradition B",
            isOrboDefault: false
        )
        let availability = KleisAvailability(l1: true, l2: true, l3: true)!

        let valid = Kleis(
            id: KleisID(rawValue: "variant-kleis")!,
            family: .lots,
            context: .natal,
            availability: availability,
            formulas: [first, second]
        )
        XCTAssertEqual(valid?.operationalFormula, first)

        let secondDefault = makeFormula(
            requiredResources: [resourceB],
            formula: "Asc + B",
            tradition: "Tradition B",
            isOrboDefault: true
        )
        XCTAssertNil(
            Kleis(
                id: KleisID(rawValue: "invalid-defaults")!,
                family: .lots,
                context: .natal,
                availability: availability,
                formulas: [first, secondDefault]
            )
        )
    }

    func testMultipleVariantsWithoutOrboDefaultCannotUseGenericCastGate() {
        let first = makeFormula(
            requiredResources: [resourceA],
            formula: "Asc + A",
            tradition: "Tradition A"
        )
        let second = makeFormula(
            requiredResources: [resourceB],
            formula: "Asc + B",
            tradition: "Tradition B"
        )
        let id = KleisID(rawValue: "unselected-variant-kleis")!
        let kleis = Kleis(
            id: id,
            family: .lots,
            context: .natal,
            availability: KleisAvailability(l1: false, l2: false, l3: true)!,
            formulas: [first, second]
        )!
        let kleides = Kleides([kleis])!

        XCTAssertNil(kleis.operationalFormula)
        XCTAssertThrowsError(
            try Hecate.prepareCast(id, using: [resourceA, resourceB], from: kleides)
        ) { error in
            XCTAssertEqual(error as? HecateFailure, .invalidCast(id))
        }
    }

    func testAstroDNAUsesFrozenPageMetadataWithoutInventingADefaultChoice() {
        let kleis = AstroDNAKleis.declaration

        XCTAssertEqual(kleis.context, .natal)
        XCTAssertEqual(
            kleis.availability,
            KleisAvailability(l1: true, l2: true, l3: true)!
        )
        XCTAssertEqual(kleis.formulas, [AstroDNAKleis.formula])
        XCTAssertFalse(AstroDNAKleis.formula.isOrboDefault)
        XCTAssertEqual(kleis.operationalFormula, AstroDNAKleis.formula)
    }

    private func makeFormula(
        requiredResources: [HecateResourceKey],
        formula: String,
        tradition: String,
        sectRule: KleisSectRule = .none,
        conditions: [String] = [],
        isOrboDefault: Bool = false,
        status: KleisFormulaStatus = .complete
    ) -> KleisFormula {
        KleisFormula(
            requiredResources: requiredResources,
            formula: formula,
            tradition: tradition,
            sectRule: sectRule,
            conditions: conditions,
            isOrboDefault: isOrboDefault,
            sources: ["Hecate Stage 4 test"],
            status: status
        )!
    }
}
