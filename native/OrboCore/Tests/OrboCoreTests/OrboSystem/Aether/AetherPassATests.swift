import XCTest
@testable import OrboCore

final class AetherPassATests: XCTestCase {
    func testAetherExistsAndGovernsAstrosphereEnvironment() {
        XCTAssertEqual(Aether.governedDomain, .astrosphereEnvironment)
    }
}
