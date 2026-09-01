import XCTest
@testable import OrboCore

final class SynchronicSpineActIIITests: XCTestCase {
    func testHoraeScanReadsCompleteForgedExtentWithoutChangingSpine() throws {
        let fixture = try makeFixture()
        let scan = try Horae.scanSynchronicSpine(fixture.sealed)

        XCTAssertEqual(scan.sealID, fixture.sealed.sealID)
        XCTAssertEqual(scan.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(scan.ticketID, fixture.foundation.commission.ticketID)
        XCTAssertEqual(scan.start, fixture.foundation.bone.start)
        XCTAssertEqual(scan.natal, fixture.foundation.bone.natal)
        XCTAssertEqual(scan.end, fixture.foundation.bone.end)
    }

    func testChronosQueryRequiresMatchingHoraeScan() throws {
        let fixture = try makeFixture()
        let scan = try Horae.scanSynchronicSpine(fixture.sealed)
        let query = try Chronos.classifySynchronicSpineForQuery(fixture.sealed, after: scan)
        XCTAssertEqual(query.sealID, fixture.sealed.sealID)

        let wrong = SynchronicSpineHoraeScan(
            sealID: UUID(),
            subjectID: scan.subjectID,
            ticketID: scan.ticketID,
            start: scan.start,
            natal: scan.natal,
            end: scan.end
        )
        XCTAssertThrowsError(
            try Chronos.classifySynchronicSpineForQuery(fixture.sealed, after: wrong)
        ) { error in
            XCTAssertEqual(error as? SynchronicSpineTimeGardenFailure, .chronosRequiresHoraeScan)
        }
    }

    func testHecateBlessingRequiresBothPriorMarksAndGrantsBothCapabilities() throws {
        let fixture = try makeFixture()
        let scan = try Horae.scanSynchronicSpine(fixture.sealed)
        let query = try Chronos.classifySynchronicSpineForQuery(fixture.sealed, after: scan)
        let blessing = try Hecate.blessSynchronicSpine(fixture.sealed, after: scan, query: query)

        XCTAssertEqual(
            blessing.capabilities,
            Set<SynchronicSpineBlessedCapability>([.calculations, .comparisons])
        )

        let wrongQuery = SynchronicSpineChronosQuery(
            sealID: UUID(),
            subjectID: query.subjectID,
            ticketID: query.ticketID
        )
        XCTAssertThrowsError(
            try Hecate.blessSynchronicSpine(fixture.sealed, after: scan, query: wrongQuery)
        ) { error in
            XCTAssertEqual(error as? SynchronicSpineTimeGardenFailure, .hecateRequiresPriorMarks)
        }
    }

    func testPlantingRequiresAllThreeMarksFromSameSealedSpine() throws {
        let fixture = try makeFixture()
        let scan = try Horae.scanSynchronicSpine(fixture.sealed)
        let query = try Chronos.classifySynchronicSpineForQuery(fixture.sealed, after: scan)
        let blessing = try Hecate.blessSynchronicSpine(fixture.sealed, after: scan, query: query)
        let planted = try SynchronicSpineTimeGarden.plant(
            fixture.sealed,
            scan: scan,
            query: query,
            blessing: blessing
        )

        XCTAssertEqual(planted.sealed.sealID, fixture.sealed.sealID)
        XCTAssertEqual(planted.horaeScan, scan)
        XCTAssertEqual(planted.chronosQuery, query)
        XCTAssertEqual(planted.blessing, blessing)
    }

    func testCompleteActIIIRelayPlantsClosesOriginalTicketAndAnnouncesAvailability() throws {
        var fixture = try makeFixture()
        var garden = SynchronicSpineActIIITimeGarden(courier: fixture.courier)
        let (planted, announcement) = try garden.run(
            sealed: fixture.sealed,
            occurredAt: fixture.foundation.bone.natal
        )

        XCTAssertEqual(planted.sealed.sealID, fixture.sealed.sealID)
        XCTAssertEqual(announcement.message, "SYNCHRONIC SPINE AVAILABLE")
        XCTAssertEqual(announcement.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(announcement.ticketID, fixture.foundation.commission.ticketID)
        XCTAssertEqual(announcement.sealID, fixture.sealed.sealID)

        let ticket = fixture.foundation.commission.ticketID
        let events = garden.courier.manifest.events(for: ticket)
        XCTAssertEqual(
            events.map(\.kind),
            [
                .ticketOpened,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToAddressee,
                .receiptRecorded,
                .resolved,
            ]
        )
        XCTAssertEqual(events[5].address, SynchronicSpineActIStarter.timeGarden)
        XCTAssertEqual(events[6].address, SynchronicSpineActIStarter.timeGarden)
        XCTAssertEqual(events[7].address, SynchronicSpineActIStarter.timeGarden)
        XCTAssertEqual(garden.courier.manifest.currentState(for: ticket), .resolved)
        XCTAssertTrue(garden.courier.manifest.unresolvedTickets().isEmpty)
    }

    private struct Fixture {
        let foundation: SynchronicSpineFoundation
        let sealed: SealedSynchronicSpine
        var courier: HermesCourier
    }

    private func makeFixture() throws -> Fixture {
        let subject = HermesSubjectID(rawValue: "native-act-iii")!
        let natal = instant(year: 2001, month: 6, day: 15, hour: 12)
        var starter = SynchronicSpineActIStarter()
        let commissioned = try starter.start(subjectID: subject, natal: natal, occurredAt: natal)

        let start = AbsoluteInstant(unixSecondsSince1970: natal.unixSecondsSince1970 - 21_600)!
        let end = AbsoluteInstant(unixSecondsSince1970: natal.unixSecondsSince1970 + 21_600)!
        let bone = SynchronicSpineBone(
            subjectID: subject,
            ticketID: commissioned.commission.ticketID,
            start: start,
            natal: natal,
            end: end
        )
        let foundation = SynchronicSpineFoundation(
            commission: commissioned.commission,
            pattern: commissioned.pattern,
            bone: bone
        )

        let sourceStart = try XCTUnwrap(JulianDay(start.julianDay.value - 0.25))
        let sourceEnd = try XCTUnwrap(JulianDay(end.julianDay.value + 0.25))
        let sourceLast = try XCTUnwrap(JulianDay(sourceEnd.value - 1e-6))
        let sourceBone = try XCTUnwrap(OrboSpineBoneSpan(start: sourceStart, end: sourceEnd))
        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in MundaneBody.canonicalOrder.enumerated() {
            let center = Double(index * 10 + 5)
            supports.append(coordinate(body, center - 0.01, sourceBone.start))
            supports.append(coordinate(body, center + 0.01, sourceLast))
        }
        let terra = [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 359.99, tiltDegrees: 23.4, julianDay: sourceBone.start)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 0.01, tiltDegrees: 23.4, julianDay: sourceBone.end)),
        ]
        let locate = try XCTUnwrap(OrboSpineLocate(bone: sourceBone, celestialSupports: supports, terraSamples: terra))
        let dna = try XCTUnwrap(AstroDNA(rawSequence: Array(repeating: 0, count: AstroDNA.geneCount)))
        let asteria = try Lachesis.callAsteriaForSynchronicSpine(foundation: foundation, natalAstroDNA: dna, mundaneSpine: locate)
        let themis = Lachesis.callThemisForSynchronicSpine(foundation: foundation, natalAstroDNA: dna)
        let oceanus = Lachesis.callOceanusForSynchronicSpine(foundation: foundation, asteria: asteria)
        let rhea = Lachesis.callRheaForSynchronicSpine(foundation: foundation, asteria: asteria)
        let contents = try Lachesis.holdSynchronicSpinePatternContents(
            foundation: foundation,
            asteria: asteria,
            themis: themis,
            oceanus: oceanus,
            rhea: rhea
        )
        let schematic: CertifiedSynchronicSpineSchematic
        switch Atropos.certifySynchronicSpine(contents) {
        case .success(let value): schematic = value
        case .failure(let failure): throw failure
        }
        _ = try starter.receiveAtroposCertifiedSchematic(schematic, occurredAt: natal)

        var forge = SynchronicSpineActIIForge(courier: starter.courier)
        let sealed = try forge.run(schematic: schematic, occurredAt: natal)
        return Fixture(foundation: foundation, sealed: sealed, courier: forge.courier)
    }

    private func coordinate(_ body: MundaneBody, _ degrees: Double, _ jd: JulianDay) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(physicalDegrees: degrees, motion: .direct)!,
            julianDay: jd
        )
    }

    private func instant(year: Int, month: Int, day: Int, hour: Int = 0) -> AbsoluteInstant {
        let date = CivilDate(year: year, month: month, day: day)!
        let time = CivilClockTime(hour: hour, minute: 0, second: 0)!
        let offset = UTCOffset(secondsEast: 0)!
        switch CivilTime.resolve(date: date, time: time, fixedOffset: offset) {
        case .resolved(let match): return match.instant
        default:
            XCTFail("Expected resolvable UTC instant")
            return AbsoluteInstant(unixSecondsSince1970: 0)!
        }
    }
}
