import CryptoKit
import Foundation

public enum HephaestusQuarantineReason: String, Codable, Hashable, Sendable {
    case candidateIdentityMismatch = "candidate-identity-mismatch"
    case fabricationRecordMismatch = "fabrication-record-mismatch"
    case testimonyCandidateMismatch = "testimony-candidate-mismatch"
    case testimonyRecipeMismatch = "testimony-recipe-mismatch"
    case resonanceContractMismatch = "resonance-contract-mismatch"
    case unsupportedDioscuriContract = "unsupported-dioscuri-contract"
    case malformedTestimony = "malformed-testimony"
    case dioscuriRejected = "dioscuri-rejected"
}

/// Deterministic sidecar proving Hephaestus completed one unchanged candidate.
/// The seal never alters the artifact bytes the Dioscuri resonated.
public struct HephaestusSeal: Hashable, Codable, Sendable {
    public static let contractVersion: UInt16 = 1
    public static let identityAlgorithm = "SHA-256"

    public let contractVersion: UInt16
    public let candidateSHA256: String
    public let artifactByteCount: Int
    public let recipeIdentifier: String
    public let recipeVersion: UInt16
    public let resonanceContract: HephaestusResonanceContractIdentity
    public let dioscuriContractVersion: UInt16
    public let dioscuriEvidenceSHA256: String
    public let sealSHA256: String

    init(candidate: TimespineCandidate, testimony: DioscuriTestimony) {
        self.contractVersion = Self.contractVersion
        self.candidateSHA256 = candidate.identity.sha256
        self.artifactByteCount = candidate.artifactData.count
        self.recipeIdentifier = candidate.forgeRecord.recipeIdentifier
        self.recipeVersion = candidate.forgeRecord.recipeVersion
        self.resonanceContract = candidate.forgeRecord.resonanceContract
        self.dioscuriContractVersion = testimony.dioscuriContractVersion
        self.dioscuriEvidenceSHA256 = testimony.evidenceSHA256
        self.sealSHA256 = Self.identity(
            candidateSHA256: candidate.identity.sha256,
            artifactByteCount: candidate.artifactData.count,
            recipeIdentifier: candidate.forgeRecord.recipeIdentifier,
            recipeVersion: candidate.forgeRecord.recipeVersion,
            resonanceContract: candidate.forgeRecord.resonanceContract,
            dioscuriContractVersion: testimony.dioscuriContractVersion,
            dioscuriEvidenceSHA256: testimony.evidenceSHA256
        )
    }

    private static func identity(
        candidateSHA256: String,
        artifactByteCount: Int,
        recipeIdentifier: String,
        recipeVersion: UInt16,
        resonanceContract: HephaestusResonanceContractIdentity,
        dioscuriContractVersion: UInt16,
        dioscuriEvidenceSHA256: String
    ) -> String {
        var writer = HephaestusSealWriter()
        writer.u16(contractVersion)
        writer.string(candidateSHA256)
        writer.i64(Int64(artifactByteCount))
        writer.string(recipeIdentifier)
        writer.u16(recipeVersion)
        writer.string(resonanceContract.identifier)
        writer.u16(resonanceContract.version)
        writer.u16(dioscuriContractVersion)
        writer.string(dioscuriEvidenceSHA256)
        return writer.sha256
    }
}

/// Successfully completed work. The candidate remains the exact immutable object
/// manufactured before Dioscuri resonance; the seal and testimony are sidecars.
public struct HephaestusSealedArtifact: Sendable {
    public let candidate: TimespineCandidate
    public let testimony: DioscuriTestimony
    public let seal: HephaestusSeal

    init(candidate: TimespineCandidate, testimony: DioscuriTestimony, seal: HephaestusSeal) {
        self.candidate = candidate
        self.testimony = testimony
        self.seal = seal
    }
}

/// Failed closing work is preserved intact for diagnosis. Hephaestus never mutates,
/// repairs, averages, or deletes the candidate during quarantine.
public struct HephaestusQuarantinedArtifact: Sendable {
    public let candidate: TimespineCandidate
    public let testimony: DioscuriTestimony
    public let reason: HephaestusQuarantineReason

    init(
        candidate: TimespineCandidate,
        testimony: DioscuriTestimony,
        reason: HephaestusQuarantineReason
    ) {
        self.candidate = candidate
        self.testimony = testimony
        self.reason = reason
    }
}

public enum HephaestusDisposition: Sendable {
    case sealed(HephaestusSealedArtifact)
    case quarantined(HephaestusQuarantinedArtifact)
}

public extension Hephaestus {
    static var fabricationRole: String { "make" }
    static var completionRole: String { "seal or quarantine" }
    static var resonanceAuthority: String { "Dioscuri" }
    static var overruleRole: String { "none" }
    static var sealMutationRole: String { "none" }
    static var quarantineLaw: String { "preserve exact work" }

    /// Completes the second half of the same Hephaestus fabrication lifecycle.
    /// Ordinary integrity failures always receive a disposition rather than escaping into limbo.
    static func complete(
        candidate: TimespineCandidate,
        testimony: DioscuriTestimony
    ) -> HephaestusDisposition {
        let actualIdentity = TimespineCandidateIdentity.hash(artifactData: candidate.artifactData)
        guard actualIdentity == candidate.identity else {
            return quarantine(candidate, testimony, .candidateIdentityMismatch)
        }

        let record = candidate.forgeRecord
        guard record.candidateSHA256 == candidate.identity.sha256,
              record.artifactByteCount == candidate.artifactData.count,
              !record.recipeIdentifier.isEmpty,
              record.recipeVersion > 0 else {
            return quarantine(candidate, testimony, .fabricationRecordMismatch)
        }

        guard testimony.candidateSHA256 == candidate.identity.sha256 else {
            return quarantine(candidate, testimony, .testimonyCandidateMismatch)
        }
        guard testimony.recipeIdentifier == record.recipeIdentifier,
              testimony.recipeVersion == record.recipeVersion else {
            return quarantine(candidate, testimony, .testimonyRecipeMismatch)
        }
        guard testimony.resonanceContract == record.resonanceContract else {
            return quarantine(candidate, testimony, .resonanceContractMismatch)
        }
        guard testimony.dioscuriContractVersion == Dioscuri.contractVersion else {
            return quarantine(candidate, testimony, .unsupportedDioscuriContract)
        }
        guard testimony.isInternallyConsistent else {
            return quarantine(candidate, testimony, .malformedTestimony)
        }
        guard testimony.result == .resonant else {
            return quarantine(candidate, testimony, .dioscuriRejected)
        }

        let seal = HephaestusSeal(candidate: candidate, testimony: testimony)
        return .sealed(HephaestusSealedArtifact(
            candidate: candidate,
            testimony: testimony,
            seal: seal
        ))
    }

    private static func quarantine(
        _ candidate: TimespineCandidate,
        _ testimony: DioscuriTestimony,
        _ reason: HephaestusQuarantineReason
    ) -> HephaestusDisposition {
        .quarantined(HephaestusQuarantinedArtifact(
            candidate: candidate,
            testimony: testimony,
            reason: reason
        ))
    }
}

private struct HephaestusSealWriter {
    private(set) var data = Data()

    var sha256: String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    mutating func string(_ value: String) {
        let bytes = Data(value.utf8)
        u64(UInt64(bytes.count))
        data.append(bytes)
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
