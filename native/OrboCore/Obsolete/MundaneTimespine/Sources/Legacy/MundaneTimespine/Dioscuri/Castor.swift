import Foundation

public enum CastorError: Error, Equatable, CustomStringConvertible {
    case candidateIdentityMismatch
    case candidateProvenanceMismatch
    case candidateContractMismatch
    case runtimeImageUnavailable
    case handoffCandidateMismatch
    case outsideSupportedSpan(Int64)

    public var description: String {
        switch self {
        case .candidateIdentityMismatch:
            return "Castor candidate bytes do not match the Hephaestus candidate identity."
        case .candidateProvenanceMismatch:
            return "Castor candidate provenance does not match the encoded ORBOTS artifact."
        case .candidateContractMismatch:
            return "Castor candidate structural counts do not match the Hephaestus Forge record."
        case .runtimeImageUnavailable:
            return "Castor cannot form the ephemeris-free runtime image required for civic navigation."
        case .handoffCandidateMismatch:
            return "Castor received a civic handoff for a different Timespine candidate."
        case let .outsideSupportedSpan(offset):
            return "Castor civic offset \(offset) seconds is outside the candidate's supported half-open span."
        }
    }
}

/// The mortal/civic resonator. Castor answers second.
///
/// Castor receives only Pollux's blind civic handoff. He independently verifies the same
/// immutable Hephaestus candidate, enters it through the native runtime Reader, and reports
/// the simultaneous celestial state he finds. He does not receive or infer Pollux's expected
/// celestial identity and performs no comparison or certification.
public struct Castor: Sendable {
    public static let role = "civic resonator"
    public static let nature = "mortal"
    public static let order = "answers second"
    public static let axis = "civic UT"
    public static let inputLaw = "Pollux civic handoff"
    public static let readerRole = "native"
    public static let forgeRole = "none"
    public static let ephemerisRole = "none"
    public static let expectationRole = "none"
    public static let answerLaw = "simultaneous celestial state"
    public static let comparisonRole = "none"

    public let candidateSHA256: String
    public let bodyCount: Int

    private let supportedStart: JulianDay
    private let supportedEnd: JulianDay
    private let reader: MundaneTimespineReader

    public init(candidate: TimespineCandidate) throws {
        let actualIdentity = TimespineCandidateIdentity.hash(artifactData: candidate.artifactData)
        guard actualIdentity == candidate.identity else {
            throw CastorError.candidateIdentityMismatch
        }

        let record = candidate.forgeRecord
        guard record.candidateSHA256 == actualIdentity.sha256,
              record.artifactByteCount == candidate.artifactData.count,
              record.storageFamily == MundaneTimespineStorageFormat.identifier,
              record.storageVersion == MundaneTimespineStorageFormat.version,
              record.celestialTimeFirst,
              MundaneTimespineStorageFormat.celestialTimeFirst else {
            throw CastorError.candidateProvenanceMismatch
        }

        let storage = try candidate.artifact.storageImage()
        let occurrenceCount = storage.bodies.reduce(0) { $0 + $1.occurrences.count }
        let stationCount = storage.bodies.reduce(0) { $0 + $1.stations.count }
        let passageCount = storage.bodies.reduce(0) { $0 + $1.retrogradePassages.count }
        guard storage.spanName == record.spanName,
              storage.astronomicalSource == record.astronomicalSource,
              storage.astronomicalSourceVersion == record.astronomicalSourceVersion,
              storage.bodies.count == record.bodyCount,
              occurrenceCount == record.bodyOccurrenceCount,
              stationCount == record.stationCount,
              passageCount == record.retrogradePassageCount,
              storage.relationships.count == record.relationshipCount,
              storage.eclipses.count == record.eclipseCount else {
            throw CastorError.candidateContractMismatch
        }

        guard let runtime = storage.runtimeImage() else {
            throw CastorError.runtimeImageUnavailable
        }

        candidateSHA256 = actualIdentity.sha256
        bodyCount = runtime.bodySeries.count
        supportedStart = runtime.supportedStart
        supportedEnd = runtime.supportedEnd
        reader = MundaneTimespineReader(image: runtime)
    }

    /// Receive only mortal time and independently answer what celestial state exists there.
    public func answer(_ handoff: PolluxCivicHandoff) throws -> CastorAnswer {
        guard handoff.candidateSHA256 == candidateSHA256 else {
            throw CastorError.handoffCandidateMismatch
        }
        guard handoff.civicOffsetSeconds >= 0 else {
            throw CastorError.outsideSupportedSpan(handoff.civicOffsetSeconds)
        }

        guard let julianDay = JulianDay(
            supportedStart.value + Double(handoff.civicOffsetSeconds) / 86_400
        ), julianDay.value >= supportedStart.value,
           julianDay.value < supportedEnd.value else {
            throw CastorError.outsideSupportedSpan(handoff.civicOffsetSeconds)
        }

        let moment = try reader.state(at: julianDay)
        return CastorAnswer(
            candidateSHA256: candidateSHA256,
            civicOffsetSeconds: handoff.civicOffsetSeconds,
            julianDay: julianDay,
            states: moment.states
        )
    }
}
