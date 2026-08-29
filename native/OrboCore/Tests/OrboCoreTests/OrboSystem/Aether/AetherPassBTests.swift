import XCTest
@testable import OrboCore

final class AetherPassBTests: XCTestCase {
    func testAetherEnvironmentCarriesCelestialStarsAndEarthwardMatter() {
        let celestial = AetherField(stops: [
            AetherFieldStop(
                position: 0.0,
                color: AetherColorValue(red: 0.10, green: 0.20, blue: 0.30)
            )
        ])
        let stars = [
            AetherStar(
                horizontalPosition: 0.42,
                verticalPosition: 0.18,
                apparentRadius: 0.002,
                intensity: 0.31
            )
        ]
        let earthward = AetherField(stops: [
            AetherFieldStop(
                position: 1.0,
                color: AetherColorValue(red: 0.60, green: 0.40, blue: 0.20)
            )
        ])

        let environment = AetherEnvironment(
            celestialField: celestial,
            starField: stars,
            earthwardField: earthward
        )

        XCTAssertEqual(environment.celestialField, celestial)
        XCTAssertEqual(environment.starField, stars)
        XCTAssertEqual(environment.earthwardField, earthward)
    }

    func testEnvironmentalValuesRemainPresentationNeutralData() {
        let color = AetherColorValue(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4)
        let stop = AetherFieldStop(position: 0.5, color: color)
        let star = AetherStar(
            horizontalPosition: 0.25,
            verticalPosition: 0.75,
            apparentRadius: 0.01,
            intensity: 0.8
        )

        XCTAssertEqual(stop.position, 0.5)
        XCTAssertEqual(stop.color, color)
        XCTAssertEqual(star.horizontalPosition, 0.25)
        XCTAssertEqual(star.verticalPosition, 0.75)
        XCTAssertEqual(star.apparentRadius, 0.01)
        XCTAssertEqual(star.intensity, 0.8)
    }
}
