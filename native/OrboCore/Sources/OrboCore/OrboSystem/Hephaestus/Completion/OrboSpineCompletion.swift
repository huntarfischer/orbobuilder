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
    case testimonyNotDivergent
    case testimonyNotConfirmed
}

public enum HephaestusOrboSpineDisposition: Equatable, Sendable {
    case reforge(SpineResonanceTestimony)
    case sealed(OrboSpineSeal)
}

/// Hephaestus's OrboSpine completion boundary.
public enum HephaestusOrboSpineCompletion {
    /// G2 proves that Dioscuri testimony belongs to the exact work in hand.
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

    /// G3 returns valid divergent testimony to Hephaestus for reforging.
    public static func reforge(
        schematic: SpineSchematic,
        candidate: OrboSpineRuntime,
        testimony: SpineResonanceTestimony
    ) throws -> HephaestusOrboSpineDisposition {
        let boundTestimony = try receive(
            schematic: schematic,
            candidate: candidate,
            testimony: testimony
        )
        guard case .divergent = boundTestimony.result else {
            throw OrboSpineCompletionError.testimonyNotDivergent
        }

        return .reforge(boundTestimony)
    }

    /// G4 seals the exact OrboSpine only after valid confirmed testimony.
    public static func seal(
        schematic: SpineSchematic,
        candidate: OrboSpineRuntime,
        testimony: SpineResonanceTestimony
    ) throws -> HephaestusOrboSpineDisposition {
        let boundTestimony = try receive(
            schematic: schematic,
            candidate: candidate,
            testimony: testimony
        )
        guard case .confirmed = boundTestimony.result else {
            throw OrboSpineCompletionError.testimonyNotConfirmed
        }

        return .sealed(OrboSpineSeal(
            schematicIdentity: boundTestimony.schematicIdentity,
            schematicVersion: boundTestimony.schematicVersion,
            candidateIdentity: boundTestimony.candidateIdentity
        ))
    }
}
