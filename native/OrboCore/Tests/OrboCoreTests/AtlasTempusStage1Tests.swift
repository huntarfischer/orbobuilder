import XCTest
@testable import OrboCore

final class AtlasTempusStage1Tests: XCTestCase {
    func testOrdinaryEngravingResolvesToposAndTempusThroughCivilTime() throws {
        let engraving = makeEngraving(
            date: CivilDate(year: 1985, month: 4, day: 10)!,
            time: CivilClockTime(hour: 20, minute: 16)!
        )

        let resolved = try found(Atlas().resolve(engraving))
        let topos = try XCTUnwrap(resolved.topos)
        let tempus = try XCTUnwrap(resolved.tempus)

        XCTAssertEqual(topos.place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(topos.place.timezone.rawValue, "America/Chicago")

        guard case let .resolved(expected) = CivilTime.resolve(
            date: engraving.birthDate,
            time: engraving.birthTime,
            in: topos.place.timezone
        ) else {
            XCTFail("Expected canonical Madison civil time to resolve uniquely")
            return
        }

        XCTAssertEqual(tempus.absoluteInstant, expected.instant)
        XCTAssertEqual(tempus.provenance.source, .timeZoneDatabase)
        XCTAssertEqual(tempus.provenance.timeZoneDataVersion, CivilTime.timeZoneDataVersion)
        XCTAssertEqual(resolved.subjectID, engraving.subjectID)
        XCTAssertEqual(resolved.name, engraving.name)
        XCTAssertEqual(resolved.birthDate, engraving.birthDate)
        XCTAssertEqual(resolved.birthTime, engraving.birthTime)
        XCTAssertEqual(resolved.birthLocation, engraving.birthLocation)
        XCTAssertNil(resolved.astroDNA)
        XCTAssertNil(resolved.tapestry)
        XCTAssertFalse(resolved.engraved)
    }

    func testAmbiguousPlaceStopsBeforeTempusResolution() {
        let engraving = makeEngraving(
            date: CivilDate(year: 1985, month: 4, day: 10)!,
            time: CivilClockTime(hour: 20, minute: 16)!,
            location: "Tokyo, Japan"
        )

        guard case let .ambiguous(topoi) = Atlas().resolve(engraving) else {
            XCTFail("Expected ambiguous Topos result")
            return
        }

        XCTAssertGreaterThanOrEqual(topoi.count, 2)
    }

    func testRepeatedCivilTimeReturnsBothLegitimateTempusCandidates() throws {
        let engraving = makeEngraving(
            date: CivilDate(year: 2024, month: 11, day: 3)!,
            time: CivilClockTime(hour: 1, minute: 30)!
        )

        guard case let .ambiguousTempus(first, second) = Atlas().resolve(engraving) else {
            XCTFail("Expected repeated Madison civil time to remain ambiguous")
            return
        }

        let firstTopos = try XCTUnwrap(first.topos)
        let firstTempus = try XCTUnwrap(first.tempus)
        let secondTempus = try XCTUnwrap(second.tempus)

        guard case let .ambiguous(expectedFirst, expectedSecond) = CivilTime.resolve(
            date: engraving.birthDate,
            time: engraving.birthTime,
            in: firstTopos.place.timezone
        ) else {
            XCTFail("Expected CivilTime to return the same repeated-time ambiguity")
            return
        }

        XCTAssertEqual(firstTempus.absoluteInstant, expectedFirst.instant)
        XCTAssertEqual(secondTempus.absoluteInstant, expectedSecond.instant)
        XCTAssertNotEqual(firstTempus.absoluteInstant, secondTempus.absoluteInstant)
        XCTAssertEqual(first.topos, second.topos)
    }

    func testNonexistentCivilTimeRemainsUnresolvedAfterTopos() throws {
        let engraving = makeEngraving(
            date: CivilDate(year: 2024, month: 3, day: 10)!,
            time: CivilClockTime(hour: 2, minute: 30)!
        )

        guard case let .nonexistentCivilTime(partial) = Atlas().resolve(engraving) else {
            XCTFail("Expected spring-forward gap to remain nonexistent")
            return
        }

        XCTAssertNotNil(partial.topos)
        XCTAssertNil(partial.tempus)
    }

    func testUnsupportedYearRemainsExplicitAfterTopos() {
        let engraving = makeEngraving(
            date: CivilDate(year: 2150, month: 1, day: 1)!,
            time: CivilClockTime(hour: 12, minute: 0)!
        )

        guard case let .unsupportedYear(partial, year) = Atlas().resolve(engraving) else {
            XCTFail("Expected unsupported CivilTime year")
            return
        }

        XCTAssertEqual(year, 2150)
        XCTAssertNotNil(partial.topos)
        XCTAssertNil(partial.tempus)
    }

    func testUnsupportedCalendarRemainsExplicitAfterTopos() {
        let engraving = makeEngraving(
            date: CivilDate(year: 1900, month: 1, day: 1, calendar: .julian)!,
            time: CivilClockTime(hour: 12, minute: 0)!
        )

        guard case let .unsupportedCalendar(partial, calendar) = Atlas().resolve(engraving) else {
            XCTFail("Expected unsupported CivilTime calendar")
            return
        }

        XCTAssertEqual(calendar, .julian)
        XCTAssertNotNil(partial.topos)
        XCTAssertNil(partial.tempus)
    }

    private func makeEngraving(
        date: CivilDate,
        time: CivilClockTime,
        location: String = "Madison, WI"
    ) -> Engraving {
        Engraving(
            subjectID: HermesSubjectID(rawValue: "atlas-tempus-stage-1")!,
            name: "Stage One",
            birthDate: date,
            birthTime: time,
            birthLocation: location
        )
    }

    private func found(
        _ resolution: EngravingAtlasResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Engraving {
        guard case let .found(engraving) = resolution else {
            XCTFail("Expected found resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return engraving
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
