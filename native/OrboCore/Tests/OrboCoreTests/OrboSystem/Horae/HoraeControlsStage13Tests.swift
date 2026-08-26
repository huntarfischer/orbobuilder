import XCTest
@testable import OrboCore

final class HoraeControlsStage13Tests: XCTestCase {
    func testEveryCanonicalBodyCanActAsATemporalGrip() throws {
        let locate = try XCTUnwrap(makeAllBodyClockLocate())
        let horae = Horae(locate: locate)
        let targetDay = 20.0
        let anchor = try XCTUnwrap(JulianDay(locate.bone.start.value + 18.5))

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let target = degreeForBody(index: index, day: targetDay)
            let output = try horae.driveDirectionalDegree(
                to: target,
                body: body,
                from: anchor
            )
            let state = try XCTUnwrap(output.controlState)
            let selected = try XCTUnwrap(
                output.celestial.first(where: { $0.body == body })
            )
            let seek = try horae.seek(to: output.julianDay)

            XCTAssertEqual(
                output.julianDay.value,
                locate.bone.start.value + targetDay,
                accuracy: 1e-8
            )
            XCTAssertEqual(selected.directionalDegree, target)
            XCTAssertEqual(state.address.body, body)
            XCTAssertEqual(state.address.directionalDegree, target)
            XCTAssertEqual(state.address.julianDay, output.julianDay)
            XCTAssertEqual(state.bodyRole, .pinned)
            XCTAssertEqual(state.directionalDegreeRole, .driven)
            XCTAssertEqual(state.julianDayRole, .resolved)
            XCTAssertEqual(output.celestial, seek.celestial)
            XCTAssertEqual(output.terra, seek.terra)
        }
    }

    func testEqualAngularMovementProducesBodySpecificUTFromForgedTracts() throws {
        let locate = try XCTUnwrap(makeAllBodyClockLocate())
        let horae = Horae(locate: locate)
        let startDay = 10.0
        let angularDelta = 0.02
        var resolvedDeltas: [Double] = []

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let startDegree = degreeForBody(index: index, day: startDay)
            let targetDegree = try XCTUnwrap(
                OrboSpineDirectionalDegree(
                    physicalDegrees: startDegree.physicalDegrees + angularDelta,
                    motion: .direct
                )
            )
            let anchor = try XCTUnwrap(
                JulianDay(locate.bone.start.value + startDay)
            )
            let output = try horae.driveDirectionalDegree(
                to: targetDegree,
                body: body,
                from: anchor
            )
            let resolvedDelta = output.julianDay.value - anchor.value
            let expectedDelta = angularDelta / rateForBody(index: index)

            XCTAssertEqual(resolvedDelta, expectedDelta, accuracy: 1e-8)
            resolvedDeltas.append(resolvedDelta)
        }

        for left in 0..<resolvedDeltas.count {
            for right in (left + 1)..<resolvedDeltas.count {
                XCTAssertGreaterThan(
                    abs(resolvedDeltas[left] - resolvedDeltas[right]),
                    1e-6,
                    "Distinct forged tracts must produce distinct UT response"
                )
            }
        }
    }

    func testEveryBodyClockIsDeterministicFromSameAnchor() throws {
        let locate = try XCTUnwrap(makeAllBodyClockLocate())
        let horae = Horae(locate: locate)
        let anchor = try XCTUnwrap(JulianDay(locate.bone.start.value + 14.0))

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let target = degreeForBody(index: index, day: 17.25)

            let first = try horae.driveDirectionalDegree(
                to: target,
                body: body,
                from: anchor
            )
            let second = try horae.driveDirectionalDegree(
                to: target,
                body: body,
                from: anchor
            )

            XCTAssertEqual(second, first)
        }
    }

    func testEveryBodyCanMoveForwardAndBackWithoutHiddenCursor() throws {
        let locate = try XCTUnwrap(makeAllBodyClockLocate())
        let horae = Horae(locate: locate)
        let firstDay = 12.0
        let angularDelta = 0.02

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let firstDegree = degreeForBody(index: index, day: firstDay)
            let secondDegree = try XCTUnwrap(
                OrboSpineDirectionalDegree(
                    physicalDegrees: firstDegree.physicalDegrees + angularDelta,
                    motion: .direct
                )
            )
            let firstUT = try XCTUnwrap(
                JulianDay(locate.bone.start.value + firstDay)
            )

            let forward = try horae.driveDirectionalDegree(
                to: secondDegree,
                body: body,
                from: firstUT
            )
            let backward = try horae.driveDirectionalDegree(
                to: firstDegree,
                body: body,
                from: forward.julianDay
            )

            XCTAssertGreaterThan(forward.julianDay.value, firstUT.value)
            XCTAssertEqual(backward.julianDay.value, firstUT.value, accuracy: 1e-8)
            XCTAssertEqual(
                try horae.seek(to: backward.julianDay).celestial,
                backward.celestial
            )
        }
    }

    func testConsumerSocketExposesEveryCanonicalBodyClock() throws {
        let locate = try XCTUnwrap(makeAllBodyClockLocate())
        let horae = Horae(locate: locate)
        let anchor = try XCTUnwrap(JulianDay(locate.bone.start.value + 16.0))

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let target = degreeForBody(index: index, day: 19.5)

            let direct = try horae.driveDirectionalDegree(
                to: target,
                body: body,
                from: anchor
            )
            let throughSocket = try horae.respond(
                to: .driveDirectionalDegree(
                    to: target,
                    body: body,
                    from: anchor
                )
            )

            XCTAssertEqual(throughSocket, direct)
        }
    }

    private func makeAllBodyClockLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_800_000.0))
        let end = try XCTUnwrap(JulianDay(start.value + 40.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        var supports: [OrboSpineCelestialCoordinate] = []

        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            for day in 0..<40 {
                let julianDay = try XCTUnwrap(
                    JulianDay(start.value + Double(day))
                )
                supports.append(
                    coordinate(
                        body,
                        physicalDegrees: physicalDegreeForBody(
                            index: index,
                            day: Double(day)
                        ),
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

    /// Deliberately synthetic and non-astronomical. Every canonical body receives
    /// a different forged rate, including ordering that does not resemble nature.
    /// Horae must follow these tracts rather than contain body-specific rate logic.
    private func rateForBody(index: Int) -> Double {
        0.005 * Double(index + 1)
    }

    private func startingPhysicalDegree(index: Int) -> Double {
        15.0 + Double(index) * 25.0
    }

    private func physicalDegreeForBody(index: Int, day: Double) -> Double {
        startingPhysicalDegree(index: index)
            + rateForBody(index: index) * day
    }

    private func degreeForBody(
        index: Int,
        day: Double
    ) -> OrboSpineDirectionalDegree {
        OrboSpineDirectionalDegree(
            physicalDegrees: physicalDegreeForBody(index: index, day: day),
            motion: .direct
        )!
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
