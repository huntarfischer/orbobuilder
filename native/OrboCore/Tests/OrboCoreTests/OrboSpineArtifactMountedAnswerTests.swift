import XCTest
@testable import OrboCore

final class OrboSpineArtifactMountedAnswerTests: XCTestCase {
    func testMountedSpineReturnsRealCoordinateAndTerraAnswers() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)

        let julianDay = JulianDay((source.bone.start.value + source.bone.end.value) / 2.0)
        let sun = try mounted.coordinate(body: .sun, at: julianDay)
        let moon = try mounted.coordinate(body: .moon, at: julianDay)
        let terra = try mounted.terra(at: julianDay)

        XCTAssert((0..<360).contains(sun.physicalDegrees))
        XCTAssert((0..<360).contains(moon.physicalDegrees))
        XCTAssert(terra.turnDegrees.isFinite)
        XCTAssert(terra.tiltDegrees.isFinite)
    }
}
