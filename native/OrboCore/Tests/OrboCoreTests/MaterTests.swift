import XCTest
@testable import OrboCore

final class MaterTests: XCTestCase {
    private struct ParityFixture: Decodable {
        struct SignFact: Decodable {
            let signIndex: Int
            let element: Element
            let modality: Modality
            let domicile: Planet
            let exaltationPlanet: Planet?
            let exaltationDegree: Double?
            let detriment: Planet
            let fall: Planet?
        }

        struct BoundFact: Decodable {
            let signIndex: Int
            let ruler: Planet
            let start: Double
            let end: Double
        }

        struct TriplicityFact: Decodable {
            let element: Element
            let day: Planet
            let night: Planet
            let participating: Planet
        }

        let id: String
        let signFacts: [SignFact]
        let boundsScheme: BoundsScheme
        let bounds: [BoundFact]
        let faceScheme: FaceScheme
        let faces: [Planet]
        let triplicityScheme: TriplicityScheme
        let triplicities: [TriplicityFact]
    }

    private func fixture() throws -> ParityFixture {
        try FixtureLoader.decode(ParityFixture.self, named: "mater-parity", kind: .parity)
    }

    private func signFact(_ sign: Sign, in fixture: ParityFixture) -> ParityFixture.SignFact {
        fixture.signFacts.first { $0.signIndex == sign.rawValue }!
    }

    private func boundFact(
        for longitude: CelestialLongitude,
        in fixture: ParityFixture
    ) -> ParityFixture.BoundFact {
        let signIndex = longitude.sign.rawValue
        let degree = longitude.degreeInSign.value
        return fixture.bounds.first {
            $0.signIndex == signIndex && degree >= $0.start && degree < $0.end
        }!
    }

    private func triplicityFact(
        for element: Element,
        in fixture: ParityFixture
    ) -> ParityFixture.TriplicityFact {
        fixture.triplicities.first { $0.element == element }!
    }

    private func expectedDignities(
        planet: Planet,
        longitude: CelestialLongitude,
        sect: Sect?,
        fixture: ParityFixture
    ) -> Set<DignityRung> {
        let sign = signFact(longitude.sign, in: fixture)
        let bound = boundFact(for: longitude, in: fixture)
        let faceRuler = fixture.faces[Int(longitude.degrees / 10)]
        let triplicity = triplicityFact(for: sign.element, in: fixture)

        var result = Set<DignityRung>()
        if sign.domicile == planet { result.insert(.domicile) }
        if sign.exaltationPlanet == planet { result.insert(.exaltation) }

        let operative: Planet?
        switch sect {
        case .day: operative = triplicity.day
        case .night: operative = triplicity.night
        case nil: operative = nil
        }
        if operative == planet || triplicity.participating == planet {
            result.insert(.triplicity)
        }
        if bound.ruler == planet { result.insert(.bound) }
        if faceRuler == planet { result.insert(.face) }
        return result
    }

    private func expectedDebilities(
        planet: Planet,
        sign: ParityFixture.SignFact
    ) -> Set<EssentialDebility> {
        var result = Set<EssentialDebility>()
        if sign.detriment == planet { result.insert(.detriment) }
        if sign.fall == planet { result.insert(.fall) }
        return result
    }

    func testPrototypeParityFixtureCoversAllCanonicalSignFacts() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.id, "mater-rulers-prototype-parity-v1")
        XCTAssertEqual(fixture.signFacts.count, 12)

        for expected in fixture.signFacts {
            let sign = try XCTUnwrap(Sign(rawValue: expected.signIndex))
            XCTAssertEqual(Mater.element(of: sign), expected.element)
            XCTAssertEqual(Mater.modality(of: sign), expected.modality)
            XCTAssertEqual(Mater.domicileRuler(of: sign), expected.domicile)
            XCTAssertEqual(Mater.detrimentRuler(in: sign), expected.detriment)
            XCTAssertEqual(Mater.fallRuler(in: sign), expected.fall)

            let exaltation = Mater.exaltation(in: sign)
            XCTAssertEqual(exaltation?.planet, expected.exaltationPlanet)
            XCTAssertEqual(exaltation?.degree.value, expected.exaltationDegree)
        }
    }

    func testTraditionalRulershipAndClassicalDispositorBoundary() {
        XCTAssertEqual(Mater.classicalDispositors, Planet.classicalSeven)
        XCTAssertEqual(Mater.signsRuled(by: .sun), [.leo])
        XCTAssertEqual(Mater.signsRuled(by: .moon), [.cancer])
        XCTAssertEqual(Mater.signsRuled(by: .mercury), [.gemini, .virgo])
        XCTAssertEqual(Mater.signsRuled(by: .venus), [.taurus, .libra])
        XCTAssertEqual(Mater.signsRuled(by: .mars), [.aries, .scorpio])
        XCTAssertEqual(Mater.signsRuled(by: .jupiter), [.sagittarius, .pisces])
        XCTAssertEqual(Mater.signsRuled(by: .saturn), [.capricorn, .aquarius])
        XCTAssertEqual(Mater.signsRuled(by: .uranus), [])
        XCTAssertEqual(Mater.signsRuled(by: .neptune), [])
        XCTAssertEqual(Mater.signsRuled(by: .pluto), [])
    }

    func testAllSevenExaltationsRoundTripBySignAndPlanet() throws {
        let fixture = try fixture()
        let expected = fixture.signFacts.filter { $0.exaltationPlanet != nil }
        XCTAssertEqual(expected.count, 7)

        for fact in expected {
            let sign = try XCTUnwrap(Sign(rawValue: fact.signIndex))
            let planet = try XCTUnwrap(fact.exaltationPlanet)
            let bySign = try XCTUnwrap(Mater.exaltation(in: sign))
            let byPlanet = try XCTUnwrap(Mater.exaltation(of: planet))
            XCTAssertEqual(bySign, byPlanet)
            XCTAssertEqual(bySign.degree.value, fact.exaltationDegree)
        }

        XCTAssertNil(Mater.exaltation(of: .uranus))
        XCTAssertNil(Mater.exaltation(of: .neptune))
        XCTAssertNil(Mater.exaltation(of: .pluto))
    }

    func testDetrimentAndFallRemainStampedOppositions() {
        for sign in Sign.canonicalOrder {
            XCTAssertEqual(Mater.detrimentRuler(in: sign), Mater.domicileRuler(of: sign.opposite))
            XCTAssertEqual(Mater.fallRuler(in: sign), Mater.exaltation(in: sign.opposite)?.planet)
        }
    }

    func testEgyptianBoundsMatchAllSixtyPrototypeArcsAndArithmetic() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.boundsScheme, .egyptian)
        XCTAssertEqual(fixture.bounds.count, 60)

        var counts: [Planet: Int] = [:]
        var totals: [Planet: Double] = [:]

        for expected in fixture.bounds {
            let sign = try XCTUnwrap(Sign(rawValue: expected.signIndex))
            let sample = expected.start + ((expected.end - expected.start) / 2)
            let longitude = try XCTUnwrap(CelestialLongitude(Double(sign.rawValue * 30) + sample))
            let actual = Mater.bound(at: longitude)

            XCTAssertEqual(actual.sign, sign)
            XCTAssertEqual(actual.ruler, expected.ruler)
            XCTAssertEqual(actual.start.value, expected.start)
            XCTAssertEqual(actual.end.value, expected.end)
            XCTAssertEqual(actual.scheme, .egyptian)

            counts[actual.ruler, default: 0] += 1
            totals[actual.ruler, default: 0] += actual.end.value - actual.start.value
        }

        let expectedTotals: [Planet: Double] = [
            .saturn: 57, .jupiter: 79, .mars: 66, .venus: 82, .mercury: 76,
        ]
        for (planet, total) in expectedTotals {
            XCTAssertEqual(counts[planet], 12)
            XCTAssertEqual(totals[planet], total)
        }
        XCTAssertEqual(totals.values.reduce(0, +), 360)
        XCTAssertNil(counts[.sun])
        XCTAssertNil(counts[.moon])
    }

    func testEveryEgyptianBoundBoundaryIsHalfOpen() throws {
        let fixture = try fixture()
        let epsilon = 0.000_001

        for expected in fixture.bounds {
            let signStart = Double(expected.signIndex * 30)
            let exactStart = try XCTUnwrap(CelestialLongitude(signStart + expected.start))
            XCTAssertEqual(Mater.bound(at: exactStart).ruler, expected.ruler)

            let justBeforeEnd = try XCTUnwrap(CelestialLongitude(signStart + expected.end - epsilon))
            XCTAssertEqual(Mater.bound(at: justBeforeEnd).ruler, expected.ruler)

            let exactEnd = try XCTUnwrap(CelestialLongitude(signStart + expected.end))
            let expectedAtEnd = boundFact(for: exactEnd, in: fixture)
            XCTAssertEqual(Mater.bound(at: exactEnd).ruler, expectedAtEnd.ruler)
        }
    }

    func testChaldeanFacesMatchAllThirtySixPrototypeDecansAndBoundaries() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.faceScheme, .chaldean)
        XCTAssertEqual(fixture.faces.count, 36)

        for index in 0..<36 {
            let longitude = try XCTUnwrap(CelestialLongitude(Double(index * 10)))
            let face = Mater.face(at: longitude)
            XCTAssertEqual(face.ruler, fixture.faces[index])
            XCTAssertEqual(face.sign.rawValue, index / 3)
            XCTAssertEqual(face.decan, (index % 3) + 1)
            XCTAssertEqual(face.scheme, .chaldean)
        }

        XCTAssertEqual(fixture.faces[0...2], [.mars, .sun, .venus])
        XCTAssertEqual(Array(fixture.faces[3...5]), [.mercury, .moon, .saturn])
        XCTAssertEqual(Array(fixture.faces[33...35]), [.saturn, .jupiter, .mars])
    }

    func testDorotheanTriplicityPreservesAllThreeLordsAndSectSelection() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.triplicityScheme, .dorothean)
        XCTAssertEqual(fixture.triplicities.count, 4)

        for expected in fixture.triplicities {
            let sign = try XCTUnwrap(Sign.canonicalOrder.first { Mater.element(of: $0) == expected.element })
            let actual = Mater.triplicity(of: sign)
            XCTAssertEqual(actual.element, expected.element)
            XCTAssertEqual(actual.dayRuler, expected.day)
            XCTAssertEqual(actual.nightRuler, expected.night)
            XCTAssertEqual(actual.participatingRuler, expected.participating)
            XCTAssertEqual(actual.operativeRuler(for: .day), expected.day)
            XCTAssertEqual(actual.operativeRuler(for: .night), expected.night)
            XCTAssertNil(actual.operativeRuler(for: nil))
            XCTAssertEqual(actual.scheme, .dorothean)
        }
    }

    func testEssentialConditionMatchesPrototypeTablesAcrossWholeZodiacAndSectStates() throws {
        let fixture = try fixture()
        let sects: [Sect?] = [nil, .day, .night]
        var checks = 0

        for degree in 0..<360 {
            let longitude = try XCTUnwrap(CelestialLongitude(Double(degree)))
            let sign = signFact(longitude.sign, in: fixture)
            let expectedBound = boundFact(for: longitude, in: fixture)
            let expectedFace = fixture.faces[degree / 10]
            let expectedTriplicity = triplicityFact(for: sign.element, in: fixture)

            for planet in Planet.classicalSeven {
                for sect in sects {
                    let actual = try XCTUnwrap(
                        Mater.essentialCondition(of: planet, at: longitude, sect: sect)
                    )
                    XCTAssertEqual(
                        actual.dignities,
                        expectedDignities(planet: planet, longitude: longitude, sect: sect, fixture: fixture)
                    )
                    XCTAssertEqual(actual.debilities, expectedDebilities(planet: planet, sign: sign))
                    XCTAssertEqual(actual.bound.ruler, expectedBound.ruler)
                    XCTAssertEqual(actual.face.ruler, expectedFace)
                    XCTAssertEqual(actual.triplicity.dayRuler, expectedTriplicity.day)
                    XCTAssertEqual(actual.triplicity.nightRuler, expectedTriplicity.night)
                    XCTAssertEqual(actual.triplicity.participatingRuler, expectedTriplicity.participating)
                    XCTAssertEqual(actual.isPeregrine, actual.dignities.isEmpty)
                    checks += 1
                }
            }
        }

        XCTAssertEqual(checks, 7 * 360 * 3)
    }

    func testDebilitiesRemainIndependentOfPositiveDignity() throws {
        let mercuryPisces = try XCTUnwrap(CelestialLongitude(11 * 30 + 5))
        let mercury = try XCTUnwrap(
            Mater.essentialCondition(of: .mercury, at: mercuryPisces, sect: .day)
        )
        XCTAssertEqual(mercury.debilities, [.detriment, .fall])

        let moonScorpio = try XCTUnwrap(CelestialLongitude(7 * 30 + 20))
        let moon = try XCTUnwrap(
            Mater.essentialCondition(of: .moon, at: moonScorpio, sect: .day)
        )
        XCTAssertEqual(moon.debilities, [.fall])
        XCTAssertTrue(moon.dignities.contains(.triplicity))
        XCTAssertFalse(moon.isPeregrine)
    }

    func testPeregrineUsesTheCompleteFiveRungLawNotTheOldSignOnlyShortcut() throws {
        let marsGeminiFace = try XCTUnwrap(CelestialLongitude(2 * 30 + 10))
        let mars = try XCTUnwrap(
            Mater.essentialCondition(of: .mars, at: marsGeminiFace, sect: .day)
        )
        XCTAssertEqual(mars.dignities, [.face])
        XCTAssertFalse(mars.isPeregrine)

        let marsGeminiBound = try XCTUnwrap(CelestialLongitude(2 * 30 + 20))
        let boundMars = try XCTUnwrap(
            Mater.essentialCondition(of: .mars, at: marsGeminiBound, sect: .day)
        )
        XCTAssertEqual(boundMars.dignities, [.bound])
        XCTAssertFalse(boundMars.isPeregrine)

        let mercuryLeo = try XCTUnwrap(CelestialLongitude(4 * 30 + 5))
        let mercury = try XCTUnwrap(
            Mater.essentialCondition(of: .mercury, at: mercuryLeo, sect: .day)
        )
        XCTAssertTrue(mercury.dignities.isEmpty)
        XCTAssertTrue(mercury.isPeregrine)
    }

    func testModernPlanetsDoNotEnterClassicalEssentialDignity() throws {
        let longitude = try XCTUnwrap(CelestialLongitude(225))
        XCTAssertNil(Mater.essentialCondition(of: .uranus, at: longitude, sect: .day))
        XCTAssertNil(Mater.essentialCondition(of: .neptune, at: longitude, sect: .day))
        XCTAssertNil(Mater.essentialCondition(of: .pluto, at: longitude, sect: .day))
    }
}
