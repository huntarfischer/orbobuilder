import XCTest
@testable import OrboCore

final class OrboSpineArtifactMountedAnswerTests: XCTestCase {
    func testMountedSpineReturnsRealCoordinateAndTerraAnswers() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)

        let julianDay = JulianDay((source.bone.start.value + source.bone.end.value) / 2.0)

        let expectedSun = try source.locate.coordinate(body: .sun, at: julianDay)
        let expectedMoon = try source.locate.coordinate(body: .moon, at: julianDay)
        let expectedTerra = try source.locate.terra(at: julianDay)

        let sun = try mounted.coordinate(body: .sun, at: julianDay)
        let moon = try mounted.coordinate(body: .moon, at: julianDay)
        let terra = try mounted.terra(at: julianDay)

        print("ORBOSPINE_MOUNTED artifactBytes=\(forged.data.count)")
        print("ORBOSPINE_MOUNTED spineIdentity=\(mounted.metadata.spineIdentity)")
        print("ORBOSPINE_MOUNTED julianDay=\(julianDay.value)")
        print("ORBOSPINE_MOUNTED sun source=\(expectedSun.physicalDegrees) mounted=\(sun.physicalDegrees) motion=\(sun.motion)")
        print("ORBOSPINE_MOUNTED moon source=\(expectedMoon.physicalDegrees) mounted=\(moon.physicalDegrees) motion=\(moon.motion)")
        print("ORBOSPINE_MOUNTED terra sourceTurn=\(expectedTerra.turnDegrees) mountedTurn=\(terra.turnDegrees) sourceTilt=\(expectedTerra.tiltDegrees) mountedTilt=\(terra.tiltDegrees)")
        print("ORBOSPINE_MOUNTED library stations=\(mounted.stations().count) retrogrades=\(mounted.retrogradePassages().count) ring=\(mounted.ringOccurrences().count) eclipses=\(mounted.eclipses().count) shells=\(mounted.shellIntervals().count)")

        XCTAssertEqual(mounted.metadata.spineIdentity, forged.spineIdentity)
        XCTAssertEqual(sun.physicalDegrees, expectedSun.physicalDegrees, accuracy: 1e-10)
        XCTAssertEqual(sun.motion, expectedSun.motion)
        XCTAssertEqual(moon.physicalDegrees, expectedMoon.physicalDegrees, accuracy: 1e-10)
        XCTAssertEqual(moon.motion, expectedMoon.motion)
        XCTAssertEqual(terra.turnDegrees, expectedTerra.turnDegrees, accuracy: 1e-10)
        XCTAssertEqual(terra.tiltDegrees, expectedTerra.tiltDegrees, accuracy: 1e-10)
    }
}
