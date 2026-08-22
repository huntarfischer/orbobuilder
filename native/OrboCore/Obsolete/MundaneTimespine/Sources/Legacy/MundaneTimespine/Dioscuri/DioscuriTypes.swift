import Foundation

public enum DioscuriScope: String, CaseIterable, Codable, Hashable, Sendable {
    case bodyOccurrence = "body-occurrence"
    case marker
    case motion
    case exactRelationship = "exact-relationship"
    case eclipse
}

public enum DioscuriInvariantOutcome: String, Codable, Hashable, Sendable {
    case resonance
    case quantizedCoincidence = "quantized-coincidence"
    case divergence
}

public enum DioscuriDivergenceKind: String, Codable, Hashable, Sendable {
    case celestialIdentity = "celestial-identity"
    case marker
    case motion
    case relationshipGeometry = "relationship-geometry"
    case relationshipOccurrence = "relationship-occurrence"
    case eclipseGeometry = "eclipse-geometry"
    case eclipseOccurrence = "eclipse-occurrence"
    case candidateIdentity = "candidate-identity"
    case nondeterministicResonance = "nondeterministic-resonance"
}

public struct DioscuriInvariantCheck: Hashable, Sendable {
    public let scope: DioscuriScope
    public let outcome: DioscuriInvariantOutcome
    public let kind: DioscuriDivergenceKind
    public let subject: String
    public let expected: String
    public let observed: String

    init(
        scope: DioscuriScope,
        outcome: DioscuriInvariantOutcome,
        kind: DioscuriDivergenceKind,
        subject: String,
        expected: String,
        observed: String
    ) {
        self.scope = scope
        self.outcome = outcome
        self.kind = kind
        self.subject = subject
        self.expected = expected
        self.observed = observed
    }
}

public struct PolluxConfirmation: Hashable, Sendable {
    public let candidateSHA256: String
    public let civicOffsetSeconds: Int64
    public let checks: [DioscuriInvariantCheck]

    public var isResonant: Bool {
        !checks.contains { $0.outcome == .divergence }
    }

    public var hasQuantizedCoincidence: Bool {
        checks.contains { $0.outcome == .quantizedCoincidence }
    }

    init(candidateSHA256: String, civicOffsetSeconds: Int64, checks: [DioscuriInvariantCheck]) {
        self.candidateSHA256 = candidateSHA256
        self.civicOffsetSeconds = civicOffsetSeconds
        self.checks = checks
    }
}

public struct DioscuriDivergence: Hashable, Codable, Sendable {
    public let candidateSHA256: String
    public let scope: DioscuriScope
    public let kind: DioscuriDivergenceKind
    public let civicOffsetSeconds: Int64
    public let subject: String
    public let expected: String
    public let firstObserved: String
    public let secondObserved: String
    public let deterministic: Bool

    init(
        candidateSHA256: String,
        scope: DioscuriScope,
        kind: DioscuriDivergenceKind,
        civicOffsetSeconds: Int64,
        subject: String,
        expected: String,
        firstObserved: String,
        secondObserved: String,
        deterministic: Bool
    ) {
        self.candidateSHA256 = candidateSHA256
        self.scope = scope
        self.kind = kind
        self.civicOffsetSeconds = civicOffsetSeconds
        self.subject = subject
        self.expected = expected
        self.firstObserved = firstObserved
        self.secondObserved = secondObserved
        self.deterministic = deterministic
    }
}

public struct DioscuriScopeTally: Hashable, Codable, Sendable {
    public let scope: DioscuriScope
    public let questions: Int
    public let resonant: Int
    public let quantizedCoincidences: Int
    public let divergent: Int

    init(
        scope: DioscuriScope,
        questions: Int,
        resonant: Int,
        quantizedCoincidences: Int,
        divergent: Int
    ) {
        self.scope = scope
        self.questions = questions
        self.resonant = resonant
        self.quantizedCoincidences = quantizedCoincidences
        self.divergent = divergent
    }
}

/// Counts fully testified questions in each deterministic certification phase. A checkpoint is
/// always taken after a whole question, including any required second strike, never mid-strike.
public struct DioscuriCertificationOffsets: Hashable, Codable, Sendable {
    public var bodyOccurrence: Int
    public var motionTopology: Int
    public var station: Int
    public var exactRelationship: Int
    public var eclipse: Int

    public init(
        bodyOccurrence: Int = 0,
        motionTopology: Int = 0,
        station: Int = 0,
        exactRelationship: Int = 0,
        eclipse: Int = 0
    ) {
        self.bodyOccurrence = bodyOccurrence
        self.motionTopology = motionTopology
        self.station = station
        self.exactRelationship = exactRelationship
        self.eclipse = eclipse
    }

    func value(for phase: DioscuriCertificationPhase) -> Int {
        switch phase {
        case .bodyOccurrence: return bodyOccurrence
        case .motionTopology: return motionTopology
        case .station: return station
        case .exactRelationship: return exactRelationship
        case .eclipse: return eclipse
        }
    }

    mutating func set(_ value: Int, for phase: DioscuriCertificationPhase) {
        switch phase {
        case .bodyOccurrence: bodyOccurrence = value
        case .motionTopology: motionTopology = value
        case .station: station = value
        case .exactRelationship: exactRelationship = value
        case .eclipse: eclipse = value
        }
    }
}

/// Persisted partial testimony state. It is not a verdict, certificate, seal, or quarantine.
/// Resume is allowed only when every binding field still matches the exact candidate and the
/// current Dioscuri certification implementation. Hephaestus never accepts this type as testimony.
public struct DioscuriCertificationCheckpoint: Hashable, Codable, Sendable {
    public static let formatVersion: UInt16 = 1

    public let checkpointFormatVersion: UInt16
    public let candidateSHA256: String
    public let recipeIdentifier: String
    public let recipeVersion: UInt16
    public let resonanceContract: HephaestusResonanceContractIdentity
    public let dioscuriContractVersion: UInt16
    public let certificationImplementationVersion: UInt16
    public let storageVersion: UInt16
    public let completed: DioscuriCertificationOffsets
    public let scopeTallies: [DioscuriScopeTally]
    public let divergences: [DioscuriDivergence]

    init(
        candidate: TimespineCandidate,
        certificationImplementationVersion: UInt16,
        completed: DioscuriCertificationOffsets,
        scopeTallies: [DioscuriScopeTally],
        divergences: [DioscuriDivergence]
    ) {
        self.checkpointFormatVersion = Self.formatVersion
        self.candidateSHA256 = candidate.identity.sha256
        self.recipeIdentifier = candidate.forgeRecord.recipeIdentifier
        self.recipeVersion = candidate.forgeRecord.recipeVersion
        self.resonanceContract = candidate.forgeRecord.resonanceContract
        self.dioscuriContractVersion = Dioscuri.contractVersion
        self.certificationImplementationVersion = certificationImplementationVersion
        self.storageVersion = candidate.forgeRecord.storageVersion
        self.completed = completed
        self.scopeTallies = scopeTallies
        self.divergences = divergences
    }
}

public enum DioscuriCheckpointError: Error, Equatable, CustomStringConvertible {
    case unsupportedFormat(UInt16)
    case candidateMismatch
    case recipeMismatch
    case resonanceContractMismatch
    case dioscuriContractMismatch
    case implementationMismatch
    case storageVersionMismatch
    case invalidProgress
    case invalidTallies
    case invalidDivergenceBinding

    public var description: String {
        switch self {
        case let .unsupportedFormat(version):
            return "Unsupported Dioscuri checkpoint format version \(version)."
        case .candidateMismatch:
            return "Dioscuri checkpoint belongs to a different candidate SHA-256."
        case .recipeMismatch:
            return "Dioscuri checkpoint recipe binding does not match the candidate."
        case .resonanceContractMismatch:
            return "Dioscuri checkpoint resonance contract does not match the candidate."
        case .dioscuriContractMismatch:
            return "Dioscuri checkpoint was made under a different Dioscuri contract version."
        case .implementationMismatch:
            return "Dioscuri checkpoint was made by a different certification implementation version."
        case .storageVersionMismatch:
            return "Dioscuri checkpoint storage version does not match the candidate."
        case .invalidProgress:
            return "Dioscuri checkpoint phase progress is not a valid deterministic prefix."
        case .invalidTallies:
            return "Dioscuri checkpoint tally state is internally inconsistent."
        case .invalidDivergenceBinding:
            return "Dioscuri checkpoint contains divergence evidence for another candidate."
        }
    }
}

public struct DioscuriCertificate: Hashable, Sendable {
    public let contractVersion: UInt16
    public let candidateSHA256: String
    public let recipeIdentifier: String
    public let recipeVersion: UInt16
    public let storageVersion: UInt16
    public let scopeTallies: [DioscuriScopeTally]

    public var totalQuestions: Int { scopeTallies.reduce(0) { $0 + $1.questions } }
    public var quantizedCoincidences: Int { scopeTallies.reduce(0) { $0 + $1.quantizedCoincidences } }

    init(
        contractVersion: UInt16,
        candidateSHA256: String,
        recipeIdentifier: String,
        recipeVersion: UInt16,
        storageVersion: UInt16,
        scopeTallies: [DioscuriScopeTally]
    ) {
        self.contractVersion = contractVersion
        self.candidateSHA256 = candidateSHA256
        self.recipeIdentifier = recipeIdentifier
        self.recipeVersion = recipeVersion
        self.storageVersion = storageVersion
        self.scopeTallies = scopeTallies
    }
}

public struct DioscuriRejectionReport: Hashable, Sendable {
    public let contractVersion: UInt16
    public let candidateSHA256: String
    public let scopeTallies: [DioscuriScopeTally]
    public let divergences: [DioscuriDivergence]

    public var confirmedDivergenceCount: Int {
        divergences.filter(\.deterministic).count
    }

    public var nondeterministicCount: Int {
        divergences.filter { !$0.deterministic }.count
    }

    init(
        contractVersion: UInt16,
        candidateSHA256: String,
        scopeTallies: [DioscuriScopeTally],
        divergences: [DioscuriDivergence]
    ) {
        self.contractVersion = contractVersion
        self.candidateSHA256 = candidateSHA256
        self.scopeTallies = scopeTallies
        self.divergences = divergences
    }
}

public enum DioscuriVerdict: Sendable {
    case certificate(DioscuriCertificate)
    case rejection(DioscuriRejectionReport)
}

public struct DioscuriStrikeReport: Sendable {
    public let first: PolluxConfirmation
    public let second: PolluxConfirmation?
    public let divergences: [DioscuriDivergence]

    public var isResonant: Bool { divergences.isEmpty }
}
