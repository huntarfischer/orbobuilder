import XCTest
@testable import OrboCore

final class OrboSectFormulaTests: XCTestCase {
    func testDayIncludesBothHorizonBoundaries() {
        for ascendant in [0.0, 221.0, 359.0] {
            for sun in [ascendant, (ascendant + 180).truncatingRemainder(dividingBy: 360)] {
                XCTAssertEqual(OrboFormulae.sect(
                    ascendant: CelestialLongitude(ascendant)!,
                    sun: CelestialLongitude(sun)!
                ), .day)
            }
        }
    }

    func testLowerSemicircleIsNightAndUpperSemicircleIsDay() {
        for sun in [0.001, 90.0, 179.999] {
            XCTAssertEqual(OrboFormulae.sect(
                ascendant: CelestialLongitude(0)!, sun: CelestialLongitude(sun)!
            ), .night)
        }
        for sun in [180.001, 270.0, 359.999] {
            XCTAssertEqual(OrboFormulae.sect(
                ascendant: CelestialLongitude(0)!, sun: CelestialLongitude(sun)!
            ), .day)
        }
    }

    func testEanNightArcWrapsAcrossZero() {
        for sun in [21.0, 40.0] {
            XCTAssertEqual(OrboFormulae.sect(
                ascendant: CelestialLongitude(221)!, sun: CelestialLongitude(sun)!
            ), .night)
        }
        XCTAssertEqual(OrboFormulae.sect(
            ascendant: CelestialLongitude(359)!, sun: CelestialLongitude(0)!
        ), .night)
    }

    func testDayStartsAtDescendantAfterWrappedNightArc() {
        for sun in [41.0, 42.0, 220.999] {
            XCTAssertEqual(OrboFormulae.sect(
                ascendant: CelestialLongitude(221)!, sun: CelestialLongitude(sun)!
            ), .day)
        }
    }
}
