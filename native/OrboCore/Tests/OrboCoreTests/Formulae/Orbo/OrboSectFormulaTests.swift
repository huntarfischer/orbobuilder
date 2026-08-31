import XCTest
@testable import OrboCore

final class OrboSectFormulaTests: XCTestCase {
    func testDayIncludesAscendantThroughDescendantBoundaries() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(0)!,
                sun: CelestialLongitude(0)!
            ),
            .day
        )
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(0)!,
                sun: CelestialLongitude(90)!
            ),
            .day
        )
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(0)!,
                sun: CelestialLongitude(180)!
            ),
            .day
        )
    }

    func testNightBeginsImmediatelyAfterDescendantAndContinuesThrough359() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(0)!,
                sun: CelestialLongitude(181)!
            ),
            .night
        )
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(0)!,
                sun: CelestialLongitude(359)!
            ),
            .night
        )
    }

    func testDayArcWrapsAcrossZero() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(359)!,
                sun: CelestialLongitude(0)!
            ),
            .day
        )
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(221)!,
                sun: CelestialLongitude(21)!
            ),
            .day
        )
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(221)!,
                sun: CelestialLongitude(40)!
            ),
            .day
        )
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(221)!,
                sun: CelestialLongitude(41)!
            ),
            .day
        )
    }

    func testNightBeginsAt181DegreesAfterWrappedAscendant() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(221)!,
                sun: CelestialLongitude(42)!
            ),
            .night
        )
    }
}
