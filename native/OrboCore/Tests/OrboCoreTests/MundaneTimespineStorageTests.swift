import XCTest
@testable import OrboCore

final class MundaneTimespineStorageTests: XCTestCase {
    func testStorageVersionIsIndependentAndCelestialTimeFirst() {
        XCTAssertEqual(MundaneTimespineStorageFormat.version, 2)
        XCTAssertTrue(MundaneTimespineStorageFormat.celestialTimeFirst)
        XCTAssertEqual(MundaneTimespineStorageFormat.microdegreesPerDegree, 1_000_000)
        XCTAssertEqual(AstroDNA.codec, 4)
    }

    func testDeterministicRoundTripPreservesCelestialAnatomy() throws {
        let fixture = try makeFixture()
        let first = try fixture.encodedArtifact()
        let second = try fixture.encodedArtifact()

        XCTAssertEqual(first, second)
        XCTAssertEqual(Array(first.prefix(8)), Array("ORBOTS02".utf8))
        XCTAssertEqual(first[8], 2)
        XCTAssertEqual(first[9], 0)
        XCTAssertEqual(first[10] & 1, 1)

        let artifact = try MundaneTimespineArtifact(data: first)
        let decoded = try artifact.storageImage()
        XCTAssertEqual(decoded.spanName, fixture.spanName)
        XCTAssertEqual(decoded.bodies.count, 1)
        XCTAssertEqual(decoded.bodies[0].occurrences.count, 3)
        XCTAssertEqual(decoded.bodies[0].occurrences[1].markerWholeDegrees, [251])
        XCTAssertEqual(decoded.bodies[0].stations.count, 1)
        XCTAssertEqual(decoded.bodies[0].retrogradePassages.count, 1)
        XCTAssertEqual(decoded.relationships.map(\.mark), [.trine, .semisquare])
        XCTAssertEqual(decoded.eclipses.count, 1)
        XCTAssertEqual(decoded.eclipses[0].centrality, "central")
        XCTAssertNoThrow(try artifact.runtimeImage())
    }

    func testExactRelationshipStoresOneCelestialCoordinateAndRingGeometryReconstructsTheOther() throws {
        let fixture = try makeFixture()
        let decoded = try MundaneTimespineArtifact(storageImage: fixture).storageImage()
        let major = decoded.relationships[0]
        let minor = decoded.relationships[1]

        XCTAssertEqual(major.bodyBCelestialTimeDegrees, 220.123456, accuracy: 0.000001)
        XCTAssertEqual(minor.bodyBCelestialTimeDegrees, 325.987655, accuracy: 0.000001)
        XCTAssertEqual(major.exactAspectResidualArcSeconds, 0)
        XCTAssertEqual(minor.exactAspectResidualArcSeconds, 0)

        let originalMajor = fixture.relationships[0]
        let angularErrorArcSeconds = abs(major.bodyACelestialTimeDegrees - originalMajor.bodyACelestialTimeDegrees) * 3_600
        XCTAssertLessThanOrEqual(angularErrorArcSeconds, 0.0018 + 1e-9)

        let civicErrorSeconds = abs(major.julianDay.value - originalMajor.julianDay.value) * 86_400
        XCTAssertLessThanOrEqual(civicErrorSeconds, 0.50001)
    }

    func testEclipseRemainsCelestialDegreeFirstWithCivicOccurrence() throws {
        let fixture = try makeFixture()
        let eclipse = try XCTUnwrap(MundaneTimespineArtifact(storageImage: fixture).storageImage().eclipses.first)
        let original = try XCTUnwrap(fixture.eclipses.first)

        XCTAssertEqual(eclipse.kind, .solar)
        XCTAssertEqual(eclipse.type, .total)
        XCTAssertEqual(eclipse.eclipseDegree, 44.123457, accuracy: 0.000001)
        XCTAssertEqual(eclipse.centrality, "central")
        XCTAssertEqual(eclipse.magnitude, original.magnitude)
        XCTAssertEqual(eclipse.secondaryMagnitude, original.secondaryMagnitude)
        XCTAssertLessThanOrEqual(abs(eclipse.eclipseDegree - original.eclipseDegree) * 3_600, 0.0018 + 1e-9)
        XCTAssertLessThanOrEqual(abs(eclipse.julianDay.value - original.julianDay.value) * 86_400, 0.50001)
    }

    func testArtifactRejectsVersionLawAndTruncationCorruption() throws {
        let bytes = try makeFixture().encodedArtifact()

        var badVersion = bytes
        badVersion[8] = 3
        XCTAssertThrowsError(try MundaneTimespineArtifact(data: badVersion)) { error in
            XCTAssertEqual(error as? MundaneTimespineStorageError, .unsupportedVersion(3))
        }

        var missingLaw = bytes
        missingLaw[10] = 0
        XCTAssertThrowsError(try MundaneTimespineArtifact(data: missingLaw)) { error in
            XCTAssertEqual(error as? MundaneTimespineStorageError, .celestialTimeLawMissing)
        }

        XCTAssertThrowsError(try MundaneTimespineArtifact(data: Data(bytes.dropLast())))
    }

    func testStorageImageRejectsEventsOutsideHalfOpenSpan() throws {
        let start = JulianDay(1_000)!
        let end = JulianDay(1_001)!
        let body = try makeBody()
        let atExclusiveEnd = MundaneTimespineRelationshipEvent(
            bodyA: .sun,
            bodyB: .moon,
            mark: .square,
            orientation: .bodyBAhead,
            bodyACelestialTimeDegrees: 10,
            bodyBCelestialTimeDegrees: 100,
            julianDay: end,
            exactAspectResidualArcSeconds: 0
        )!

        XCTAssertNil(MundaneTimespineStorageImage(
            spanName: "half-open",
            astronomicalSource: "fixture",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodies: [body],
            relationships: [atExclusiveEnd]
        ))
    }

    private func makeFixture() throws -> MundaneTimespineStorageImage {
        let start = JulianDay(1_000)!
        let end = JulianDay(1_001)!
        let body = try makeBody()

        let major = MundaneTimespineRelationshipEvent(
            bodyA: .mercury,
            bodyB: .venus,
            mark: .trine,
            orientation: .bodyBAhead,
            bodyACelestialTimeDegrees: 100.1234564,
            bodyBCelestialTimeDegrees: 220.1234564,
            julianDay: JulianDay(start.value + 1_234.4 / 86_400)!,
            exactAspectResidualArcSeconds: 0.00002
        )!
        let minor = MundaneTimespineRelationshipEvent(
            bodyA: .mars,
            bodyB: .jupiter,
            mark: .semisquare,
            orientation: .bodyAAhead,
            bodyACelestialTimeDegrees: 10.9876546,
            bodyBCelestialTimeDegrees: 325.9876546,
            julianDay: JulianDay(start.value + 2_345.6 / 86_400)!,
            exactAspectResidualArcSeconds: 0.00001
        )!
        let eclipseJD = JulianDay(start.value + 3_456.2 / 86_400)!
        let eclipse = MundaneTimespineEclipseEvent(
            kind: .solar,
            type: .total,
            eclipseDegree: 44.1234566,
            julianDay: eclipseJD,
            greatestEclipseJulianDay: JulianDay(eclipseJD.value + 47.4 / 86_400)!,
            magnitude: 1.0234,
            secondaryMagnitude: 0.991,
            centrality: "central"
        )!

        return try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "storage fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodies: [body],
            relationships: [major, minor],
            eclipses: [eclipse]
        ))
    }

    private func makeBody() throws -> MundaneTimespineStoredBody {
        try XCTUnwrap(MundaneTimespineStoredBody(
            body: .mercury,
            ticksPerDegree: 1,
            markerBodies: [.sun],
            occurrences: [
                MundaneTimespineStoredOccurrence(
                    celestialTick: 100,
                    civicOffsetSeconds: 0,
                    sequenceDirection: .increasing,
                    markerWholeDegrees: [250]
                ),
                MundaneTimespineStoredOccurrence(
                    celestialTick: 101,
                    civicOffsetSeconds: 100,
                    sequenceDirection: .increasing,
                    markerWholeDegrees: [251]
                ),
                MundaneTimespineStoredOccurrence(
                    celestialTick: 102,
                    civicOffsetSeconds: 200,
                    sequenceDirection: .decreasing,
                    markerWholeDegrees: [252]
                ),
            ],
            stations: [
                MundaneTimespineStoredStation(
                    celestialMicrodegrees: 101_500_000,
                    civicOffsetSeconds: 150,
                    motionAfter: .retrograde
                )
            ],
            retrogradePassages: [
                MundaneTimespineStoredRetrogradePassage(
                    startCelestialMicrodegrees: 101_500_000,
                    endCelestialMicrodegrees: 101_000_000,
                    startCivicOffsetSeconds: 150,
                    endCivicOffsetSeconds: 250
                )
            ]
        ))
    }
}
