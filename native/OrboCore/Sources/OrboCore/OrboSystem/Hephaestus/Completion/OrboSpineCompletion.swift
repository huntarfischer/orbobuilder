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
