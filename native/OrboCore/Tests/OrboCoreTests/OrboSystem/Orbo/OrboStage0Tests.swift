import XCTest
@testable import OrboCore

final class OrboStage0Tests: XCTestCase {
    func testFreshOrboCanBeInstantiated() {
        _ = Orbo()
    }

    func testFreshOrboBeginsRestingFrontOfHouse() {
        let orbo = Orbo()

        XCTAssertEqual(orbo.frontOfHouse, .resting)
    }

    func testFreshOrboBeginsIdleBackOfHouse() {
        let orbo = Orbo()

        XCTAssertEqual(orbo.backOfHouse, .idle)
    }

    func testFrontAndBackOfHouseAreIndependentlyObservable() {
        var orbo = Orbo()

        orbo.transitionFrontOfHouse(to: .onboarding)

        XCTAssertEqual(orbo.frontOfHouse, .onboarding)
        XCTAssertEqual(orbo.backOfHouse, .idle)
    }

    func testBackOfHouseTransitionDoesNotMutateFrontOfHouse() {
        var orbo = Orbo()

        orbo.transitionFrontOfHouse(to: .introducingAstrosphere)
        orbo.transitionBackOfHouse(to: .engravingCommissioned)

        XCTAssertEqual(orbo.frontOfHouse, .introducingAstrosphere)
        XCTAssertEqual(orbo.backOfHouse, .engravingCommissioned)
    }
}
