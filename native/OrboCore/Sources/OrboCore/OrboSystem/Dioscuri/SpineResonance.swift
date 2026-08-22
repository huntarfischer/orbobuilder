/// The Dioscuri's first resonance assignment.
/// The Schematic says what should be true; the candidate is the finished OrboSpine to be checked.
public struct SpineResonanceAssignment: Sendable {
    public let schematic: SpineSchematic
    public let candidate: OrboSpineRuntime
    public let candidateIdentity: String

    public init?(schematic: SpineSchematic, candidate: OrboSpineRuntime) {
        guard schematic.identity == candidate.identity,
              schematic.bone == candidate.bone,
              schematic.astronomicalAuthority == candidate.provenance.astronomicalAuthority,
              schematic.astronomicalSourceVersion == candidate.provenance.astronomicalSourceVersion else {
            return nil
        }

        self.schematic = schematic
        self.candidate = candidate
        self.candidateIdentity = candidate.provenance.candidateManifestSHA256
    }
}
