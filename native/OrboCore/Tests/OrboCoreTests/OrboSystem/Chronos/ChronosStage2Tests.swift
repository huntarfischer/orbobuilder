import XCTest
@testable import OrboCore

final class ChronosStage2Tests: XCTestCase {
    func testBodyStatePreservesEveryHoraeOccurrenceAsOrderedMoments() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let sampleUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let state = try locate.coordinate(of: .moon, at: sampleUT).directionalDegree

        let expected = try horae.occurrenceUTs(of: .moon, at: state)
        XCTAssertGreaterThanOrEqual(expected.count, 2)

        let answer = try resolved(
            Chronos.resolveBodyState(
                body: .moon,
                directionalDegree: state,
                using: horae
            )
        )

        XCTAssertEqual(try moments(from: answer), expected)
        XCTAssertEqual(answer.hits.count, expected.count)
        XCTAssertTrue(answer.hits.allSatisfy {
            $0.fact == .bodyState(body: .moon, directionalDegree: state)
                && $0.source?.rawValue == "horae-occurrence"
        })
    }

    func testBodyStateReturnsResolvedEmptyAnswerWhenStateNeverOccurs() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let unavailable = try XCTUnwrap(
            OrboSpineDirectionalDegree(
                physicalDegrees: 120,
                motion: .retrograde
            )
        )

        let answer = try resolved(
            Chronos.resolveBodyState(
                body: .moon,
                directionalDegree: unavailable,
                using: horae
            )
        )

        XCTAssertTrue(answer.hits.isEmpty)
    }

    func testBodyStateAnswersRemainInsideHoraeBoneDomain() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let sampleUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let state = try locate.coordinate(of: .moon, at: sampleUT).directionalDegree

        let answer = try resolved(
            Chronos.resolveBodyState(
                body: .moon,
                directionalDegree: state,
                using: horae
            )
        )
        let domain = horae.controlDomain

        for julianDay in try moments(from: answer) {
            XCTAssertGreaterThanOrEqual(julianDay.value, domain.start.value)
            XCTAssertLessThan(julianDay.value, domain.endExclusive.value)
        }
    }

    func testBodyStateQueryDoesNotMoveHoraePlane() throws {
        let locate = try XCTUnwrap(makeLocate())
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let horae = Horae(
            locate: locate,
            now: { AbsoluteInstant(julianDay: fixedUT)! }
        )
        let state = try locate.coordinate(of: .moon, at: fixedUT).directionalDegree
        let before = try horae.live()

        _ = try Chronos.resolveBodyState(
            body: .moon,
            directionalDegree: state,
            using: horae
        )

        let after = try horae.live()
        XCTAssertEqual(after, before)
        XCTAssertEqual(after.julianDay, fixedUT)
        XCTAssertNil(after.controlState)
    }

    func testBodyStatePreservesHoraeAuthorityFailure() throws {
        let locate = try XCTUnwrap(makeSunOnlyLocate())
        let horae = Horae(locate: locate)
        let state = try XCTUnwrap(
            OrboSpineDirectionalDegree(
                physicalDegrees: 10,
                motion: .direct
            )
        )

        XCTAssertThrowsError(
            try Chronos.resolveBodyState(
                body: .mercury,
                directionalDegree: state,
                using: horae
            )
        ) { error in
            XCTAssertEqual(
                error as? OrboSpineLocateError,
                .bodyUnavailable(.mercury)
            )
        }
    }

    private func makeLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_600_000))
        let end = try XCTUnwrap(JulianDay(2_600_160))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let increment = OrboSpineContract.supportDegrees(for: body) * 0.5
            let startingPhysical = Double(index) * 25

            for day in 0..<160 {
                let julianDay = try XCTUnwrap(
                    JulianDay(start.value + Double(day))
                )
                supports.append(
                    coordinate(
                        body,
                        physicalDegrees: normalized(
                            startingPhysical + increment * Double(day)
                        ),
                        at: julianDay
                    )
                )
            }
        }

        let terra = [
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 100,
                    tiltDegrees: 23.4,
                    julianDay: start
                )
            ),
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 110,
                    tiltDegrees: 23.5,
                    julianDay: end
                )
            ),
        ]

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        )
    }

    private func makeSunOnlyLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_700_000))
        let midpoint = try XCTUnwrap(JulianDay(2_700_000.5))
        let end = try XCTUnwrap(JulianDay(2_700_001))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        let supports = [
            coordinate(.sun, physicalDegrees: 10, at: start),
            coordinate(.sun, physicalDegrees: 15, at: midpoint),
        ]

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports
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

    private func normalized(_ physicalDegrees: Double) -> Double {
        let remainder = physicalDegrees.truncatingRemainder(dividingBy: 360)
        return remainder >= 0 ? remainder : remainder + 360
    }

    private func coordinate(
        _ body: MundaneBody,
        physicalDegrees: Double,
        at julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: .direct
            )!,
            julianDay: julianDay
        )
    }

    private enum TestError: Error {
        case unexpectedResolution
        case unexpectedAddress
    }
}
