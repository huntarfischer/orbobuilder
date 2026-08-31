import XCTest
@testable import OrboCore

final class NatalSpineActIIIBeat3ChronosTests: XCTestCase {
    func testChronosIndexesTheFinishedSpineIdentityWithoutReplacingIt() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let before = spine
        let index = Chronos.indexNatalSpine(spine)

        XCTAssertEqual(index.subjectID, spine.subjectID)
        XCTAssertEqual(index.packageID, spine.packageID)
        XCTAssertEqual(index.bounds, spine.bounds)
        XCTAssertEqual(spine, before)
    }

    func testAllHousePassagesComeFromThemisIntervals() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let sample = try XCTUnwrap(spine.candidate.themis.first)
        let predicate = ChronosPredicate.natalHousePassage(
            body: sample.span.body,
            house: sample.span.house
        )
        let query = try XCTUnwrap(ChronosQuery(predicate: predicate))
        let answer = try resolved(Chronos.resolveNatalSpine(query, using: index))
        let expected = spine.candidate.themis.filter {
            $0.span.body == sample.span.body && $0.span.house == sample.span.house
        }

        XCTAssertEqual(answer.hits.count, expected.count)
        XCTAssertEqual(
            answer.hits.map(\.source?.rawValue),
            expected.map { "natal-spine:themis:\($0.sourceRow)" }
        )
    }

    func testExactContainingLookupFindsTheHousePassageAtOneUT() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let sample = try XCTUnwrap(spine.candidate.themis.first)
        let anchor = JulianDay((sample.span.start.value + sample.span.end.value) / 2)!
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalHousePassage(
                    body: sample.span.body,
                    house: sample.span.house
                ),
                relation: .containing,
                anchor: anchor
            )
        )
        let answer = try resolved(Chronos.resolveNatalSpine(query, using: index))

        XCTAssertFalse(answer.hits.isEmpty)
        XCTAssertTrue(answer.hits.allSatisfy { hit in
            guard case let .interval(interval) = hit.address else { return false }
            return anchor.value >= interval.start.value
                && anchor.value < interval.endExclusive.value
        })
    }

    func testRangeLookupSelectsRingRealizationsInsideTheRequestedWindow() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let event = try XCTUnwrap(spine.candidate.oceanus.first?.realization)
        let range = try XCTUnwrap(
            ChronosInterval(
                start: JulianDay(event.occurrence.julianDay.value - 1)!,
                endExclusive: JulianDay(event.occurrence.julianDay.value + 1)!
            )
        )
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalRingRealization(
                    mundaneBody: nil,
                    natalGene: nil,
                    relation: nil
                ),
                scope: .range(range)
            )
        )
        let answer = try resolved(Chronos.resolveNatalSpine(query, using: index))

        XCTAssertTrue(answer.hits.contains { hit in
            abs(hit.address.start.value - event.occurrence.julianDay.value) <= 1e-9
        })
        XCTAssertTrue(answer.hits.allSatisfy {
            $0.address.start.value >= range.start.value
                && $0.address.start.value < range.endExclusive.value
        })
    }

    func testRingQueryCanNameMundaneBodyNatalTargetAndRelation() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let event = try XCTUnwrap(spine.candidate.oceanus.first?.realization)
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalRingRealization(
                    mundaneBody: event.mundaneBody,
                    natalGene: event.natalGene,
                    relation: event.relation
                )
            )
        )
        let answer = try resolved(Chronos.resolveNatalSpine(query, using: index))

        XCTAssertEqual(answer.hits.count, 1)
        XCTAssertEqual(answer.hits.first?.address, .moment(event.occurrence.julianDay))
    }

    func testHouseCrossingsCanBeQueriedBetweenTwoTimes() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let crossing = try XCTUnwrap(
            spine.candidate.rhea.compactMap { forged -> NatalSpineHouseCrossing? in
                guard case let .houseCrossing(value) = forged.qualification.source else {
                    return nil
                }
                return value
            }.first
        )
        let range = try XCTUnwrap(
            ChronosInterval(
                start: JulianDay(crossing.occurrence.value - 1)!,
                endExclusive: JulianDay(crossing.occurrence.value + 1)!
            )
        )
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalHouseCrossing(
                    body: nil,
                    fromHouse: nil,
                    toHouse: nil
                ),
                scope: .range(range)
            )
        )
        let answer = try resolved(Chronos.resolveNatalSpine(query, using: index))

        XCTAssertTrue(answer.hits.contains { $0.address == .moment(crossing.occurrence) })
    }

    func testMaterConditionSupportsAllFirstLastAndCount() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let firstTemper = try XCTUnwrap(spine.candidate.rhea.first?.qualification.temper)
        let condition: NatalSpineMaterCondition = firstTemper.sectDay ? .sectDay : .sectNight
        let predicate = ChronosPredicate.natalMaterCondition(condition: condition, body: nil)
        let allQuery = try XCTUnwrap(ChronosQuery(predicate: predicate))
        let all = try resolved(Chronos.resolveNatalSpine(allQuery, using: index))

        XCTAssertFalse(all.hits.isEmpty)
        XCTAssertEqual(try Chronos.countNatalSpine(allQuery, using: index), all.hits.count)

        let firstQuery = try XCTUnwrap(
            ChronosQuery(predicate: predicate, order: .ascending, limit: 1)
        )
        let first = try resolved(Chronos.resolveNatalSpine(firstQuery, using: index))
        XCTAssertEqual(first.hits.first, all.hits.first)

        let lastQuery = try XCTUnwrap(
            ChronosQuery(predicate: predicate, order: .descending, limit: 1)
        )
        let last = try resolved(Chronos.resolveNatalSpine(lastQuery, using: index))
        XCTAssertEqual(last.hits.first?.address, all.hits.last?.address)
    }

    func testOccurrenceQueryCanAskForNextMaterFact() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let firstTemper = try XCTUnwrap(spine.candidate.rhea.first?.qualification.temper)
        let condition: NatalSpineMaterCondition = firstTemper.sectDay ? .sectDay : .sectNight
        let predicate = ChronosPredicate.natalMaterCondition(condition: condition, body: nil)
        let allQuery = try XCTUnwrap(ChronosQuery(predicate: predicate))
        let all = try resolved(Chronos.resolveNatalSpine(allQuery, using: index))
        let firstAddress = try XCTUnwrap(all.hits.first?.address)
        let anchor = JulianDay(firstAddress.start.value - 0.5)!
        let nextQuery = try XCTUnwrap(
            ChronosQuery(
                predicate: predicate,
                relation: .next,
                anchor: anchor
            )
        )
        let next = try resolved(Chronos.resolveNatalSpine(nextQuery, using: index))

        XCTAssertEqual(next.hits.first?.address, all.hits.first?.address)
    }

    func testExplicitAbsenceIsResolvedAsAnEmptyAnswer() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let event = try XCTUnwrap(spine.candidate.oceanus.first?.realization)
        let absentRelation = try XCTUnwrap(RingMark.allCases.first { $0 != event.relation })
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalRingRealization(
                    mundaneBody: event.mundaneBody,
                    natalGene: event.natalGene,
                    relation: absentRelation
                )
            )
        )
        let answer = try resolved(Chronos.resolveNatalSpine(query, using: index))

        XCTAssertTrue(answer.hits.isEmpty)
    }

    func testNonNatalPredicateCannotBeSilentlyAnsweredByNatalIndex() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let index = Chronos.indexNatalSpine(spine)
        let query = try XCTUnwrap(
            ChronosQuery(predicate: .station(body: .saturn))
        )

        XCTAssertThrowsError(try Chronos.resolveNatalSpine(query, using: index)) { error in
            XCTAssertEqual(error as? NatalSpineChronosFailure, .unsupportedPredicate)
        }
    }

    private func resolved(_ resolution: ChronosResolution) throws -> ChronosAnswer {
        switch resolution {
        case let .resolved(answer): return answer
        case let .unresolved(reason):
            XCTFail("Unexpected unresolved Chronos result: \(reason)")
            return ChronosAnswer(hits: [])
        }
    }
}
