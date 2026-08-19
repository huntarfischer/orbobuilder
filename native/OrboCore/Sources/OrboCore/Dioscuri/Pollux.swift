import Foundation

public enum PolluxError: Error, Equatable, CustomStringConvertible {
    case candidateIdentityMismatch
    case candidateProvenanceMismatch
    case candidateContractMismatch
    case markerBodyMissing(focal: MundaneBody, marker: MundaneBody)
    case ambiguousCelestialIdentity(body: MundaneBody, celestialTick: Int)
    case ambiguousStationIdentity(body: MundaneBody, celestialMicrodegrees: UInt32)
    case ambiguousRelationshipIdentity
    case ambiguousEclipseIdentity
    case celestialAddressShapeMismatch(body: MundaneBody)
    case celestialAddressNotFound(body: MundaneBody, celestialTick: Int)

    public var description: String {
        switch self {
        case .candidateIdentityMismatch:
            return "Pollux candidate bytes do not match the Hephaestus candidate identity."
        case .candidateProvenanceMismatch:
            return "Pollux candidate provenance does not match the encoded ORBOTS artifact."
        case .candidateContractMismatch:
            return "Pollux candidate structural counts do not match the Hephaestus Forge record."
        case let .markerBodyMissing(focal, marker):
            return "Pollux cannot address \(focal.displayName): marker body \(marker.displayName) is absent from the candidate."
        case let .ambiguousCelestialIdentity(body, celestialTick):
            return "Pollux found a repeated celestial identity for \(body.displayName) at tick \(celestialTick)."
        case let .ambiguousStationIdentity(body, celestialMicrodegrees):
            return "Pollux found a repeated station identity for \(body.displayName) at \(celestialMicrodegrees) microdegrees."
        case .ambiguousRelationshipIdentity:
            return "Pollux found duplicate exact-relationship records for the same qualified celestial recurrence and stored civic occurrence."
        case .ambiguousEclipseIdentity:
            return "Pollux found a repeated eclipse celestial identity."
        case let .celestialAddressShapeMismatch(body):
            return "Pollux celestial address shape does not match the stored tract for \(body.displayName)."
        case let .celestialAddressNotFound(body, celestialTick):
            return "Pollux could not find \(body.displayName) celestial tick \(celestialTick) with that marker fingerprint."
        }
    }
}

/// The immortal/celestial resonator. Pollux asks first.
///
/// Pollux knows a celestial identity before he knows its civic occurrence. He decodes the
/// immutable Hephaestus candidate directly, builds an independent celestial index, and never
/// consults MundaneTimespineReader, Forge, or an ephemeris.
public struct Pollux: Sendable {
    public static let role = "celestial resonator"
    public static let nature = "immortal"
    public static let order = "asks first"
    public static let axis = "celestial"
    public static let identityLaw = "tick + marker fingerprint"
    public static let orderingLaw = "celestial"
    public static let readerRole = "none"
    public static let ephemerisRole = "none"
    public static let civicTimeRole = "handoff only"
    public static let ambiguityPolicy = "reject unresolved ambiguity / qualify lawful recurrences"

    public let candidateSHA256: String
    public let bodyCount: Int
    public let questionCount: Int

    private let bodyIndexes: [PolluxBodyIndex]

    public init(candidate: TimespineCandidate) throws {
        let actualIdentity = TimespineCandidateIdentity.hash(artifactData: candidate.artifactData)
        guard actualIdentity == candidate.identity else {
            throw PolluxError.candidateIdentityMismatch
        }

        let record = candidate.forgeRecord
        guard record.candidateSHA256 == actualIdentity.sha256,
              record.artifactByteCount == candidate.artifactData.count,
              record.storageFamily == MundaneTimespineStorageFormat.identifier,
              record.storageVersion == MundaneTimespineStorageFormat.version,
              record.celestialTimeFirst,
              MundaneTimespineStorageFormat.celestialTimeFirst else {
            throw PolluxError.candidateProvenanceMismatch
        }

        let image = try candidate.artifact.storageImage()
        let occurrenceCount = image.bodies.reduce(0) { $0 + $1.occurrences.count }
        let stationCount = image.bodies.reduce(0) { $0 + $1.stations.count }
        let passageCount = image.bodies.reduce(0) { $0 + $1.retrogradePassages.count }
        guard image.spanName == record.spanName,
              image.astronomicalSource == record.astronomicalSource,
              image.astronomicalSourceVersion == record.astronomicalSourceVersion,
              image.bodies.count == record.bodyCount,
              occurrenceCount == record.bodyOccurrenceCount,
              stationCount == record.stationCount,
              passageCount == record.retrogradePassageCount,
              image.relationships.count == record.relationshipCount,
              image.eclipses.count == record.eclipseCount else {
            throw PolluxError.candidateContractMismatch
        }

        let availableBodies = Set(image.bodies.map(\.body))
        for storedBody in image.bodies {
            for marker in storedBody.markerBodies where !availableBodies.contains(marker) {
                throw PolluxError.markerBodyMissing(focal: storedBody.body, marker: marker)
            }
        }

        let storedByBody = Dictionary(uniqueKeysWithValues: image.bodies.map { ($0.body, $0) })
        var indexes: [PolluxBodyIndex] = []
        indexes.reserveCapacity(image.bodies.count)
        for body in MundaneBody.canonicalOrder {
            guard let stored = storedByBody[body] else { continue }
            indexes.append(try PolluxBodyIndex(storedBody: stored))
        }
        guard indexes.count == image.bodies.count else {
            throw PolluxError.candidateContractMismatch
        }

        candidateSHA256 = actualIdentity.sha256
        bodyCount = indexes.count
        questionCount = indexes.reduce(0) { $0 + $1.occurrences.count }
        bodyIndexes = indexes
    }

    /// Begin with a celestial identity and discover its civic occurrence.
    public func ask(_ address: PolluxCelestialAddress) throws -> PolluxQuestion {
        guard let index = bodyIndexes.first(where: { $0.body == address.body }) else {
            throw PolluxError.celestialAddressNotFound(
                body: address.body,
                celestialTick: address.celestialTick
            )
        }
        let occurrenceIndex = try index.occurrenceIndex(for: address)
        return index.question(
            occurrenceIndex: occurrenceIndex,
            candidateSHA256: candidateSHA256
        )
    }

    /// Deterministic exhaustive order: canonical body, celestial tick, marker fingerprint.
    public func makeQuestionCursor() -> PolluxQuestionCursor {
        PolluxQuestionCursor(
            candidateSHA256: candidateSHA256,
            bodyIndexes: bodyIndexes
        )
    }

    /// Resume that same deterministic order after `completed` fully testified questions.
    /// Seeking touches only the compact celestial index; no Castor read and no prior strike repeats.
    func makeQuestionCursor(startingAt completed: Int) -> PolluxQuestionCursor? {
        guard (0...questionCount).contains(completed) else { return nil }
        return PolluxQuestionCursor(
            candidateSHA256: candidateSHA256,
            bodyIndexes: bodyIndexes,
            startingAt: completed
        )
    }
}

public struct PolluxQuestionCursor: Sendable {
    private let candidateSHA256: String
    private let bodyIndexes: [PolluxBodyIndex]
    private var bodyPosition = 0
    private var celestialTick = 0
    private var bucketPosition = 0

    init(
        candidateSHA256: String,
        bodyIndexes: [PolluxBodyIndex],
        startingAt completed: Int = 0
    ) {
        self.candidateSHA256 = candidateSHA256
        self.bodyIndexes = bodyIndexes
        seek(to: completed)
    }

    public mutating func next() -> PolluxQuestion? {
        while bodyPosition < bodyIndexes.count {
            let index = bodyIndexes[bodyPosition]

            while celestialTick < index.occurrenceIndicesByTick.count {
                let bucket = index.occurrenceIndicesByTick[celestialTick]
                if bucketPosition < bucket.count {
                    let occurrenceIndex = bucket[bucketPosition]
                    bucketPosition += 1
                    return index.question(
                        occurrenceIndex: occurrenceIndex,
                        candidateSHA256: candidateSHA256
                    )
                }
                celestialTick += 1
                bucketPosition = 0
            }

            bodyPosition += 1
            celestialTick = 0
            bucketPosition = 0
        }

        return nil
    }

    private mutating func seek(to completed: Int) {
        guard completed > 0 else { return }
        var remaining = completed

        for bodyIndex in bodyIndexes.indices {
            let index = bodyIndexes[bodyIndex]
            if remaining >= index.occurrences.count {
                remaining -= index.occurrences.count
                continue
            }

            bodyPosition = bodyIndex
            celestialTick = 0
            bucketPosition = 0
            while celestialTick < index.occurrenceIndicesByTick.count {
                let bucketCount = index.occurrenceIndicesByTick[celestialTick].count
                if remaining < bucketCount {
                    bucketPosition = remaining
                    return
                }
                remaining -= bucketCount
                celestialTick += 1
            }
            return
        }

        bodyPosition = bodyIndexes.count
        celestialTick = 0
        bucketPosition = 0
    }
}
