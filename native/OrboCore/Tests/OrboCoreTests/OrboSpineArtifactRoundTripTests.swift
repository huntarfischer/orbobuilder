import XCTest
@testable import OrboCore

final class OrboSpineArtifactRoundTripTests: XCTestCase {
    func testMountedArtifactAnswersMatchSourceRuntime() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)

        XCTAssertEqual(mounted.metadata.spineIdentity, forged.spineIdentity)
        XCTAssertEqual(mounted.metadata.boneStart, source.bone.start)
        XCTAssertEqual(mounted.metadata.boneEnd, source.bone.end)

        let sampleTimes: [JulianDay] = [
            source.bone.start,
            JulianDay((source.bone.start.value + source.bone.end.value) / 2.0),
            source.bone.end
        ]

        for body in OrboSpineContract.canonicalBodies {
            for julianDay in sampleTimes {
                let expected = try source.locate.coordinate(body: body, at: julianDay)
                let actual = try mounted.coordinate(body: body, at: julianDay)
                XCTAssertEqual(actual.physicalDegrees, expected.physicalDegrees, accuracy: 1e-10)
                XCTAssertEqual(actual.motion, expected.motion)
            }
        }

        for julianDay in sampleTimes {
            let expected = try source.locate.terra(at: julianDay)
            let actual = try mounted.terra(at: julianDay)
            XCTAssertEqual(actual.turnDegrees, expected.turnDegrees, accuracy: 1e-10)
            XCTAssertEqual(actual.tiltDegrees, expected.tiltDegrees, accuracy: 1e-10)
        }

        XCTAssertEqual(mounted.stations(), source.library.stations)
        XCTAssertEqual(mounted.retrogradePassages(), source.library.retrogradePassages)
        XCTAssertEqual(mounted.ringOccurrences(), source.library.ringChronology)
        XCTAssertEqual(mounted.eclipses(), source.library.eclipses)
        XCTAssertEqual(mounted.shellIntervals(), source.library.shellIntervals)
    }
}
