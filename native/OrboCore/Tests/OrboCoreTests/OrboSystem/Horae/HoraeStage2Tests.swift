import XCTest
@testable import OrboCore

final class HoraeStage2Tests: XCTestCase {
    func testSeekReturnsTheLocateCrossSectionAtOneUT() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(JulianDay(2_500_000.25))

        let expectedCelestial = try OrboSpineContract.canonicalBodies.map { body in
            try locate.coordinate(of: body, at: target)
        }
        let expectedTerra = try locate.terra(at: target)

        let output = try horae.seek(to: target)

        XCTAssertEqual(output.julianDay, target)
        XCTAssertEqual(output.celestial, expectedCelestial)
        XCTAssertEqual(output.celestial.map(\.body), OrboSpineContract.canonicalBodies)
        XCTAssertTrue(output.celestial.allSatisfy { $0.julianDay == target })
        XCTAssertEqual(output.terra, expectedTerra)
        XCTAssertEqual(output.terra.julianDay, target)
    }

    func testSeekRequiresEveryCanonicalBodyAvailableThroughLocate() throws {
        let missingBody = try XCTUnwrap(OrboSpineContract.canonicalBodies.last)
        let locate = try XCTUnwrap(makeLocate(excluding: missingBody))
        let horae = Horae(locate: locate)
        let target = try XCTUnwrap(JulianDay(2_500_000.25))

        XCTAssertThrowsError(try horae.seek(to: target)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .bodyUnavailable(missingBody))
        }
    }

    func testSeekPropagatesLocateBoneFailureWithoutClamping() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let outside = try XCTUnwrap(JulianDay(2_500_001.0))

        XCTAssertThrowsError(try horae.seek(to: outside)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    private func makeLocate(excluding excludedBody: MundaneBody? = nil) throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_500_000.0))
        let midpoint = try XCTUnwrap(JulianDay(2_500_000.5))
        let end = try XCTUnwrap(JulianDay(2_500_001.0))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() where body != excludedBody {
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
