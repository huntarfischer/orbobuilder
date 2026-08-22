import XCTest
@testable import OrboCore

final class DioscuriPolluxPrecisionTests: XCTestCase {
    func testG6PolluxConfirmsNumericalIdentityButPreservesRealDivergence() throws {
        let julianDay = try XCTUnwrap(JulianDay(1_000.5))
        let expected = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10.5,
                motion: .direct
            )),
            julianDay: julianDay
        )
        let numericalDust = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10.50000000005,
                motion: .direct
            )),
            julianDay: julianDay
        )
        let realDifference = OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10.500001,
                motion: .direct
            )),
            julianDay: julianDay
        )

        XCTAssertEqual(
            PolluxResonator.confirm(expected: expected, returned: numericalDust),
            .confirmed
        )
        XCTAssertEqual(
            PolluxResonator.confirm(expected: expected, returned: realDifference),
            .divergent(expected: expected, returned: realDifference)
        )
    }
}
