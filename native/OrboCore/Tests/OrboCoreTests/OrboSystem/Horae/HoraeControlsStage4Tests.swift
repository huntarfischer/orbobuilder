import XCTest
@testable import OrboCore

final class HoraeControlsStage4Tests: XCTestCase {
    func testPinnedBodyAndDegreeConstrainDrivenUTToNearestRealOccurrence() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let targetDegree = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 20,
            motion: .direct
        ))
        let occurrences = try locate.occurrences(of: .sun, at: targetDegree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 2)

        let requestedUT = try XCTUnwrap(JulianDay(
            occurrences[1].julianDay.value + 3
        ))
        let output = try horae.driveUT(
            to: requestedUT,
            body: .sun,
            directionalDegree: targetDegree
        )
        let expected = try horae.seek(to: occurrences[1].julianDay)
        let state = try XCTUnwrap(output.controlState)

        XCTAssertEqual(output.julianDay, occurrences[1].julianDay)
        XCTAssertNotEqual(output.julianDay, requestedUT)
        XCTAssertEqual(output.celestial, expected.celestial)
        XCTAssertEqual(output.terra, expected.terra)
        XCTAssertEqual(state.address.body, .sun)
        XCTAssertEqual(state.address.directionalDegree, targetDegree)
        XCTAssertEqual(state.address.julianDay, occurrences[1].julianDay)
        XCTAssertEqual(state.bodyRole, .pinned)
        XCTAssertEqual(state.directionalDegreeRole, .pinned)
        XCTAssertEqual(state.julianDayRole, .driven)
    }

    func testPinnedBodyAndDegreeRejectExactUTTieInsteadOfGuessing() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let targetDegree = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 20,
            motion: .direct
        ))
        let occurrences = try locate.occurrences(of: .sun, at: targetDegree)
        XCTAssertGreaterThanOrEqual(occurrences.count, 2)

        let midpoint = try XCTUnwrap(JulianDay(
            (occurrences[0].julianDay.value + occurrences[1].julianDay.value) / 2
        ))

        XCTAssertThrowsError(
            try horae.driveUT(
                to: midpoint,
                body: .sun,
                directionalDegree: targetDegree
            )
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .ambiguousOccurrence(body: .sun, directionalDegree: targetDegree)
            )
        }
    }

    func testPinnedUTAllowsBodyDriveWithinSameCrossSection() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let expected = try horae.seek(to: fixedUT)

        let mercuryOutput = try horae.driveBody(to: .mercury, at: fixedUT)
        let venusOutput = try horae.driveBody(to: .venus, at: fixedUT)
        let mercuryState = try XCTUnwrap(mercuryOutput.controlState)
        let venusState = try XCTUnwrap(venusOutput.controlState)
        let expectedMercury = try locate.coordinate(of: .mercury, at: fixedUT)
        let expectedVenus = try locate.coordinate(of: .venus, at: fixedUT)

        XCTAssertEqual(mercuryOutput.julianDay, fixedUT)
        XCTAssertEqual(venusOutput.julianDay, fixedUT)
        XCTAssertEqual(mercuryOutput.celestial, expected.celestial)
        XCTAssertEqual(venusOutput.celestial, expected.celestial)
        XCTAssertEqual(mercuryOutput.terra, expected.terra)
        XCTAssertEqual(venusOutput.terra, expected.terra)

        XCTAssertEqual(mercuryState.address.body, .mercury)
        XCTAssertEqual(mercuryState.address.directionalDegree, expectedMercury.directionalDegree)
        XCTAssertEqual(mercuryState.address.julianDay, fixedUT)
        XCTAssertEqual(mercuryState.bodyRole, .driven)
        XCTAssertEqual(mercuryState.directionalDegreeRole, .resolved)
        XCTAssertEqual(mercuryState.julianDayRole, .pinned)

        XCTAssertEqual(venusState.address.body, .venus)
        XCTAssertEqual(venusState.address.directionalDegree, expectedVenus.directionalDegree)
        XCTAssertEqual(venusState.address.julianDay, fixedUT)
        XCTAssertEqual(venusState.bodyRole, .driven)
        XCTAssertEqual(venusState.directionalDegreeRole, .resolved)
        XCTAssertEqual(venusState.julianDayRole, .pinned)
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
