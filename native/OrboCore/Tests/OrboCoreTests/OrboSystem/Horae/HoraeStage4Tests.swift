import XCTest
@testable import OrboCore

final class HoraeStage4Tests: XCTestCase {
    func testLiveAtKnownInstantEqualsSeekToSameUT() throws {
        let locate = try XCTUnwrap(makeLocate())
        let target = try XCTUnwrap(JulianDay(2_500_000.375))
        let instant = try XCTUnwrap(AbsoluteInstant(julianDay: target))
        let horae = Horae(locate: locate, now: { instant })

        let live = try horae.live()
        let seek = try horae.seek(to: target)

        XCTAssertEqual(live, seek)
        XCTAssertEqual(live.julianDay, target)
    }

    func testLivePropagatesSeekBoneFailure() throws {
        let locate = try XCTUnwrap(makeLocate())
        let outside = try XCTUnwrap(JulianDay(2_500_001.25))
        let instant = try XCTUnwrap(AbsoluteInstant(julianDay: outside))
        let horae = Horae(locate: locate, now: { instant })

        XCTAssertThrowsError(try horae.live()) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    private func makeLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_000.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_000.5))
        let end = try XCTUnwrap(JulianDay(2_500_001.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let firstPhysical = Double(index) * 20.0
            let secondPhysical = firstPhysical + OrboSpineContract.supportDegrees(for: body) * 0.5

            supports.append(
                coordinate(
                    body,
                    physicalDegrees: firstPhysical,
                    at: start
                )
            )
            supports.append(
                coordinate(
                    body,
                    physicalDegrees: secondPhysical,
                    at: midpoint
                )
            )
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
