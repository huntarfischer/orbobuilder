/// Hephaestus's final seal for one exact OrboSpine candidate under one Schematic commission.
public struct OrboSpineSeal: Hashable, Sendable {
    public let schematicIdentity: String
    public let schematicVersion: UInt16
    public let candidateIdentity: String

    init(
        schematicIdentity: String,
        schematicVersion: UInt16,
        candidateIdentity: String
    ) {
        self.schematicIdentity = schematicIdentity
        self.schematicVersion = schematicVersion
        self.candidateIdentity = candidateIdentity
    }
}

public enum OrboSpineCompletionError: Error, Equatable, Sendable {
    case invalidTestimonyBinding
}

/// Hephaestus's OrboSpine completion boundary.
/// G2 only proves that Dioscuri testimony belongs to the exact work in hand.
public enum HephaestusOrboSpineCompletion {
    public static func receive(
        schematic: SpineSchematic,
        candidate: OrboSpineRuntime,
        testimony: SpineResonanceTestimony
    ) throws -> SpineResonanceTestimony {
        guard testimony.schematicIdentity == schematic.identity,
              testimony.schematicVersion == schematic.version,
              testimony.candidateIdentity == candidate.provenance.candidateManifestSHA256 else {
            throw OrboSpineCompletionError.invalidTestimonyBinding
        }

        return testimony
    }
}
