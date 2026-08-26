import XCTest
@testable import OrboCore

final class HoraeControlsStage5Tests: XCTestCase {
    func testControlIntentSeamRoutesAllProvenControlPathsThroughOneHoraeOutput() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let targetDegree = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 20,
            motion: .direct
        ))
        let occurrence = try XCTUnwrap(
            locate.occurrences(of: .sun, at: targetDegree).first
        )

        let utIntent = HoraeControlIntent.driveUT(
            to: fixedUT,
            body: .mercury
        )
        XCTAssertEqual(
            try horae.respond(to: utIntent),
            try horae.driveUT(to: fixedUT, body: .mercury)
        )

        let constrainedIntent = HoraeControlIntent.driveConstrainedUT(
            to: occurrence.julianDay,
            body: .sun,
            directionalDegree: targetDegree
        )
        XCTAssertEqual(
            try horae.respond(to: constrainedIntent),
            try horae.driveUT(
                to: occurrence.julianDay,
                body: .sun,
                directionalDegree: targetDegree
            )
        )

        let degreeIntent = HoraeControlIntent.driveDirectionalDegree(
            to: targetDegree,
            body: .sun,
            from: occurrence.julianDay
        )
        XCTAssertEqual(
            try horae.respond(to: degreeIntent),
            try horae.driveDirectionalDegree(
                to: targetDegree,
                body: .sun,
                from: occurrence.julianDay
            )
        )

        let bodyIntent = HoraeControlIntent.driveBody(
            to: .venus,
            at: fixedUT
        )
        XCTAssertEqual(
            try horae.respond(to: bodyIntent),
            try horae.driveBody(to: .venus, at: fixedUT)
        )
    }

    func testControlIntentSeamPreservesControlFailureLaw() throws {
        let locate = try XCTUnwrap(makeRepeatingLocate())
        let horae = Horae(locate: locate)
        let missing = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 60,
            motion: .retrograde
        ))
        let anchor = try XCTUnwrap(JulianDay(locate.bone.start.value + 30))
        let intent = HoraeControlIntent.driveDirectionalDegree(
            to: missing,
            body: .mercury,
            from: anchor
        )

        XCTAssertThrowsError(try horae.respond(to: intent)) { error in
            XCTAssertEqual(
                error as? HoraeControlError,
                .noOccurrence(body: .mercury, directionalDegree: missing)
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
