/// One celestial question Pollux can ask without carrying civic time.
/// occurrenceIndex is chronological among exact forged supports for that directional degree.
public struct SpineCelestialChallenge: Hashable, Sendable {
    public let body: MundaneBody
    public let directionalDegree: OrboSpineDirectionalDegree
    public let occurrenceIndex: Int

    public init?(body: MundaneBody, directionalDegree: OrboSpineDirectionalDegree, occurrenceIndex: Int = 0) {
        guard occurrenceIndex >= 0 else { return nil }
        self.body = body
        self.directionalDegree = directionalDegree
        self.occurrenceIndex = occurrenceIndex
    }
}

public enum SpineResonanceResult: Equatable, Sendable {
    case confirmed
    case divergent(
        expected: OrboSpineCelestialCoordinate,
        returned: OrboSpineCelestialCoordinate
    )
}

public enum SpineResonanceError: Error, Equatable {
    case celestialProductMismatch
    case challengeUnavailable
}

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

    /// ASK → ANSWER → CONFIRM for one celestial challenge.
    /// Pollux reads finished forged celestial matter; Castor receives only body + UT and reads
    /// the assembled runtime. No correction, averaging, retry, manufacture, or sealing occurs.
    public func resonate(
        _ challenge: SpineCelestialChallenge,
        celestialProduct: SpineForgeProduct
    ) throws -> SpineResonanceResult {
        guard celestialProduct.schematicIdentity == schematic.identity,
              celestialProduct.schematicVersion == schematic.version,
              celestialProduct.bone == schematic.bone,
              celestialProduct.astronomicalAuthority == schematic.astronomicalAuthority,
              celestialProduct.astronomicalSourceVersion == schematic.astronomicalSourceVersion else {
            throw SpineResonanceError.celestialProductMismatch
        }

        guard let expected = PolluxResonator.ask(challenge, from: celestialProduct) else {
            throw SpineResonanceError.challengeUnavailable
        }

        let returned = try CastorResonator.answer(
            body: expected.body,
            at: expected.julianDay,
            from: candidate
        )

        return PolluxResonator.confirm(expected: expected, returned: returned)
    }
}
