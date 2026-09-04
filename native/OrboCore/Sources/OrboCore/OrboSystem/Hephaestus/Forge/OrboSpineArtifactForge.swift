import Foundation

/// Hephaestus's final physical manufacture step for the universal OrboSpine.
/// Construction matter enters here; one deterministic finished artifact leaves.
internal enum HephaestusOrboSpineArtifactForge {
    /// Physical manufacture from the already-assembled candidate. The Schematic remains
    /// explicit because an ordinary runtime is not itself a forge instruction.
    static func forge(
        schematic: SpineSchematic,
        candidate: OrboSpineRuntime,
        to url: URL
    ) throws -> OrboSpineArtifactReceipt {
        guard schematic.identity == candidate.identity,
              schematic.bone == candidate.bone,
              schematic.astronomicalAuthority == candidate.provenance.astronomicalAuthority,
              schematic.astronomicalSourceVersion == candidate.provenance.astronomicalSourceVersion,
              candidate.locate.artifactTracts.map(\.body) == MundaneBody.canonicalOrder else {
            throw OrboSpineArtifactError.invalidMetadata
        }
        return try forge(
            OrboSpineArtifactMatter(
                schematicIdentity: schematic.identity,
                schematicVersion: schematic.version,
                bone: candidate.bone,
                candidateManifestSHA256: candidate.provenance.candidateManifestSHA256,
                astronomicalAuthority: candidate.provenance.astronomicalAuthority,
                astronomicalSourceVersion: candidate.provenance.astronomicalSourceVersion,
                tracts: candidate.locate.artifactTracts,
                terra: candidate.locate.artifactTerraSamples,
                stations: candidate.stations,
                retrogradePassages: candidate.retrogradePassages,
                ring: candidate.ringOccurrences,
                eclipses: candidate.eclipses,
                shells: candidate.shellIntervals,
                inventory: candidate.inventory
            ),
            to: url
        )
    }

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
