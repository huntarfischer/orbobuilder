import XCTest
@testable import OrboCore

final class SynchronicSpinePassBTests: XCTestCase {
    func testLachesisHoldsExactlyTheFinishedPatternContents() throws {
        let fixture = try makeFixture()
        let contents = try Lachesis.holdSynchronicSpinePatternContents(
            foundation: fixture.foundation,
            asteria: fixture.asteria,
            themis: fixture.themis,
            oceanus: fixture.oceanus,
            rhea: fixture.rhea
        )

        XCTAssertEqual(contents.boneCount, 1)
        XCTAssertEqual(contents.asteriaPassCount, 12)
        XCTAssertEqual(contents.themisImprintCount, 7)
        XCTAssertEqual(contents.oceanusTideCount, 3)
        XCTAssertEqual(contents.rheaQualifierCount, 12)
        XCTAssertTrue(contents.foundation.pattern.matchesInventory(
            boneCount: contents.boneCount,
            asteriaPassCount: contents.asteriaPassCount,
            themisImprintCount: contents.themisImprintCount,
            oceanusTideCount: contents.oceanusTideCount,
            rheaQualifierCount: contents.rheaQualifierCount
        ))

        XCTAssertEqual(contents.asteria.passes.map(\.body), SynchronicAsteriaBody.canonicalOrder)
        XCTAssertEqual(contents.rhea.qualifiers.map(\.body), SynchronicAsteriaBody.canonicalOrder)
        XCTAssertEqual(contents.themis.imprints.map(\.offset), SynchronicThemisField.canonicalOffsets)
        XCTAssertEqual(contents.oceanus.tides.map(\.identity), SynchronicOceanusTideIdentity.canonicalOrder)
    }

    func testAllConstituentsPreserveOneNativeTicketAndBone() throws {
        let fixture = try makeFixture()
        let contents = try Lachesis.holdSynchronicSpinePatternContents(
            foundation: fixture.foundation,
            asteria: fixture.asteria,
            themis: fixture.themis,
            oceanus: fixture.oceanus,
            rhea: fixture.rhea
        )
        let subject = fixture.foundation.commission.subjectID
        let ticket = fixture.foundation.commission.ticketID
        let bone = fixture.foundation.bone

        XCTAssertEqual(contents.asteria.subjectID, subject)
        XCTAssertEqual(contents.themis.subjectID, subject)
        XCTAssertEqual(contents.oceanus.subjectID, subject)
        XCTAssertEqual(contents.rhea.subjectID, subject)
        XCTAssertEqual(contents.asteria.ticketID, ticket)
        XCTAssertEqual(contents.themis.ticketID, ticket)
        XCTAssertEqual(contents.oceanus.ticketID, ticket)
        XCTAssertEqual(contents.rhea.ticketID, ticket)
        XCTAssertEqual(contents.asteria.bone, bone)
        XCTAssertEqual(contents.themis.bone, bone)
        XCTAssertEqual(contents.oceanus.bone, bone)
        XCTAssertEqual(contents.rhea.bone, bone)
    }

    func testLachesisRejectsConstituentFromWrongNative() throws {
        let fixture = try makeFixture()
        let wrongSubject = HermesSubjectID(rawValue: "wrong-native-pass-b")!
        let wrongRhea = SynchronicRheaField(
            subjectID: wrongSubject,
            ticketID: fixture.rhea.ticketID,
            bone: fixture.rhea.bone,
            qualifiers: fixture.rhea.qualifiers
        )

        XCTAssertThrowsError(
            try Lachesis.holdSynchronicSpinePatternContents(
                foundation: fixture.foundation,
                asteria: fixture.asteria,
                themis: fixture.themis,
                oceanus: fixture.oceanus,
                rhea: wrongRhea
            )
        ) { error in
            XCTAssertEqual(error as? SynchronicSpinePassBFailure, .mismatchedConstituent)
        }
    }

    func testLachesisRejectsMissingQualifierRatherThanLettingAnotherStandIn() throws {
        let fixture = try makeFixture()
        let incompleteRhea = SynchronicRheaField(
            subjectID: fixture.rhea.subjectID,
            ticketID: fixture.rhea.ticketID,
            bone: fixture.rhea.bone,
            qualifiers: Array(fixture.rhea.qualifiers.dropLast())
        )

        XCTAssertThrowsError(
            try Lachesis.holdSynchronicSpinePatternContents(
                foundation: fixture.foundation,
                asteria: fixture.asteria,
                themis: fixture.themis,
                oceanus: fixture.oceanus,
                rhea: incompleteRhea
            )
        ) { error in
            XCTAssertEqual(error as? SynchronicSpinePassBFailure, .incompletePatternContents)
        }
    }

    private struct Fixture {
        let foundation: SynchronicSpineFoundation
        let asteria: SynchronicAsteriaField
        let themis: SynchronicThemisField
        let oceanus: SynchronicOceanusField
        let rhea: SynchronicRheaField
    }

    private func makeFixture() throws -> Fixture {
        let subject = HermesSubjectID(rawValue: "native-pass-b-integration")!
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
        let sourceLastSupport = try XCTUnwrap(JulianDay(sourceEnd.value - 1e-6))
        let sourceBone = try XCTUnwrap(OrboSpineBoneSpan(start: sourceStart, end: sourceEnd))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in MundaneBody.canonicalOrder.enumerated() {
            let center = Double(index * 10 + 5)
            supports.append(coordinate(body, normalized(center - 0.01), sourceBone.start))
            supports.append(coordinate(body, normalized(center + 0.01), sourceLastSupport))
        }
        let terra = [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 359.99, tiltDegrees: 23.4, julianDay: sourceBone.start)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 0.01, tiltDegrees: 23.4, julianDay: sourceBone.end)),
        ]
        let locate = try XCTUnwrap(OrboSpineLocate(
            bone: sourceBone,
            celestialSupports: supports,
            terraSamples: terra
        ))
        let dna = try XCTUnwrap(AstroDNA(rawSequence: Array(repeating: 0, count: AstroDNA.geneCount)))
        let asteria = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: dna,
            mundaneSpine: locate
        )
        let themis = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: dna
        )
        let oceanus = Lachesis.callOceanusForSynchronicSpine(
            foundation: foundation,
            asteria: asteria
        )
        let rhea = Lachesis.callRheaForSynchronicSpine(
            foundation: foundation,
            asteria: asteria
        )

        return Fixture(
            foundation: foundation,
            asteria: asteria,
            themis: themis,
            oceanus: oceanus,
            rhea: rhea
        )
    }

    private func coordinate(
        _ body: MundaneBody,
        _ degrees: Double,
        _ julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: .direct
            )!,
            julianDay: julianDay
        )
    }

    private func normalized(_ degrees: Double) -> Double {
        let remainder = degrees.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }

    private func instant(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0
    ) -> AbsoluteInstant {
        let date = CivilDate(year: year, month: month, day: day)!
        let time = CivilClockTime(hour: hour, minute: minute, second: second)!
        let offset = UTCOffset(secondsEast: 0)!

        switch CivilTime.resolve(date: date, time: time, fixedOffset: offset) {
        case .resolved(let match):
            return match.instant
        default:
            XCTFail("Expected resolvable Gregorian UTC instant")
            return AbsoluteInstant(unixSecondsSince1970: 0)!
        }
    }
}
