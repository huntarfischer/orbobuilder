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

public struct DioscuriDivergence: Hashable, Sendable {
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

public struct DioscuriScopeTally: Hashable, Sendable {
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
