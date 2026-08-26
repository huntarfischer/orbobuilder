import XCTest
@testable import OrboCore

final class HoraeControlsStage10Tests: XCTestCase {
    func testPureAbsoluteUTIntentEqualsSeekWithoutPointAddress() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(JulianDay(locate.bone.start.value + 0.375))

        let expected = try horae.seek(to: target)
        let output = try horae.respond(to: .seekUT(to: target))

        XCTAssertEqual(output, expected)
        XCTAssertEqual(output.julianDay, target)
        XCTAssertNil(output.controlState)
    }

    func testPositiveRelativeUTMovesExactRequestedAmount() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let current = try XCTUnwrap(JulianDay(locate.bone.start.value + 0.5))
        let offset = try XCTUnwrap(HoraeUTOffset(hours: 6))
        let expectedUT = try XCTUnwrap(JulianDay(current.value + 0.25))

        let output = try horae.shiftUT(from: current, by: offset)
        let expected = try horae.seek(to: expectedUT)

        XCTAssertEqual(output, expected)
        XCTAssertEqual(output.julianDay, expectedUT)
        XCTAssertNil(output.controlState)
    }

    func testNegativeRelativeUTMovesExactRequestedAmount() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let current = try XCTUnwrap(JulianDay(locate.bone.start.value + 0.5))
        let offset = try XCTUnwrap(HoraeUTOffset(hours: -6))
        let expectedUT = try XCTUnwrap(JulianDay(current.value - 0.25))

        let output = try horae.respond(to: .shiftUT(from: current, by: offset))
        let expected = try horae.seek(to: expectedUT)

        XCTAssertEqual(output, expected)
        XCTAssertEqual(output.julianDay, expectedUT)
        XCTAssertNil(output.controlState)
    }

    func testUTOffsetVocabularyExpressesEquivalentUnits() throws {
        let seconds = try XCTUnwrap(HoraeUTOffset(seconds: 21_600))
        let minutes = try XCTUnwrap(HoraeUTOffset(minutes: 360))
        let hours = try XCTUnwrap(HoraeUTOffset(hours: 6))
        let days = try XCTUnwrap(HoraeUTOffset(days: 0.25))

        XCTAssertEqual(seconds, minutes)
        XCTAssertEqual(minutes, hours)
        XCTAssertEqual(hours, days)
    }

    func testForwardThenEqualBackwardReturnsExactlyToStartingOutput() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let start = try XCTUnwrap(JulianDay(locate.bone.start.value + 0.375))
        let forwardOffset = try XCTUnwrap(HoraeUTOffset(hours: 6))
        let backwardOffset = try XCTUnwrap(HoraeUTOffset(hours: -6))
        let startingOutput = try horae.seek(to: start)

        let forward = try horae.shiftUT(from: start, by: forwardOffset)
        let returned = try horae.shiftUT(
            from: forward.julianDay,
            by: backwardOffset
        )

        XCTAssertEqual(returned, startingOutput)
    }

    func testConsumerCanChainRelativeMovesWithoutHoraeRetainingState() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let start = try XCTUnwrap(JulianDay(locate.bone.start.value + 0.125))
        let offset = try XCTUnwrap(HoraeUTOffset(hours: 6))

        let first = try horae.respond(to: .shiftUT(from: start, by: offset))
        let second = try horae.respond(to: .shiftUT(
            from: first.julianDay,
            by: offset
        ))
        let expectedUT = try XCTUnwrap(JulianDay(start.value + 0.5))
        let expected = try Horae(locate: locate).seek(to: expectedUT)

        XCTAssertEqual(second, expected)
        XCTAssertNil(first.controlState)
        XCTAssertNil(second.controlState)
    }

    func testRelativeUTBeforeBoneStartFailsWithoutClampOrWrap() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let offset = try XCTUnwrap(HoraeUTOffset(seconds: -1))

        XCTAssertThrowsError(
            try horae.respond(to: .shiftUT(
                from: locate.bone.start,
                by: offset
            ))
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    func testRelativeUTAtEndExclusiveFailsWithoutClampOrWrap() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let current = try XCTUnwrap(JulianDay(locate.bone.end.value - 0.25))
        let offset = try XCTUnwrap(HoraeUTOffset(hours: 6))

        XCTAssertThrowsError(
            try horae.respond(to: .shiftUT(
                from: current,
                by: offset
            ))
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    func testExistingBodyPinnedUTControlRemainsPointAddressControl() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(JulianDay(locate.bone.start.value + 0.375))

        let direct = try horae.driveUT(to: target, body: .mercury)
        let intent = try horae.respond(to: .driveUT(to: target, body: .mercury))
        let state = try XCTUnwrap(intent.controlState)

        XCTAssertEqual(intent, direct)
        XCTAssertEqual(state.address.body, .mercury)
        XCTAssertEqual(state.address.julianDay, target)
        XCTAssertEqual(state.bodyRole, .pinned)
        XCTAssertEqual(state.directionalDegreeRole, .resolved)
        XCTAssertEqual(state.julianDayRole, .driven)
    }

    private func makeLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_000.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_000.5))
        let end = try XCTUnwrap(JulianDay(2_500_001.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let physical = Double(index) * 20
            let step = OrboSpineContract.supportDegrees(for: body) * 0.5
            supports.append(coordinate(
                body,
                physicalDegrees: physical,
                at: start
            ))
            supports.append(coordinate(
                body,
                physicalDegrees: physical + step,
                at: midpoint
            ))
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
