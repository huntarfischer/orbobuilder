import XCTest
@testable import OrboCore

final class OrboSpineArtifactMountedNavigationTests: XCTestCase {
    func testMountedNavigationMatchesSourceRuntimeForRepresentativeDegree() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)
        let degree = OrboSpineDirectionalDegree(0)

        for body in OrboSpineContract.canonicalBodies {
            let expected = try source.locate.occurrences(body: body, at: degree)
            let actual = try mounted.occurrences(body: body, at: degree)
            XCTAssertEqual(actual.count, expected.count)
            for (lhs, rhs) in zip(actual, expected) {
                XCTAssertEqual(lhs.julianDay.value, rhs.julianDay.value, accuracy: 1e-10)
                XCTAssertEqual(lhs.physicalDegrees, rhs.physicalDegrees, accuracy: 1e-10)
                XCTAssertEqual(lhs.motion, rhs.motion)
            }
        }
    }
}
