import XCTest
@testable import OrboCore

final class AstrolabeActIITests: XCTestCase {
    private func chart() -> AstrolabeChart {
        AstrolabeChart(subject: Apollo.placeOnAstrolabe(identity: "contract-subject"), kind: .sky,
            name: "The sky", julianDay: JulianDay(2451545)!, place: nil, sect: nil, placements: [], houses: [])
    }
    private func ticket(_ plate: LunarPlate, _ rows: [LunarRow], doctrine: [LunarDoctrine] = [.spine]) -> LunarTicket {
        LunarTicket(plate: plate, subject: LunarSubject(chart: chart(), course: .sky), rows: rows, doctrine: doctrine)
    }
    func testWholeReadingRefusesMixedRowsAndMissingCredits() throws {
        XCTAssertThrowsError(try Artemis.pass(ticket(.fact, [.fact(key: "valid", value: "yes", qualified: nil), .relation(left: "a", mark: "trine", right: "b", orb: 0)])))
        XCTAssertThrowsError(try Artemis.pass(ticket(.fact, [], doctrine: [])))
        let result = try Artemis.pass(ticket(.fact, [.fact(key: "phase", value: "waxing", qualified: nil)]))
        XCTAssertEqual(result.caption, "the sky of this moment")
        XCTAssertEqual(result.rest, .facts)
        XCTAssertEqual(result.provenance, ["OrboSpine · Horae"])
    }
    func testForeignHouseRefusesWholeReading() {
        let qualified = LunarQualifiedValue(body: .moon, longitude: CelestialLongitude(12)!,
            house: LunarHouse(native: Apollo.placeOnAstrolabe(identity: "other"), number: .first))
        XCTAssertThrowsError(try Artemis.pass(ticket(.fact, [.fact(key: "Moon", value: "12°", qualified: qualified)]))) {
            XCTAssertEqual($0 as? LunarPortFailure, .wrongHouseSubject)
        }
    }
    func testTracksKeepRawOverflowButRejectInvalidRangesAndStandaloneUse() throws {
        let track = LunarTrack(value: 12, minimum: 0, maximum: 10, unit: "units")
        let result = try Artemis.pass(ticket(.ledger, [.ledger(mark: "•", what: "event", when: JulianDay(2451545)!, track: track)]))
        XCTAssertEqual(result.ticket.rows.count, 1)
        XCTAssertEqual(track.value, 12)
        XCTAssertEqual(track.fill, 1)
        XCTAssertThrowsError(try Artemis.pass(ticket(.track, [])))
        for invalid in [LunarTrack(value: .nan, minimum: 0, maximum: 10, unit: ""), LunarTrack(value: 1, minimum: 1, maximum: 1, unit: "")] {
            XCTAssertThrowsError(try Artemis.pass(ticket(.ledger, [.ledger(mark: "•", what: "event", when: JulianDay(2451545)!, track: invalid)])))
        }
    }
    func testSpanAllowsValensOverflowButNotOutsideChildStart() throws {
        let child = LunarSpan(glyph: "A", level: 2, start: JulianDay(105)!, end: JulianDay(120)!)
        let parent = LunarSpan(glyph: "B", level: 1, start: JulianDay(100)!, end: JulianDay(110)!, children: [child])
        XCTAssertNoThrow(try Artemis.pass(ticket(.span, [.span(parent)])))
        let wrong = LunarSpan(glyph: "B", level: 1, start: JulianDay(106)!, end: JulianDay(110)!, children: [child])
        XCTAssertThrowsError(try Artemis.pass(ticket(.span, [.span(wrong)])))
    }
    func testProseCannotArriveAsAnIndependentTicketOrInventAnEmptyShelf() throws {
        XCTAssertThrowsError(try Artemis.pass(ticket(.prose, [.prose(address: "x", text: "words", source: "source")])))
        let parent = try Artemis.pass(ticket(.fact, [.fact(key: "Moon", value: "12°", qualified: nil)]))
        XCTAssertNil(try Artemis.expand(parent, row: 0, shelf: [:], source: "test"))
        XCTAssertThrowsError(try Artemis.expand(parent, row: 1, shelf: [:], source: "test"))
    }
    func testScrubUsesRelativeTurnNotFingerPosition() {
        let domain = HoraeControlDomain(start: JulianDay(2400000)!, endExclusive: JulianDay(2500000)!)
        var a = ApolloScrub(body: .moon, julianDay: JulianDay(2451545)!, angle: 359, radius: 120)
        var b = ApolloScrub(body: .moon, julianDay: JulianDay(2451545)!, angle: 100, radius: 120)
        let one = a.move(angle: 1, radius: 120, domain: domain)
        let two = b.move(angle: 102, radius: 120, domain: domain)
        XCTAssertEqual(one, two)
        XCTAssertEqual(one.value - 2451545, 2.0 / 360 * 27.32166, accuracy: 1e-8)
    }
    func testRadiusGearAndDomainBoundary() {
        let domain = HoraeControlDomain(start: JulianDay(2451544)!, endExclusive: JulianDay(2451546)!)
        var outer = ApolloScrub(body: .moon, julianDay: JulianDay(2451545)!, angle: 0, radius: 120)
        var inner = outer
        let slow = outer.move(angle: 1, radius: 120, domain: domain)
        let fast = inner.move(angle: 1, radius: 60, domain: domain)
        XCTAssertGreaterThan(fast.value, slow.value)
        let edge = inner.move(angle: 180, radius: 60, domain: domain)
        XCTAssertLessThan(edge.value, domain.endExclusive.value)
        XCTAssertEqual(edge.value, domain.endExclusive.value.nextDown)
    }
    func testRealSpineScrubRetainsSourceMotionAndOneMoment() throws {
        let runtime = try SealedOrboSpineFixture.runtime()
        let horae = Horae(locate: runtime.locate)
        let initial = try Apollo.establishAegis(at: JulianDay(2451545)!, using: horae, hestia: nil, atPlace: nil)
        var scrub = ApolloScrub(body: .mercury, julianDay: initial.source.julianDay, angle: 140, radius: 120)
        let moment = scrub.move(angle: 170, radius: 120, domain: horae.controlDomain)
        let answer = try horae.seek(to: moment)
        let moved = try Apollo.advanceAegis(initial, from: answer)
        XCTAssertEqual(moved.source, answer)
        XCTAssertEqual(moved.sky.julianDay, moment)
        for source in answer.celestial {
            let gene = source.body == .trueNorthNode ? AstroDNAGene.northNode : AstroDNAGene(rawValue: source.body.displayName)!
            XCTAssertEqual(moved.sky.placement(gene)?.longitude.degrees, source.directionalDegree.physicalDegrees)
            XCTAssertEqual(moved.sky.placement(gene)?.motion, source.directionalDegree.motion)
        }
        XCTAssertEqual(try Artemis.moon(moved).ticket.subject.chart, moved.sky)
    }
    func testChronosAlmanacAndPythiaReadActualDoors() throws {
        let runtime = try SealedOrboSpineFixture.runtime()
        let horae = Horae(locate: runtime.locate)
        let moment = JulianDay(2451545)!
        let almanac = Chronos.almanac(after: moment, body: .mercury, using: runtime.library)
        XCTAssertFalse(almanac.hits.isEmpty)
        XCTAssertTrue(almanac.hits.allSatisfy { $0.address.start.value > moment.value && $0.fact == .station(body: .mercury) })
        let frame = try horae.seek(to: moment)
        let moon = try XCTUnwrap(frame.celestial.first { $0.body == .moon })
        let returns = try Pythia.returns(body: .moon, at: moon.directionalDegree, after: moment, using: horae)
        XCTAssertFalse(returns.hits.isEmpty)
        for hit in returns.hits.prefix(3) {
            let found = try horae.seek(to: hit.address.start).celestial.first { $0.body == .moon }!
            XCTAssertEqual(found.directionalDegree.degrees, moon.directionalDegree.degrees, accuracy: 0.001)
        }
    }
    func testTabulaHasTwelveSeatsWithAgreedOwners() {
        XCTAssertEqual(Hermes.tabulaSeats.count, 12)
        XCTAssertEqual(HermesTabulaSeat.moon.owner, "Artemis")
        XCTAssertEqual(HermesTabulaSeat.almanac.owner, "Chronos")
        XCTAssertEqual(HermesTabulaSeat.timing.owner, "Pythia")
        XCTAssertEqual(HermesTabulaSeat.archive.owner, "Hestia")
    }

    func testPreparedLunarShelvesAndFusedAlmanacRetainSpineMatter() throws {
        let runtime = try SealedOrboSpineFixture.runtime()
        XCTAssertEqual(runtime.library.eclipses, runtime.eclipses)
        XCTAssertEqual(runtime.library.ringOccurrences, runtime.ringOccurrences)
        let moment = JulianDay(2451545)!
        let fused = Chronos.almanacEvents(after: moment, body: nil, streams: [.stations, .contacts, .eclipses], using: runtime.library)
        XCTAssertFalse(fused.isEmpty)
        XCTAssertLessThanOrEqual(fused.count, 30)
        XCTAssertEqual(fused.map(\.moment.value), fused.map(\.moment.value).sorted())
        XCTAssertTrue(Chronos.almanacEvents(after: moment, body: nil, streams: [], using: runtime.library).isEmpty)
        for event in fused {
            switch event {
            case let .contact(contact): XCTAssertTrue(runtime.ringOccurrences.contains(contact))
            case let .eclipse(eclipse): XCTAssertTrue(runtime.eclipses.contains(eclipse))
            case let .station(station): XCTAssertTrue(runtime.stations.contains(station))
            }
        }
    }

    func testDisabledAspectCannotAttractAndZeroSpeedCannotInventCorrection() throws {
        let runtime = try SealedOrboSpineFixture.runtime()
        let horae = Horae(locate: runtime.locate)
        let moment = JulianDay(2451545)!
        func sample(_ jd: JulianDay, sun: Double) throws -> ApolloAegis {
            let source = try horae.seek(to: jd)
            let chart = AstrolabeChart(subject: Apollo.placeOnAstrolabe(identity: "magnet-contract"), kind: .sky,
                name: "Magnet contract", julianDay: jd, place: nil, sect: nil,
                placements: [AstrolabePlacement(gene: .sun, longitude: CelestialLongitude(sun)!, motion: .direct, house: nil, condition: nil),
                             AstrolabePlacement(gene: .moon, longitude: CelestialLongitude(82)!, motion: .direct, house: nil, condition: nil)], houses: [])
            return ApolloAegis(source: source, sky: chart, natal: nil, lunarSeparation: RingSeparation(82 - sun)!)
        }
        let a = try sample(moment, sun: 22.2)
        let b = try sample(JulianDay(moment.value + 0.05)!, sun: 22.3)
        var settings = ApolloAspectSettings()
        settings.enabled = []
        XCTAssertEqual(Apollo.magneticMoment(raw: moment, body: .sun, first: a, second: b, settings: settings, domain: horae.controlDomain), moment)
        settings.enabled = [.sextile]
        XCTAssertNotEqual(Apollo.magneticMoment(raw: moment, body: .sun, first: a, second: b, settings: settings, domain: horae.controlDomain), moment)
        let stationary = try sample(JulianDay(moment.value + 0.05)!, sun: 22.2)
        XCTAssertEqual(Apollo.magneticMoment(raw: moment, body: .sun, first: a, second: stationary, settings: settings, domain: horae.controlDomain), moment)
        let exact = try sample(moment, sun: 22)
        XCTAssertEqual(Apollo.contacts(in: exact.sky, settings: settings).first?.residual, 0)
        XCTAssertEqual(settings.orb(for: .quincunx), 3)
        XCTAssertEqual(settings.orb(for: .quintile), 2.4, accuracy: 1e-12)
    }
}
