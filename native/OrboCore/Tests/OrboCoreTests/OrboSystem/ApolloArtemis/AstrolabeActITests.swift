import XCTest
@testable import OrboCore

final class AstrolabeActITests: XCTestCase {
    func testNatalWheelAndPaneReadTheSameKeptNightChart() throws {
        let hestia = try birth("Ean Weslynn", 1985, 4, 10, 20, 16, "Madison, WI")
        let birth = try XCTUnwrap(hestia.nativeEngraving())
        let aegis = try instrument(hestia, at: birth.tempus!.absoluteInstant.julianDay)
        let chart = try XCTUnwrap(aegis.natal)
        let sun = try XCTUnwrap(chart.placement(.sun))
        let pane = try Apollo.presentToArtemis(chart, selecting: .sun)
        XCTAssertEqual(chart.sect, .night)
        XCTAssertEqual(sun.house, .sixth)
        XCTAssertEqual(sun.condition?.fieldTemper.bearer, .mars)
        XCTAssertEqual(chart.placement(.mars)?.longitude.sign, .taurus)
        XCTAssertEqual(chart.placement(.ascendant)?.longitude.sign, .scorpio)
        XCTAssertEqual(chart.placement(.moon)?.house, .third)
        XCTAssertEqual(pane.rows, [sun])
        XCTAssertEqual(pane.subject.rawValue, birth.subjectID.rawValue)
        XCTAssertEqual(Artemis.signalForIris(pane).signal.reading, pane)
        let testimony = birth.tapestry!.tapestry.degrees.flatMap { $0.mater.conditions }
        XCTAssertEqual(sun.condition, testimony.first { $0.planet == .sun })
        for gene in AstroDNAGene.canonicalOrder {
            XCTAssertEqual(chart.placement(gene)?.longitude, birth.astroDNA?.longitude(of: gene))
            XCTAssertEqual(chart.placement(gene)?.motion, birth.astroDNA?.motion(of: gene))
        }
    }

    func testChangingSkyKeepsNatalChartAndReadingUnchanged() throws {
        let hestia = try birth("Ean Weslynn", 1985, 4, 10, 20, 16, "Madison, WI")
        let jd = hestia.nativeEngraving()!.tempus!.absoluteInstant.julianDay
        let a = try instrument(hestia, at: jd)
        let horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        let b = try Apollo.advanceAegis(a, from: horae.seek(to: JulianDay(jd.value + 7)!))
        XCTAssertEqual(b, try instrument(hestia, at: JulianDay(jd.value + 7)!))
        XCTAssertEqual(a.natal, b.natal)
        XCTAssertNotEqual(a.sky.placement(.moon)?.longitude, b.sky.placement(.moon)?.longitude)
        XCTAssertEqual(try Apollo.presentToArtemis(a.natal!), try Apollo.presentToArtemis(b.natal!))
        XCTAssertEqual(Apollo.signalForIris(b).signal.aegis?.source, b.source)
        for coordinate in b.source.celestial {
            let gene = coordinate.body == .trueNorthNode ? AstroDNAGene.northNode : AstroDNAGene(rawValue: coordinate.body.displayName)!
            XCTAssertEqual(b.sky.placement(gene)?.longitude.degrees, coordinate.directionalDegree.physicalDegrees)
            XCTAssertEqual(b.sky.placement(gene)?.motion, coordinate.directionalDegree.motion)
        }
        let cast = try Hecate.castAscendant(terra: b.source.terra, topos: b.sky.place!)
        XCTAssertEqual(b.sky.placement(.ascendant)?.longitude.degrees, Double(cast.arcsecond) / 3600)
        XCTAssertEqual(b.lunarSeparation, Ring.separation(from: b.sky.placement(.sun)!.longitude, to: b.sky.placement(.moon)!.longitude))
    }

    func testOtherNativesKeepTheirOwnSubjectsHousesAndDispositors() throws {
        let london = try birth("London tester", 1990, 5, 17, 14, 32, "London, United Kingdom")
        let sydney = try birth("Sydney tester", 2000, 1, 1, 6, 15, "Sydney, Australia")
        let jd = london.nativeEngraving()!.tempus!.absoluteInstant.julianDay
        let a = try instrument(london, at: jd).natal!
        let b = try instrument(sydney, at: jd).natal!
        XCTAssertNotEqual(a.subject, b.subject)
        XCTAssertEqual(a.placement(.sun)?.longitude.sign, .taurus)
        XCTAssertEqual(b.placement(.sun)?.longitude.sign, .capricorn)
        for chart in [a, b] {
            let pane = try Apollo.presentToArtemis(chart)
            XCTAssertEqual(pane.rows.count, 12)
            XCTAssertEqual(pane.subject, chart.subject)
            let rising = chart.placement(.ascendant)!.longitude.sign
            for row in pane.rows {
                XCTAssertEqual(row.house, Tympan.house(of: row.longitude.sign, rising: rising))
                if let condition = row.condition {
                    XCTAssertNotNil(chart.placement(AstroDNAGene(rawValue: condition.fieldTemper.bearer.rawValue)!))
                }
            }
        }
    }

    func testSkyWithoutPlaceDoesNotInventAnAscendantOrHouses() throws {
        let horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        let aegis = try Apollo.establishAegis(at: JulianDay(2451545)!, using: horae, hestia: nil, atPlace: nil)
        XCTAssertNil(aegis.natal)
        XCTAssertNil(aegis.sky.placement(.ascendant))
        XCTAssertTrue(aegis.sky.houses.isEmpty)
        XCTAssertTrue(aegis.sky.placements.allSatisfy { $0.house == nil })
        XCTAssertThrowsError(try Apollo.presentToArtemis(aegis.sky, selecting: .ascendant))
        XCTAssertEqual(try Apollo.presentToArtemis(aegis.sky).rows.count, 11)
    }

    func testMixedMomentsAreRefusedBeforeTheyReachTheHeaderOrWheel() throws {
        let horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        let a = try horae.seek(to: JulianDay(2451545)!)
        let b = try horae.seek(to: JulianDay(2451546)!)
        let mixed = HoraeOutput(julianDay: a.julianDay, celestial: a.celestial, terra: b.terra)
        XCTAssertThrowsError(try Apollo.establishAegis(from: mixed, hestia: nil, atPlace: nil))
        let duplicate = HoraeOutput(julianDay: a.julianDay,
            celestial: Array(repeating: a.celestial[0], count: 11), terra: a.terra)
        XCTAssertThrowsError(try Apollo.establishAegis(from: duplicate, hestia: nil, atPlace: nil))
    }

    private func instrument(_ hestia: Hestia, at jd: JulianDay) throws -> ApolloAegis {
        let horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        return try Apollo.establishAegis(at: jd, using: horae, hestia: hestia, atPlace: hestia.nativeEngraving()?.topos)
    }

    private func birth(_ name: String, _ year: Int, _ month: Int, _ day: Int,
                       _ hour: Int, _ minute: Int, _ place: String) throws -> Hestia {
        var orbo = Orbo()
        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name(name))
        _ = try orbo.respondToOnboarding(.astrologyInterest(.interested))
        _ = try orbo.respondToOnboarding(.birthDate(CivilDate(year: year, month: month, day: day)!))
        _ = try orbo.respondToOnboarding(.birthLocation(place))
        _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        _ = try orbo.respondToOnboarding(.birthTime(CivilClockTime(hour: hour, minute: minute)!))
        var hermes = HermesCourier()
        var hestia = Hestia(nativeSubjectID: HermesSubjectID(rawValue: name)!)
        var horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        _ = try deliverOrboEngraving(orbo: &orbo, horae: &horae, hermes: &hermes, hestia: &hestia)
        return hestia
    }
}
