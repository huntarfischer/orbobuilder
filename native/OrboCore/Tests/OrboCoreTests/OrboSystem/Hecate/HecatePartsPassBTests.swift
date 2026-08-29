import XCTest
@testable import OrboCore

final class HecatePartsPassBTests: XCTestCase {
    func testPassBContainsExactlyNinetySevenNatalParts() {
        let natal = PartsKleidesCatalogue.entries.filter { $0.kleis.context == .natal }
        XCTAssertEqual(natal.count, 97)
    }

    func testPassBPreservesSevenEightyTenNatalDivision() {
        let natal = PartsKleidesCatalogue.entries.filter { $0.kleis.context == .natal }
        let counts = Dictionary(grouping: natal, by: \.natalDivision).mapValues(\.count)

        XCTAssertEqual(counts[.planetary], 7)
        XCTAssertEqual(counts[.house], 80)
        XCTAssertEqual(counts[.miscellaneous], 10)
    }

    func testPassBPreservesExactHouseShelfCounts() {
        let houseEntries = PartsKleidesCatalogue.entries.filter { $0.natalDivision == .house }
        let counts = Dictionary(grouping: houseEntries, by: \.houseCategory).mapValues(\.count)
        let expected = [3, 3, 3, 8, 5, 4, 16, 5, 7, 12, 11, 3]

        for house in 1...12 {
            XCTAssertEqual(counts[house], expected[house - 1], "House \(house)")
        }
    }

    func testEveryPassBPageIsAnL3OnlyPartWithUniqueTechnicalIdentity() {
        let entries = PartsKleidesCatalogue.entries
        let ids = entries.map(\.kleis.id)

        XCTAssertEqual(Set(ids).count, entries.count)
        XCTAssertTrue(entries.allSatisfy { $0.kleis.family == .parts })
        XCTAssertTrue(entries.allSatisfy {
            $0.kleis.availability == KleisAvailability(l1: false, l2: false, l3: true)!
        })
        XCTAssertTrue(entries.allSatisfy { !$0.sourceLabel.isEmpty })
        XCTAssertTrue(entries.allSatisfy { entry in
            entry.formulas.allSatisfy { !$0.kleisFormula.isOrboDefault }
        })
    }

    func testEveryFormulaPreservesItsDocumentarySectFace() {
        for entry in PartsKleidesCatalogue.entries {
            for formula in entry.formulas {
                switch formula.sourceSectMark {
                case .same:
                    XCTAssertEqual(formula.dayCalculation, formula.nightCalculation, entry.sourceLabel)
                    XCTAssertEqual(formula.kleisFormula.sectRule, .same, entry.sourceLabel)
                    XCTAssertFalse(
                        formula.kleisFormula.requiredResources.contains(HecateResourceKey(rawValue: "Sect")!),
                        entry.sourceLabel
                    )

                case .reverse:
                    XCTAssertEqual(formula.kleisFormula.sectRule, .reverse, entry.sourceLabel)
                    if formula.kleisFormula.status == .unresolved {
                        XCTAssertEqual(formula.dayCalculation, "unresolved", entry.sourceLabel)
                        XCTAssertEqual(formula.nightCalculation, "unresolved", entry.sourceLabel)
                    } else {
                        XCTAssertNotEqual(formula.dayCalculation, formula.nightCalculation, entry.sourceLabel)
                        XCTAssertTrue(
                            formula.kleisFormula.requiredResources.contains(HecateResourceKey(rawValue: "Sect")!),
                            entry.sourceLabel
                        )
                        XCTAssertEqual(formula.kleisFormula.formula, formula.dayCalculation, entry.sourceLabel)
                    }

                case .unmarked:
                    XCTAssertEqual(formula.dayCalculation, formula.nightCalculation, entry.sourceLabel)
                    XCTAssertEqual(formula.kleisFormula.sectRule, .none, entry.sourceLabel)
                    XCTAssertFalse(
                        formula.kleisFormula.requiredResources.contains(HecateResourceKey(rawValue: "Sect")!),
                        entry.sourceLabel
                    )
                }
            }
        }
    }

    func testDocumentaryDuplicateIsOneKleisWithTwoSourceOccurrences() {
        let ancestors = entry("parts.natal.house04.ancestorsAndRelations")
        XCTAssertEqual(ancestors.sourceLabel, "Ancestors and relations")
        XCTAssertEqual(ancestors.sourceOccurrenceCount, 2)

        let otherEntries = PartsKleidesCatalogue.entries.filter {
            $0.kleis.id != ancestors.kleis.id
        }
        XCTAssertTrue(otherEntries.allSatisfy { $0.sourceOccurrenceCount == 1 })
    }

    func testRepresentativePlanetaryAndHouseRowsPreserveSourceCalculations() {
        let fortune = entry("parts.natal.planetary.fortuneOrLunarHoroscope").formulas[0]
        XCTAssertEqual(fortune.dayCalculation, "Asc + Moon - Sun")
        XCTAssertEqual(fortune.nightCalculation, "Asc + Sun - Moon")
        XCTAssertEqual(fortune.sourceSectMark, .reverse)

        let treasure = entry("parts.natal.house02.treasureTrove").formulas[0]
        XCTAssertEqual(treasure.dayCalculation, "Asc + Venus - Mercury")
        XCTAssertEqual(treasure.nightCalculation, "Asc + Venus - Mercury")
        XCTAssertEqual(treasure.sourceSectMark, .same)

        let sonsInLaw = entry("parts.natal.house07.sonsInLaw").formulas[0]
        XCTAssertEqual(sonsInLaw.dayCalculation, "Asc + Venus - Saturn")
        XCTAssertEqual(sonsInLaw.nightCalculation, "Asc + Saturn - Venus")
        XCTAssertEqual(sonsInLaw.sourceSectMark, .reverse)
    }

    func testSourceAmbiguitiesRemainPartialInsteadOfBeingSilentlyResolved() {
        XCTAssertEqual(
            entry("parts.natal.house04.parents").formulas[0].kleisFormula.status,
            .partial
        )
        XCTAssertEqual(
            entry("parts.natal.house04.grandparents").formulas[0].kleisFormula.status,
            .partial
        )
        XCTAssertEqual(
            entry("parts.natal.house05.children").formulas[0].kleisFormula.status,
            .partial
        )
    }

    func testKingsAndSultansRemainsExplicitlyUnresolved() {
        let kings = entry("parts.natal.house10.kingsAndSultans")
        let formula = kings.formulas[0]

        XCTAssertEqual(kings.sourceLabel, "Kings and Sultans")
        XCTAssertEqual(formula.sourceSectMark, .reverse)
        XCTAssertEqual(formula.dayCalculation, "unresolved")
        XCTAssertEqual(formula.nightCalculation, "unresolved")
        XCTAssertEqual(formula.kleisFormula.status, .unresolved)
        XCTAssertEqual(formula.kleisFormula.formula, "source formula unresolved")
        XCTAssertEqual(
            formula.kleisFormula.requiredResources,
            [HecateResourceKey(rawValue: "unresolved")!]
        )
    }

    func testMiscellaneousShelfPreservesSourceBoundary() {
        let hailaj = entry("parts.natal.miscellaneous.hailaj")
        XCTAssertEqual(hailaj.natalDivision, .miscellaneous)
        XCTAssertNil(hailaj.houseCategory)
        XCTAssertEqual(hailaj.formulas[0].sourceSectMark, .same)
        XCTAssertEqual(
            hailaj.formulas[0].dayCalculation,
            "Asc + Moon - degree of previous syzygy"
        )
    }

    func testPassBNatalDeclarationsRemainDirectCatalogueKleides() {
        let natalEntries = PartsKleidesCatalogue.entries.filter { $0.kleis.context == .natal }
        let natalDeclarations = PartsKleidesCatalogue.declarations.filter { $0.context == .natal }

        XCTAssertEqual(natalDeclarations, natalEntries.map(\.kleis))
    }

    private func entry(_ rawID: String) -> PartCatalogueEntry {
        let id = KleisID(rawValue: rawID)!
        return PartsKleidesCatalogue.entries.first(where: { $0.kleis.id == id })!
    }
}
