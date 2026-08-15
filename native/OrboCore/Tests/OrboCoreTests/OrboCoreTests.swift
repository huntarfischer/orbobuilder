import XCTest
@testable import OrboCore

final class OrboCoreTests: XCTestCase {
    func testPhaseZeroLinkageSentinel() {
        XCTAssertEqual(OrboCoreBuild.linkageSentinel, "0.0")
    }
}
