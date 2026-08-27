import XCTest
@testable import OrboCore

final class ClothoStage4Tests: XCTestCase {
    func testClothoRequiresResolvedToposBeforeAskingChronos() throws {
        let engraving = OrboOnboarding.complete(
            subjectID: HermesSubjectID(rawValue: "subject.native")!,
            name: "Traveler",
            birthDate: CivilDate(year: 1990, month: 5, day: 17)!,
            birthTime: CivilClockTime(hour: 14, minute: 32)!,
            birthLocation: "Madison, WI"
        ).contents

        XCTAssertThrowsError(try Clotho.resolveCivilMoment(for: engraving)) { error in
            XCTAssertEqual(error as? ClothoFailure, .unresolvedTopos)
        }
        XCTAssertNil(engraving.topos)
        XCTAssertNil(engraving.astroDNA)
    }

    func testClothoPreservesBothLawfulChronosMomentsForRepeatedCivilTime() throws {
        let date = try XCTUnwrap(CivilDate(year: 2024, month: 11, day: 3))
        let time = try XCTUnwrap(CivilClockTime(hour: 1, minute: 30))
        let unfinished = OrboOnboarding.complete(
            subjectID: HermesSubjectID(rawValue: "subject.repeated-time")!,
            name: "Traveler",
            birthDate: date,
            birthTime: time,
            birthLocation: "Madison, WI"
        ).contents

        let engraving: Engraving
        switch Atlas().resolve(unfinished) {
        case let .found(resolved):
            engraving = resolved
        case let .ambiguous(topoi):
            XCTFail("Madison unexpectedly resolved ambiguously: \(topoi)")
            return
        case .notFound:
            XCTFail("Madison unexpectedly failed Atlas resolution")
            return
        }

        let timezone = try XCTUnwrap(engraving.topos?.place.timezone)
        let answer = try resolved(Clotho.resolveCivilMoment(for: engraving))

        XCTAssertEqual(answer.hits.count, 2)
        let first = try moment(from: answer.hits[0])
        let second = try moment(from: answer.hits[1])
        XCTAssertLessThan(first.value, second.value)
        XCTAssertEqual(second.value - first.value, 1.0 / 24.0, accuracy: 0.000_000_01)

        for hit in answer.hits {
            XCTAssertEqual(hit.fact, .civilMoment(date: date, time: time, timezone: timezone))
            XCTAssertEqual(hit.source?.rawValue, "civil-time")
        }
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
