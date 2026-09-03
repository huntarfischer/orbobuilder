import XCTest
@testable import OrboIris

final class IrisPaneMotionTests: XCTestCase {
    func testFlickChoosesDifferentRestFromSlowRelease() {
        XCTAssertEqual(IrisPaneSpring.nearest(-30, velocity: 0, stops: [-200, 0, 200]), 0)
        XCTAssertEqual(IrisPaneSpring.nearest(-30, velocity: -1000, stops: [-200, 0, 200]), -200)
    }
    func testSpringCarriesVelocityAndSettlesWithoutFrameRateDependence() {
        var slow = IrisPaneSpring(position: 100)
        slow.target = 0; slow.velocity = -500
        var fast = slow
        for _ in 0..<180 { slow.advance(seconds: 1.0 / 60) }
        for _ in 0..<360 { fast.advance(seconds: 1.0 / 120) }
        XCTAssertEqual(slow.position, 0, accuracy: 0.2)
        XCTAssertEqual(slow.position, fast.position, accuracy: 0.2)
        XCTAssertEqual(slow.velocity, 0, accuracy: 0.2)
    }
    func testRubberBandResistsBeyondLimits() {
        XCTAssertEqual(IrisPaneSpring.rubber(50, lower: 0, upper: 100), 50)
        let overshoot = IrisPaneSpring.rubber(1000, lower: 0, upper: 100)
        XCTAssertGreaterThan(overshoot, 100)
        XCTAssertLessThan(overshoot, 146)
    }
}
