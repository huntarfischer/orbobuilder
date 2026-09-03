import XCTest
@testable import OrboCore

final class HecateStage7LotCastTests: XCTestCase {
    func testPass7SeparatesOrboAndValensErosNecessityIdentities() throws {
        let eros = try page("Eros")
        let necessity = try page("Necessity")
        let valensEros = try page("Valens Eros")
        let valensNecessity = try page("Valens Necessity")

        XCTAssertEqual(
            eros.availability,
            KleisAvailability(l1: true, l2: true, l3: true)
        )
        XCTAssertEqual(
            necessity.availability,
            KleisAvailability(l1: true, l2: true, l3: true)
        )
        XCTAssertEqual(
            valensEros.availability,
            KleisAvailability(l1: false, l2: false, l3: true)
        )
        XCTAssertEqual(
            valensNecessity.availability,
            KleisAvailability(l1: false, l2: false, l3: true)
        )

        XCTAssertTrue(eros.aliases.contains("Planetary Love (Venus)"))
        XCTAssertTrue(necessity.aliases.contains("Planetary Necessity (Mercury)"))
        XCTAssertTrue(valensEros.aliases.contains("Eros"))
        XCTAssertTrue(valensNecessity.aliases.contains("Necessity"))
    }

    func testFirstFourCarryFrozenOrboDefaultFormulae() throws {
        let fortune = try defaultFormula("Fortune")
        XCTAssertEqual(fortune.formula, "Asc + Mo - Su")
        XCTAssertEqual(fortune.tradition, "Mainstream Hellenistic / Valens")
        XCTAssertEqual(fortune.sectRule, .reverse)

        let spirit = try defaultFormula("Spirit")
        XCTAssertEqual(spirit.formula, "Asc + Su - Mo")
        XCTAssertEqual(spirit.tradition, "Hellenistic mainstream")
        XCTAssertEqual(spirit.sectRule, .reverse)

        let eros = try defaultFormula("Eros")
        XCTAssertEqual(eros.formula, "Asc + Ve - Sp")
        XCTAssertEqual(eros.tradition, "Pauline/Hermetic")
        XCTAssertEqual(eros.sectRule, .reverse)

        let necessity = try defaultFormula("Necessity")
        XCTAssertEqual(necessity.formula, "Asc + F - Me")
        XCTAssertEqual(necessity.tradition, "Pauline/Hermetic")
        XCTAssertEqual(necessity.sectRule, .reverse)
    }

    func testPaulineHermeticFormulaePreserveEngineAndReportProvenanceSeparately() throws {
        for id in ["Eros", "Necessity"] {
            let formula = try defaultFormula(id)

            XCTAssertEqual(formula.sources.count, 2)
            XCTAssertTrue(
                formula.sources.contains { $0.contains("Legacy Orbo engines") }
            )
            XCTAssertTrue(
                formula.sources.contains { $0.contains("identity only") }
            )
        }
    }

    func testFortuneAndSpiritReverseBySect() throws {
        let ascendant = longitude(350)
        let moon = longitude(20)
        let sun = longitude(100)

        let dayFortune = try Hecate.castFortune(
            ascendant: ascendant,
            moon: moon,
            sun: sun,
            sect: .day
        )
        let nightFortune = try Hecate.castFortune(
            ascendant: ascendant,
            moon: moon,
            sun: sun,
            sect: .night
        )
        let daySpirit = try Hecate.castSpirit(
            ascendant: ascendant,
            sun: sun,
            moon: moon,
            sect: .day
        )
        let nightSpirit = try Hecate.castSpirit(
            ascendant: ascendant,
            sun: sun,
            moon: moon,
            sect: .night
        )

        XCTAssertEqual(dayFortune.degrees, 270, accuracy: 1e-12)
        XCTAssertEqual(nightFortune.degrees, 70, accuracy: 1e-12)
        XCTAssertEqual(daySpirit.degrees, 70, accuracy: 1e-12)
        XCTAssertEqual(nightSpirit.degrees, 270, accuracy: 1e-12)
    }

    func testErosUsesSuppliedSpiritAndReversesBySect() throws {
        let ascendant = longitude(10)
        let venus = longitude(350)
        let spirit = longitude(30)

        let day = try Hecate.castEros(
            ascendant: ascendant,
            venus: venus,
            spirit: spirit,
            sect: .day
        )
        let night = try Hecate.castEros(
            ascendant: ascendant,
            venus: venus,
            spirit: spirit,
            sect: .night
        )

        XCTAssertEqual(day.degrees, 330, accuracy: 1e-12)
        XCTAssertEqual(night.degrees, 50, accuracy: 1e-12)
    }

    func testNecessityUsesSuppliedFortuneAndReversesBySect() throws {
        let ascendant = longitude(10)
        let fortune = longitude(350)
        let mercury = longitude(30)

        let day = try Hecate.castNecessity(
            ascendant: ascendant,
            fortune: fortune,
            mercury: mercury,
            sect: .day
        )
        let night = try Hecate.castNecessity(
            ascendant: ascendant,
            fortune: fortune,
            mercury: mercury,
            sect: .night
        )

        XCTAssertEqual(day.degrees, 330, accuracy: 1e-12)
        XCTAssertEqual(night.degrees, 50, accuracy: 1e-12)
    }

    func testErosDependencyGateDoesNotSubstituteOtherKnownLotMatterForSpirit() {
        let supplied = OrboLotCasting.resources(["Asc", "Ve", "F", "Me", "Sect"])

        XCTAssertThrowsError(
            try Hecate.prepareCast(
                OrboLotCasting.erosID,
                using: supplied,
                from: .canonical
            )
        ) { error in
            XCTAssertEqual(
                error as? HecateFailure,
                .missingResources([HecateResourceKey(rawValue: "Sp")!])
            )
        }
    }

    func testLotCastsNormalizeExactlyOntoZeroTo359Ring() throws {
        let zero = try Hecate.castFortune(
            ascendant: longitude(10),
            moon: longitude(20),
            sun: longitude(30),
            sect: .day
        )
        let wrapped = try Hecate.castEros(
            ascendant: longitude(0),
            venus: longitude(10),
            spirit: longitude(20),
            sect: .day
        )

        XCTAssertEqual(zero.degrees, 0, accuracy: 1e-12)
        XCTAssertEqual(wrapped.degrees, 350, accuracy: 1e-12)
        XCTAssertGreaterThanOrEqual(wrapped.degrees, 0)
        XCTAssertLessThan(wrapped.degrees, 360)
    }

    func testSectBoundaryRuleFeedsFortuneWithoutASecondSectDecision() throws {
        let ascendant = longitude(0)
        let moon = longitude(40)
        let sunAtAscendant = longitude(0)
        let sunAtDescendant = longitude(180)
        let sunJustAboveDescendant = longitude(180.001)

        let ascendantSect = OrboFormulae.sect(
            ascendant: ascendant,
            sun: sunAtAscendant
        )
        let descendantSect = OrboFormulae.sect(
            ascendant: ascendant,
            sun: sunAtDescendant
        )
        let daySect = OrboFormulae.sect(
            ascendant: ascendant,
            sun: sunJustAboveDescendant
        )

        XCTAssertEqual(ascendantSect, .day)
        XCTAssertEqual(descendantSect, .day)
        XCTAssertEqual(daySect, .day)

        let atAscendant = try Hecate.castFortune(
            ascendant: ascendant,
            moon: moon,
            sun: sunAtAscendant,
            sect: ascendantSect
        )
        let atDescendant = try Hecate.castFortune(
            ascendant: ascendant,
            moon: moon,
            sun: sunAtDescendant,
            sect: descendantSect
        )
        let justAboveDescendant = try Hecate.castFortune(
            ascendant: ascendant,
            moon: moon,
            sun: sunJustAboveDescendant,
            sect: daySect
        )

        XCTAssertEqual(atAscendant.degrees, 40, accuracy: 1e-12)
        XCTAssertEqual(atDescendant.degrees, 220, accuracy: 1e-12)
        XCTAssertEqual(justAboveDescendant.degrees, 219.999, accuracy: 1e-9)
    }

    private func page(_ id: String) throws -> Kleis {
        try XCTUnwrap(
            Kleides.canonical.kleis(KleisID(rawValue: id)!)
        )
    }

    private func defaultFormula(_ id: String) throws -> KleisFormula {
        try XCTUnwrap(
            try page(id).formulas.first { $0.isOrboDefault }
        )
    }

    private func longitude(_ degrees: Double) -> CelestialLongitude {
        CelestialLongitude(degrees)!
    }
}
