import Foundation

/// Hephaestus's final physical manufacture step for the universal OrboSpine.
/// Construction matter enters here; one deterministic finished artifact leaves.
internal enum HephaestusOrboSpineArtifactForge {
    static func forge(
        _ matter: OrboSpineArtifactMatter,
        to url: URL
    ) throws -> OrboSpineArtifactReceipt {
        let bytes = try OrboSpineArtifactEncoder.encode(matter)
        try bytes.write(to: url, options: .atomic)
        let mounted = try OrboSpineMountedArtifact(data: bytes)
        return OrboSpineArtifactReceipt(
            sha256: mounted.sha256,
            byteCount: bytes.count,
            formatVersion: OrboSpineArtifactFormat.version
        )
    }
}
