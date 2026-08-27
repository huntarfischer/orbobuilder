import XCTest
@testable import OrboCore

final class ChronosStage3Tests: XCTestCase {
    func testStationQueryReadsPreparedLibraryMomentsForOneBodyInOrder() throws {
        let library = try makeLibrary()

        let answer = try resolved(
            Chronos.resolveStations(body: .mercury, using: library)
        )

        XCTAssertEqual(answer.hits.count, 2)
        XCTAssertEqual(
            try moments(from: answer).map(\.value),
            [2_460_010, 2_460_030]
        )
        XCTAssertTrue(answer.hits.allSatisfy {
            $0.fact == .station(body: .mercury)
                && $0.source?.rawValue == "library:stations"
        })
    }

    func testStationQueryReturnsResolvedEmptyAnswerWhenBodyHasNoPreparedRows() throws {
        let answer = try resolved(
            Chronos.resolveStations(body: .venus, using: try makeLibrary())
        )

        XCTAssertTrue(answer.hits.isEmpty)
    }

    func testShellQueryReturnsOnePreparedHalfOpenInterval() throws {
        let library = try makeLibrary()
        let id = try XCTUnwrap(OrboSpineShellID(family: .wave, ordinal: 12))

        let answer = try resolved(
            Chronos.resolveShell(id, using: library)
        )

        XCTAssertEqual(answer.hits.count, 1)
        let hit = try XCTUnwrap(answer.hits.first)
        guard case let .interval(interval) = hit.address else {
            return XCTFail("Expected one Chronos interval")
        }

        XCTAssertEqual(interval.start.value, 2_460_000)
        XCTAssertEqual(interval.endExclusive.value, 2_460_100)
        XCTAssertEqual(hit.fact, .shell(id))
        XCTAssertEqual(hit.source?.rawValue, "library:wave")
    }

    func testShellQueryReturnsResolvedEmptyAnswerForUnknownIdentity() throws {
        let missing = try XCTUnwrap(
            OrboSpineShellID(family: .wave, ordinal: 99)
        )
        let answer = try resolved(
            Chronos.resolveShell(missing, using: try makeLibrary())
        )

        XCTAssertTrue(answer.hits.isEmpty)
    }

    private func makeLibrary() throws -> OrboSpineLibraryCatalog {
        let mercuryLate = try station(.mercury, at: 2_460_030, degree: 18)
        let mercuryEarly = try station(.mercury, at: 2_460_010, degree: 12)
        let mars = try station(.mars, at: 2_460_020, degree: 30)
        let waveID = try XCTUnwrap(
            OrboSpineShellID(family: .wave, ordinal: 12)
        )
        let shell = try XCTUnwrap(
            OrboSpineShellInterval(
                id: waveID,
                start: try XCTUnwrap(JulianDay(2_460_000)),
                end: try XCTUnwrap(JulianDay(2_460_100))
            )
        )

        return OrboSpineLibraryCatalog(
            stations: [mercuryLate, mars, mercuryEarly],
            shellIntervals: [shell]
        )
    }

    private func station(
        _ body: MundaneBody,
        at value: Double,
        degree: Double
    ) throws -> OrboSpineStation {
        try XCTUnwrap(
            OrboSpineStation(
                body: body,
                physicalDegrees: degree,
                julianDay: try XCTUnwrap(JulianDay(value)),
                laneBefore: .direct,
                laneAfter: .retrograde
            )
        )
    }

    private func resolved(
        _ resolution: ChronosResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> ChronosAnswer {
        guard case let .resolved(answer) = resolution else {
            XCTFail(
                "Expected resolved Chronos answer, got \(resolution)",
                file: file,
                line: line
            )
            throw TestError.unexpectedResolution
        }
        return answer
    }

    private func moments(
        from answer: ChronosAnswer,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [JulianDay] {
        try answer.hits.map { hit in
            guard case let .moment(julianDay) = hit.address else {
                XCTFail("Expected Chronos moment", file: file, line: line)
                throw TestError.unexpectedAddress
            }
            return julianDay
        }
    }

    private enum TestError: Error {
        case unexpectedResolution
        case unexpectedAddress
    }
}
