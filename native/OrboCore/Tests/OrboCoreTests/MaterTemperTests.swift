import XCTest
@testable import OrboCore

final class MaterTemperTests: XCTestCase {
    func testCanonicalPlanetHeadersEachCarryTwelveCanonicalSignTempers() {
        XCTAssertEqual(Mater.planetTempers.count, Planet.canonicalOrder.count)
        XCTAssertEqual(Mater.planetTempers.map(\.planet), Planet.canonicalOrder)

        for header in Mater.planetTempers {
            XCTAssertEqual(header.tempers.count, Sign.canonicalOrder.count)
            XCTAssertEqual(header.tempers.map(\.sign), Sign.canonicalOrder)
            XCTAssertTrue(header.tempers.allSatisfy { $0.planet == header.planet })
        }

        XCTAssertEqual(
            Mater.planetTempers.reduce(0) { $0 + $1.tempers.count },
            Planet.canonicalOrder.count * Sign.canonicalOrder.count
        )
    }

    func testSignElementAndModalityFlagsAreOneHotAndMatchCanonicalMater() {
        for header in Mater.planetTempers {
            for temper in header.tempers {
                let signFlags = [
                    temper.signFlags.aries,
                    temper.signFlags.taurus,
                    temper.signFlags.gemini,
                    temper.signFlags.cancer,
                    temper.signFlags.leo,
                    temper.signFlags.virgo,
                    temper.signFlags.libra,
                    temper.signFlags.scorpio,
                    temper.signFlags.sagittarius,
                    temper.signFlags.capricorn,
                    temper.signFlags.aquarius,
                    temper.signFlags.pisces,
                ]
                XCTAssertEqual(signFlags.filter { $0 }.count, 1)
                XCTAssertTrue(signFlags[temper.sign.rawValue])

                let elementFlags = [
                    temper.elementFlags.fire,
                    temper.elementFlags.earth,
                    temper.elementFlags.air,
                    temper.elementFlags.water,
                ]
                XCTAssertEqual(elementFlags.filter { $0 }.count, 1)
                XCTAssertEqual(temper.element, Mater.element(of: temper.sign))

                switch temper.element {
                case .fire: XCTAssertTrue(temper.elementFlags.fire)
                case .earth: XCTAssertTrue(temper.elementFlags.earth)
                case .air: XCTAssertTrue(temper.elementFlags.air)
                case .water: XCTAssertTrue(temper.elementFlags.water)
                }

                let modalityFlags = [
                    temper.modalityFlags.cardinal,
                    temper.modalityFlags.fixed,
                    temper.modalityFlags.mutable,
                ]
                XCTAssertEqual(modalityFlags.filter { $0 }.count, 1)
                XCTAssertEqual(temper.modality, Mater.modality(of: temper.sign))

                switch temper.modality {
                case .cardinal: XCTAssertTrue(temper.modalityFlags.cardinal)
                case .fixed: XCTAssertTrue(temper.modalityFlags.fixed)
                case .mutable: XCTAssertTrue(temper.modalityFlags.mutable)
                }
            }
        }
    }

    func testTraditionalSignConditionsAreStampedFromExistingMaterAuthority() {
        for planet in Planet.canonicalOrder {
            for sign in Sign.canonicalOrder {
                let temper = Mater.temper(of: planet, in: sign)

                XCTAssertEqual(
                    temper.traditionalRulership.domicile,
                    Mater.domicileRuler(of: sign) == planet
                )
                XCTAssertEqual(
                    temper.traditionalRulership.detriment,
                    Mater.detrimentRuler(in: sign) == planet
                )
                XCTAssertEqual(
                    temper.exaltation,
                    Mater.exaltation(in: sign)?.planet == planet
                )
                XCTAssertEqual(
                    temper.fall,
                    Mater.fallRuler(in: sign) == planet
                )
            }
        }
    }

    func testTriplicityDayAndNightAnswersArePrecomputedFromExistingDoctrine() {
        for planet in Planet.canonicalOrder {
            for sign in Sign.canonicalOrder {
                let temper = Mater.temper(of: planet, in: sign)
                let triplicity = Mater.triplicity(of: sign)

                XCTAssertEqual(
                    temper.triplicityDay,
                    triplicity.dayRuler == planet || triplicity.participatingRuler == planet
                )
                XCTAssertEqual(
                    temper.triplicityNight,
                    triplicity.nightRuler == planet || triplicity.participatingRuler == planet
                )
            }
        }
    }

    func testModernRulershipAugmentationIsOnlyTheAgreedThreeDomicilesAndDetriments() {
        let all = Mater.planetTempers.flatMap(\.tempers)
        XCTAssertEqual(all.filter { $0.modernRulership.domicile }.count, 3)
        XCTAssertEqual(all.filter { $0.modernRulership.detriment }.count, 3)

        XCTAssertTrue(Mater.temper(of: .pluto, in: .scorpio).modernRulership.domicile)
        XCTAssertTrue(Mater.temper(of: .pluto, in: .taurus).modernRulership.detriment)

        XCTAssertTrue(Mater.temper(of: .uranus, in: .aquarius).modernRulership.domicile)
        XCTAssertTrue(Mater.temper(of: .uranus, in: .leo).modernRulership.detriment)

        XCTAssertTrue(Mater.temper(of: .neptune, in: .pisces).modernRulership.domicile)
        XCTAssertTrue(Mater.temper(of: .neptune, in: .virgo).modernRulership.detriment)

        XCTAssertTrue(Mater.temper(of: .mars, in: .scorpio).traditionalRulership.domicile)
        XCTAssertTrue(Mater.temper(of: .saturn, in: .aquarius).traditionalRulership.domicile)
        XCTAssertTrue(Mater.temper(of: .jupiter, in: .pisces).traditionalRulership.domicile)
    }

    func testPlanetAndSignLookupReturnsTheCanonicalReusableTemper() {
        for header in Mater.planetTempers {
            XCTAssertEqual(Mater.tempers(for: header.planet), header)

            for sign in Sign.canonicalOrder {
                XCTAssertEqual(
                    Mater.temper(of: header.planet, in: sign),
                    header.temper(in: sign)
                )
            }
        }
    }
}
