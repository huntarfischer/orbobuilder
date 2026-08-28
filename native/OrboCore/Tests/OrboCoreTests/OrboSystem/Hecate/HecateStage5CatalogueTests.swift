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

    func testExactlyFirstFourLotsCarryOrboDefaultsAfterDefaultsPass() {
        let defaults = lots.flatMap { page in
            page.formulas
                .filter { $0.isOrboDefault }
                .map { _ in page.id.rawValue }
        }

        XCTAssertEqual(defaults.count, 4)
        XCTAssertEqual(
            Set(defaults),
            Set(["Fortune", "Spirit", "Eros", "Necessity"])
        )
    }

    func testCataloguePreservesFormulaStatusCountsAfterIdentityReconciliation() {
        let formulas = lots.flatMap { $0.formulas }

        XCTAssertEqual(formulas.filter { $0.status == .complete }.count, 173)
        XCTAssertEqual(formulas.filter { $0.status == .partial }.count, 7)
        XCTAssertEqual(formulas.filter { $0.status == .unresolved }.count, 2)
    }

    func testUnresolvedHistoricalMaterialRemainsExplicitlyUnresolved() throws {
        let exaltation = try XCTUnwrap(
            Kleides.canonical.kleis(KleisID(rawValue: "Exaltation")!)
        )
        let formula = try XCTUnwrap(exaltation.formulas.first)

        XCTAssertEqual(formula.status, .unresolved)
        XCTAssertEqual(formula.requiredResources.map(\.rawValue), ["unresolved"])

        for id in ["Eros", "Necessity"] {
            let page = try XCTUnwrap(
                Kleides.canonical.kleis(KleisID(rawValue: id)!)
            )
            XCTAssertTrue(page.formulas.allSatisfy { $0.status == .complete })
            XCTAssertFalse(
                page.formulas
                    .flatMap { $0.requiredResources }
                    .contains(HecateResourceKey(rawValue: "unresolved")!)
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

        XCTAssertEqual(pagesByFormula.count, 87)
        XCTAssertEqual(
            pagesByFormula.values.filter { $0.count > 1 }.count,
            34
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
