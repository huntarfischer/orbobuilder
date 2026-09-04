import XCTest
@testable import OrboCore

final class OrboSpineArtifactMountedBodyCoverageTests: XCTestCase {
    func testMountedSpineAnswersEveryCanonicalBodyAtInteriorMoment() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)
        let julianDay = JulianDay((source.bone.start.value + source.bone.end.value) / 2.0)

        for body in OrboSpineContract.canonicalBodies {
            let answer = try mounted.coordinate(body: body, at: julianDay)
            XCTAssertEqual(answer.body, body)
            XCTAssert((0..<360).contains(answer.physicalDegrees))
        }
    }
}
