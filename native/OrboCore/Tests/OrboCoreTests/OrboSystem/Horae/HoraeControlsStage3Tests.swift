import XCTest
@testable import OrboCore

final class HoraeControlsStage3Tests: XCTestCase {
    func testDirectionalDegreeDriveResolvesUTThroughPinnedBodyTract() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 60,
            motion: .direct
        ))
        let current = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let occurrence = try XCTUnwrap(
            locate.occurrences(of: .mercury, at: target).first
        )

        let output = try horae.driveDirectionalDegree(
            to: target,
            body: .mercury,
            from: current
        )
        let seekOutput = try horae.seek(to: occurrence.julianDay)
        let state = try XCTUnwrap(output.controlState)

        XCTAssertEqual(output.julianDay, seekOutput.julianDay)
        XCTAssertEqual(output.celestial, seekOutput.celestial)
        XCTAssertEqual(output.terra, seekOutput.terra)
        XCTAssertEqual(state.address.body, .mercury)
        XCTAssertEqual(state.address.directionalDegree, target)
        XCTAssertEqual(state.address.julianDay, occurrence.julianDay)
        XCTAssertEqual(state.bodyRole, .pinned)
        XCTAssertEqual(state.directionalDegreeRole, .driven)
        XCTAssertEqual(state.julianDayRole, .resolved)
    }

    func testDirectionalDegreeDriveUsesCurrentUTToStayWithNearestRepeatedOccurrence() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 20,
            motion: .direct
        ))
        let occurrences = try locate.occurrences(of: .sun, at: target)
        XCTAssertGreaterThanOrEqual(occurrences.count, 2)

        let nearFirst = try XCTUnwrap(JulianDay(occurrences[0].julianDay.value + 2))
        let nearSecond = try XCTUnwrap(JulianDay(occurrences[1].julianDay.value + 2))

        let firstOutput = try horae.driveDirectionalDegree(
            to: target,
            body: .sun,
            from: nearFirst
        )
        let secondOutput = try horae.driveDirectionalDegree(
            to: target,
            body: .sun,
            from: nearSecond
        )

        XCTAssertEqual(firstOutput.controlState?.address.julianDay, occurrences[0].julianDay)
        XCTAssertEqual(secondOutput.controlState?.address.julianDay, occurrences[1].julianDay)
        XCTAssertNotEqual(firstOutput.julianDay, secondOutput.julianDay)
    }

    func testDirectionalDegreeDriveRejectsExactContinuityTieInsteadOfGuessing() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 20,
            motion: .direct
        ))
        let occurrences = try locate.occurrences(of: .sun, at: target)
        XCTAssertGreaterThanOrEqual(occurrences.count, 2)

        let midpoint = try XCTUnwrap(JulianDay(
            (occurrences[0].julianDay.value + occurrences[1].julianDay.value) / 2
        ))

        XCTAssertThrowsError(
            try horae.driveDirectionalDegree(
                to: target,
                body: .sun,
                from: midpoint
            )
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .ambiguousOccurrence(body: .sun, directionalDegree: target)
            )
        }
    }

    func testDirectionalDegreeDriveDoesNotInventMissingOccurrence() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 60,
            motion: .retrograde
        ))
        let current = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))

        XCTAssertThrowsError(
            try horae.driveDirectionalDegree(
                to: target,
                body: .mercury,
                from: current
            )
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrence(body: .mercury, directionalDegree: target)
            )
        }
    }

    private func makeRepeatingLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_000))
        let end = try XCTUnwrap(JulianDay(2_500_160))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let increment = OrboSpineContract.supportDegrees(for: body) * 0.5
            let startingPhysical = Double(index) * 20

            for day in 0..<160 {
                let rawPhysical = startingPhysical + increment * Double(day)
                let physical = rawPhysical.truncatingRemainder(dividingBy: 360)
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
