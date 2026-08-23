import XCTest
@testable import OrboCore

final class HoraeStage3Tests: XCTestCase {
    func testSeekReturnsSameOutputWhenReturningToSameUTAfterOtherSeeks() throws {
        let horae = Horae(locate: try XCTUnwrap(makeLocate()))

        let t1 = try XCTUnwrap(JulianDay(2_500_000.125))
        let t2 = try XCTUnwrap(JulianDay(2_500_000.500))
        let t3 = try XCTUnwrap(JulianDay(2_500_000.875))

        let firstT1 = try horae.seek(to: t1)
        _ = try horae.seek(to: t2)
        _ = try horae.seek(to: t3)
        let returnedT1 = try horae.seek(to: t1)

        XCTAssertEqual(returnedT1, firstT1)
    }

    func testSeekAtSameUTIsIndependentOfDirectionOfApproach() throws {
        let horae = Horae(locate: try XCTUnwrap(makeLocate()))

        let target = try XCTUnwrap(JulianDay(2_500_000.500))
        let below = try XCTUnwrap(JulianDay(2_500_000.250))
        let above = try XCTUnwrap(JulianDay(2_500_000.750))

        let direct = try horae.seek(to: target)

        _ = try horae.seek(to: below)
        let fromBelow = try horae.seek(to: target)

        _ = try horae.seek(to: above)
        let fromAbove = try horae.seek(to: target)

        XCTAssertEqual(fromBelow, direct)
        XCTAssertEqual(fromAbove, direct)
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
