import XCTest
@testable import OrboCore

final class AetherPassCTests: XCTestCase {
    func testOrboSummonsAetherWithoutTakingEnvironmentalGovernance() {
        let orbo = Orbo()
        let governor = orbo.summonAether()

        XCTAssertEqual(governor.governedDomain, .astrosphereEnvironment)
        XCTAssertEqual(Aether.governedDomain, .astrosphereEnvironment)
    }

    func testAetherEstablishesEnvironmentAfterOrboSummonsIt() {
        let orbo = Orbo()
        let governor = orbo.summonAether()

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

        let environment = governor.establishEnvironment(
            celestialField: celestial,
            starField: stars,
            earthwardField: earthward
        )

        XCTAssertEqual(environment.celestialField, celestial)
        XCTAssertEqual(environment.starField, stars)
        XCTAssertEqual(environment.earthwardField, earthward)
    }
}
