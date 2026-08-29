import XCTest
@testable import OrboCore

final class AetherPassDTests: XCTestCase {
    func testHeadlessMVPPathLeavesOrboHostingStateUntouched() {
        let orbo = Orbo()
        let initialFrontOfHouse = orbo.frontOfHouse
        let initialBackOfHouse = orbo.backOfHouse
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

        XCTAssertEqual(orbo.frontOfHouse, initialFrontOfHouse)
        XCTAssertEqual(orbo.backOfHouse, initialBackOfHouse)
        XCTAssertEqual(environment.celestialField, celestial)
        XCTAssertEqual(environment.starField, stars)
        XCTAssertEqual(environment.earthwardField, earthward)
    }

    func testAetherDoesNotRetainEnvironmentalStateBetweenCalls() {
        let firstCelestial = AetherField(stops: [
            AetherFieldStop(
                position: 0.0,
                color: AetherColorValue(red: 0.10, green: 0.20, blue: 0.30)
            )
        ])
        let secondCelestial = AetherField(stops: [
            AetherFieldStop(
                position: 0.0,
                color: AetherColorValue(red: 0.30, green: 0.20, blue: 0.10)
            )
        ])
        let earthward = AetherField(stops: [])

        let first = Aether.establishEnvironment(
            celestialField: firstCelestial,
            starField: [],
            earthwardField: earthward
        )
        let second = Aether.establishEnvironment(
            celestialField: secondCelestial,
            starField: [],
            earthwardField: earthward
        )

        XCTAssertEqual(first.celestialField, firstCelestial)
        XCTAssertEqual(second.celestialField, secondCelestial)
        XCTAssertNotEqual(first, second)
    }

    func testAetherMVPLeavesTwinGovernanceIntact() {
        let orbo = Orbo()

        XCTAssertEqual(orbo.summonAether().governedDomain, .astrosphereEnvironment)
        XCTAssertEqual(orbo.summonApollo().governedInstrument, .astrolabe)
        XCTAssertEqual(orbo.summonArtemis().governedInstrument, .lunarPane)
    }
}
