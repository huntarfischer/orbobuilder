import CryptoKit
import Foundation

public enum DioscuriTestimonyResult: String, Codable, Hashable, Sendable {
    case resonant
    case rejected
}

/// Generic candidate-bound envelope returned by the Dioscuri to Hephaestus.
/// Detailed resonance evidence remains Dioscuri-owned; Hephaestus reads only this
/// binding and result when deciding whether the unchanged work may leave the forge.
public struct DioscuriTestimony: Sendable {
    public let candidateSHA256: String
    public let recipeIdentifier: String
    public let recipeVersion: UInt16
    public let resonanceContract: HephaestusResonanceContractIdentity
    public let dioscuriContractVersion: UInt16
    public let result: DioscuriTestimonyResult
    public let evidenceSHA256: String
    public let evidence: DioscuriVerdict

    init(
        candidateSHA256: String,
        recipeIdentifier: String,
        recipeVersion: UInt16,
        resonanceContract: HephaestusResonanceContractIdentity,
        dioscuriContractVersion: UInt16,
        result: DioscuriTestimonyResult,
        evidenceSHA256: String,
        evidence: DioscuriVerdict
    ) {
        self.candidateSHA256 = candidateSHA256
        self.recipeIdentifier = recipeIdentifier
        self.recipeVersion = recipeVersion
        self.resonanceContract = resonanceContract
        self.dioscuriContractVersion = dioscuriContractVersion
        self.result = result
        self.evidenceSHA256 = evidenceSHA256
        self.evidence = evidence
    }

    init(candidate: TimespineCandidate, verdict: DioscuriVerdict) {
        self.candidateSHA256 = candidate.identity.sha256
        self.recipeIdentifier = candidate.forgeRecord.recipeIdentifier
        self.recipeVersion = candidate.forgeRecord.recipeVersion
        self.resonanceContract = candidate.forgeRecord.resonanceContract
        self.dioscuriContractVersion = Dioscuri.contractVersion
        self.result = Self.result(of: verdict)
        self.evidenceSHA256 = Self.evidenceIdentity(of: verdict)
        self.evidence = verdict
    }

    /// Hephaestus may ask whether the envelope still faithfully contains the exact
    /// Dioscuri evidence, without interpreting any domain-specific resonance check.
    var isInternallyConsistent: Bool {
        guard evidenceSHA256 == Self.evidenceIdentity(of: evidence),
              result == Self.result(of: evidence),
              candidateSHA256 == Self.candidateSHA256(of: evidence) else {
            return false
        }

        if case let .certificate(certificate) = evidence {
            return recipeIdentifier == certificate.recipeIdentifier
                && recipeVersion == certificate.recipeVersion
        }
        return true
    }

    private static func result(of verdict: DioscuriVerdict) -> DioscuriTestimonyResult {
        switch verdict {
        case .certificate: return .resonant
        case .rejection: return .rejected
        }
    }

    private static func candidateSHA256(of verdict: DioscuriVerdict) -> String {
        switch verdict {
        case let .certificate(certificate): return certificate.candidateSHA256
        case let .rejection(report): return report.candidateSHA256
        }
    }

    private static func evidenceIdentity(of verdict: DioscuriVerdict) -> String {
        var writer = DioscuriEvidenceWriter()
        switch verdict {
        case let .certificate(certificate):
            writer.string("certificate")
            writer.u16(certificate.contractVersion)
            writer.string(certificate.candidateSHA256)
            writer.string(certificate.recipeIdentifier)
            writer.u16(certificate.recipeVersion)
            writer.u16(certificate.storageVersion)
            let tallies = certificate.scopeTallies.sorted { $0.scope.rawValue < $1.scope.rawValue }
            writer.u64(UInt64(tallies.count))
            for tally in tallies { writer.tally(tally) }

        case let .rejection(report):
            writer.string("rejection")
            writer.u16(report.contractVersion)
            writer.string(report.candidateSHA256)
            let tallies = report.scopeTallies.sorted { $0.scope.rawValue < $1.scope.rawValue }
            writer.u64(UInt64(tallies.count))
            for tally in tallies { writer.tally(tally) }
            writer.u64(UInt64(report.divergences.count))
            for divergence in report.divergences { writer.divergence(divergence) }
        }
        return writer.sha256
    }
}

public extension Dioscuri {
    /// Runs the candidate's bound resonance examination and returns testimony to Hephaestus.
    /// The recipe/contract binding comes from the immutable candidate, never from the caller.
    /// Progress is observational only and cannot influence a verdict.
    static func testify(
        candidate: TimespineCandidate,
        progress: ((DioscuriCertificationProgress) -> Void)? = nil
    ) throws -> DioscuriTestimony {
        let verdict = try Dioscuri(candidate: candidate).certify(progress: progress)
        return DioscuriTestimony(candidate: candidate, verdict: verdict)
    }

    /// Runs or resumes the same bound examination while emitting durable partial testimony.
    /// A checkpoint can restore progress, but it can never itself become a DioscuriTestimony.
    static func testify(
        candidate: TimespineCandidate,
        resumingFrom checkpoint: DioscuriCertificationCheckpoint?,
        progress: ((DioscuriCertificationProgress) -> Void)? = nil,
        checkpointHandler: ((DioscuriCertificationCheckpoint) throws -> Void)? = nil
    ) throws -> DioscuriTestimony {
        let verdict = try Dioscuri(candidate: candidate).certify(
            resumingFrom: checkpoint,
            progress: progress,
            checkpointHandler: checkpointHandler
        )
        return DioscuriTestimony(candidate: candidate, verdict: verdict)
    }
}

private struct DioscuriEvidenceWriter {
    private(set) var data = Data()

    var sha256: String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    mutating func tally(_ value: DioscuriScopeTally) {
        string(value.scope.rawValue)
        i64(Int64(value.questions))
        i64(Int64(value.resonant))
        i64(Int64(value.quantizedCoincidences))
        i64(Int64(value.divergent))
    }

    mutating func divergence(_ value: DioscuriDivergence) {
        string(value.candidateSHA256)
        string(value.scope.rawValue)
        string(value.kind.rawValue)
        i64(value.civicOffsetSeconds)
        string(value.subject)
        string(value.expected)
        string(value.firstObserved)
        string(value.secondObserved)
        byte(value.deterministic ? 1 : 0)
    }

    mutating func string(_ value: String) {
        let bytes = Data(value.utf8)
        u64(UInt64(bytes.count))
        data.append(bytes)
    }

    mutating func byte(_ value: UInt8) {
        data.append(value)
    }

    mutating func u16(_ value: UInt16) {
        var little = value.littleEndian
        withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
    }

    mutating func u64(_ value: UInt64) {
        var little = value.littleEndian
        withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
    }

    mutating func i64(_ value: Int64) {
        var little = value.littleEndian
        withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
    }
}
