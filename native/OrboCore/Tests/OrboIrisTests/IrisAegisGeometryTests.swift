import XCTest
import OrboCore
@testable import OrboIris

final class IrisAegisGeometryTests: XCTestCase {
    func testHorizonRendersAtLeftAndOppositionAtRight() {
        let geometry = IrisAegisGeometry(diameter: 400, horizon: 221.5)
        let asc = geometry.point(longitude: 221.5, radius: 180)
        let descendant = geometry.point(longitude: 41.5, radius: 180)
        XCTAssertEqual(asc.x, 20, accuracy: 1e-9)
        XCTAssertEqual(asc.y, 200, accuracy: 1e-9)
        XCTAssertEqual(descendant.x, 380, accuracy: 1e-9)
        XCTAssertEqual(descendant.y, 200, accuracy: 1e-9)
    }

    func testZodiacalOrientationAndDisplayFormattingPreserveSourcePrecision() {
        let geometry = IrisAegisGeometry(diameter: 400, horizon: nil)
        let cancer = geometry.point(longitude: 90, radius: 180)
        XCTAssertEqual(cancer.x, 200, accuracy: 1e-9)
        XCTAssertEqual(cancer.y, 380, accuracy: 1e-9)
        let position = CelestialLongitude(21 + 9.0 / 60 + 42.0 / 3600)!
        XCTAssertEqual(IrisAstrolabeStyle.position(position), "21°9′")
        XCTAssertEqual(position.degrees, 21 + 9.0 / 60 + 42.0 / 3600)
    }
}
