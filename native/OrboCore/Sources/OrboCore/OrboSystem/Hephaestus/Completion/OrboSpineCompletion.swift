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
        try requireBinding(
            schematic: schematic,
            candidateIdentity: candidate.provenance.spineIdentity,
            testimonySchematicIdentity: testimony.schematicIdentity,
            testimonySchematicVersion: testimony.schematicVersion,
            testimonyCandidateIdentity: testimony.candidateIdentity
        )
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

    /// Production completion accepts the durable identity fields of already-certified testimony
    /// without requiring the whole candidate runtime to be rebuilt solely to recover its hash.
    public static func complete(
        schematic: SpineSchematic,
        candidateIdentity: String,
        testimonySchematicIdentity: String,
        testimonySchematicVersion: UInt16,
        testimonyCandidateIdentity: String,
        testimonyResult: SpineResonanceTestimonyResult
    ) throws -> HephaestusOrboSpineDisposition {
        try requireBinding(
            schematic: schematic,
            candidateIdentity: candidateIdentity,
            testimonySchematicIdentity: testimonySchematicIdentity,
            testimonySchematicVersion: testimonySchematicVersion,
            testimonyCandidateIdentity: testimonyCandidateIdentity
        )

        switch testimonyResult {
        case .confirmed:
            return .sealed(OrboSpineSeal(
                schematicIdentity: testimonySchematicIdentity,
                schematicVersion: testimonySchematicVersion,
                candidateIdentity: testimonyCandidateIdentity
            ))
        case .divergent:
            throw OrboSpineCompletionError.testimonyNotConfirmed
        }
    }

    /// G5 makes Hephaestus the single authority that resolves valid Dioscuri testimony.
    public static func complete(
        schematic: SpineSchematic,
        candidate: OrboSpineRuntime,
        testimony: SpineResonanceTestimony
    ) throws -> HephaestusOrboSpineDisposition {
        switch testimony.result {
        case .confirmed:
            return try complete(
                schematic: schematic,
                candidateIdentity: candidate.provenance.spineIdentity,
                testimonySchematicIdentity: testimony.schematicIdentity,
                testimonySchematicVersion: testimony.schematicVersion,
                testimonyCandidateIdentity: testimony.candidateIdentity,
                testimonyResult: testimony.result
            )
        case .divergent:
            _ = try receive(
                schematic: schematic,
                candidate: candidate,
                testimony: testimony
            )
            return .reforge(testimony)
        }
    }

    private static func requireBinding(
        schematic: SpineSchematic,
        candidateIdentity: String,
        testimonySchematicIdentity: String,
        testimonySchematicVersion: UInt16,
        testimonyCandidateIdentity: String
    ) throws {
        guard testimonySchematicIdentity == schematic.identity,
              testimonySchematicVersion == schematic.version,
              testimonyCandidateIdentity == candidateIdentity else {
            throw OrboSpineCompletionError.invalidTestimonyBinding
        }
    }
}
