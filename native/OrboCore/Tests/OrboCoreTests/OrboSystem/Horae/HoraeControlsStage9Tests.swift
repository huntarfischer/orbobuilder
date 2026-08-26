import XCTest
@testable import OrboCore

final class HoraeControlsStage9Tests: XCTestCase {
    func testNextOccurrenceFromBetweenOccurrencesChoosesFirstStrictlyAfterAnchor() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let occurrences = try orderedOccurrences(locate, degree: degree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 4)

        let anchor = try midpoint(occurrences[1].julianDay, occurrences[2].julianDay)
        let output = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: anchor,
            direction: .next
        )

        try assertPinnedOccurrenceOutput(
            output,
            equals: occurrences[2],
            horae: horae
        )
    }

    func testPreviousOccurrenceFromBetweenOccurrencesChoosesFirstStrictlyBeforeAnchor() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let occurrences = try orderedOccurrences(locate, degree: degree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 4)

        let anchor = try midpoint(occurrences[1].julianDay, occurrences[2].julianDay)
        let output = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: anchor,
            direction: .previous
        )

        try assertPinnedOccurrenceOutput(
            output,
            equals: occurrences[1],
            horae: horae
        )
    }

    func testExactOccurrenceAnchorSkipsCurrentOccurrenceInBothDirections() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let occurrences = try orderedOccurrences(locate, degree: degree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 4)
        let anchor = occurrences[1].julianDay

        let next = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: anchor,
            direction: .next
        )
        let previous = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: anchor,
            direction: .previous
        )

        XCTAssertEqual(next.julianDay, occurrences[2].julianDay)
        XCTAssertEqual(previous.julianDay, occurrences[0].julianDay)
    }

    func testOccurrenceNavigationDoesNotWrapPastBoneSides() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let occurrences = try orderedOccurrences(locate, degree: degree)
        XCTAssertFalse(occurrences.isEmpty)
        let startAnchor = locate.bone.start
        let endAnchor = try XCTUnwrap(JulianDay(locate.bone.end.value - 0.000_001))

        XCTAssertThrowsError(
            try horae.navigateOccurrence(
                of: .moon,
                at: degree,
                from: startAnchor,
                direction: .previous
            )
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrenceInDirection(
                    body: .moon,
                    directionalDegree: degree,
                    from: startAnchor,
                    direction: .previous
                )
            )
        }

        XCTAssertThrowsError(
            try horae.navigateOccurrence(
                of: .moon,
                at: degree,
                from: endAnchor,
                direction: .next
            )
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrenceInDirection(
                    body: .moon,
                    directionalDegree: degree,
                    from: endAnchor,
                    direction: .next
                )
            )
        }
    }

    func testForwardAndBackwardTraversalAreDeterministic() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let occurrences = try orderedOccurrences(locate, degree: degree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 4)

        let first = occurrences[1].julianDay
        let forward = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: first,
            direction: .next
        )
        let backward = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: forward.julianDay,
            direction: .previous
        )

        XCTAssertEqual(forward.julianDay, occurrences[2].julianDay)
        XCTAssertEqual(backward.julianDay, first)

        let repeatedForward = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: first,
            direction: .next
        )
        XCTAssertEqual(repeatedForward, forward)
    }

    func testOccurrenceIntentMatchesDirectHoraeCall() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let occurrences = try orderedOccurrences(locate, degree: degree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 3)
        let anchor = occurrences[1].julianDay

        let direct = try horae.navigateOccurrence(
            of: .moon,
            at: degree,
            from: anchor,
            direction: .next
        )
        let intent = try horae.respond(to: .navigateOccurrence(
            body: .moon,
            directionalDegree: degree,
            from: anchor,
            direction: .next
        ))

        XCTAssertEqual(intent, direct)
    }

    private func assertPinnedOccurrenceOutput(
        _ output: HoraeOutput,
        equals occurrence: OrboSpineOccurrence,
        horae: Horae,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let seek = try horae.seek(to: occurrence.julianDay)
        let state = try XCTUnwrap(output.controlState, file: file, line: line)

        XCTAssertEqual(output.julianDay, occurrence.julianDay, file: file, line: line)
        XCTAssertEqual(output.celestial, seek.celestial, file: file, line: line)
        XCTAssertEqual(output.terra, seek.terra, file: file, line: line)
        XCTAssertEqual(state.address.body, .moon, file: file, line: line)
        XCTAssertEqual(state.address.directionalDegree, occurrence.directionalDegree, file: file, line: line)
        XCTAssertEqual(state.address.julianDay, occurrence.julianDay, file: file, line: line)
        XCTAssertEqual(state.bodyRole, .pinned, file: file, line: line)
        XCTAssertEqual(state.directionalDegreeRole, .pinned, file: file, line: line)
        XCTAssertEqual(state.julianDayRole, .driven, file: file, line: line)
    }

    private func orderedOccurrences(
        _ locate: OrboSpineLocate,
        degree: OrboSpineDirectionalDegree
    ) throws -> [OrboSpineOccurrence] {
        try locate.occurrences(of: .moon, at: degree).sorted {
            $0.julianDay.value < $1.julianDay.value
        }
    }

    private func midpoint(_ lhs: JulianDay, _ rhs: JulianDay) throws -> JulianDay {
        try XCTUnwrap(JulianDay((lhs.value + rhs.value) / 2))
    }

    private func targetDegree() -> OrboSpineDirectionalDegree {
        OrboSpineDirectionalDegree(
            physicalDegrees: 120,
            motion: .direct
        )!
    }

    private func makeRepeatingLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_000))
        let end = try XCTUnwrap(JulianDay(2_500_250))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let increment = OrboSpineContract.supportDegrees(for: body) * 0.5
            let startingPhysical = body == .moon ? 0 : Double(index) * 20

            for day in 0..<250 {
                let physical = normalized(
                    startingPhysical + increment * Double(day)
                )
                let julianDay = try XCTUnwrap(JulianDay(start.value + Double(day)))
                supports.append(coordinate(
                    body,
                    physicalDegrees: physical,
                    at: julianDay
                ))
            }
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110,
                tiltDegrees: 23.5,
                julianDay: end
            )),
        ]

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        )
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
}
