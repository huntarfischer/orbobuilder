import XCTest
@testable import OrboCore

final class HecatePartsPassCTests: XCTestCase {
    func testPassCCompletesOneHundredFiftyFiveDistinctParts() {
        XCTAssertEqual(PartsKleidesCatalogue.entries.count, 155)
        XCTAssertEqual(PartsKleidesCatalogue.declarations.count, 155)
        XCTAssertEqual(Set(PartsKleidesCatalogue.entries.map(\.kleis.id)).count, 155)
        XCTAssertEqual(PartsKleidesCatalogue.entries.map(\.sourceOccurrenceCount).reduce(0, +), 156)
        XCTAssertEqual(
            PartsKleidesCatalogue.declarations,
            PartsKleidesCatalogue.entries.map(\.kleis)
        )
    }

    func testPassCPreservesExactContextCounts() {
        let counts = Dictionary(grouping: PartsKleidesCatalogue.entries, by: { $0.kleis.context })
            .mapValues(\.count)

        XCTAssertEqual(counts[.natal], 97)
        XCTAssertEqual(counts[.annualConjunction], 8)
        XCTAssertEqual(counts[.mundaneWeather], 8)
        XCTAssertEqual(counts[.agricultural], 24)
        XCTAssertEqual(counts[.horary], 18)
    }

    func testEveryNonNatalPartUsesExistingContextWithoutNatalTaxonomy() {
        let nonNatal = PartsKleidesCatalogue.entries.filter { $0.kleis.context != .natal }
        XCTAssertEqual(nonNatal.count, 58)
        XCTAssertTrue(nonNatal.allSatisfy { $0.natalDivision == nil })
        XCTAssertTrue(nonNatal.allSatisfy { $0.houseCategory == nil })
        XCTAssertTrue(nonNatal.allSatisfy {
            $0.kleis.availability == KleisAvailability(l1: false, l2: false, l3: true)!
        })
        XCTAssertTrue(nonNatal.allSatisfy { entry in
            entry.formulas.allSatisfy { !$0.kleisFormula.isOrboDefault }
        })
    }

    func testPassCFormulaRowsReconcileToSourceStructure() {
        let nonNatal = PartsKleidesCatalogue.entries.filter { $0.kleis.context != .natal }
        let formulas = nonNatal.flatMap(\.formulas)

        XCTAssertEqual(formulas.count, 63)
        XCTAssertEqual(formulas.filter { $0.kleisFormula.status == .complete }.count, 59)
        XCTAssertEqual(formulas.filter { $0.kleisFormula.status == .partial }.count, 4)
        XCTAssertEqual(formulas.filter { $0.kleisFormula.status == .unresolved }.count, 0)
    }

    func testAnnualAlternativeFormulasRemainInsideTheirNamedParts() {
        let sultan = entry("parts.annualConjunction.sultansLot")
        XCTAssertEqual(sultan.sourceLabel, "The Sultan's Lot")
        XCTAssertEqual(sultan.formulas.count, 3)
        XCTAssertEqual(sultan.formulas.map(\.kleisFormula.status), [.partial, .partial, .complete])
        XCTAssertEqual(sultan.formulas[0].dayCalculation, "Jupiter + MC of the return chart - MC")
        XCTAssertEqual(sultan.formulas[1].dayCalculation, "Jupiter + MC of the return chart - Sun")
        XCTAssertEqual(sultan.formulas[2].dayCalculation, "Asc + Degree conj. - Deg. Asc. Conj.")

        let victory = entry("parts.annualConjunction.victory")
        XCTAssertEqual(victory.formulas.count, 2)
        XCTAssertTrue(victory.formulas.allSatisfy { $0.kleisFormula.status == .partial })

        let battle = entry("parts.annualConjunction.battle")
        XCTAssertEqual(battle.formulas.count, 3)
        XCTAssertEqual(battle.formulas[0].dayCalculation, "Degree of Lot of Victory - Moon - Mars")
        XCTAssertEqual(battle.formulas[1].kleisFormula.tradition, "Umar (as attributed by al-Biruni)")
        XCTAssertEqual(battle.formulas[2].kleisFormula.tradition, "Al Furkhan (as attributed by al-Biruni)")
    }

    func testTriumphPreservesReverseDayAndNightFaces() {
        let triumph = entry("parts.annualConjunction.triumph").formulas[0]
        XCTAssertEqual(triumph.sourceSectMark, .reverse)
        XCTAssertEqual(triumph.dayCalculation, "Asc + Jupiter - Fortune")
        XCTAssertEqual(triumph.nightCalculation, "Asc + Fortune - Jupiter")
        XCTAssertEqual(triumph.kleisFormula.sectRule, .reverse)
        XCTAssertTrue(triumph.kleisFormula.requiredResources.contains(HecateResourceKey(rawValue: "Sect")!))
    }

    func testFloodsPreservesMoonRiseConditionWithoutInventingSectMark() {
        let floods = entry("parts.mundaneWeather.floods").formulas[0]

        XCTAssertEqual(floods.dayCalculation, "Moon + Sun - Saturn")
        XCTAssertEqual(floods.nightCalculation, "Moon + Sun - Saturn")
        XCTAssertEqual(floods.sourceSectMark, .unmarked)
        XCTAssertEqual(floods.kleisFormula.sectRule, .none)
        XCTAssertEqual(floods.kleisFormula.conditions, ["Cast chart at Moon-rise"])
        XCTAssertFalse(floods.kleisFormula.requiredResources.contains(HecateResourceKey(rawValue: "Sect")!))
    }

    func testAgriculturalShelfContainsExactlyTwentyFourReverseParts() {
        let agriculture = PartsKleidesCatalogue.entries.filter { $0.kleis.context == .agricultural }
        XCTAssertEqual(agriculture.count, 24)
        XCTAssertTrue(agriculture.allSatisfy { $0.formulas.count == 1 })
        XCTAssertTrue(agriculture.allSatisfy { $0.formulas[0].sourceSectMark == .reverse })

        let riceMillet = entry("parts.agricultural.riceMillet").formulas[0]
        XCTAssertEqual(riceMillet.dayCalculation, "Asc + Venus - Jupiter")
        XCTAssertEqual(riceMillet.nightCalculation, "Asc + Jupiter - Venus")

        let rawSilkCotton = entry("parts.agricultural.rawSilkCotton").formulas[0]
        XCTAssertEqual(rawSilkCotton.dayCalculation, "Asc + Venus - Mercury")
        XCTAssertEqual(rawSilkCotton.nightCalculation, "Asc + Mercury - Venus")
    }

    func testHoraryShelfPreservesPrintedNonstandardFormulaFaces() {
        XCTAssertEqual(
            entry("parts.horary.freedmenAndServants").formulas[0].dayCalculation,
            "Mercury + Saturn - Jupiter"
        )
        XCTAssertEqual(
            entry("parts.horary.lordsAndMasters").formulas[0].dayCalculation,
            "Moon - Saturn - Jupiter"
        )
        XCTAssertEqual(
            entry("parts.horary.dismissalOrResignation").formulas[0].dayCalculation,
            "Jupiter + Jupiter - Sun"
        )
        XCTAssertEqual(
            entry("parts.horary.timeThereof").formulas[0].dayCalculation,
            "Cusp 10th + Fortune - Lord of the affair"
        )
    }

    func testHoraryReverseRowsReverseOnlyMeasuredOperands() {
        let urgent = entry("parts.horary.urgentWish").formulas[0]
        XCTAssertEqual(urgent.dayCalculation, "Asc + Lord of Asc - Lord of hour")
        XCTAssertEqual(urgent.nightCalculation, "Asc + Lord of hour - Lord of Asc")

        let attainment = entry("parts.horary.timeOfAttainment").formulas[0]
        XCTAssertEqual(attainment.dayCalculation, "Asc + Lord of 10th - Lord of hour")
        XCTAssertEqual(attainment.nightCalculation, "Asc + Lord of hour - Lord of 10th")

        let information = entry("parts.horary.informationTrueOrNot").formulas[0]
        XCTAssertEqual(information.dayCalculation, "Asc + Moon - Mercury")
        XCTAssertEqual(information.nightCalculation, "Asc + Mercury - Moon")
    }

    func testPassCStillDoesNotRegisterOrCastPartsCanonically() {
        XCTAssertFalse(Kleides.canonical.all.contains(where: { $0.family == .parts }))
        XCTAssertEqual(Kleides.canonical.all.count, 165)
    }

    private func entry(_ rawID: String) -> PartCatalogueEntry {
        let id = KleisID(rawValue: rawID)!
        return PartsKleidesCatalogue.entries.first(where: { $0.kleis.id == id })!
    }
}
