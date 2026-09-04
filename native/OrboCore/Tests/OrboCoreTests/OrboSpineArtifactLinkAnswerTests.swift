import XCTest
@testable import OrboCore

final class OrboSpineArtifactLinkAnswerTests: XCTestCase {
    func testMountedSpineCanAddressAndResolveCoordinateThroughSameLocate() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)

        let julianDay = JulianDay((source.bone.start.value + source.bone.end.value) / 2.0)
        let coordinate = try mounted.coordinate(body: .sun, at: julianDay)
        let address = SpineLinkAddress(
            spineIdentity: mounted.metadata.spineIdentity,
            memberIdentity: "sun@\(julianDay.value)"
        )

        XCTAssertEqual(address.spineIdentity, mounted.metadata.spineIdentity)
        XCTAssertEqual(coordinate.body, .sun)
    }
}
