import XCTest
@testable import OrboCore

final class MaterQualificationTests: XCTestCase {
    private func completeLongitudes(
        overriding overrides: [Planet: Double] = [:]
    ) -> [Planet: CelestialLongitude] {
        var raw: [Planet: Double] = [
            .sun: 120,
            .moon: 90,
            .mercury: 150,
            .venus: 180,
            .mars: 0,
            .jupiter: 240,
            .saturn: 270,
            .uranus: 60,
            .neptune: 30,
            .pluto: 300,
        ]
        for (planet, longitude) in overrides {
            raw[planet] = longitude
        }
        return Dictionary(
            uniqueKeysWithValues: raw.map { planet, degrees in
                (planet, CelestialLongitude(degrees)!)
            }
        )
    }

    func testQualificationKeepsCanonicalReusableTemperAndFieldUnderExactCoordinates() {
        let longitudes = completeLongitudes()
        let qualified = Mater.qualifyField(longitudes, sect: .day)

        XCTAssertEqual(qualified.longitudes, longitudes)
        XCTAssertEqual(qualified.tempers.count, Planet.canonicalOrder.count)
        XCTAssertEqual(qualified.tempers.map(\.planet), Planet.canonicalOrder)
        XCTAssertEqual(qualified.byPlanet.count, Planet.canonicalOrder.count)

        for planet in Planet.canonicalOrder {
            let exact = qualified.temper(for: planet)
            let sign = longitudes[planet]!.sign

            XCTAssertEqual(exact.longitude, longitudes[planet])
            XCTAssertEqual(exact.fieldTemper, qualified.field.temper(for: planet))
            XCTAssertEqual(exact.fieldTemper.temper, Mater.temper(of: planet, in: sign))
            XCTAssertEqual(qualified.field.placements[planet], sign)
        }
    }

    func testExactExaltationDegreeIsAQualifierNotASecondTemper() {
        let exact = Mater.qualifyField(
            completeLongitudes(overriding: [.sun: 19]),
            sect: .day
        ).temper(for: .sun)
        let nearby = Mater.qualifyField(
            completeLongitudes(overriding: [.sun: 19.5]),
            sect: .day
        ).temper(for: .sun)

        XCTAssertTrue(exact.exaltation)
        XCTAssertTrue(exact.atExaltationDegree)
        XCTAssertTrue(nearby.exaltation)
        XCTAssertFalse(nearby.atExaltationDegree)
        XCTAssertEqual(exact.fieldTemper.temper, nearby.fieldTemper.temper)
        XCTAssertEqual(exact.fieldTemper.temper, Mater.temper(of: .sun, in: .aries))
    }

    func testSectOnlySelectsAlreadyKnownTriplicityState() {
        let longitudes = completeLongitudes(overriding: [.sun: 5])
        let day = Mater.qualifyField(longitudes, sect: .day).temper(for: .sun)
        let night = Mater.qualifyField(longitudes, sect: .night).temper(for: .sun)
        let unsected = Mater.qualifyField(longitudes, sect: nil).temper(for: .sun)

        XCTAssertTrue(day.sectDay)
        XCTAssertFalse(day.sectNight)
        XCTAssertFalse(night.sectDay)
        XCTAssertTrue(night.sectNight)
        XCTAssertFalse(unsected.sectDay)
        XCTAssertFalse(unsected.sectNight)

        XCTAssertTrue(day.triplicity)
        XCTAssertFalse(night.triplicity)
        XCTAssertFalse(unsected.triplicity)

        XCTAssertEqual(day.fieldTemper.temper, night.fieldTemper.temper)
        XCTAssertEqual(night.fieldTemper.temper, unsected.fieldTemper.temper)
        XCTAssertEqual(day.triplicityDayRuler, .sun)
        XCTAssertEqual(day.triplicityNightRuler, .jupiter)
        XCTAssertEqual(day.triplicityParticipatingRuler, .saturn)
        XCTAssertEqual(day.triplicityOperativeRuler, .sun)
        XCTAssertEqual(night.triplicityOperativeRuler, .jupiter)
        XCTAssertNil(unsected.triplicityOperativeRuler)
    }

    func testQualifiedClassicalConditionsMatchExistingMaterAuthority() throws {
        let longitudes = completeLongitudes(overriding: [
            .sun: 19,
            .moon: 213,
            .mercury: 335,
            .venus: 7,
            .mars: 298,
            .jupiter: 105,
            .saturn: 201,
        ])

        for sect in [Sect?.none, .some(.day), .some(.night)] {
            let qualified = Mater.qualifyField(longitudes, sect: sect)

            for planet in Planet.classicalSeven {
                let exact = qualified.temper(for: planet)
                let existing = try XCTUnwrap(
                    Mater.essentialCondition(
                        of: planet,
                        at: longitudes[planet]!,
                        sect: sect
                    )
                )

                XCTAssertEqual(
                    exact.traditionalDomicile,
                    existing.dignities.contains(.domicile)
                )
                XCTAssertEqual(exact.exaltation, existing.dignities.contains(.exaltation))
                XCTAssertEqual(exact.triplicity, existing.dignities.contains(.triplicity))
                XCTAssertEqual(exact.bound, existing.dignities.contains(.bound))
                XCTAssertEqual(exact.face, existing.dignities.contains(.face))
                XCTAssertEqual(
                    exact.traditionalDetriment,
                    existing.debilities.contains(.detriment)
                )
                XCTAssertEqual(exact.fall, existing.debilities.contains(.fall))
                XCTAssertTrue(exact.peregrineApplies)
                XCTAssertEqual(exact.peregrine, existing.isPeregrine)
                XCTAssertEqual(exact.boundRuler, existing.bound.ruler)
                XCTAssertEqual(exact.faceRuler, existing.face.ruler)
            }
        }
    }

    func testModernDomicileAndDetrimentRemainSeparateRecordedChannels() {
        let domiciles = Mater.qualifyField(
            completeLongitudes(overriding: [
                .pluto: 225,
                .uranus: 315,
                .neptune: 345,
            ]),
            sect: nil
        )

        for planet in [Planet.pluto, .uranus, .neptune] {
            let exact = domiciles.temper(for: planet)
            XCTAssertTrue(exact.modernDomicile)
            XCTAssertFalse(exact.traditionalDomicile)
            XCTAssertFalse(exact.peregrineApplies)
            XCTAssertFalse(exact.peregrine)
        }

        let detriments = Mater.qualifyField(
            completeLongitudes(overriding: [
                .pluto: 45,
                .uranus: 135,
                .neptune: 165,
            ]),
            sect: nil
        )

        XCTAssertTrue(detriments.temper(for: .pluto).modernDetriment)
        XCTAssertTrue(detriments.temper(for: .uranus).modernDetriment)
        XCTAssertTrue(detriments.temper(for: .neptune).modernDetriment)
    }

    func testDegreeScrubKeepsSignTemperWhileBoundAndFaceQualifiersChange() {
        let early = Mater.qualifyField(
            completeLongitudes(overriding: [.venus: 7]),
            sect: .day
        ).temper(for: .venus)
        let late = Mater.qualifyField(
            completeLongitudes(overriding: [.venus: 25]),
            sect: .day
        ).temper(for: .venus)

        XCTAssertEqual(early.fieldTemper.temper, late.fieldTemper.temper)
        XCTAssertEqual(early.fieldTemper.temper, Mater.temper(of: .venus, in: .aries))

        XCTAssertTrue(early.bound)
        XCTAssertEqual(early.boundRuler, .venus)
        XCTAssertFalse(early.face)

        XCTAssertFalse(late.bound)
        XCTAssertTrue(late.face)
        XCTAssertEqual(late.faceRuler, .venus)
    }

    func testAstrolabeSignScrubChangesTemperByReferenceAtTheBoundary() {
        let aries = Mater.qualifyField(
            completeLongitudes(overriding: [.venus: 29.999]),
            sect: .day
        ).temper(for: .venus)
        let taurus = Mater.qualifyField(
            completeLongitudes(overriding: [.venus: 30]),
            sect: .day
        ).temper(for: .venus)

        XCTAssertEqual(aries.fieldTemper.temper, Mater.temper(of: .venus, in: .aries))
        XCTAssertEqual(taurus.fieldTemper.temper, Mater.temper(of: .venus, in: .taurus))
        XCTAssertTrue(aries.traditionalDetriment)
        XCTAssertFalse(aries.traditionalDomicile)
        XCTAssertFalse(taurus.traditionalDetriment)
        XCTAssertTrue(taurus.traditionalDomicile)
    }

    func testCoordinateOriginDoesNotChangeMaterQualification() {
        let sameCoordinates = completeLongitudes(overriding: [
            .venus: 17,
            .mars: 47,
            .jupiter: 277,
        ])

        // These labels deliberately never enter Mater. They stand for four
        // possible callers handing the exact same coordinate field to the law.
        let origins = ["natal", "mundane", "electional", "synchronic"]
        let outputs = origins.map { _ in
            Mater.qualifyField(sameCoordinates, sect: .night).tempers
        }

        for output in outputs.dropFirst() {
            XCTAssertEqual(output, outputs[0])
        }
    }

    func testFieldDependentReceptionSurvivesIntoTheQualifiedRead() {
        let qualified = Mater.qualifyField(
            completeLongitudes(overriding: [
                .mars: 45,
                .venus: 15,
            ]),
            sect: .night
        )

        let mars = qualified.temper(for: .mars)
        let venus = qualified.temper(for: .venus)

        XCTAssertTrue(mars.mutualReception)
        XCTAssertEqual(mars.mutualReceptionWith, [.venus])
        XCTAssertEqual(mars.mutualReceptionKinds, [.domicile])

        XCTAssertTrue(venus.mutualReception)
        XCTAssertEqual(venus.mutualReceptionWith, [.mars])
        XCTAssertEqual(venus.mutualReceptionKinds, [.domicile])
    }
}
