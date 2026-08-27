import XCTest
@testable import OrboCore

final class ChronosStage0Tests: XCTestCase {
    func testAddressSupportsMomentAndValidatedHalfOpenInterval() throws {
        let moment = try XCTUnwrap(JulianDay(2_460_000.25))
        let start = try XCTUnwrap(JulianDay(2_460_100.0))
        let end = try XCTUnwrap(JulianDay(2_460_101.0))
        let interval = try XCTUnwrap(
            ChronosInterval(start: start, endExclusive: end)
        )

        XCTAssertEqual(ChronosAddress.moment(moment).start, moment)
        XCTAssertNil(ChronosAddress.moment(moment).endExclusive)
        XCTAssertEqual(ChronosAddress.interval(interval).start, start)
        XCTAssertEqual(ChronosAddress.interval(interval).endExclusive, end)
        XCTAssertNil(ChronosInterval(start: start, endExclusive: start))
        XCTAssertNil(ChronosInterval(start: end, endExclusive: start))
    }

    func testAnswerSupportsZeroOneManyAndOrdersTemporalAddresses() throws {
        let fact = ChronosFactIdentity.station(body: .mercury)
        let early = ChronosHit(
            address: .moment(try XCTUnwrap(JulianDay(10))),
            fact: fact
        )
        let middle = ChronosHit(
            address: .moment(try XCTUnwrap(JulianDay(20))),
            fact: fact
        )
        let late = ChronosHit(
            address: .moment(try XCTUnwrap(JulianDay(30))),
            fact: fact
        )

        XCTAssertTrue(ChronosAnswer(hits: []).hits.isEmpty)
        XCTAssertEqual(ChronosAnswer(hits: [middle]).hits, [middle])
        XCTAssertEqual(
            ChronosAnswer(hits: [late, early, middle]).hits,
            [early, middle, late]
        )
        XCTAssertEqual(
            ChronosAnswer(
                hits: [early, late, middle],
                order: .descending
            ).hits,
            [late, middle, early]
        )
    }

    func testEqualTemporalAddressesRetainInputOrder() throws {
        let instant = try XCTUnwrap(JulianDay(2_460_000))
        let first = ChronosHit(
            address: .moment(instant),
            fact: .station(body: .mercury)
        )
        let second = ChronosHit(
            address: .moment(instant),
            fact: .station(body: .mars)
        )

        XCTAssertEqual(
            ChronosAnswer(hits: [second, first]).hits,
            [second, first]
        )
    }

    func testQueryContractRequiresExplicitAnchorsAndPositiveLimits() throws {
        let predicate = ChronosPredicate.station(body: .mercury)
        let anchor = try XCTUnwrap(JulianDay(2_460_000))

        XCTAssertNotNil(ChronosQuery(predicate: predicate))
        XCTAssertNil(ChronosQuery(predicate: predicate, relation: .next))
        XCTAssertNil(ChronosQuery(
            predicate: predicate,
            relation: .all,
            anchor: anchor
        ))
        XCTAssertNotNil(ChronosQuery(
            predicate: predicate,
            relation: .next,
            anchor: anchor
        ))
        XCTAssertNil(ChronosQuery(predicate: predicate, limit: 0))
        XCTAssertNotNil(ChronosQuery(predicate: predicate, limit: 1))
    }

    func testResolutionDistinguishesEmptyTruthFromUnresolvedQuery() {
        let empty = ChronosResolution.resolved(ChronosAnswer(hits: []))
        let unresolved = ChronosResolution.unresolved(.nonexistentCivilTime)

        XCTAssertNotEqual(empty, unresolved)
    }

    func testMvpPredicateVocabularyContainsOnlyFactualQueryFamilies() throws {
        let date = try XCTUnwrap(CivilDate(year: 1985, month: 4, day: 10))
        let time = try XCTUnwrap(CivilClockTime(hour: 20, minute: 16))
        let timezone = try XCTUnwrap(
            TimezoneIdentifier(rawValue: "America/Chicago")
        )
        let state = try XCTUnwrap(OrboSpineDirectionalDegree(47.25))
        let shell = try XCTUnwrap(
            OrboSpineShellID(family: .wave, ordinal: 12)
        )

        let predicates: [ChronosPredicate] = [
            .civilMoment(date: date, time: time, timezone: timezone),
            .bodyState(body: .mars, directionalDegree: state),
            .station(body: .mercury),
            .shell(shell),
        ]

        XCTAssertEqual(predicates.count, 4)
        XCTAssertEqual(
            Set(ChronosRelation.allCases.map(\.rawValue)),
            Set([
                "all",
                "before",
                "after",
                "previous",
                "next",
                "nearest",
                "containing",
            ])
        )
    }

    func testCoreContractCarriesOnlyTemporalAndFactualFields() throws {
        let query = try XCTUnwrap(
            ChronosQuery(predicate: .station(body: .mercury))
        )
        let hit = ChronosHit(
            address: .moment(try XCTUnwrap(JulianDay(2_460_000))),
            fact: .station(body: .mercury),
            source: try XCTUnwrap(
                ChronosSourceReference(rawValue: "station-row:1")
            )
        )
        let answer = ChronosAnswer(hits: [hit])

        XCTAssertEqual(
            Set(Mirror(reflecting: query).children.compactMap(\.label)),
            Set(["predicate", "scope", "relation", "anchor", "order", "limit"])
        )
        XCTAssertEqual(
            Set(Mirror(reflecting: hit).children.compactMap(\.label)),
            Set(["address", "fact", "source"])
        )
        XCTAssertEqual(
            Set(Mirror(reflecting: answer).children.compactMap(\.label)),
            Set(["hits", "order"])
        )
    }
}
