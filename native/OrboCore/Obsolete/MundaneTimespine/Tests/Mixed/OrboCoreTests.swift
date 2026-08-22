import Foundation
import XCTest
@testable import OrboCore

final class OrboCoreTests: XCTestCase {
    func testPhaseZeroLinkageSentinel() {
        XCTAssertEqual(OrboCoreBuild.linkageSentinel, "0.0")
    }

    func testCastorAnswersBlindPolluxHandoffThroughNativeReader() throws {
        let candidate = try makeCastorCandidate(bodies: castorFixtureBodies())
        let pollux = try Pollux(candidate: candidate)
        let castor = try Castor(candidate: candidate)
        let address = try XCTUnwrap(PolluxCelestialAddress(
            body: .mercury,
            celestialTick: 170,
            ticksPerDegree: 10,
            markerFingerprint: [PolluxMarkerCell(body: .sun, wholeDegree: 243)!]
        ))
        let question = try pollux.ask(address)

        let answer = try castor.answer(question.handoff)
        let mercury = try XCTUnwrap(answer[.mercury])
        let sun = try XCTUnwrap(answer[.sun])

        XCTAssertEqual(Castor.role, "civic resonator")
        XCTAssertEqual(Castor.nature, "mortal")
        XCTAssertEqual(Castor.order, "answers second")
        XCTAssertEqual(Castor.axis, "civic UT")
        XCTAssertEqual(Castor.inputLaw, "Pollux civic handoff")
        XCTAssertEqual(Castor.readerRole, "native")
        XCTAssertEqual(Castor.forgeRole, "none")
        XCTAssertEqual(Castor.ephemerisRole, "none")
        XCTAssertEqual(Castor.expectationRole, "none")
        XCTAssertEqual(Castor.comparisonRole, "none")
        XCTAssertEqual(Castor.answerLaw, "simultaneous celestial state")

        XCTAssertEqual(answer.candidateSHA256, candidate.identity.sha256)
        XCTAssertEqual(answer.civicOffsetSeconds, 4_321)
        XCTAssertEqual(mercury.celestialTimeDegrees, 17.0, accuracy: 1e-12)
        XCTAssertEqual(mercury.motion, .retrograde)
        XCTAssertEqual(mercury.source, .storedAnchor)
        XCTAssertFalse(mercury.isStation)

        // Castor derives the marker body's raw celestial state from the Sun's own chronology.
        // He is not handed Pollux's stored marker cell of 243 degrees.
        XCTAssertEqual(sun.source, .interpolated)
        XCTAssertGreaterThan(sun.celestialTimeDegrees, 243.0)
        XCTAssertLessThan(sun.celestialTimeDegrees, 244.0)
    }

    func testCastorFocalPolluxOccurrenceReturnsAsStoredAnchor() throws {
        let candidate = try makeCastorCandidate(bodies: castorFixtureBodies())
        let pollux = try Pollux(candidate: candidate)
        let castor = try Castor(candidate: candidate)
        let address = try XCTUnwrap(PolluxCelestialAddress(
            body: .mercury,
            celestialTick: 170,
            ticksPerDegree: 10,
            markerFingerprint: [PolluxMarkerCell(body: .sun, wholeDegree: 243)!]
        ))

        let answer = try castor.answer(try pollux.ask(address).handoff)
        let mercury = try XCTUnwrap(answer[.mercury])

        XCTAssertEqual(mercury.celestialTimeDegrees, address.celestialDegrees, accuracy: 1e-12)
        XCTAssertEqual(mercury.source, .storedAnchor)
        XCTAssertEqual(mercury.motion, .retrograde)
    }

    func testCastorRejectsHandoffFromDifferentCandidate() throws {
        let candidate = try makeCastorCandidate(bodies: castorFixtureBodies())
        let castor = try Castor(candidate: candidate)
        let foreign = PolluxCivicHandoff(
            candidateSHA256: String(repeating: "f", count: 64),
            civicOffsetSeconds: 4_321
        )

        XCTAssertThrowsError(try castor.answer(foreign)) { error in
            XCTAssertEqual(error as? CastorError, .handoffCandidateMismatch)
        }
    }

    func testCastorRejectsCivicOccurrenceOutsideHalfOpenSpan() throws {
        let candidate = try makeCastorCandidate(bodies: castorFixtureBodies())
        let castor = try Castor(candidate: candidate)

        XCTAssertThrowsError(try castor.answer(PolluxCivicHandoff(
            candidateSHA256: candidate.identity.sha256,
            civicOffsetSeconds: -1
        ))) { error in
            XCTAssertEqual(error as? CastorError, .outsideSupportedSpan(-1))
        }

        XCTAssertThrowsError(try castor.answer(PolluxCivicHandoff(
            candidateSHA256: candidate.identity.sha256,
            civicOffsetSeconds: 86_400
        ))) { error in
            XCTAssertEqual(error as? CastorError, .outsideSupportedSpan(86_400))
        }
    }

    func testCastorRejectsCandidateThatCannotFormRuntimeImage() throws {
        let lone = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                MundaneTimespineStoredOccurrence(
                    celestialTick: 10,
                    civicOffsetSeconds: 100,
                    sequenceDirection: .increasing,
                    markerWholeDegrees: []
                ),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let candidate = try makeCastorCandidate(bodies: [lone])

        XCTAssertThrowsError(try Castor(candidate: candidate)) { error in
            XCTAssertEqual(error as? CastorError, .runtimeImageUnavailable)
        }
    }

    func testCastorAnswersAllAvailableBodiesInCanonicalOrder() throws {
        let sun = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                MundaneTimespineStoredOccurrence(celestialTick: 10, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                MundaneTimespineStoredOccurrence(celestialTick: 11, civicOffsetSeconds: 200, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let moon = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .moon,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                MundaneTimespineStoredOccurrence(celestialTick: 50, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
                MundaneTimespineStoredOccurrence(celestialTick: 51, civicOffsetSeconds: 200, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let candidate = try makeCastorCandidate(bodies: [moon, sun])
        let castor = try Castor(candidate: candidate)
        let answer = try castor.answer(PolluxCivicHandoff(
            candidateSHA256: candidate.identity.sha256,
            civicOffsetSeconds: 150
        ))

        XCTAssertEqual(castor.bodyCount, 2)
        XCTAssertEqual(answer.states.map(\.body), [.sun, .moon])
        XCTAssertNotNil(answer[.sun])
        XCTAssertNotNil(answer[.moon])
    }

    func testCastorRejectsCandidateWhoseBytesAndIdentityDoNotMatch() throws {
        let candidate = try makeCastorCandidate(bodies: castorFixtureBodies())
        let wrongIdentity = TimespineCandidateIdentity.hash(
            artifactData: Data([0x43, 0x41, 0x53, 0x54, 0x4f, 0x52])
        )
        let mismatched = TimespineCandidate(
            identity: wrongIdentity,
            artifact: candidate.artifact,
            forgeRecord: candidate.forgeRecord
        )

        XCTAssertThrowsError(try Castor(candidate: mismatched)) { error in
            XCTAssertEqual(error as? CastorError, .candidateIdentityMismatch)
        }
    }

    private func castorFixtureBodies() throws -> [MundaneTimespineStoredBody] {
        let sun = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .sun,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                MundaneTimespineStoredOccurrence(
                    celestialTick: 243,
                    civicOffsetSeconds: 4_000,
                    sequenceDirection: .increasing,
                    markerWholeDegrees: []
                ),
                MundaneTimespineStoredOccurrence(
                    celestialTick: 244,
                    civicOffsetSeconds: 5_000,
                    sequenceDirection: .increasing,
                    markerWholeDegrees: []
                ),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let mercury = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .mercury,
            ticksPerDegree: 10,
            markerBodies: [.sun],
            occurrences: [
                MundaneTimespineStoredOccurrence(
                    celestialTick: 171,
                    civicOffsetSeconds: 4_000,
                    sequenceDirection: .decreasing,
                    markerWholeDegrees: [243]
                ),
                MundaneTimespineStoredOccurrence(
                    celestialTick: 170,
                    civicOffsetSeconds: 4_321,
                    sequenceDirection: .decreasing,
                    markerWholeDegrees: [243]
                ),
                MundaneTimespineStoredOccurrence(
                    celestialTick: 169,
                    civicOffsetSeconds: 5_000,
                    sequenceDirection: .decreasing,
                    markerWholeDegrees: [244]
                ),
            ],
            stations: [],
            retrogradePassages: []
        ))
        return [mercury, sun]
    }

    private func makeCastorCandidate(
        bodies: [MundaneTimespineStoredBody]
    ) throws -> TimespineCandidate {
        let start = JulianDay(1_000)!
        let end = JulianDay(1_001)!
        let image = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "Castor XCTest fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodies: bodies,
            relationships: [],
            eclipses: []
        ))
        let data = try image.encodedArtifact()
        let artifact = try MundaneTimespineArtifact(data: data)
        let identity = TimespineCandidateIdentity.hash(artifactData: data)
        let record = TimespineForgeRecord(
            recipeIdentifier: "xctest-castor",
            recipeVersion: 1,
            spanName: image.spanName,
            astronomicalSource: image.astronomicalSource,
            astronomicalSourceVersion: image.astronomicalSourceVersion,
            storageFamily: MundaneTimespineStorageFormat.identifier,
            storageVersion: MundaneTimespineStorageFormat.version,
            celestialTimeFirst: MundaneTimespineStorageFormat.celestialTimeFirst,
            bodyCount: bodies.count,
            bodyOccurrenceCount: bodies.reduce(0) { $0 + $1.occurrences.count },
            stationCount: bodies.reduce(0) { $0 + $1.stations.count },
            retrogradePassageCount: bodies.reduce(0) { $0 + $1.retrogradePassages.count },
            relationshipCount: 0,
            eclipseCount: 0,
            artifactByteCount: data.count,
            candidateSHA256: identity.sha256
        )
        return TimespineCandidate(
            identity: identity,
            artifact: artifact,
            forgeRecord: record
        )
    }
}
