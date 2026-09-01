import XCTest
@testable import OrboCore

final class SynchronicSpineAtroposTests: XCTestCase {
    func testAtroposCertifiesOnlyCompletePatternContents() throws {
        let fixture = try makeFixture()
        let result = Atropos.certifySynchronicSpine(fixture.contents)
        let schematic = try certified(result)

        XCTAssertEqual(schematic.status, .fulfilled)
        XCTAssertEqual(schematic.contents.foundation.commission.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(schematic.contents.foundation.commission.ticketID, fixture.foundation.commission.ticketID)
        XCTAssertEqual(schematic.contents.foundation.bone, fixture.foundation.bone)
        XCTAssertEqual(schematic.contents.asteria.passes.count, 12)
        XCTAssertEqual(schematic.contents.themis.imprints.count, 7)
        XCTAssertEqual(schematic.contents.oceanus.tides.count, 3)
        XCTAssertEqual(schematic.contents.rhea.qualifiers.count, 12)
    }

    func testAtroposRejectsCorruptedDeclaredCount() throws {
        let fixture = try makeFixture()
        let corrupt = copyContents(fixture.contents, asteriaPassCount: 11)
        XCTAssertEqual(Atropos.certifySynchronicSpine(corrupt).failure, .declaredInventoryMismatch)
    }

    func testAtroposRejectsWrongBoneWithoutRecalculating() throws {
        let fixture = try makeFixture()
        let original = fixture.contents.asteria
        let wrongBone = SynchronicSpineBone(
            subjectID: fixture.foundation.commission.subjectID,
            ticketID: fixture.foundation.commission.ticketID,
            start: fixture.foundation.bone.start,
            natal: fixture.foundation.bone.natal,
            end: AbsoluteInstant(unixSecondsSince1970: fixture.foundation.bone.end.unixSecondsSince1970 + 1)!
        )
        let corruptAsteria = SynchronicAsteriaField(
            subjectID: original.subjectID,
            ticketID: original.ticketID,
            bone: wrongBone,
            passes: original.passes
        )
        let corrupt = SynchronicSpinePatternContents(
            foundation: fixture.contents.foundation,
            asteria: corruptAsteria,
            themis: fixture.contents.themis,
            oceanus: fixture.contents.oceanus,
            rhea: fixture.contents.rhea
        )

        XCTAssertEqual(Atropos.certifySynchronicSpine(corrupt).failure, .boneMismatch)
    }

    func testAtroposRejectsMissingOrDuplicatedAsteriaBody() throws {
        let fixture = try makeFixture()
        let original = fixture.contents.asteria
        var passes = Array(original.passes.dropLast())
        passes.append(original.passes[0])
        let corruptField = SynchronicAsteriaField(
            subjectID: original.subjectID,
            ticketID: original.ticketID,
            bone: original.bone,
            passes: passes
        )
        let corrupt = SynchronicSpinePatternContents(
            foundation: fixture.contents.foundation,
            asteria: corruptField,
            themis: fixture.contents.themis,
            oceanus: fixture.contents.oceanus,
            rhea: fixture.contents.rhea
        )

        XCTAssertEqual(Atropos.certifySynchronicSpine(corrupt).failure, .asteriaMismatch)
    }

    func testAtroposRejectsBadThemisOceanusAndRheaIdentitySets() throws {
        let fixture = try makeFixture()

        let t = fixture.contents.themis
        let badThemis = SynchronicThemisField(
            subjectID: t.subjectID,
            ticketID: t.ticketID,
            bone: t.bone,
            natalRisingSign: t.natalRisingSign,
            imprints: Array(t.imprints.dropLast()) + [t.imprints[0]]
        )
        let themisContents = SynchronicSpinePatternContents(
            foundation: fixture.contents.foundation,
            asteria: fixture.contents.asteria,
            themis: badThemis,
            oceanus: fixture.contents.oceanus,
            rhea: fixture.contents.rhea
        )
        XCTAssertEqual(Atropos.certifySynchronicSpine(themisContents).failure, .themisMismatch)

        let o = fixture.contents.oceanus
        let badOceanus = SynchronicOceanusField(
            subjectID: o.subjectID,
            ticketID: o.ticketID,
            bone: o.bone,
            tides: [o.tides[0], o.tides[0], o.tides[2]]
        )
        let oceanusContents = SynchronicSpinePatternContents(
            foundation: fixture.contents.foundation,
            asteria: fixture.contents.asteria,
            themis: fixture.contents.themis,
            oceanus: badOceanus,
            rhea: fixture.contents.rhea
        )
        XCTAssertEqual(Atropos.certifySynchronicSpine(oceanusContents).failure, .oceanusMismatch)

        let r = fixture.contents.rhea
        let badRhea = SynchronicRheaField(
            subjectID: r.subjectID,
            ticketID: r.ticketID,
            bone: r.bone,
            qualifiers: Array(r.qualifiers.dropLast()) + [r.qualifiers[0]]
        )
        let rheaContents = SynchronicSpinePatternContents(
            foundation: fixture.contents.foundation,
            asteria: fixture.contents.asteria,
            themis: fixture.contents.themis,
            oceanus: fixture.contents.oceanus,
            rhea: badRhea
        )
        XCTAssertEqual(Atropos.certifySynchronicSpine(rheaContents).failure, .rheaMismatch)
    }

    func testAtroposRejectsWrongNative() throws {
        let fixture = try makeFixture()
        let r = fixture.contents.rhea
        let wrongRhea = SynchronicRheaField(
            subjectID: HermesSubjectID(rawValue: "wrong-atropos-native")!,
            ticketID: r.ticketID,
            bone: r.bone,
            qualifiers: r.qualifiers
        )
        let corrupt = SynchronicSpinePatternContents(
            foundation: fixture.contents.foundation,
            asteria: fixture.contents.asteria,
            themis: fixture.contents.themis,
            oceanus: fixture.contents.oceanus,
            rhea: wrongRhea
        )
        XCTAssertEqual(Atropos.certifySynchronicSpine(corrupt).failure, .identityMismatch)
    }

    func testAtroposCallsHermesExactlyAfterCertificationAndDoesNotDeliverToHephaestus() throws {
        var fixture = try makeFixture()
        let schematic = try certified(Atropos.certifySynchronicSpine(fixture.contents))
        let reference = try Atropos.callHermesForCertifiedSynchronicSpine(
            schematic,
            courier: &fixture.courier,
            occurredAt: fixture.foundation.bone.natal
        )
        let ticket = fixture.foundation.commission.ticketID
        let events = fixture.courier.manifest.events(for: ticket)

        XCTAssertEqual(reference.certificationID, schematic.certificationID)
        XCTAssertEqual(reference.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(reference.ticketID, ticket)
        XCTAssertEqual(events.map(\.kind), [.ticketOpened, .deliveredToStop, .recoveredFromStop])
        XCTAssertEqual(events.last?.address, SynchronicSpineActIStarter.clotho)
        XCTAssertEqual(fixture.courier.manifest.currentState(for: ticket), .unresolved)
        XCTAssertFalse(events.contains { $0.address == SynchronicSpineActIStarter.hephaestus })

        XCTAssertThrowsError(
            try Atropos.callHermesForCertifiedSynchronicSpine(
                schematic,
                courier: &fixture.courier,
                occurredAt: fixture.foundation.bone.natal
            )
        )
    }

    private struct Fixture {
        let foundation: SynchronicSpineFoundation
        let contents: SynchronicSpinePatternContents
        var courier: HermesCourier
    }

    private func makeFixture() throws -> Fixture {
        let subject = HermesSubjectID(rawValue: "native-atropos")!
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
        return Fixture(foundation: foundation, contents: contents, courier: starter.courier)
    }

    private func copyContents(
        _ value: SynchronicSpinePatternContents,
        asteriaPassCount: Int
    ) -> SynchronicSpinePatternContents {
        SynchronicSpinePatternContents(
            foundation: value.foundation,
            asteria: value.asteria,
            themis: value.themis,
            oceanus: value.oceanus,
            rhea: value.rhea,
            asteriaPassCount: asteriaPassCount
        )
    }

    private func certified(
        _ result: Result<CertifiedSynchronicSpineSchematic, SynchronicSpineAtroposFailure>
    ) throws -> CertifiedSynchronicSpineSchematic {
        switch result {
        case .success(let schematic): return schematic
        case .failure(let failure):
            XCTFail("Expected certification, got \(failure)")
            throw failure
        }
    }

    private func coordinate(_ body: MundaneBody, _ degrees: Double, _ jd: JulianDay) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(physicalDegrees: degrees, motion: .direct)!,
            julianDay: jd
        )
    }

    private func instant(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> AbsoluteInstant {
        let date = CivilDate(year: year, month: month, day: day)!
        let time = CivilClockTime(hour: hour, minute: minute, second: 0)!
        let offset = UTCOffset(secondsEast: 0)!
        switch CivilTime.resolve(date: date, time: time, fixedOffset: offset) {
        case .resolved(let match): return match.instant
        default:
            XCTFail("Expected resolvable UTC instant")
            return AbsoluteInstant(unixSecondsSince1970: 0)!
        }
    }
}

private extension Result {
    var failure: Failure? {
        if case .failure(let failure) = self { return failure }
        return nil
    }
}
