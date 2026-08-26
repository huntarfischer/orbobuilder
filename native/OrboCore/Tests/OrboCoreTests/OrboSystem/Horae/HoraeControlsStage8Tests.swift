import XCTest
@testable import OrboCore

final class HoraeControlsStage8Tests: XCTestCase {
    func testDegreeLockedBodyDriveResolvesEachSelectedBodyToRealOccurrence() throws {
        let locate = try XCTUnwrap(makeDegreeLockedLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let anchor = try XCTUnwrap(JulianDay(locate.bone.start.value + 50))

        for body in [MundaneBody.mercury, .venus, .saturn] {
            let occurrences = try locate.occurrences(of: body, at: degree)
            XCTAssertFalse(occurrences.isEmpty)
            let expected = try XCTUnwrap(nearestOccurrence(in: occurrences, to: anchor))

            let output = try horae.respond(to: .driveBodyAtDegree(
                to: body,
                directionalDegree: degree,
                from: anchor
            ))
            let state = try XCTUnwrap(output.controlState)
            let seek = try horae.seek(to: expected.julianDay)

            XCTAssertEqual(output.julianDay, expected.julianDay)
            XCTAssertEqual(output.celestial, seek.celestial)
            XCTAssertEqual(output.terra, seek.terra)
            XCTAssertEqual(state.address.body, body)
            XCTAssertEqual(state.address.directionalDegree, expected.directionalDegree)
            XCTAssertEqual(state.address.julianDay, expected.julianDay)
            XCTAssertEqual(state.bodyRole, .driven)
            XCTAssertEqual(state.directionalDegreeRole, .pinned)
            XCTAssertEqual(state.julianDayRole, .resolved)
        }
    }

    func testDegreeLockedBodyDriveUsesSameContinuityLawForRepeatedOccurrences() throws {
        let locate = try XCTUnwrap(makeDegreeLockedLocate())
        let horae = Horae(locate: locate)
        let degree = targetDegree()
        let occurrences = try locate.occurrences(of: .sun, at: degree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 2)

        let firstAnchor = try XCTUnwrap(JulianDay(occurrences[0].julianDay.value + 0.01))
        let secondAnchor = try XCTUnwrap(JulianDay(occurrences[1].julianDay.value + 0.01))

        let first = try horae.driveBody(
            to: .sun,
            at: degree,
            from: firstAnchor
        )
        let second = try horae.driveBody(
            to: .sun,
            at: degree,
            from: secondAnchor
        )

        XCTAssertEqual(first.julianDay, occurrences[0].julianDay)
        XCTAssertEqual(second.julianDay, occurrences[1].julianDay)
    }

    func testDegreeLockedBodyDriveDoesNotInventUnavailableState() throws {
        let locate = try XCTUnwrap(makeDegreeLockedLocate())
        let horae = Horae(locate: locate)
        let anchor = try XCTUnwrap(JulianDay(locate.bone.start.value + 50))
        let unavailable = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 120,
            motion: .retrograde
        ))

        XCTAssertThrowsError(
            try horae.respond(to: .driveBodyAtDegree(
                to: .mercury,
                directionalDegree: unavailable,
                from: anchor
            ))
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrence(body: .mercury, directionalDegree: unavailable)
            )
        }
    }

    func testExactDegreeAndUTConstraintAcceptsOnlyTrueBodyAddress() throws {
        let locate = try XCTUnwrap(makeDegreeLockedLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let coordinate = try locate.coordinate(of: .mars, at: fixedUT)

        let intent = HoraeControlIntent.driveConstrainedBody(
            to: .mars,
            directionalDegree: coordinate.directionalDegree,
            at: fixedUT
        )
        let output = try horae.respond(to: intent)
        let direct = try horae.driveBody(
            to: .mars,
            matching: coordinate.directionalDegree,
            at: fixedUT
        )
        let state = try XCTUnwrap(output.controlState)

        XCTAssertEqual(output, direct)
        XCTAssertEqual(output.julianDay, fixedUT)
        XCTAssertEqual(state.address, HoraeAddress(
            body: .mars,
            directionalDegree: coordinate.directionalDegree,
            julianDay: fixedUT
        ))
        XCTAssertEqual(state.bodyRole, .driven)
        XCTAssertEqual(state.directionalDegreeRole, .pinned)
        XCTAssertEqual(state.julianDayRole, .pinned)
    }

    func testExactConstraintMismatchFailsDistinctlyEvenWhenDegreeExistsElsewhere() throws {
        let locate = try XCTUnwrap(makeDegreeLockedLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let elsewhereUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 60))
        let elsewhere = try locate.coordinate(of: .mercury, at: elsewhereUT)
        let occurrences = try locate.occurrences(
            of: .mercury,
            at: elsewhere.directionalDegree
        )
        XCTAssertFalse(occurrences.isEmpty)

        XCTAssertThrowsError(
            try horae.respond(to: .driveConstrainedBody(
                to: .mercury,
                directionalDegree: elsewhere.directionalDegree,
                at: fixedUT
            ))
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .constraintUnsatisfied(
                    body: .mercury,
                    directionalDegree: elsewhere.directionalDegree,
                    julianDay: fixedUT
                )
            )
        }
    }

    private func makeDegreeLockedLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_000))
        let end = try XCTUnwrap(JulianDay(2_500_160))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        let target = 120.0

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let increment = OrboSpineContract.supportDegrees(for: body) * 0.5
            let targetDay = 20 + (index * 6)
            let startingPhysical = target - (increment * Double(targetDay))

            for day in 0..<160 {
                let physical = normalized(
                    startingPhysical + (increment * Double(day))
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

    private func targetDegree() -> OrboSpineDirectionalDegree {
        OrboSpineDirectionalDegree(
            physicalDegrees: 120,
            motion: .direct
        )!
    }

    private func nearestOccurrence(
        in occurrences: [OrboSpineOccurrence],
        to anchor: JulianDay
    ) -> OrboSpineOccurrence? {
        occurrences.min { lhs, rhs in
            abs(lhs.julianDay.value - anchor.value)
                < abs(rhs.julianDay.value - anchor.value)
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
}
