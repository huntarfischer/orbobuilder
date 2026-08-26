import XCTest
@testable import OrboCore

final class HoraeControlsStage14Tests: XCTestCase {
    func testLiveRemainsStableAcrossEverySuccessfulControlMode() throws {
        let locate = try XCTUnwrap(makeLocate())
        let liveUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 50.0))
        let liveInstant = try XCTUnwrap(AbsoluteInstant(julianDay: liveUT))
        let horae = Horae(locate: locate, now: { liveInstant })
        let expectedLive = try horae.seek(to: liveUT)

        let constrainedDegree = try locate.coordinate(
            of: .sun,
            at: try XCTUnwrap(JulianDay(locate.bone.start.value + 20.0))
        ).directionalDegree
        let mercuryDegree = try locate.coordinate(
            of: .mercury,
            at: try XCTUnwrap(JulianDay(locate.bone.start.value + 35.0))
        ).directionalDegree
        let saturnDegree = try locate.coordinate(
            of: .saturn,
            at: try XCTUnwrap(JulianDay(locate.bone.start.value + 60.0))
        ).directionalDegree
        let marsUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 65.0))
        let marsDegree = try locate.coordinate(of: .mars, at: marsUT).directionalDegree
        let occurrenceAnchor = try XCTUnwrap(
            JulianDay(locate.bone.start.value + 20.0)
        )

        let intents: [HoraeControlIntent] = [
            .seekUT(
                to: try XCTUnwrap(JulianDay(locate.bone.start.value + 40.0))
            ),
            .shiftUT(
                from: try XCTUnwrap(JulianDay(locate.bone.start.value + 40.0)),
                by: try XCTUnwrap(HoraeUTOffset(hours: 12.0))
            ),
            .driveUT(
                to: try XCTUnwrap(JulianDay(locate.bone.start.value + 42.0)),
                body: .mercury
            ),
            .driveConstrainedUT(
                to: try XCTUnwrap(JulianDay(locate.bone.start.value + 22.0)),
                body: .sun,
                directionalDegree: constrainedDegree
            ),
            .driveDirectionalDegree(
                to: mercuryDegree,
                body: .mercury,
                from: try XCTUnwrap(JulianDay(locate.bone.start.value + 34.0))
            ),
            .driveBody(
                to: .venus,
                at: try XCTUnwrap(JulianDay(locate.bone.start.value + 45.0))
            ),
            .driveBodyAtDegree(
                to: .saturn,
                directionalDegree: saturnDegree,
                from: try XCTUnwrap(JulianDay(locate.bone.start.value + 58.0))
            ),
            .driveConstrainedBody(
                to: .mars,
                directionalDegree: marsDegree,
                at: marsUT
            ),
            .navigateOccurrence(
                body: .sun,
                directionalDegree: constrainedDegree,
                from: occurrenceAnchor,
                direction: .next
            ),
        ]

        XCTAssertNil(expectedLive.controlState)
        XCTAssertEqual(try horae.live(), expectedLive)

        for intent in intents {
            _ = try horae.respond(to: intent)
            let live = try horae.live()
            XCTAssertEqual(live, expectedLive)
            XCTAssertNil(live.controlState)
        }
    }

    func testRepresentativeFailedControlsDoNotPoisonLive() throws {
        let locate = try XCTUnwrap(makeLocate())
        let liveUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 50.0))
        let liveInstant = try XCTUnwrap(AbsoluteInstant(julianDay: liveUT))
        let horae = Horae(locate: locate, now: { liveInstant })
        let expectedLive = try horae.seek(to: liveUT)

        XCTAssertThrowsError(
            try horae.respond(to: .seekUT(to: locate.bone.end))
        ) { error in
            XCTAssertEqual(
                error as? OrboSpineLocateError,
                .outsideBone
            )
        }
        XCTAssertEqual(try horae.live(), expectedLive)

        let impossibleRetrograde = try XCTUnwrap(
            OrboSpineDirectionalDegree(
                physicalDegrees: 120.0,
                motion: .retrograde
            )
        )
        let anchor = try XCTUnwrap(JulianDay(locate.bone.start.value + 40.0))
        XCTAssertThrowsError(
            try horae.respond(to: .driveDirectionalDegree(
                to: impossibleRetrograde,
                body: .mercury,
                from: anchor
            ))
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrence(
                    body: .mercury,
                    directionalDegree: impossibleRetrograde
                )
            )
        }
        XCTAssertEqual(try horae.live(), expectedLive)

        let elsewhereUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 80.0))
        let elsewhereDegree = try locate.coordinate(
            of: .mercury,
            at: elsewhereUT
        ).directionalDegree
        XCTAssertThrowsError(
            try horae.respond(to: .driveConstrainedBody(
                to: .mercury,
                directionalDegree: elsewhereDegree,
                at: anchor
            ))
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .constraintUnsatisfied(
                    body: .mercury,
                    directionalDegree: elsewhereDegree,
                    julianDay: anchor
                )
            )
        }
        XCTAssertEqual(try horae.live(), expectedLive)

        let sunOccurrenceUT = try XCTUnwrap(
            JulianDay(locate.bone.start.value + 20.0)
        )
        let sunDegree = try locate.coordinate(
            of: .sun,
            at: sunOccurrenceUT
        ).directionalDegree
        let lateAnchor = try XCTUnwrap(
            JulianDay(locate.bone.end.value - 0.000_001)
        )
        XCTAssertThrowsError(
            try horae.respond(to: .navigateOccurrence(
                body: .sun,
                directionalDegree: sunDegree,
                from: lateAnchor,
                direction: .next
            ))
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrenceInDirection(
                    body: .sun,
                    directionalDegree: sunDegree,
                    from: lateAnchor,
                    direction: .next
                )
            )
        }
        XCTAssertEqual(try horae.live(), expectedLive)
        XCTAssertNil(try horae.live().controlState)
    }

    func testLiveAlwaysRemainsPureCrossSectionAfterPointAddressControls() throws {
        let locate = try XCTUnwrap(makeLocate())
        let liveUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 75.0))
        let liveInstant = try XCTUnwrap(AbsoluteInstant(julianDay: liveUT))
        let horae = Horae(locate: locate, now: { liveInstant })
        let expected = try horae.seek(to: liveUT)

        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 60.0))
        let degree = try locate.coordinate(of: .venus, at: fixedUT).directionalDegree
        let controlled = try horae.respond(to: .driveConstrainedBody(
            to: .venus,
            directionalDegree: degree,
            at: fixedUT
        ))

        XCTAssertNotNil(controlled.controlState)

        let firstLive = try horae.live()
        let secondLive = try horae.live()
        XCTAssertEqual(firstLive, expected)
        XCTAssertEqual(secondLive, expected)
        XCTAssertNil(firstLive.controlState)
        XCTAssertNil(secondLive.controlState)
    }

    func testBoneEdgeSocketStressCannotContaminateLive() throws {
        let locate = try XCTUnwrap(makeLocate())
        let liveUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 50.0))
        let liveInstant = try XCTUnwrap(AbsoluteInstant(julianDay: liveUT))
        let horae = Horae(locate: locate, now: { liveInstant })
        let expectedLive = try horae.seek(to: liveUT)
        let justBeforeEnd = try XCTUnwrap(
            JulianDay(locate.bone.end.value - 0.000_001)
        )

        let startOutput = try horae.respond(to: .seekUT(to: locate.bone.start))
        XCTAssertEqual(startOutput.julianDay, locate.bone.start)
        XCTAssertEqual(try horae.live(), expectedLive)

        let nearEndOutput = try horae.respond(to: .seekUT(to: justBeforeEnd))
        XCTAssertEqual(nearEndOutput.julianDay, justBeforeEnd)
        XCTAssertEqual(try horae.live(), expectedLive)

        XCTAssertThrowsError(
            try horae.respond(to: .seekUT(to: locate.bone.end))
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
        XCTAssertEqual(try horae.live(), expectedLive)

        let beforeStart = try XCTUnwrap(
            JulianDay(locate.bone.start.value - 0.000_001)
        )
        XCTAssertThrowsError(
            try horae.respond(to: .seekUT(to: beforeStart))
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
        XCTAssertEqual(try horae.live(), expectedLive)

        XCTAssertThrowsError(
            try horae.respond(to: .shiftUT(
                from: locate.bone.start,
                by: try XCTUnwrap(HoraeUTOffset(hours: -1.0))
            ))
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
        XCTAssertEqual(try horae.live(), expectedLive)

        let nearEndAnchor = try XCTUnwrap(
            JulianDay(locate.bone.end.value - (1.0 / 24.0))
        )
        XCTAssertThrowsError(
            try horae.respond(to: .shiftUT(
                from: nearEndAnchor,
                by: try XCTUnwrap(HoraeUTOffset(hours: 2.0))
            ))
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
        XCTAssertEqual(try horae.live(), expectedLive)
        XCTAssertNil(try horae.live().controlState)
    }

    private func makeLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_900_000.0))
        let end = try XCTUnwrap(JulianDay(start.value + 160.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        var supports: [OrboSpineCelestialCoordinate] = []

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let increment = OrboSpineContract.supportDegrees(for: body) * 0.5
            let startingPhysical = Double(index) * 20.0

            for day in 0..<160 {
                let julianDay = try XCTUnwrap(
                    JulianDay(start.value + Double(day))
                )
                let physical = normalized(
                    startingPhysical + increment * Double(day)
                )
                supports.append(
                    coordinate(
                        body,
                        physicalDegrees: physical,
                        at: julianDay
                    )
                )
            }
        }

        let terra = [
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 100.0,
                    tiltDegrees: 23.4,
                    julianDay: start
                )
            ),
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 110.0,
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

    private func normalized(_ physicalDegrees: Double) -> Double {
        let remainder = physicalDegrees.truncatingRemainder(dividingBy: 360.0)
        return remainder >= 0 ? remainder : remainder + 360.0
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
