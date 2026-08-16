import XCTest
@testable import OrboCore

final class CivilTimeTests: XCTestCase {
    func testCivilVocabularyRejectsInvalidDatesTimesAndOffsets() {
        XCTAssertNotNil(CivilDate(year: 2000, month: 2, day: 29))
        XCTAssertNil(CivilDate(year: 1900, month: 2, day: 29))
        XCTAssertNotNil(CivilDate(year: 1900, month: 2, day: 29, calendar: .julian))
        XCTAssertNil(CivilDate(year: 2026, month: 13, day: 1))
        XCTAssertNil(CivilDate(year: 2026, month: 4, day: 31))

        XCTAssertNotNil(CivilClockTime(hour: 23, minute: 59, second: 59))
        XCTAssertNil(CivilClockTime(hour: 24, minute: 0))
        XCTAssertNil(CivilClockTime(hour: 12, minute: 60))
        XCTAssertNil(CivilClockTime(hour: 12, minute: 0, second: 60))

        XCTAssertNotNil(UTCOffset(secondsEast: -86_400))
        XCTAssertNotNil(UTCOffset(secondsEast: 86_400))
        XCTAssertNil(UTCOffset(secondsEast: 86_401))
        XCTAssertNil(UTCOffset(hoursEast: .infinity))
    }

    func testJulianDayKeepsGregorianAndJulianCalendarLawDistinct() {
        let utc = UTCOffset(secondsEast: 0)!
        let noon = CivilClockTime(hour: 12, minute: 0)!
        let j2000 = CivilTime.julianDay(
            date: CivilDate(year: 2000, month: 1, day: 1)!,
            time: noon,
            offset: utc
        )
        XCTAssertEqual(j2000.value, 2_451_545.0, accuracy: 0.000_000_001)

        let gregorian = CivilTime.julianDay(
            date: CivilDate(year: 120, month: 2, day: 7, calendar: .gregorian)!,
            time: CivilClockTime(hour: 18, minute: 35)!,
            offset: UTCOffset(secondsEast: 8_640)!
        )
        let julian = CivilTime.julianDay(
            date: CivilDate(year: 120, month: 2, day: 7, calendar: .julian)!,
            time: CivilClockTime(hour: 18, minute: 35)!,
            offset: UTCOffset(secondsEast: 8_640)!
        )
        XCTAssertEqual(gregorian.value - julian.value, 1.0, accuracy: 0.000_000_001)
    }

    func testPrototypeAndAAFParityFixture() throws {
        let fixture = try FixtureLoader.decode(
            ParityFixture.self,
            named: "civil-time-parity",
            kind: .parity
        )

        for row in fixture.zoneCases {
            let match = try resolved(
                CivilTime.resolve(
                    date: row.date,
                    time: row.time,
                    in: TimezoneIdentifier(row.timezone!)!
                )
            )
            XCTAssertEqual(match.offset.secondsEast, row.offsetSeconds)
            XCTAssertEqual(match.instant.julianDay.value, row.julianDay, accuracy: 0.000_000_01)
        }

        for row in fixture.fixedOffsetCases {
            let jd = CivilTime.julianDay(
                date: row.date,
                time: row.time,
                offset: UTCOffset(secondsEast: row.offsetSeconds)!
            )
            XCTAssertEqual(jd.value, row.julianDay, accuracy: 0.000_000_01)
        }
    }

    func testBirthplaceTimezoneResolves1985MadisonClockWithoutDeviceZone() throws {
        let match = try resolved(
            CivilTime.resolve(
                date: CivilDate(year: 1985, month: 4, day: 10)!,
                time: CivilClockTime(hour: 20, minute: 16)!,
                in: TimezoneIdentifier("America/Chicago")!
            )
        )

        XCTAssertEqual(match.offset.secondsEast, -21_600)
        XCTAssertEqual(match.instant.julianDay.value, 2_446_166.5944444444, accuracy: 0.000_000_01)
        XCTAssertEqual(match.timezone, TimezoneIdentifier("America/Chicago"))
        XCTAssertEqual(match.source, .timeZoneDatabase)
        XCTAssertEqual(match.isDaylightSavingTime, false)
    }

    func testHistoricalPre1970TimezoneRuleIsReadFromTimezoneHistory() throws {
        let match = try resolved(
            CivilTime.resolve(
                date: CivilDate(year: 1918, month: 7, day: 1)!,
                time: CivilClockTime(hour: 12, minute: 0)!,
                in: TimezoneIdentifier("America/New_York")!
            )
        )

        XCTAssertEqual(match.offset.secondsEast, -14_400)
        XCTAssertEqual(match.instant.julianDay.value, 2_421_776.1666666665, accuracy: 0.000_000_01)
        XCTAssertEqual(match.isDaylightSavingTime, true)
    }

    func testRepeatedFallBackClockTimeReturnsBothInstantsRatherThanChoosing() {
        let resolution = CivilTime.resolve(
            date: CivilDate(year: 2024, month: 11, day: 3)!,
            time: CivilClockTime(hour: 1, minute: 30)!,
            in: TimezoneIdentifier("America/Chicago")!
        )

        guard case let .ambiguous(first, second) = resolution else {
            return XCTFail("Expected an explicit ambiguous result, got \(resolution)")
        }

        XCTAssertEqual(first.offset.secondsEast, -18_000)
        XCTAssertEqual(second.offset.secondsEast, -21_600)
        XCTAssertEqual(
            second.instant.unixSecondsSince1970 - first.instant.unixSecondsSince1970,
            3_600,
            accuracy: 0.001
        )
    }

    func testSpringForwardGapReturnsNonexistentRatherThanShiftingClock() {
        let resolution = CivilTime.resolve(
            date: CivilDate(year: 2024, month: 3, day: 10)!,
            time: CivilClockTime(hour: 2, minute: 30)!,
            in: TimezoneIdentifier("America/Chicago")!
        )
        XCTAssertEqual(resolution, .nonexistent)
    }

    func testUnknownTimezoneNeverFallsBackToDeviceClock() {
        let zone = TimezoneIdentifier("Orbo/Not_A_Zone")!
        let resolution = CivilTime.resolve(
            date: CivilDate(year: 2026, month: 8, day: 16)!,
            time: CivilClockTime(hour: 12, minute: 0)!,
            in: zone
        )
        XCTAssertEqual(resolution, .unknownTimeZone(zone))
    }

    func testSupportedRangeIsExplicitAndAppliedBeforeTimezoneResolution() {
        XCTAssertEqual(CivilTime.supportedYearRange, 1700...2149)

        let early = CivilTime.resolve(
            date: CivilDate(year: 1699, month: 12, day: 31)!,
            time: CivilClockTime(hour: 12, minute: 0)!,
            in: TimezoneIdentifier("America/Chicago")!
        )
        let late = CivilTime.resolve(
            date: CivilDate(year: 2150, month: 1, day: 1)!,
            time: CivilClockTime(hour: 12, minute: 0)!,
            in: TimezoneIdentifier("America/Chicago")!
        )

        XCTAssertEqual(early, .unsupportedYear(1699))
        XCTAssertEqual(late, .unsupportedYear(2150))
    }

    func testFixedOffsetPathPreservesHistoricalAAFClockLaw() throws {
        let match = try resolved(
            CivilTime.resolve(
                date: CivilDate(year: 1783, month: 4, day: 3)!,
                time: CivilClockTime(hour: 20, minute: 30)!,
                fixedOffset: UTCOffset(secondsEast: -17_760)!
            )
        )

        XCTAssertEqual(match.source, .fixedOffset)
        XCTAssertNil(match.timezone)
        XCTAssertNil(match.isDaylightSavingTime)
        XCTAssertEqual(match.offset.clockDescription, "-04:56")
        XCTAssertEqual(match.instant.julianDay.value, 2_372_380.5597222224, accuracy: 0.000_000_01)
    }

    func testLocalMeanTimeIsDerivedOnlyFromGeographicLongitude() throws {
        let longitude = GeographicLongitude(-89.40)!
        let offset = UTCOffset.localMeanTime(for: longitude)
        XCTAssertEqual(offset.secondsEast, -21_456)
        XCTAssertEqual(offset.clockDescription, "-05:57:36")

        let match = try resolved(
            CivilTime.resolveLocalMeanTime(
                date: CivilDate(year: 1783, month: 4, day: 3)!,
                time: CivilClockTime(hour: 20, minute: 30)!,
                longitude: longitude
            )
        )
        XCTAssertEqual(match.source, .localMeanTime)
        XCTAssertEqual(match.offset, offset)
    }

    func testTimezoneDatabaseVersionAndSourceAreExplicit() throws {
        XCTAssertFalse(
            CivilTime.timeZoneDataVersion
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        )

        let match = try resolved(
            CivilTime.resolve(
                date: CivilDate(year: 2026, month: 7, day: 1)!,
                time: CivilClockTime(hour: 12, minute: 0)!,
                in: TimezoneIdentifier("America/Chicago")!
            )
        )
        XCTAssertEqual(match.source, .timeZoneDatabase)
        XCTAssertEqual(match.timezone?.rawValue, "America/Chicago")
    }

    private func resolved(
        _ resolution: CivilTimeResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> CivilTimeMatch {
        guard case let .resolved(match) = resolution else {
            XCTFail("Expected resolved Civil Time, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return match
    }

    private struct ParityFixture: Decodable {
        let zoneCases: [ParityRow]
        let fixedOffsetCases: [ParityRow]
    }

    private struct ParityRow: Decodable {
        let calendar: CivilCalendar?
        let year: Int
        let month: Int
        let day: Int
        let hour: Int
        let minute: Int
        let second: Int
        let timezone: String?
        let offsetSeconds: Int
        let julianDay: Double

        var date: CivilDate {
            CivilDate(
                year: year,
                month: month,
                day: day,
                calendar: calendar ?? .gregorian
            )!
        }

        var time: CivilClockTime {
            CivilClockTime(hour: hour, minute: minute, second: second)!
        }
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
