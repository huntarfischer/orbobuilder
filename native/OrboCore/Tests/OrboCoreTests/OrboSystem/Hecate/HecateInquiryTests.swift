import XCTest
@testable import OrboCore

final class HecateInquiryTests: XCTestCase {
    func testCanAskHecateWhatSheKnowsAboutALot() throws {
        let fortune = try XCTUnwrap(Hecate.inquire(KleisID(rawValue: "Fortune")!))

        XCTAssertEqual(fortune.kleis.family, .lots)
        XCTAssertEqual(fortune.kleis.context, .natal)
        XCTAssertEqual(fortune.formulas.count, 3)
        XCTAssertTrue(fortune.formulas.contains(where: {
            $0.formula.formula == "Asc + Mo - Su" && $0.formula.sectRule == .reverse
        }))
        XCTAssertTrue(fortune.formulas.allSatisfy { $0.dayCalculation == nil })
        XCTAssertTrue(fortune.formulas.allSatisfy { $0.nightCalculation == nil })
        XCTAssertTrue(fortune.formulas.allSatisfy { $0.sourceSectMark == nil })
    }

    func testCanAskHecateForAPartsExplicitDayAndNightCalculations() throws {
        let sons = try XCTUnwrap(
            Hecate.inquire(KleisID(rawValue: "parts.natal.house07.sonsInLaw")!)
        )
        let formula = try XCTUnwrap(sons.formulas.first)

        XCTAssertEqual(sons.kleis.family, .parts)
        XCTAssertEqual(sons.sourceLabel, "Sons in law")
        XCTAssertEqual(sons.natalDivision, .house)
        XCTAssertEqual(sons.houseCategory, 7)
        XCTAssertEqual(formula.dayCalculation, "Asc + Venus - Saturn")
        XCTAssertEqual(formula.nightCalculation, "Asc + Saturn - Venus")
        XCTAssertEqual(formula.sourceSectMark, .reverse)
        XCTAssertEqual(formula.formula.sectRule, .reverse)
    }

    func testCanAskHecateForChildrenWithoutCollapsingLotAndPartIdentities() {
        let children = Hecate.inquire(named: "Children")

        XCTAssertEqual(children.count, 2)
        XCTAssertEqual(Set(children.map { $0.kleis.family }), Set([.lots, .parts]))
        XCTAssertTrue(children.contains(where: { $0.kleis.id.rawValue == "Children" }))
        XCTAssertTrue(children.contains(where: {
            $0.kleis.id.rawValue == "parts.natal.house05.children"
        }))
    }

    func testCanDisambiguateANameQuestionByFamily() {
        let lots = Hecate.inquire(named: "Children", family: .lots)
        let parts = Hecate.inquire(named: "Children", family: .parts)

        XCTAssertEqual(lots.map { $0.kleis.id.rawValue }, ["Children"])
        XCTAssertEqual(parts.map { $0.kleis.id.rawValue }, ["parts.natal.house05.children"])
    }

    func testCanAskHecateForAllNatalLotsOrNatalParts() {
        XCTAssertEqual(Hecate.inquire(family: .lots, context: .natal).count, 111)
        XCTAssertEqual(Hecate.inquire(family: .parts, context: .natal).count, 97)
    }

    func testCanAskHecateForEveryHouseSevenPart() {
        let houseSeven = Hecate.inquireParts(natalDivision: .house, houseCategory: 7)

        XCTAssertEqual(houseSeven.count, 16)
        XCTAssertTrue(houseSeven.allSatisfy { $0.kleis.family == .parts })
        XCTAssertTrue(houseSeven.allSatisfy { $0.kleis.context == .natal })
        XCTAssertTrue(houseSeven.allSatisfy { $0.natalDivision == .house })
        XCTAssertTrue(houseSeven.allSatisfy { $0.houseCategory == 7 })
    }

    func testCanAskHecateWhichPartFormulasRequireFortune() {
        let fortune = HecateResourceKey(rawValue: "F")!
        let matches = Hecate.inquireFormulas(requiring: fortune, family: .parts)
        let ids = Set(matches.map { $0.kleisID.rawValue })

        XCTAssertFalse(matches.isEmpty)
        XCTAssertTrue(ids.contains("parts.natal.house10.riseInStation"))
        XCTAssertTrue(ids.contains("parts.natal.house10.buyingAndSelling"))
        XCTAssertTrue(matches.allSatisfy { $0.formula.formula.requiredResources.contains(fortune) })
    }

    func testCanAskHecateWhichPartFormulasAreAttributedToHermes() {
        let matches = Hecate.inquireFormulas(attributedTo: "Hermes", family: .parts)
        let ids = Set(matches.map { $0.kleisID.rawValue })

        XCTAssertEqual(matches.count, 7)
        XCTAssertTrue(ids.contains("parts.natal.house04.realEstateHermes"))
        XCTAssertTrue(ids.contains("parts.natal.house06.diseaseHermes"))
        XCTAssertTrue(ids.contains("parts.natal.house07.marriageMenHermes"))
        XCTAssertTrue(ids.contains("parts.natal.house07.marriageWomenHermes"))
        XCTAssertTrue(ids.contains("parts.natal.house07.marriageMenWomenHermes"))
        XCTAssertTrue(ids.contains("parts.natal.house07.timeOfMarriageHermes"))
        XCTAssertTrue(ids.contains("parts.natal.house12.enmityHermes"))
        XCTAssertTrue(matches.allSatisfy {
            $0.formula.formula.tradition.lowercased().contains("hermes")
        })
    }

    func testCanAskHecateWhichLotFormulasComeFromValens() {
        let matches = Hecate.inquireFormulas(attributedTo: "Valens", family: .lots)

        XCTAssertFalse(matches.isEmpty)
        XCTAssertTrue(matches.contains(where: { $0.kleisID.rawValue == "Valens Eros" }))
        XCTAssertTrue(matches.contains(where: { $0.kleisID.rawValue == "Valens Necessity" }))
        XCTAssertTrue(matches.allSatisfy { $0.family == .lots })
    }

    func testCanAskHecateWhichPartFormulasAreUnresolved() {
        let matches = Hecate.inquireFormulas(status: .unresolved, family: .parts)

        XCTAssertFalse(matches.isEmpty)
        XCTAssertTrue(matches.contains(where: {
            $0.kleisID.rawValue == "parts.natal.house10.kingsAndSultans"
        }))
        XCTAssertTrue(matches.allSatisfy { $0.formula.formula.status == .unresolved })
    }

    func testCanAskHecateForAnAnnualPartShelfWithoutInventingANewContext() {
        let annual = Hecate.inquire(family: .parts, context: .annualConjunction)

        XCTAssertEqual(annual.count, 8)
        XCTAssertTrue(annual.allSatisfy { $0.kleis.context == .annualConjunction })
        XCTAssertTrue(annual.allSatisfy { $0.natalDivision == nil })
        XCTAssertTrue(annual.allSatisfy { $0.houseCategory == nil })
    }

    func testUnknownExactKeyReturnsNoAnswerRatherThanCastingOrGuessing() {
        XCTAssertNil(Hecate.inquire(KleisID(rawValue: "parts.unknown")!))
        XCTAssertTrue(Hecate.inquire(named: "not a real key").isEmpty)
    }
}
