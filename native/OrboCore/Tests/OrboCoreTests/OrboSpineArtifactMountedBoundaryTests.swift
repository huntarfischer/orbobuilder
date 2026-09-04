import XCTest
@testable import OrboCore

final class OrboSpineArtifactMountedBoundaryTests: XCTestCase {
    func testMountedSpineAnswersAtBoneBoundaries() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)

        for body in OrboSpineContract.canonicalBodies {
            let start = try mounted.coordinate(body: body, at: source.bone.start)
            let end = try mounted.coordinate(body: body, at: source.bone.end)
            XCTAssertEqual(start.body, body)
            XCTAssertEqual(end.body, body)
        }
    }
}
