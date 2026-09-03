import XCTest
@testable import OrboCore

final class AssembledOrboSystemTests: XCTestCase {
    func testEanTravelsThroughTheProductionDeliveryAndHestiaOwnsHisNatalTruth() throws {
        let result = try birth(name: "Ean Weslynn", date: CivilDate(year: 1985, month: 4, day: 10)!,
                               time: CivilClockTime(hour: 20, minute: 16)!, place: "Madison, WI")
        let engraving = try XCTUnwrap(result.hestia.nativeEngraving())
        let dna = try XCTUnwrap(engraving.astroDNA)
        XCTAssertEqual(dna.sign(of: .sun), .aries)
        XCTAssertEqual(dna.sign(of: .moon), .capricorn)
        XCTAssertEqual(dna.sign(of: .ascendant), .scorpio)
        XCTAssertEqual(engraving.sect, .night)
        XCTAssertEqual(dna.longitude(of: .sun).degrees, 21.13, accuracy: 0.1)
        XCTAssertEqual(dna.longitude(of: .moon).degrees, 277.57, accuracy: 0.2)
        XCTAssertEqual(dna.longitude(of: .ascendant).degrees, 221.48, accuracy: 0.2)
        XCTAssertEqual(engraving.tapestry?.tapestry.degrees.count, DegreeAddress.count)
        XCTAssertEqual(result.orbo.backOfHouse, .nativeReady)
        let ticket = try XCTUnwrap(result.orbo.engravingTicketID)
        XCTAssertEqual(result.hermes.manifest.currentState(for: ticket), .resolved)
        XCTAssertEqual(result.hermes.manifest.currentState(for: result.notice), .resolved)
        let deliveries = result.hermes.manifest.events(for: ticket).compactMap(\.address)
        XCTAssertTrue(deliveries.contains(Hestia.address))
        XCTAssertTrue(deliveries.contains(OrboOnboarding.engravingItinerary[1]))
    }

    func testDifferentBirthsUseOneMountedSpineAndKeepIndependentHearths() throws {
        let first = try birth(name: "London tester", date: CivilDate(year: 1990, month: 5, day: 17)!,
                              time: CivilClockTime(hour: 14, minute: 32)!, place: "London, United Kingdom")
        let second = try birth(name: "Sydney tester", date: CivilDate(year: 2000, month: 1, day: 1)!,
                               time: CivilClockTime(hour: 6, minute: 15)!, place: "Sydney, Australia")
        let a = try XCTUnwrap(first.hestia.nativeEngraving())
        let b = try XCTUnwrap(second.hestia.nativeEngraving())
        XCTAssertNotEqual(a.subjectID, b.subjectID)
        XCTAssertNotEqual(a.tempus, b.tempus)
        XCTAssertNotEqual(a.astroDNA, b.astroDNA)
        XCTAssertEqual(a.astroDNA?.sign(of: .sun), .taurus)
        XCTAssertEqual(b.astroDNA?.sign(of: .sun), .capricorn)
        XCTAssertEqual(a.topos?.place.timezone.rawValue, "Europe/London")
        XCTAssertEqual(b.topos?.place.timezone.rawValue, "Australia/Sydney")
        XCTAssertNil(first.hestia.canonicalTapestry(for: b.subjectID))
        XCTAssertNil(second.hestia.canonicalTapestry(for: a.subjectID))
        let horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        for engraving in [a, b] {
            let tempus = try XCTUnwrap(engraving.tempus)
            let output = try horae.seek(to: tempus.absoluteInstant.julianDay)
            let sun = try XCTUnwrap(output.celestial.first { $0.body == .sun })
            XCTAssertEqual(try XCTUnwrap(engraving.astroDNA).longitude(of: .sun).degrees,
                           sun.directionalDegree.physicalDegrees, accuracy: 1.0 / 3600)
        }
    }

    func testChronosAndHecateReadTheSameMountedCandidate() throws {
        let runtime = try SealedOrboSpineFixture.runtime()
        let horae = Horae(locate: runtime.locate)
        let jd = JulianDay(2_451_545.0)!
        let output = try horae.seek(to: jd)
        let coordinates = [output.celestial[1], output.celestial[0], output.celestial[2]]
        let addresses = try coordinates.map { try runtime.link.address(of: $0) }
        let request = HecateLink(link: SpineLinkSet(members: addresses)!)
        let received = try request.coordinates(through: runtime.link)
        XCTAssertEqual(received, coordinates)
        XCTAssertTrue(addresses.allSatisfy { $0.spineIdentity == runtime.provenance.candidateManifestSHA256 })
        let bad = SpineLinkAddress(spineIdentity: "another-spine", memberIdentity: addresses[0].memberIdentity)!
        XCTAssertThrowsError(try runtime.link.coordinate(at: bad)) {
            XCTAssertEqual($0 as? SpineLinkFailure, .wrongSpine)
        }
        let missing = SpineLinkAddress(spineIdentity: runtime.link.spineIdentity, memberIdentity: "missing")!
        XCTAssertThrowsError(try runtime.link.coordinate(at: missing))
        let source = coordinates[0]
        guard case let .resolved(occurrences) = try Chronos.resolveBodyState(
            body: source.body, directionalDegree: source.directionalDegree, using: horae
        ) else { return XCTFail("Chronos did not resolve through Horae") }
        XCTAssertTrue(occurrences.hits.contains { abs($0.address.start.value - jd.value) < 1e-7 })
        guard case let .resolved(stations) = Chronos.resolveStations(body: .mercury, using: runtime.library) else {
            return XCTFail("Chronos did not read Library")
        }
        XCTAssertFalse(stations.hits.isEmpty)
        XCTAssertEqual(stations.hits.map(\.address.start), runtime.stations.filter { $0.body == .mercury }.map(\.julianDay))
    }

    func testHecateCastsExistingFortuneFromLinkedBirthMembers() throws {
        let runtime = try SealedOrboSpineFixture.runtime()
        let result = try birth(name: "Ean", date: CivilDate(year: 1985, month: 4, day: 10)!,
                               time: CivilClockTime(hour: 20, minute: 16)!, place: "Madison, WI")
        let engraving = try XCTUnwrap(result.hestia.nativeEngraving())
        let dna = try XCTUnwrap(engraving.astroDNA)
        let output = try Horae(locate: runtime.locate).seek(to: XCTUnwrap(engraving.tempus).absoluteInstant.julianDay)
        let members = try output.celestial.filter { $0.body == .sun || $0.body == .moon }.map { try runtime.link.address(of: $0) }
        let received = try HecateLink(link: SpineLinkSet(members: members)!).coordinates(through: runtime.link)
        let sun = try XCTUnwrap(received.first { $0.body == .sun })
        let moon = try XCTUnwrap(received.first { $0.body == .moon })
        let fortune = try Hecate.castFortune(ascendant: dna.longitude(of: .ascendant),
                                            moon: CelestialLongitude(moon.directionalDegree.physicalDegrees)!,
                                            sun: CelestialLongitude(sun.directionalDegree.physicalDegrees)!,
                                            sect: XCTUnwrap(engraving.sect))
        XCTAssertTrue(fortune.degrees.isFinite)
        XCTAssertEqual(fortune.degrees, 325.04, accuracy: 0.4)
    }

    func testUnresolvablePlaceDoesNotLightHearthOrAnnounceReadiness() throws {
        var orbo = try onboarding(name: "Unknown", date: CivilDate(year: 2000, month: 1, day: 1)!,
                                  time: CivilClockTime(hour: 12, minute: 0)!, place: "No such place 998877")
        var hermes = HermesCourier()
        var hestia = Hestia(nativeSubjectID: HermesSubjectID(rawValue: "unknown-place")!)
        var horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        XCTAssertThrowsError(try deliverOrboEngraving(orbo: &orbo, horae: &horae, hermes: &hermes, hestia: &hestia))
        XCTAssertFalse(hestia.hearthLit)
        XCTAssertNil(hestia.nativeEngraving())
        XCTAssertFalse(orbo.canEnterBigThree)
    }

    private func birth(name: String, date: CivilDate, time: CivilClockTime, place: String) throws
        -> (orbo: Orbo, hermes: HermesCourier, hestia: Hestia, notice: HermesTicketID) {
        var orbo = try onboarding(name: name, date: date, time: time, place: place)
        var hermes = HermesCourier()
        var hestia = Hestia(nativeSubjectID: HermesSubjectID(rawValue: name)!)
        var horae = Horae(locate: try SealedOrboSpineFixture.runtime().locate)
        let notice = try deliverOrboEngraving(orbo: &orbo, horae: &horae, hermes: &hermes, hestia: &hestia)
        return (orbo, hermes, hestia, notice)
    }

    private func onboarding(name: String, date: CivilDate, time: CivilClockTime, place: String) throws -> Orbo {
        var orbo = Orbo()
        _ = orbo.beginOnboarding()
        _ = try orbo.respondToOnboarding(.name(name))
        _ = try orbo.respondToOnboarding(.astrologyInterest(.interested))
        _ = try orbo.respondToOnboarding(.birthDate(date))
        _ = try orbo.respondToOnboarding(.birthLocation(place))
        _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
        _ = try orbo.respondToOnboarding(.birthTime(time))
        return orbo
    }
}
