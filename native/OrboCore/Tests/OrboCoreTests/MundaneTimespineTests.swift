import Foundation
import XCTest
@testable import OrboCore

final class MundaneTimespineTests: XCTestCase {
    private struct CandidateFixture: Decodable {
        struct Profile: Decodable {
            let body: String
            let segmentDays: Double
        }

        let status: String
        let codec: Int
        let astroDNACodec: Int
        let representation: String
        let coefficientScale: Int
        let polynomialDegree: Int
        let supportedStartJulianDay: Double
        let supportedEndJulianDay: Double
        let estimatedCoefficientBytes: Int
        let profiles: [Profile]
    }

    private struct AnalyticReference: ForgeEphemerisReference {
        let epoch = 2_451_545.0

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState {
            let t = julianDay.value - epoch
            let ordinal = Double(body.rawValue + 1)
            let base = 357.25 + ordinal * 0.13
            let linear = body == .trueNorthNode ? -0.31 : 0.42 + ordinal * 0.017
            let quadratic = (ordinal.truncatingRemainder(dividingBy: 3) - 1) * 0.0012
            let cubic = (ordinal.truncatingRemainder(dividingBy: 2) == 0 ? 1 : -1) * 0.000015
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

    func testCandidateFixturePinsRepresentationAndCanonicalBodyProfile() throws {
        let fixture = try fixture()
        XCTAssertEqual(fixture.status, "candidate-representation-only")
        XCTAssertEqual(fixture.codec, MundaneTimespine.codec)
        XCTAssertEqual(fixture.astroDNACodec, AstroDNA.codec)
        XCTAssertEqual(fixture.representation, MundaneTimespine.representation)
        XCTAssertEqual(fixture.coefficientScale, MundaneTimespine.coefficientScale)
        XCTAssertEqual(fixture.polynomialDegree, 7)
        XCTAssertEqual(fixture.profiles.map(\.body), MundaneBody.canonicalOrder.map(\.displayName))
        XCTAssertEqual(fixture.profiles.map(\.segmentDays), MundaneTimespineForge.candidateProfiles.map(\.segmentDays))
        XCTAssertEqual(
            MundaneTimespineForge.candidateProfiles.first { $0.body == .mercury }?.segmentDays,
            1.0
        )
        XCTAssertEqual(MundaneBody.canonicalOrder.last, .trueNorthNode)
        XCTAssertNil(MundaneBody.trueNorthNode.planet)
    }

    func testFullRangeCandidateCoefficientPayloadEstimateMatchesGoldenMeasurement() throws {
        let fixture = try fixture()
        let plan = try XCTUnwrap(MundaneTimespineForgePlan(
            version: "v1-candidate",
            astronomicalSource: "qualified-reference-required",
            astronomicalSourceVersion: "pending-full-artifact-forge",
            supportedStart: JulianDay(fixture.supportedStartJulianDay)!,
            supportedEnd: JulianDay(fixture.supportedEndJulianDay)!,
            profiles: MundaneTimespineForge.candidateProfiles
        ))
        XCTAssertEqual(
            MundaneTimespineForge.estimatedCoefficientBytes(for: plan),
            fixture.estimatedCoefficientBytes
        )
        XCTAssertLessThan(fixture.estimatedCoefficientBytes, 16 * 1_024 * 1_024)
    }

    func testForgeManufacturesArbitraryStateReadsFromOneUniversalChronology() throws {
        let reference = AnalyticReference()
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: reference)

        for body in MundaneBody.canonicalOrder {
            for offset in [0.05, 0.5, 1.75, 3.5, 6.25, 7.95] {
                let jd = JulianDay(2_451_545.0 + offset)!
                let expected = try reference.state(of: body, at: jd)
                let actual = try timespine.state(of: body, at: jd)
                XCTAssertEqual(actual.longitude.degrees, expected.longitude.degrees, accuracy: 0.000_01)
                XCTAssertEqual(
                    actual.longitudinalSpeedDegreesPerDay,
                    expected.longitudinalSpeedDegreesPerDay,
                    accuracy: 0.000_02
                )
            }
        }
    }

    func testLongitudeUnwrapSurvivesZeroDegreeCrossing() throws {
        let reference = AnalyticReference()
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: reference)
        let body = MundaneBody.sun

        for offset in stride(from: 0.0, to: 8.0, by: 0.125) {
            let jd = JulianDay(2_451_545.0 + offset)!
            let expected = try reference.state(of: body, at: jd)
            let actual = try timespine.state(of: body, at: jd)
            let delta = foldedDifference(actual.longitude.degrees, expected.longitude.degrees)
            XCTAssertLessThan(delta, 0.000_01)
        }
    }

    func testTrueNorthNodeMotionIsReadFromChronologyAndCanBeRetrograde() throws {
        let reference = AnalyticReference()
        let timespine = try MundaneTimespineForge.manufacture(plan: shortPlan(), reference: reference)
        let state = try timespine.state(of: .trueNorthNode, at: JulianDay(2_451_548.25)!)
        XCTAssertLessThan(state.longitudinalSpeedDegreesPerDay, 0)
        XCTAssertEqual(state.motion, .retrograde)
    }

    func testResumableForgeProducesByteIdenticalArtifactToOneShotForge() throws {
        let plan = shortPlan()
        let reference = AnalyticReference()
        let oneShot = try MundaneTimespineForge.manufacture(plan: plan, reference: reference)

        var cursor = MundaneTimespineForge.makeCursor(plan: plan)
        var lastCompleted = 0
        while !cursor.isComplete {
            let progress = try cursor.step(reference: reference, segmentBudget: 3)
            XCTAssertGreaterThanOrEqual(progress.completedSegments, lastCompleted)
            XCTAssertGreaterThanOrEqual(progress.fractionComplete, 0)
            XCTAssertLessThanOrEqual(progress.fractionComplete, 1)
            lastCompleted = progress.completedSegments
        }
        let chunked = try cursor.product()
        XCTAssertEqual(chunked.encodedArtifact(), oneShot.encodedArtifact())
        XCTAssertEqual(chunked.checksum, oneShot.checksum)
    }

    func testBinaryCodecRoundTripsWithoutChangingCelestialReads() throws {
        let original = try MundaneTimespineForge.manufacture(
            plan: shortPlan(),
            reference: AnalyticReference()
        )
        let data = original.encodedArtifact()
        let decoded = try MundaneTimespine.decodeArtifact(data)

        XCTAssertEqual(decoded.metadata.version, original.metadata.version)
        XCTAssertEqual(decoded.metadata.codec, MundaneTimespine.codec)
        XCTAssertEqual(decoded.metadata.astroDNACodec, AstroDNA.codec)
        XCTAssertEqual(decoded.checksum, original.checksum)

        for body in MundaneBody.canonicalOrder {
            let jd = JulianDay(2_451_550.125)!
            XCTAssertEqual(
                try decoded.state(of: body, at: jd).longitude.degrees,
                try original.state(of: body, at: jd).longitude.degrees,
                accuracy: 1e-12
            )
            XCTAssertEqual(
                try decoded.state(of: body, at: jd).longitudinalSpeedDegreesPerDay,
                try original.state(of: body, at: jd).longitudinalSpeedDegreesPerDay,
                accuracy: 1e-12
            )
        }
    }

    func testChecksumUsesKnownSHA256Vector() {
        let data = Data("abc".utf8)
        XCTAssertEqual(
            MundaneTimespineCodec.sha256Hex(data),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
    }

    func testCodecRejectsBadMagicUnsupportedCodecAndTruncation() throws {
        let timespine = try MundaneTimespineForge.manufacture(
            plan: shortPlan(),
            reference: AnalyticReference()
        )
        let valid = timespine.encodedArtifact()

        var badMagic = valid
        badMagic[0] ^= 0xff
        XCTAssertThrowsError(try MundaneTimespine.decodeArtifact(badMagic)) { error in
            XCTAssertEqual(error as? MundaneTimespineError, .invalidArtifactMagic)
        }

        var badCodec = valid
        badCodec[8] = 2
        badCodec[9] = 0
        XCTAssertThrowsError(try MundaneTimespine.decodeArtifact(badCodec)) { error in
            XCTAssertEqual(error as? MundaneTimespineError, .unsupportedCodec(2))
        }

        XCTAssertThrowsError(try MundaneTimespine.decodeArtifact(valid.dropLast(5)))
    }

    func testTimespineRangeIsHalfOpenAndDoesNotGuessOutsideItsArtifact() throws {
        let timespine = try MundaneTimespineForge.manufacture(
            plan: shortPlan(),
            reference: AnalyticReference()
        )
        XCTAssertTrue(timespine.contains(JulianDay(2_451_545.0)!))
        XCTAssertTrue(timespine.contains(JulianDay(2_451_552.999)!))
        XCTAssertFalse(timespine.contains(JulianDay(2_451_553.0)!))
        XCTAssertThrowsError(
            try timespine.state(of: .sun, at: JulianDay(2_451_544.999)!)
        )
        XCTAssertThrowsError(
            try timespine.state(of: .sun, at: JulianDay(2_451_553.0)!)
        )
    }

    private func foldedDifference(_ a: Double, _ b: Double) -> Double {
        var delta = (a - b).truncatingRemainder(dividingBy: 360)
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return abs(delta)
    }
}
