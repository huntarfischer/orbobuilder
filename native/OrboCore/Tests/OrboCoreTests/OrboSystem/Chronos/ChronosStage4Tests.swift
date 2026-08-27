import XCTest
@testable import OrboCore

final class ChronosStage4Tests: XCTestCase {
    func testScopeIsHalfOpenForMomentAddresses() throws {
        let answer = stationAnswer([10, 20, 30])
        let scope = try XCTUnwrap(ChronosInterval(
            start: try jd(10),
            endExclusive: try jd(30)
        ))
        let query = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury),
            scope: .range(scope)
        ))

        let selected = Chronos.apply(query, to: answer)

        XCTAssertEqual(try momentValues(selected), [10, 20])
    }

    func testScopeSelectsOverlappingIntervalWithoutClippingCanonicalAddress() throws {
        let shell = try shellID(.wave, 12)
        let canonical = try XCTUnwrap(ChronosInterval(
            start: try jd(5),
            endExclusive: try jd(15)
        ))
        let answer = ChronosAnswer(hits: [
            ChronosHit(address: .interval(canonical), fact: .shell(shell))
        ])
        let scope = try XCTUnwrap(ChronosInterval(
            start: try jd(10),
            endExclusive: try jd(20)
        ))
        let query = try XCTUnwrap(ChronosQuery(
            predicate: .shell(shell),
            scope: .range(scope)
        ))

        let selected = Chronos.apply(query, to: answer)

        XCTAssertEqual(selected.hits.count, 1)
        XCTAssertEqual(selected.hits.first?.address, .interval(canonical))
    }

    func testBeforeAndAfterAreStrictTemporalRelations() throws {
        let answer = stationAnswer([10, 20, 30])
        let anchor = try jd(20)
        let before = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury),
            relation: .before,
            anchor: anchor
        ))
        let after = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury),
            relation: .after,
            anchor: anchor
        ))

        XCTAssertEqual(try momentValues(Chronos.apply(before, to: answer)), [10])
        XCTAssertEqual(try momentValues(Chronos.apply(after, to: answer)), [30])
    }

    func testContainingUsesHalfOpenIntervalLaw() throws {
        let shell = try shellID(.frame, 1)
        let interval = try XCTUnwrap(ChronosInterval(
            start: try jd(10),
            endExclusive: try jd(20)
        ))
        let answer = ChronosAnswer(hits: [
            ChronosHit(address: .interval(interval), fact: .shell(shell))
        ])
        let atStart = try XCTUnwrap(ChronosQuery(
            predicate: .shell(shell),
            relation: .containing,
            anchor: try jd(10)
        ))
        let atEnd = try XCTUnwrap(ChronosQuery(
            predicate: .shell(shell),
            relation: .containing,
            anchor: try jd(20)
        ))

        XCTAssertEqual(Chronos.apply(atStart, to: answer).hits.count, 1)
        XCTAssertTrue(Chronos.apply(atEnd, to: answer).hits.isEmpty)
    }

    func testPreviousAndNextSelectClosestLawfulSideWithoutChoosingNow() throws {
        let answer = stationAnswer([10, 20, 30, 40])
        let anchor = try jd(25)
        let previous = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury),
            relation: .previous,
            anchor: anchor
        ))
        let next = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury),
            relation: .next,
            anchor: anchor
        ))

        XCTAssertEqual(try momentValues(Chronos.apply(previous, to: answer)), [20])
        XCTAssertEqual(try momentValues(Chronos.apply(next, to: answer)), [30])
    }

    func testNearestPreservesEquidistantMultiplicity() throws {
        let answer = stationAnswer([20, 30, 50])
        let query = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury),
            relation: .nearest,
            anchor: try jd(25)
        ))

        let selected = Chronos.apply(query, to: answer)

        XCTAssertEqual(try momentValues(selected), [20, 30])
    }

    func testOrderAndLimitAreAppliedAfterTemporalSelection() throws {
        let answer = stationAnswer([10, 20, 30, 40])
        let query = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury),
            order: .descending,
            limit: 2
        ))

        let selected = Chronos.apply(query, to: answer)

        XCTAssertEqual(selected.order, .descending)
        XCTAssertEqual(try momentValues(selected), [40, 30])
    }

    func testQueryPredicateSelectsOnlyItsOwnFactualIdentity() throws {
        let answer = ChronosAnswer(hits: [
            ChronosHit(
                address: .moment(try jd(10)),
                fact: .station(body: .mercury)
            ),
            ChronosHit(
                address: .moment(try jd(20)),
                fact: .station(body: .mars)
            ),
        ])
        let query = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury)
        ))

        let selected = Chronos.apply(query, to: answer)

        XCTAssertEqual(try momentValues(selected), [10])
        XCTAssertEqual(selected.hits.first?.fact, .station(body: .mercury))
    }

    func testOperatorsPreserveUnresolvedSourceOutcomeWithoutInventingTruth() throws {
        let query = try XCTUnwrap(ChronosQuery(
            predicate: .station(body: .mercury)
        ))
        let unresolved = ChronosResolution.unresolved(.nonexistentCivilTime)

        XCTAssertEqual(Chronos.apply(query, to: unresolved), unresolved)
    }

    private func stationAnswer(_ values: [Double]) -> ChronosAnswer {
        ChronosAnswer(hits: values.map { value in
            ChronosHit(
                address: .moment(JulianDay(value)!),
                fact: .station(body: .mercury)
            )
        })
    }

    private func momentValues(
        _ answer: ChronosAnswer,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [Double] {
        try answer.hits.map { hit in
            guard case let .moment(julianDay) = hit.address else {
                XCTFail("Expected Chronos moment", file: file, line: line)
                throw TestError.unexpectedAddress
            }
            return julianDay.value
        }
    }

    private func jd(_ value: Double) throws -> JulianDay {
        try XCTUnwrap(JulianDay(value))
    }

    private func shellID(
        _ family: OrboSpineShellFamily,
        _ ordinal: Int
    ) throws -> OrboSpineShellID {
        try XCTUnwrap(OrboSpineShellID(family: family, ordinal: ordinal))
    }

    private enum TestError: Error {
        case unexpectedAddress
    }
}
