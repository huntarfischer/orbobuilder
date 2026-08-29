import XCTest
@testable import OrboCore

final class HecatePartsPassATests: XCTestCase {
    func testPartCatalogueEntryEmitsOrdinaryKleis() {
        let entry = makeEntry(
            id: "parts.test.house07",
            context: .natal,
            natalDivision: .house,
            houseCategory: 7
        )!

        XCTAssertEqual(entry.kleis.id, KleisID(rawValue: "parts.test.house07")!)
        XCTAssertEqual(entry.kleis.context, .natal)
        XCTAssertEqual(entry.kleis.formulas, entry.formulas.map(\.kleisFormula))
    }

    func testEmittedKleisAlwaysUsesPartsFamily() {
        let entry = makeEntry(
            context: .annualConjunction,
            natalDivision: nil,
            houseCategory: nil
        )!

        XCTAssertEqual(entry.kleis.family, .parts)
    }

    func testPartFormulaEntryPreservesExistingKleisFormula() {
        let formula = makeFormula()
        let entry = PartFormulaEntry(
            kleisFormula: formula,
            dayCalculation: "Asc + Mo - Su",
            nightCalculation: "Asc + Su - Mo",
            sourceSectMark: .reverse
        )!

        XCTAssertEqual(entry.kleisFormula, formula)
    }

    func testPartFormulaEntryPreservesDayCalculation() {
        let entry = makePartFormula(
            day: "  Asc + Mo - Su  ",
            night: "Asc + Su - Mo",
            mark: .reverse
        )

        XCTAssertEqual(entry.dayCalculation, "Asc + Mo - Su")
    }

    func testPartFormulaEntryPreservesNightCalculation() {
        let entry = makePartFormula(
            day: "Asc + Mo - Su",
            night: "  Asc + Su - Mo  ",
            mark: .reverse
        )

        XCTAssertEqual(entry.nightCalculation, "Asc + Su - Mo")
    }

    func testPartFormulaEntryPreservesSourceSectMark() {
        XCTAssertEqual(
            makePartFormula(day: "same", night: "same", mark: .same).sourceSectMark,
            .same
        )
        XCTAssertEqual(
            makePartFormula(day: "day", night: "night", mark: .reverse).sourceSectMark,
            .reverse
        )
    }

    func testPartFormulaEntryDocumentaryFaceDoesNotAlterKleisFormula() {
        let formula = makeFormula(expression: "stored Hecate formula")
        let entry = PartFormulaEntry(
            kleisFormula: formula,
            dayCalculation: "documentary day face",
            nightCalculation: "documentary night face",
            sourceSectMark: .reverse
        )!

        XCTAssertEqual(entry.kleisFormula.formula, "stored Hecate formula")
        XCTAssertEqual(entry.dayCalculation, "documentary day face")
        XCTAssertEqual(entry.nightCalculation, "documentary night face")
    }

    func testNatalHouseEntryMayCarryHouseCategory() {
        let entry = makeEntry(
            context: .natal,
            natalDivision: .house,
            houseCategory: 7
        )!

        XCTAssertEqual(entry.natalDivision, .house)
        XCTAssertEqual(entry.houseCategory, 7)
        XCTAssertNil(makeEntry(context: .natal, natalDivision: .house, houseCategory: nil))
        XCTAssertNil(makeEntry(context: .natal, natalDivision: .house, houseCategory: 0))
        XCTAssertNil(makeEntry(context: .natal, natalDivision: .house, houseCategory: 13))
    }

    func testNatalPlanetaryEntryCannotCarryHouseCategory() {
        XCTAssertNotNil(
            makeEntry(context: .natal, natalDivision: .planetary, houseCategory: nil)
        )
        XCTAssertNil(
            makeEntry(context: .natal, natalDivision: .planetary, houseCategory: 1)
        )
    }

    func testNatalMiscellaneousEntryCannotCarryHouseCategory() {
        XCTAssertNotNil(
            makeEntry(context: .natal, natalDivision: .miscellaneous, houseCategory: nil)
        )
        XCTAssertNil(
            makeEntry(context: .natal, natalDivision: .miscellaneous, houseCategory: 1)
        )
    }

    func testNatalEntryRequiresNatalDivision() {
        XCTAssertNil(
            makeEntry(context: .natal, natalDivision: nil, houseCategory: nil)
        )
    }

    func testNonNatalEntryCannotCarryNatalDivision() {
        for context in nonNatalContexts {
            XCTAssertNotNil(
                makeEntry(context: context, natalDivision: nil, houseCategory: nil),
                "Expected \(context.rawValue) to accept no natal division"
            )
            XCTAssertNil(
                makeEntry(context: context, natalDivision: .planetary, houseCategory: nil),
                "Expected \(context.rawValue) to reject a natal division"
            )
        }
    }

    func testNonNatalEntryCannotCarryHouseCategory() {
        for context in nonNatalContexts {
            XCTAssertNil(
                makeEntry(context: context, natalDivision: nil, houseCategory: 7),
                "Expected \(context.rawValue) to reject a house category"
            )
        }
    }

    func testDeclarationsEqualEntriesMappedToKleis() {
        let entries = [
            makeEntry(
                id: "parts.test.planetary",
                context: .natal,
                natalDivision: .planetary,
                houseCategory: nil
            )!,
            makeEntry(
                id: "parts.test.horary",
                context: .horary,
                natalDivision: nil,
                houseCategory: nil
            )!,
        ]

        XCTAssertEqual(
            PartsKleidesCatalogue.declarations(from: entries),
            entries.map(\.kleis)
        )
        XCTAssertEqual(
            PartsKleidesCatalogue.declarations,
            PartsKleidesCatalogue.entries.map(\.kleis)
        )
    }

    func testPartsCatalogueDoesNotRegisterWithCanonicalKleidesYet() {
        XCTAssertFalse(PartsKleidesCatalogue.entries.isEmpty)
        XCTAssertEqual(
            PartsKleidesCatalogue.declarations,
            PartsKleidesCatalogue.entries.map(\.kleis)
        )
        XCTAssertFalse(Kleides.canonical.all.contains(where: { $0.family == .parts }))
    }

    func testEmittedPartIsL3Only() {
        let entry = makeEntry(
            context: .natal,
            natalDivision: .planetary,
            houseCategory: nil
        )!

        XCTAssertEqual(
            entry.kleis.availability,
            KleisAvailability(l1: false, l2: false, l3: true)!
        )
    }

    func testPartCatalogueEntryRejectsOrboDefaultFormula() {
        let defaultFormula = makeFormula(isOrboDefault: true)
        let partFormula = PartFormulaEntry(
            kleisFormula: defaultFormula,
            dayCalculation: "day",
            nightCalculation: "night",
            sourceSectMark: .reverse
        )!

        XCTAssertNil(
            PartCatalogueEntry(
                id: KleisID(rawValue: "parts.test.default")!,
                sourceLabel: "Default Test",
                context: .natal,
                natalDivision: .planetary,
                formulas: [partFormula]
            )
        )
    }

    private var nonNatalContexts: [KleisContext] {
        [.annualConjunction, .mundaneWeather, .agricultural, .horary]
    }

    private func makePartFormula(
        day: String,
        night: String,
        mark: PartFormulaEntry.SourceSectMark
    ) -> PartFormulaEntry {
        PartFormulaEntry(
            kleisFormula: makeFormula(),
            dayCalculation: day,
            nightCalculation: night,
            sourceSectMark: mark
        )!
    }

    private func makeFormula(
        expression: String = "Asc + Mo - Su",
        isOrboDefault: Bool = false
    ) -> KleisFormula {
        KleisFormula(
            requiredResources: [
                HecateResourceKey(rawValue: "Asc")!,
                HecateResourceKey(rawValue: "Mo")!,
                HecateResourceKey(rawValue: "Su")!,
            ],
            formula: expression,
            tradition: "Pass A test",
            sectRule: .reverse,
            isOrboDefault: isOrboDefault,
            sources: ["Pass A test source"],
            status: .complete
        )!
    }

    private func makeEntry(
        id: String = "parts.test.entry",
        context: KleisContext,
        natalDivision: PartNatalDivision?,
        houseCategory: Int?
    ) -> PartCatalogueEntry? {
        PartCatalogueEntry(
            id: KleisID(rawValue: id)!,
            sourceLabel: "Test Part",
            context: context,
            natalDivision: natalDivision,
            houseCategory: houseCategory,
            formulas: [
                makePartFormula(
                    day: "Asc + Mo - Su",
                    night: "Asc + Su - Mo",
                    mark: .reverse
                ),
            ]
        )
    }
}
