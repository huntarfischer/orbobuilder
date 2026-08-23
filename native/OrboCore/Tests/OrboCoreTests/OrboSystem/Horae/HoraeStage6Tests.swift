import XCTest
@testable import OrboCore

final class HoraeStage6Tests: XCTestCase {
    func testDenseForwardAndReverseSeekSeriesReturnsIdenticalOutputs() throws {
        let horae = Horae(locate: try XCTUnwrap(makeLocate()))
        let base = 2_500_400.0
        let values = (0..<100).map { base + Double($0) * 0.009 }

        var forward: [Double: HoraeOutput] = [:]
        for value in values {
            let target = try XCTUnwrap(JulianDay(value))
            forward[value] = try horae.seek(to: target)
        }

        for value in values.reversed() {
            let target = try XCTUnwrap(JulianDay(value))
            let reverseOutput = try horae.seek(to: target)
            XCTAssertEqual(reverseOutput, forward[value])
        }
    }

    func testArbitraryJumpsAndReturnsDoNotLeaveStaleState() throws {
        let horae = Horae(locate: try XCTUnwrap(makeLocate()))
        let anchor = try XCTUnwrap(JulianDay(2_500_400.333))
        let anchorOutput = try horae.seek(to: anchor)

        let jumps = [
            2_500_400.901,
            2_500_400.042,
            2_500_400.777,
            2_500_400.125,
            2_500_400.640,
            2_500_400.250,
            2_500_400.875,
        ]

        for value in jumps {
            _ = try horae.seek(to: XCTUnwrap(JulianDay(value)))
            XCTAssertEqual(try horae.seek(to: anchor), anchorOutput)
        }
    }

    func testLiveAndSeekCanAlternateWithoutContaminatingEitherSignal() throws {
        let locate = try XCTUnwrap(makeLocate())
        let liveUT = try XCTUnwrap(JulianDay(2_500_400.625))
        let liveInstant = try XCTUnwrap(AbsoluteInstant(julianDay: liveUT))
        let horae = Horae(locate: locate, now: { liveInstant })

        let expectedLive = try horae.seek(to: liveUT)

        XCTAssertEqual(try horae.live(), expectedLive)

        for value in [
            2_500_400.050,
            2_500_400.850,
            2_500_400.300,
            2_500_400.700,
        ] {
            _ = try horae.seek(to: XCTUnwrap(JulianDay(value)))
            XCTAssertEqual(try horae.live(), expectedLive)
        }
    }

    func testRepeatedSeekAtSameUTNeverDrifts() throws {
        let horae = Horae(locate: try XCTUnwrap(makeLocate()))
        let target = try XCTUnwrap(JulianDay(2_500_400.487654321))
        let first = try horae.seek(to: target)

        for _ in 0..<100 {
            XCTAssertEqual(try horae.seek(to: target), first)
        }
    }

    private func makeLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_400.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_400.5))
        let end = try XCTUnwrap(JulianDay(2_500_401.0))
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
