import XCTest
@testable import OrboCore

final class DomainTests: XCTestCase {
    func testPlanetVocabularyAndClassicalBoundary() {
        XCTAssertEqual(Planet.canonicalOrder, Planet.allCases)
        XCTAssertEqual(Planet.canonicalOrder.count, 10)
        XCTAssertEqual(Planet.classicalSeven.count, 7)
        XCTAssertEqual(Set(Planet.classicalSeven).count, 7)
        XCTAssertTrue(Planet.classicalSeven.allSatisfy { $0.isClassical })
        XCTAssertFalse(Planet.uranus.isClassical)
        XCTAssertFalse(Planet.neptune.isClassical)
        XCTAssertFalse(Planet.pluto.isClassical)
    }

    func testSignVocabularyIsCanonicalAndOppositionIsInvolutive() {
        XCTAssertEqual(Sign.canonicalOrder, Sign.allCases)
        XCTAssertEqual(Sign.allCases.count, 12)
        XCTAssertEqual(Sign.aries.rawValue, 0)
        XCTAssertEqual(Sign.pisces.rawValue, 11)
        XCTAssertEqual(Sign.aries.opposite, .libra)
        XCTAssertEqual(Sign.scorpio.opposite, .taurus)

        for sign in Sign.allCases {
            XCTAssertEqual(sign.opposite.opposite, sign)
        }
    }

    func testHouseVocabularyUsesOrdinalsAndOppositionIsInvolutive() {
        XCTAssertEqual(House.canonicalOrder, House.allCases)
        XCTAssertEqual(House.allCases.count, 12)
        XCTAssertEqual(House.first.rawValue, 1)
        XCTAssertEqual(House.twelfth.rawValue, 12)
        XCTAssertEqual(House.first.opposite, .seventh)
        XCTAssertEqual(House.eighth.opposite, .second)

        for house in House.allCases {
            XCTAssertEqual(house.opposite.opposite, house)
        }
    }

    func testClosedVocabularyCounts() {
        XCTAssertEqual(Element.allCases.count, 4)
        XCTAssertEqual(Modality.allCases.count, 3)
        XCTAssertEqual(Motion.allCases, [.direct, .retrograde])
        XCTAssertEqual(Sect.allCases, [.day, .night])
        XCTAssertEqual(DignityRung.allCases.count, 5)
        XCTAssertEqual(
            Set(DignityRung.allCases),
            Set([.domicile, .exaltation, .triplicity, .bound, .face])
        )
        XCTAssertEqual(Set(EssentialDebility.allCases), Set([.detriment, .fall]))
    }

    func testCelestialLongitudeCanonicalizesAtConstructionBoundary() {
        XCTAssertEqual(CelestialLongitude(0)?.degrees, 0)
        XCTAssertEqual(CelestialLongitude(360)?.degrees, 0)
        XCTAssertEqual(CelestialLongitude(720)?.degrees, 0)
        XCTAssertEqual(CelestialLongitude(-1)?.degrees, 359)
        XCTAssertEqual(CelestialLongitude(721)?.degrees, 1)
        XCTAssertNil(CelestialLongitude(.nan))
        XCTAssertNil(CelestialLongitude(.infinity))
        XCTAssertNil(CelestialLongitude(-.infinity))
    }

    func testCelestialLongitudeProvidesOnlyPositionalSignGeometry() throws {
        let ariesEnd = try XCTUnwrap(CelestialLongitude(29.999))
        let taurusStart = try XCTUnwrap(CelestialLongitude(30))
        let pisces = try XCTUnwrap(CelestialLongitude(359.5))

        XCTAssertEqual(ariesEnd.sign, .aries)
        XCTAssertEqual(taurusStart.sign, .taurus)
        XCTAssertEqual(taurusStart.degreeInSign.value, 0)
        XCTAssertEqual(pisces.sign, .pisces)
        XCTAssertEqual(pisces.degreeInSign.value, 29.5, accuracy: 0.000_000_1)
    }

    func testDegreeInSignRejectsInvalidPositions() {
        XCTAssertNotNil(DegreeInSign(0))
        XCTAssertNotNil(DegreeInSign(29.999_999))
        XCTAssertNil(DegreeInSign(-0.000_001))
        XCTAssertNil(DegreeInSign(30))
        XCTAssertNil(DegreeInSign(.nan))
        XCTAssertNil(DegreeInSign(.infinity))
    }

    func testDegreeBoundaryAllowsThirtyButNothingBeyondIt() {
        XCTAssertNotNil(DegreeBoundaryInSign(0))
        XCTAssertNotNil(DegreeBoundaryInSign(30))
        XCTAssertNil(DegreeBoundaryInSign(-0.000_001))
        XCTAssertNil(DegreeBoundaryInSign(30.000_001))
    }

    func testDefaultDignityDoctrineIsExplicit() {
        let doctrine = DignityDoctrine.orboDefault
        XCTAssertEqual(doctrine.bounds, .egyptian)
        XCTAssertEqual(doctrine.triplicity, .dorothean)
        XCTAssertEqual(doctrine.faces, .chaldean)
        XCTAssertEqual(BoundsScheme.allCases, [.egyptian])
        XCTAssertEqual(TriplicityScheme.allCases, [.dorothean])
        XCTAssertEqual(FaceScheme.allCases, [.chaldean])
    }

    func testBoundAndFaceRecordsRejectMalformedIntervals() throws {
        let zero = try XCTUnwrap(DegreeBoundaryInSign(0))
        let six = try XCTUnwrap(DegreeBoundaryInSign(6))
        let thirty = try XCTUnwrap(DegreeBoundaryInSign(30))

        XCTAssertNotNil(Bound(ruler: .jupiter, sign: .aries, start: zero, end: six, scheme: .egyptian))
        XCTAssertNotNil(Bound(ruler: .saturn, sign: .aries, start: six, end: thirty, scheme: .egyptian))
        XCTAssertNil(Bound(ruler: .jupiter, sign: .aries, start: six, end: six, scheme: .egyptian))
        XCTAssertNil(Bound(ruler: .jupiter, sign: .aries, start: thirty, end: six, scheme: .egyptian))

        XCTAssertNotNil(Face(ruler: .mars, sign: .aries, decan: 1, scheme: .chaldean))
        XCTAssertNotNil(Face(ruler: .venus, sign: .aries, decan: 3, scheme: .chaldean))
        XCTAssertNil(Face(ruler: .mars, sign: .aries, decan: 0, scheme: .chaldean))
        XCTAssertNil(Face(ruler: .mars, sign: .aries, decan: 4, scheme: .chaldean))
    }

    func testTriplicityPreservesAllRulersAndSelectsOnlyWithKnownSect() {
        let fire = Triplicity(
            element: .fire,
            dayRuler: .sun,
            nightRuler: .jupiter,
            participatingRuler: .saturn,
            scheme: .dorothean
        )

        XCTAssertEqual(fire.operativeRuler(for: .day), .sun)
        XCTAssertEqual(fire.operativeRuler(for: .night), .jupiter)
        XCTAssertNil(fire.operativeRuler(for: nil))
        XCTAssertEqual(fire.participatingRuler, .saturn)
    }

    func testEssentialConditionDerivesPeregrineAndRejectsModernPlanets() throws {
        let longitude = try XCTUnwrap(CelestialLongitude(10))
        let start = try XCTUnwrap(DegreeBoundaryInSign(6))
        let end = try XCTUnwrap(DegreeBoundaryInSign(12))
        let bound = try XCTUnwrap(
            Bound(ruler: .venus, sign: .aries, start: start, end: end, scheme: .egyptian)
        )
        let face = try XCTUnwrap(
            Face(ruler: .sun, sign: .aries, decan: 2, scheme: .chaldean)
        )
        let triplicity = Triplicity(
            element: .fire,
            dayRuler: .sun,
            nightRuler: .jupiter,
            participatingRuler: .saturn,
            scheme: .dorothean
        )

        let peregrine = try XCTUnwrap(
            EssentialCondition(
                planet: .mercury,
                longitude: longitude,
                dignities: [],
                debilities: [],
                bound: bound,
                face: face,
                triplicity: triplicity
            )
        )
        XCTAssertTrue(peregrine.isPeregrine)

        let dignified = try XCTUnwrap(
            EssentialCondition(
                planet: .sun,
                longitude: longitude,
                dignities: [.triplicity, .face],
                debilities: [],
                bound: bound,
                face: face,
                triplicity: triplicity
            )
        )
        XCTAssertFalse(dignified.isPeregrine)

        XCTAssertNil(
            EssentialCondition(
                planet: .pluto,
                longitude: longitude,
                dignities: [],
                debilities: [],
                bound: bound,
                face: face,
                triplicity: triplicity
            )
        )
    }

    func testEssentialDebilitiesCanCoexist() {
        let both: Set<EssentialDebility> = [.detriment, .fall]
        XCTAssertEqual(both.count, 2)
        XCTAssertTrue(both.contains(.detriment))
        XCTAssertTrue(both.contains(.fall))
    }
}
