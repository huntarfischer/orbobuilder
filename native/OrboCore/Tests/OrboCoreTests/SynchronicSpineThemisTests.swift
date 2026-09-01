import XCTest
@testable import OrboCore

final class SynchronicSpineThemisTests: XCTestCase {
    func testThemisProvidesExactlySevenCanonicalOffsetsAroundNatalRising() throws {
        let foundation = try makeFoundation()
        let dna = makeAstroDNA(rising: .leo)
        let field = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: dna
        )

        XCTAssertEqual(field.subjectID, foundation.commission.subjectID)
        XCTAssertEqual(field.ticketID, foundation.commission.ticketID)
        XCTAssertEqual(field.bone, foundation.bone)
        XCTAssertEqual(field.natalRisingSign, .leo)
        XCTAssertEqual(field.imprints.count, 7)
        XCTAssertEqual(field.imprints.map(\.offset), [-3, -2, -1, 0, 1, 2, 3])
        XCTAssertEqual(
            field.imprints.map(\.risingSign),
            [.taurus, .gemini, .cancer, .leo, .virgo, .libra, .scorpio]
        )
        XCTAssertEqual(Set(field.imprints.map(\.risingSign)).count, 7)
        XCTAssertEqual(field[0]?.risingSign, .leo)
    }

    func testSevenFramesWrapLawfullyAcrossPiscesAndAries() throws {
        let foundation = try makeFoundation(subject: "native-wrap")
        let field = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: makeAstroDNA(rising: .aries)
        )

        XCTAssertEqual(
            field.imprints.map(\.risingSign),
            [.capricorn, .aquarius, .pisces, .aries, .taurus, .gemini, .cancer]
        )
        XCTAssertEqual(field[0]?.risingSign, .aries)
    }

    func testEveryFrameIsTheCompleteCanonicalTympanImprint() throws {
        let foundation = try makeFoundation(subject: "native-complete")
        let field = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: makeAstroDNA(rising: .sagittarius)
        )

        for selected in field.imprints {
            let canonical = Tympan.imprint(for: selected.risingSign)

            XCTAssertEqual(selected.imprint.risingSign, canonical.risingSign)
            XCTAssertEqual(selected.imprint.houses, canonical.houses)
            XCTAssertEqual(selected.imprint.traditionalGovernanceLattice, canonical.traditionalGovernanceLattice)
            XCTAssertEqual(selected.imprint.modernGovernance, canonical.modernGovernance)
            XCTAssertEqual(selected.imprint.houseGovernance, canonical.houseGovernance)
            XCTAssertEqual(selected.imprint.houses.count, 12)
            XCTAssertEqual(selected.imprint.houseGovernance.count, 12)
            XCTAssertEqual(
                selected.imprint.traditionalGovernanceLattice.count,
                Tympan.TraditionalGovernor.allCases.count
            )
        }
    }

    func testLibraFramePreservesVenusGovernanceOfFirstAndEighth() throws {
        let foundation = try makeFoundation(subject: "native-libra")
        let field = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: makeAstroDNA(rising: .libra)
        )
        let libra = try XCTUnwrap(field[0]?.imprint)

        XCTAssertEqual(libra.governance(of: .first).traditionalGovernor, .venus)
        XCTAssertEqual(libra.governance(of: .eighth).traditionalGovernor, .venus)
        XCTAssertEqual(libra.housesGoverned(by: .venus), [.first, .eighth])
    }

    func testScorpioFramePreservesMarsGovernanceOfFirstAndSixth() throws {
        let foundation = try makeFoundation(subject: "native-scorpio")
        let field = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: makeAstroDNA(rising: .scorpio)
        )
        let scorpio = try XCTUnwrap(field[0]?.imprint)

        XCTAssertEqual(scorpio.governance(of: .first).traditionalGovernor, .mars)
        XCTAssertEqual(scorpio.governance(of: .sixth).traditionalGovernor, .mars)
        XCTAssertEqual(scorpio.housesGoverned(by: .mars), [.first, .sixth])
    }

    func testChangingNatalAscendantChangesOnlyWhichSevenCanonicalFramesAreSelected() throws {
        let foundation = try makeFoundation(subject: "native-selection")
        let aries = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: makeAstroDNA(rising: .aries)
        )
        let taurus = Lachesis.callThemisForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: makeAstroDNA(rising: .taurus)
        )

        XCTAssertEqual(aries[0]?.risingSign, .aries)
        XCTAssertEqual(taurus[0]?.risingSign, .taurus)
        XCTAssertEqual(aries[1]?.imprint.houses, Tympan.imprint(for: .taurus).houses)
        XCTAssertEqual(taurus[-1]?.imprint.houses, Tympan.imprint(for: .aries).houses)
    }

    private func makeAstroDNA(rising: Sign) -> AstroDNA {
        var raw = Array(repeating: 0, count: AstroDNA.geneCount)
        raw[AstroDNAGene.ascendant.ordinal] = rising.rawValue * 30 * Ring.arcsecondsPerDegree
        return AstroDNA(rawSequence: raw)!
    }

    private func makeFoundation(subject: String = "native-themis") throws -> SynchronicSpineFoundation {
        let subjectID = HermesSubjectID(rawValue: subject)!
        let natal = instant(year: 2001, month: 6, day: 15, hour: 12)
        var starter = SynchronicSpineActIStarter()
        return try starter.start(subjectID: subjectID, natal: natal, occurredAt: natal)
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
