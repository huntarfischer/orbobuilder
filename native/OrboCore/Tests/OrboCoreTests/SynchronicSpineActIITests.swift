import XCTest
@testable import OrboCore

final class SynchronicSpineActIITests: XCTestCase {
    func testHephaestusForgesCertifiedSchematicIntoCandidateWithThreeDoors() throws {
        let fixture = try makeFixture()
        let candidate = SynchronicSpineHephaestus.forge(schematic: fixture.schematic)

        XCTAssertEqual(candidate.certificationID, fixture.schematic.certificationID)
        XCTAssertEqual(candidate.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(candidate.ticketID, fixture.foundation.commission.ticketID)
        XCTAssertEqual(candidate.bone, fixture.foundation.bone)
        XCTAssertEqual(candidate.contents.asteria.passes.count, 12)
        XCTAssertEqual(candidate.contents.themis.imprints.count, 7)
        XCTAssertEqual(candidate.contents.oceanus.tides.count, 3)
        XCTAssertEqual(candidate.contents.rhea.qualifiers.count, 12)
        XCTAssertEqual(candidate.doors, [.horae, .chronos, .hecate])
    }

    func testDioscuriReturnReasonsForInconsistentForgeAndReforgeCanPass() throws {
        let fixture = try makeFixture()
        let badContents = SynchronicSpinePatternContents(
            foundation: fixture.schematic.contents.foundation,
            asteria: fixture.schematic.contents.asteria,
            themis: fixture.schematic.contents.themis,
            oceanus: fixture.schematic.contents.oceanus,
            rhea: fixture.schematic.contents.rhea,
            asteriaPassCount: 11,
            themisImprintCount: 6,
            oceanusTideCount: 2,
            rheaQualifierCount: 11
        )
        let wrongBone = SynchronicSpineBone(
            subjectID: fixture.foundation.commission.subjectID,
            ticketID: fixture.foundation.commission.ticketID,
            start: fixture.foundation.bone.start,
            natal: fixture.foundation.bone.natal,
            end: AbsoluteInstant(unixSecondsSince1970: fixture.foundation.bone.end.unixSecondsSince1970 + 1)!
        )
        let corrupt = SynchronicSpineCandidate(
            schematic: fixture.schematic,
            bone: wrongBone,
            contents: badContents,
            doors: [.horae, .chronos]
        )

        switch SynchronicSpineDioscuri.verify(candidate: corrupt, against: fixture.schematic) {
        case .consistent:
            XCTFail("Dioscuri must reject a corrupt forge")
        case .inconsistent(_, let reasons):
            XCTAssertTrue(reasons.contains(.boneMismatch))
            XCTAssertTrue(reasons.contains(.asteriaMismatch))
            XCTAssertTrue(reasons.contains(.themisMismatch))
            XCTAssertTrue(reasons.contains(.oceanusMismatch))
            XCTAssertTrue(reasons.contains(.rheaMismatch))
            XCTAssertTrue(reasons.contains(.doorMismatch))
        }

        let reforged = SynchronicSpineHephaestus.reforge(schematic: fixture.schematic)
        switch SynchronicSpineDioscuri.verify(candidate: reforged, against: fixture.schematic) {
        case .inconsistent(_, let reasons):
            XCTFail("Lawful reforge remained inconsistent: \(reasons)")
        case .consistent(let candidate, let testimony):
            XCTAssertEqual(testimony.candidateID, candidate.candidateID)
            XCTAssertEqual(testimony.certificationID, fixture.schematic.certificationID)
        }
    }

    func testDioscuriTestimonyIsRequiredForHephaestusSeal() throws {
        let fixture = try makeFixture()
        let candidate = SynchronicSpineHephaestus.forge(schematic: fixture.schematic)
        let testimony: SynchronicSpineDioscuriTestimony

        switch SynchronicSpineDioscuri.verify(candidate: candidate, against: fixture.schematic) {
        case .inconsistent(_, let reasons):
            XCTFail("Lawful candidate rejected: \(reasons)")
            return
        case .consistent(_, let value):
            testimony = value
        }

        let sealed = try SynchronicSpineHephaestus.seal(candidate: candidate, testimony: testimony)
        XCTAssertEqual(sealed.candidate.candidateID, candidate.candidateID)
        XCTAssertEqual(sealed.testimony, testimony)

        let otherCandidate = SynchronicSpineHephaestus.forge(schematic: fixture.schematic)
        XCTAssertThrowsError(
            try SynchronicSpineHephaestus.seal(candidate: otherCandidate, testimony: testimony)
        ) { error in
            XCTAssertEqual(error as? SynchronicSpineActIIFailure, .testimonyMismatch)
        }
    }

    func testCompleteActIIRelayEndsWithSealedSpineInHermesCustody() throws {
        var fixture = try makeFixture()
        var forge = SynchronicSpineActIIForge(courier: fixture.courier)
        let sealed = try forge.run(
            schematic: fixture.schematic,
            occurredAt: fixture.foundation.bone.natal
        )

        XCTAssertEqual(sealed.candidate.certificationID, fixture.schematic.certificationID)
        XCTAssertEqual(sealed.candidate.bone, fixture.foundation.bone)
        XCTAssertEqual(sealed.candidate.doors, [.horae, .chronos, .hecate])
        XCTAssertEqual(sealed.testimony.candidateID, sealed.candidate.candidateID)

        let ticket = fixture.foundation.commission.ticketID
        let events = forge.courier.manifest.events(for: ticket)
        XCTAssertEqual(
            events.map(\.kind),
            [.ticketOpened, .deliveredToStop, .recoveredFromStop, .deliveredToStop, .recoveredFromStop]
        )
        XCTAssertEqual(events[1].address, SynchronicSpineActIStarter.clotho)
        XCTAssertEqual(events[2].address, SynchronicSpineActIStarter.clotho)
        XCTAssertEqual(events[3].address, SynchronicSpineActIStarter.hephaestus)
        XCTAssertEqual(events[4].address, SynchronicSpineActIStarter.hephaestus)
        XCTAssertFalse(events.contains { $0.address == SynchronicSpineActIStarter.timeGarden })
        XCTAssertEqual(forge.courier.manifest.currentState(for: ticket), .unresolved)
    }

    private struct Fixture {
        let foundation: SynchronicSpineFoundation
        let schematic: CertifiedSynchronicSpineSchematic
        var courier: HermesCourier
    }

    private func makeFixture() throws -> Fixture {
        let subject = HermesSubjectID(rawValue: "native-act-ii")!
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
        return Fixture(foundation: foundation, schematic: schematic, courier: starter.courier)
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
