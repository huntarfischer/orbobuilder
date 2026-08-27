import XCTest
@testable import OrboCore

final class ChronosStage1Tests: XCTestCase {
    func testOrdinaryCivilMomentBecomesOneCanonicalTemporalAddress() throws {
        let date = try XCTUnwrap(CivilDate(year: 1985, month: 4, day: 10))
        let time = try XCTUnwrap(CivilClockTime(hour: 20, minute: 16))
        let timezone = try XCTUnwrap(TimezoneIdentifier("America/Chicago"))

        let answer = try resolved(
            Chronos.resolveCivilMoment(
                date: date,
                time: time,
                in: timezone
            )
        )

        XCTAssertEqual(answer.hits.count, 1)
        let hit = try XCTUnwrap(answer.hits.first)
        guard case let .moment(julianDay) = hit.address else {
            return XCTFail("Expected one moment address")
        }

        XCTAssertEqual(julianDay.value, 2_446_166.5944444444, accuracy: 0.000_000_01)
        XCTAssertEqual(
            hit.fact,
            .civilMoment(date: date, time: time, timezone: timezone)
        )
        XCTAssertEqual(hit.source?.rawValue, "civil-time")
    }

    func testRepeatedCivilClockTimePreservesBothLawfulMomentsInOrder() throws {
        let resolution = Chronos.resolveCivilMoment(
            date: try XCTUnwrap(CivilDate(year: 2024, month: 11, day: 3)),
            time: try XCTUnwrap(CivilClockTime(hour: 1, minute: 30)),
            in: try XCTUnwrap(TimezoneIdentifier("America/Chicago"))
        )
        let answer = try resolved(resolution)

        XCTAssertEqual(answer.hits.count, 2)
        let first = try moment(from: answer.hits[0])
        let second = try moment(from: answer.hits[1])

        XCTAssertLessThan(first.value, second.value)
        XCTAssertEqual(second.value - first.value, 1.0 / 24.0, accuracy: 0.000_000_01)
    }

    func testNonexistentCivilClockTimeRemainsExplicitlyUnresolved() throws {
        let resolution = Chronos.resolveCivilMoment(
            date: try XCTUnwrap(CivilDate(year: 2024, month: 3, day: 10)),
            time: try XCTUnwrap(CivilClockTime(hour: 2, minute: 30)),
            in: try XCTUnwrap(TimezoneIdentifier("America/Chicago"))
        )

        XCTAssertEqual(resolution, .unresolved(.nonexistentCivilTime))
    }

    func testUnknownTimezoneRemainsExplicitlyUnresolved() throws {
        let timezone = try XCTUnwrap(TimezoneIdentifier("Orbo/Not_A_Zone"))
        let resolution = Chronos.resolveCivilMoment(
            date: try XCTUnwrap(CivilDate(year: 2026, month: 8, day: 16)),
            time: try XCTUnwrap(CivilClockTime(hour: 12, minute: 0)),
            in: timezone
        )

        XCTAssertEqual(resolution, .unresolved(.unknownTimeZone(timezone)))
    }

    func testUnsupportedYearRemainsExplicitlyUnresolved() throws {
        let resolution = Chronos.resolveCivilMoment(
            date: try XCTUnwrap(CivilDate(year: 1699, month: 12, day: 31)),
            time: try XCTUnwrap(CivilClockTime(hour: 12, minute: 0)),
            in: try XCTUnwrap(TimezoneIdentifier("America/Chicago"))
        )

        XCTAssertEqual(resolution, .unresolved(.unsupportedYear(1699)))
    }

    func testUnsupportedCalendarRemainsExplicitlyUnresolved() throws {
        let resolution = Chronos.resolveCivilMoment(
            date: try XCTUnwrap(
                CivilDate(year: 1900, month: 2, day: 28, calendar: .julian)
            ),
            time: try XCTUnwrap(CivilClockTime(hour: 12, minute: 0)),
            in: try XCTUnwrap(TimezoneIdentifier("America/Chicago"))
        )

        XCTAssertEqual(resolution, .unresolved(.unsupportedCalendar(.julian)))
    }

    private func resolved(
        _ resolution: ChronosResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> ChronosAnswer {
        guard case let .resolved(answer) = resolution else {
            XCTFail("Expected resolved Chronos answer, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return answer
    }

    private func moment(
        from hit: ChronosHit,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> JulianDay {
        guard case let .moment(julianDay) = hit.address else {
            XCTFail("Expected Chronos moment", file: file, line: line)
            throw TestError.unexpectedAddress
        }
        return julianDay
    }

    private enum TestError: Error {
        case unexpectedResolution
        case unexpectedAddress
    }
}
