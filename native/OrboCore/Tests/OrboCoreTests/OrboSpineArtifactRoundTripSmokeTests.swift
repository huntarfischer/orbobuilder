import XCTest
@testable import OrboCore

final class OrboSpineArtifactRoundTripSmokeTests: XCTestCase {
    func testArtifactMountsWithoutReconstruction() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)
        XCTAssertEqual(mounted.metadata.spineIdentity, forged.spineIdentity)
    }
}
