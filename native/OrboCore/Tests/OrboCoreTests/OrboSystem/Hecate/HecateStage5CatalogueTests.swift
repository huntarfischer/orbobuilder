import XCTest
@testable import OrboCore

final class HecateStage5CatalogueTests: XCTestCase {
    private var lots: [Kleis] {
        Kleides.canonical.all.filter { $0.family == .lots }
    }

    func testCanonicalKleidesContainsCompleteLotsCatalogue() {
        XCTAssertEqual(Kleides.canonical.all.count, 163)
        XCTAssertEqual(lots.count, 162)
        XCTAssertEqual(lots.flatMap { $0.formulas }.count, 182)
    }

    func testCataloguePreservesContextPageCounts() {
        XCTAssertEqual(lots.filter { $0.context == .natal }.count, 111)
        XCTAssertEqual(lots.filter { $0.context == .annualConjunction }.count, 8)
        XCTAssertEqual(lots.filter { $0.context == .mundaneWeather }.count, 8)
        XCTAssertEqual(lots.filter { $0.context == .agricultural }.count, 24)
        XCTAssertEqual(lots.filter { $0.context == .horary }.count, 11)
    }

    func testOnlyFirstFourLotsAreAvailableAtL1AndL2() {
        let expected = Set(["Fortune", "Spirit", "Eros", "Necessity"])

        XCTAssertEqual(
            Set(lots.filter { $0.availability.l1 }.map { $0.id.rawValue }),
            expected
        )
        XCTAssertEqual(
            Set(lots.filter { $0.availability.l2 }.map { $0.id.rawValue }),
            expected
        )
        XCTAssertTrue(lots.allSatisfy { $0.availability.l3 })
    }

    func testNoLotFormulaHasOrboDefaultBeforeDefaultsPass() {
        XCTAssertTrue(
            lots
                .flatMap { $0.formulas }
                .allSatisfy { !$0.isOrboDefault }
        )
    }

    func testCataloguePreservesFormulaStatusCounts() {
        let formulas = lots.flatMap { $0.formulas }

        XCTAssertEqual(formulas.filter { $0.status == .complete }.count, 171)
        XCTAssertEqual(formulas.filter { $0.status == .partial }.count, 7)
        XCTAssertEqual(formulas.filter { $0.status == .unresolved }.count, 4)
    }

    func testUnresolvedSourceRowsRemainUnresolvedRatherThanInvented() throws {
        for id in [
            "Planetary Love (Venus)",
            "Planetary Necessity (Mercury)",
            "Exaltation",
        ] {
            let page = try XCTUnwrap(
                Kleides.canonical.kleis(KleisID(rawValue: id)!)
            )
            let formula = try XCTUnwrap(page.formulas.first)

            XCTAssertEqual(formula.status, .unresolved)
            XCTAssertEqual(
                formula.requiredResources.map(\.rawValue),
                ["unresolved"]
            )
        }
    }

    func testFormulaColumnStillProvidesDirectCrossReference() {
        var pagesByFormula: [String: Set<KleisID>] = [:]

        for page in lots {
            for formula in page.formulas {
                pagesByFormula[formula.formula, default: []].insert(page.id)
            }
        }

        XCTAssertEqual(pagesByFormula.count, 86)
        XCTAssertEqual(
            pagesByFormula.values.filter { $0.count > 1 }.count,
            35
        )
    }

    func testRepresentativeVariantPagesRemainSingleKleisIdentities() throws {
        XCTAssertEqual(
            try XCTUnwrap(
                Kleides.canonical.kleis(KleisID(rawValue: "Fortune")!)
            ).formulas.count,
            3
        )
        XCTAssertEqual(
            try XCTUnwrap(
                Kleides.canonical.kleis(KleisID(rawValue: "Siblings")!)
            ).formulas.count,
            4
        )
        XCTAssertEqual(
            try XCTUnwrap(
                Kleides.canonical.kleis(KleisID(rawValue: "Children")!)
            ).formulas.count,
            3
        )
    }
}
