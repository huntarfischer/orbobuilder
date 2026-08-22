import CryptoKit
import Foundation

/// Content identity of one exact ORBOTS artifact.
/// The initializer is intentionally not public: external callers may inspect an identity,
/// but only Hephaestus mints a TimespineCandidate.
public struct TimespineCandidateIdentity: Hashable, Codable, Sendable, CustomStringConvertible {
    public let sha256: String

    public var description: String { sha256 }

    init(artifactData: Data) {
        self.sha256 = SHA256.hash(data: artifactData)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    static func hash(artifactData: Data) -> TimespineCandidateIdentity {
        TimespineCandidateIdentity(artifactData: artifactData)
    }
}

/// Immutable product of one Hephaestus fabrication transaction.
/// A candidate is not admitted infrastructure until the Dioscuri resonate the exact work
/// and Hephaestus receives that testimony and completes it by seal or quarantine.
public struct TimespineCandidate: Sendable {
    public let identity: TimespineCandidateIdentity
    public let artifact: MundaneTimespineArtifact
    public let forgeRecord: TimespineForgeRecord

    init(
        identity: TimespineCandidateIdentity,
        artifact: MundaneTimespineArtifact,
        forgeRecord: TimespineForgeRecord
    ) {
        self.identity = identity
        self.artifact = artifact
        self.forgeRecord = forgeRecord
    }

    public var artifactData: Data { artifact.data }
}
