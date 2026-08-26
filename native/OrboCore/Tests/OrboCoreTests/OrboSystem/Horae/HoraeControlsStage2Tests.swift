import XCTest
@testable import OrboCore

final class HoraeControlsStage2Tests: XCTestCase {
    func testUTDriveUsesSeekCrossSectionAndResolvesPinnedBodyDegree() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(JulianDay(2_500_000.25))

        let seekOutput = try horae.seek(to: target)
        let drivenOutput = try horae.driveUT(to: target, body: .mercury)
        let mercury = try XCTUnwrap(
            seekOutput.celestial.first(where: { $0.body == .mercury })
        )
        let state = try XCTUnwrap(drivenOutput.controlState)

        XCTAssertEqual(drivenOutput.julianDay, seekOutput.julianDay)
        XCTAssertEqual(drivenOutput.celestial, seekOutput.celestial)
        XCTAssertEqual(drivenOutput.terra, seekOutput.terra)

        XCTAssertEqual(state.address.body, .mercury)
        XCTAssertEqual(state.address.directionalDegree, mercury.directionalDegree)
        XCTAssertEqual(state.address.julianDay, target)
        XCTAssertEqual(state.bodyRole, .pinned)
        XCTAssertEqual(state.directionalDegreeRole, .resolved)
        XCTAssertEqual(state.julianDayRole, .driven)
    }

    func testUTDriveAtDifferentUTResolvesDifferentDegreeFromSameBodyTract() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let first = try XCTUnwrap(JulianDay(2_500_000.20))
        let second = try XCTUnwrap(JulianDay(2_500_000.40))

        let firstOutput = try horae.driveUT(to: first, body: .moon)
        let secondOutput = try horae.driveUT(to: second, body: .moon)
        let firstState = try XCTUnwrap(firstOutput.controlState)
        let secondState = try XCTUnwrap(secondOutput.controlState)

        XCTAssertEqual(firstState.address.body, .moon)
        XCTAssertEqual(secondState.address.body, .moon)
        XCTAssertEqual(firstState.address.julianDay, first)
        XCTAssertEqual(secondState.address.julianDay, second)
        XCTAssertNotEqual(
            firstState.address.directionalDegree,
            secondState.address.directionalDegree
        )

        let expectedFirst = try locate.coordinate(of: .moon, at: first)
        let expectedSecond = try locate.coordinate(of: .moon, at: second)
        XCTAssertEqual(firstState.address.directionalDegree, expectedFirst.directionalDegree)
        XCTAssertEqual(secondState.address.directionalDegree, expectedSecond.directionalDegree)
    }

    func testUTDrivePropagatesSeekBoneFailure() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let outside = try XCTUnwrap(JulianDay(2_500_001.0))

        XCTAssertThrowsError(try horae.driveUT(to: outside, body: .mercury)) { error in
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
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100.0,
                tiltDegrees: 23.4,
                julianDay: start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110.0,
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
