import Foundation
import XCTest
@testable import OrboCore

final class MundaneTimespineTests: XCTestCase {
    private struct CandidateFixture: Decodable {
        struct Profile: Decodable {
            let body: String
            let edgeSampleDays: Double
            let coreSampleDays: Double
        }
        let status: String
        let codec: Int
        let astroDNACodec: Int
        let representation: String
        let positionUnitsPerDegree: Int
        let speedUnitsPerDegreePerDay: Int
        let supportedStartJulianDay: Double
        let denseStartJulianDay: Double
        let denseEndJulianDay: Double
        let supportedEndJulianDay: Double
        let estimatedSamplePayloadBytes: Int
        let profiles: [Profile]
    }

    private struct AnalyticReference: ForgeEphemerisReference {
        let epoch = 2_451_545.0

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState {
            let t = julianDay.value - epoch
            let ordinal = Double(body.rawValue + 1)
            let base = 358.7 + ordinal * 0.07
            let linear = body == .trueNorthNode ? -0.32 : 0.35 + ordinal * 0.013
            let quadratic = (ordinal.truncatingRemainder(dividingBy: 3) - 1) * 0.0008
            let cubic = (ordinal.truncatingRemainder(dividingBy: 2) == 0 ? 1 : -1) * 0.00001
            let longitudeValue = base + linear * t + quadratic * t * t + cubic * t * t * t
            let speed = linear + 2 * quadratic * t + 3 * cubic * t * t
            return MundaneCelestialState(
                longitude: CelestialLongitude(longitudeValue)!,
                longitudinalSpeedDegreesPerDay: speed
            )!
        }
    }

    private func fixture() throws -> CandidateFixture {
        try FixtureLoader.decode(
            CandidateFixture.self,
            named: "mundane-timespine-candidate-v1",
            kind: .golden
        )
    }

    private func shortPlan() -> MundaneTimespineForgePlan {
        MundaneTimespineForgePlan(
            version: "v1-construction-fixture",
            astronomicalSource: "analytic-test-reference",
            astronomicalSourceVersion: "1",
            supportedStart: JulianDay(2_451_545.0)!,
            supportedEnd: JulianDay(2_451_553.0)!,
            profiles: MundaneTimespineForge.candidateProfiles
        )!
    }

    func testCandidateFixturePinsSeparateBodyDataProfile() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.status, "stamped-data-candidate")
        XCTAssertEqual(fixture.codec, MundaneTimespine.codec)
        XCTAssertEqual(fixture.astroDNACodec, AstroDNA.codec)
        XCTAssertEqual(fixture.representation, MundaneTimespine.representation)
        XCTAssertEqual(fixture.positionUnitsPerDegree, MundaneTimespine.positionUnitsPerDegree)
        XCTAssertEqual(fixture.speedUnitsPerDegreePerDay, MundaneTimespine.speedUnitsPerDegreePerDay)
        XCTAssertEqual(fixture.profiles.map(\.body), MundaneBody.canonicalOrder.map(\.displayName))
        XCTAssertEqual(fixture.profiles.map(\.edgeSampleDays), MundaneTimespineForge.candidateProfiles.map(\.edgeSampleDays))
        XCTAssertEqual(fixture.profiles.map(\.coreSampleDays), MundaneTimespineForge.candidateProfiles.map(\.coreSampleDays))
        XCTAssertEqual(fixture.profiles[2].body, "Mercury")
        XCTAssertEqual(fixture.profiles[2].edgeSampleDays, 1)
        XCTAssertEqual(fixture.profiles[2].coreSampleDays, 0.125)
    }

    func testFullRangeStampedPayloadEstimateMatchesGoldenMeasurement() throws {
        let fixture = try fixture()
        let plan = try XCTUnwrap(MundaneTimespineForgePlan(
            version: "v1-candidate",
            astronomicalSource: "qualified-reference-required",
            astronomicalSourceVersion: "pending",
            supportedStart: JulianDay(fixture.supportedStartJulianDay)!,
            supportedEnd: JulianDay(fixture.supportedEndJulianDay)!,
            profiles: MundaneTimespineForge.candidateProfiles
        ))
        XCTAssertEqual(MundaneTimespineForge.estimatedSamplePayloadBytes(for: plan), fixture.estimatedSamplePayloadBytes)
        XCTAssertEqual(fixture.denseStartJulianDay, MundaneTimespineForge.v1DenseStart.value)
        XCTAssertEqual(fixture.denseEndJulianDay, MundaneTimespineForge.v1DenseEnd.value)
        XCTAssertLessThan(fixture.estimatedSamplePayloadBytes, 16 * 1_024 * 1_024)
    }

    func testForgeReconstructsArbitraryStatesFromStampedKnots() throws {
        let reference = AnalyticReference()
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: reference)
        for body in MundaneBody.canonicalOrder {
            for offset in [0.05, 0.5, 1.75, 3.5, 6.25, 7.95] {
                let jd = JulianDay(2_451_545.0 + offset)!
                let expected = try reference.state(of: body, at: jd)
                let actual = try timespine.state(of: body, at: jd)
                XCTAssertLessThan(foldedDifference(actual.longitude.degrees, expected.longitude.degrees), 0.000_001)
                XCTAssertEqual(actual.longitudinalSpeedDegreesPerDay, expected.longitudinalSpeedDegreesPerDay, accuracy: 0.000_001)
            }
        }
    }

    func testArtifactSetContainsOneIndependentFilePerBodyAndManifest() throws {
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: AnalyticReference())
        let artifacts = timespine.encodedArtifacts()
        XCTAssertEqual(artifacts.bodyArtifacts.count, 11)
        XCTAssertFalse(artifacts.manifest.isEmpty)
        for body in MundaneBody.canonicalOrder {
            XCTAssertNotNil(artifacts.data(for: body))
            XCTAssertTrue(body.artifactFileName.hasSuffix(".orbbody"))
        }
        let manifestText = try XCTUnwrap(String(data: artifacts.manifest, encoding: .utf8))
        XCTAssertTrue(manifestText.contains("\"codec\" : 2"))
        XCTAssertTrue(manifestText.contains("true-north-node.orbbody"))
    }

    func testSeparateBodyCodecRoundTripsWithoutChangingReads() throws {
        let original = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: AnalyticReference())
        let artifacts = original.encodedArtifacts()
        let decoded = try MundaneTimespine.decodeArtifacts(
            manifest: artifacts.manifest,
            bodyArtifacts: artifacts.bodyArtifacts
        )
        XCTAssertEqual(decoded.checksum, original.checksum)
        for body in MundaneBody.canonicalOrder {
            let jd = JulianDay(2_451_550.125)!
            let a = try original.state(of: body, at: jd)
            let b = try decoded.state(of: body, at: jd)
            XCTAssertEqual(a.longitude.degrees, b.longitude.degrees, accuracy: 1e-12)
            XCTAssertEqual(a.longitudinalSpeedDegreesPerDay, b.longitudinalSpeedDegreesPerDay, accuracy: 1e-12)
        }
    }

    func testBodyChecksumDetectsMutationWithoutPoisoningOtherBodies() throws {
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: AnalyticReference())
        let artifacts = timespine.encodedArtifacts()
        var bodies = artifacts.bodyArtifacts
        var mercury = try XCTUnwrap(bodies[.mercury])
        mercury[mercury.count - 1] ^= 0x01
        bodies[.mercury] = mercury
        XCTAssertThrowsError(
            try MundaneTimespine.decodeArtifacts(manifest: artifacts.manifest, bodyArtifacts: bodies)
        ) { error in
            XCTAssertEqual(error as? MundaneTimespineError, .checksumMismatch(.mercury))
        }
        XCTAssertEqual(bodies[.sun], artifacts.bodyArtifacts[.sun])
    }

    func testTrueNorthNodeMotionComesFromStampedVelocity() throws {
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: AnalyticReference())
        let state = try timespine.state(of: .trueNorthNode, at: JulianDay(2_451_548.25)!)
        XCTAssertLessThan(state.longitudinalSpeedDegreesPerDay, 0)
        XCTAssertEqual(state.motion, .retrograde)
    }

    func testLongitudeInterpolationSurvivesZeroDegreeCrossing() throws {
        let reference = AnalyticReference()
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: reference)
        for offset in stride(from: 0.0, to: 8.0, by: 0.125) {
            let jd = JulianDay(2_451_545.0 + offset)!
            let expected = try reference.state(of: .sun, at: jd)
            let actual = try timespine.state(of: .sun, at: jd)
            XCTAssertLessThan(foldedDifference(actual.longitude.degrees, expected.longitude.degrees), 0.000_001)
        }
    }

    func testResumableForgeProducesByteIdenticalBodySet() throws {
        let plan = shortPlan()
        let reference = AnalyticReference()
        let oneShot = try MundaneTimespineForge.manufacture(plan: plan, reference: reference).encodedArtifacts()
        var cursor = MundaneTimespineForge.makeCursor(plan: plan)
        while !cursor.isComplete {
            _ = try cursor.step(reference: reference, sampleBudget: 7)
        }
        let chunked = try cursor.product().encodedArtifacts()
        XCTAssertEqual(chunked.manifest, oneShot.manifest)
        XCTAssertEqual(chunked.bodyArtifacts, oneShot.bodyArtifacts)
        XCTAssertEqual(chunked.manifestChecksum, oneShot.manifestChecksum)
    }

    func testTimespineRangeIsHalfOpenAndChecksumUsesKnownSHA256Vector() throws {
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: AnalyticReference())
        XCTAssertTrue(timespine.contains(JulianDay(2_451_545.0)!))
        XCTAssertTrue(timespine.contains(JulianDay(2_451_552.999)!))
        XCTAssertFalse(timespine.contains(JulianDay(2_451_553.0)!))
        XCTAssertThrowsError(try timespine.state(of: .sun, at: JulianDay(2_451_553.0)!))
        XCTAssertEqual(
            MundaneTimespineCodec.sha256Hex(Data("abc".utf8)),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
    }

    private func foldedDifference(_ a: Double, _ b: Double) -> Double {
        var delta = (a - b).truncatingRemainder(dividingBy: 360)
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return abs(delta)
    }
}
