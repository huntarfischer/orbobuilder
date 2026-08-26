import XCTest
@testable import OrboCore

final class HoraeControlsStage6Tests: XCTestCase {
    func testConsumerSocketExposesEveryProvenControlModeThroughOneOutputShape() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let occurrenceUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let mercuryOccurrence = try locate.coordinate(of: .mercury, at: occurrenceUT)

        let intents: [HoraeControlIntent] = [
            .driveUT(to: fixedUT, body: .mercury),
            .driveConstrainedUT(
                to: occurrenceUT,
                body: .mercury,
                directionalDegree: mercuryOccurrence.directionalDegree
            ),
            .driveDirectionalDegree(
                to: mercuryOccurrence.directionalDegree,
                body: .mercury,
                from: occurrenceUT
            ),
            .driveBody(to: .venus, at: fixedUT),
        ]

        for intent in intents {
            let output = try horae.respond(to: intent)
            let state = try XCTUnwrap(output.controlState)

            XCTAssertEqual(output.celestial.map(\.body), OrboSpineContract.canonicalBodies)
            XCTAssertTrue(output.celestial.allSatisfy { $0.julianDay == output.julianDay })
            XCTAssertEqual(output.terra.julianDay, output.julianDay)
            XCTAssertEqual(state.address.julianDay, output.julianDay)
        }
    }

    func testConsumerCanSwitchControlModesRepeatedlyWithoutHiddenHoraeState() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let occurrenceUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let mercuryOccurrence = try locate.coordinate(of: .mercury, at: occurrenceUT)

        let sequence: [HoraeControlIntent] = [
            .driveBody(to: .saturn, at: fixedUT),
            .driveUT(to: occurrenceUT, body: .moon),
            .driveDirectionalDegree(
                to: mercuryOccurrence.directionalDegree,
                body: .mercury,
                from: occurrenceUT
            ),
            .driveConstrainedUT(
                to: occurrenceUT,
                body: .mercury,
                directionalDegree: mercuryOccurrence.directionalDegree
            ),
            .driveBody(to: .venus, at: fixedUT),
        ]

        let firstPass = try sequence.map { try horae.respond(to: $0) }
        let secondPass = try sequence.map { try horae.respond(to: $0) }

        XCTAssertEqual(firstPass, secondPass)
    }

    func testEveryCanonicalBodyIsAvailableThroughTheSameConsumerSocket() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let expectedCrossSection = try horae.seek(to: fixedUT)

        for body in OrboSpineContract.canonicalBodies {
            let output = try horae.respond(to: .driveBody(to: body, at: fixedUT))
            let state = try XCTUnwrap(output.controlState)
            let expectedCoordinate = try XCTUnwrap(
                expectedCrossSection.celestial.first(where: { $0.body == body })
            )

            XCTAssertEqual(output.julianDay, fixedUT)
            XCTAssertEqual(output.celestial, expectedCrossSection.celestial)
            XCTAssertEqual(output.terra, expectedCrossSection.terra)
            XCTAssertEqual(state.address.body, body)
            XCTAssertEqual(state.address.directionalDegree, expectedCoordinate.directionalDegree)
            XCTAssertEqual(state.bodyRole, .driven)
            XCTAssertEqual(state.directionalDegreeRole, .resolved)
            XCTAssertEqual(state.julianDayRole, .pinned)
        }
    }

    func testFailedConsumerIntentDoesNotContaminateNextLawfulControl() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let missing = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 60,
            motion: .retrograde
        ))

        XCTAssertThrowsError(
            try horae.respond(to: .driveDirectionalDegree(
                to: missing,
                body: .mercury,
                from: fixedUT
            ))
        ) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrence(body: .mercury, directionalDegree: missing)
            )
        }

        let afterFailure = try horae.respond(to: .driveBody(to: .sun, at: fixedUT))
        let freshHorae = Horae(locate: locate)
        let fresh = try freshHorae.respond(to: .driveBody(to: .sun, at: fixedUT))

        XCTAssertEqual(afterFailure, fresh)
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
