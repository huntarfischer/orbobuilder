import XCTest
@testable import OrboCore

final class OrboSectFormulaTests: XCTestCase {
    func testSunExactlyOnAscendantDefaultsToDay() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(10)!,
                sun: CelestialLongitude(10)!
            ),
            .day
        )
    }

    func testSunStrictlyOnAscendantToDescendantArcIsNight() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(10)!,
                sun: CelestialLongitude(100)!
            ),
            .night
        )
    }

    func testSunExactlyOnDescendantDefaultsToDay() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(10)!,
                sun: CelestialLongitude(190)!
            ),
            .day
        )
    }

    func testSunStrictlyOnDescendantToAscendantArcIsDay() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(10)!,
                sun: CelestialLongitude(250)!
            ),
            .day
        )
    }

    func testNightArcWrapsAcrossZeroOnThe359Ring() {
        XCTAssertEqual(
            OrboFormulae.sect(
                ascendant: CelestialLongitude(221)!,
                sun: CelestialLongitude(21)!
            ),
            .night
        )
    }
}
