import XCTest
@testable import OrboCore

final class OrboSpineArtifactDeterminismTests: XCTestCase {
    func testHephaestusProducesByteIdenticalArtifactFromSameRuntime() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let first = try OrboSpineArtifactForge.forge(runtime: source)
        let second = try OrboSpineArtifactForge.forge(runtime: source)

        XCTAssertEqual(first.data, second.data)
        XCTAssertEqual(first.spineIdentity, second.spineIdentity)
    }
}
