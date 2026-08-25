/// One celestial question Pollux can ask without carrying civic time.
/// occurrenceIndex is chronological among resolved occurrences for that directional degree.
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

/// One station question Pollux can ask without carrying civic time.
/// occurrenceIndex is chronological among forged stations for that body.
public struct SpineStationChallenge: Hashable, Sendable {
    public let body: MundaneBody
    public let occurrenceIndex: Int

    public init?(body: MundaneBody, occurrenceIndex: Int = 0) {
        guard occurrenceIndex >= 0 else { return nil }
        self.body = body
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
    case celestialSourceMismatch
    case challengeUnavailable
}

/// The Dioscuri's first resonance assignment.
/// The Schematic says what should be true; the candidate is the finished Spine to be checked.
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
    /// Pollux reads independent source matter; Castor receives only body + UT and reads the
    /// assembled runtime. No correction, averaging, retry, manufacture, or sealing occurs.
    public func resonate(
        _ challenge: SpineCelestialChallenge,
        source: any SpineResonanceSource
    ) throws -> SpineResonanceResult {
        try requireMatching(source)
        guard let expected = PolluxResonator.ask(challenge, from: source) else {
            throw SpineResonanceError.challengeUnavailable
        }
        return try answerAndConfirm(expected)
    }

    public func resonate(
        _ challenge: SpineStationChallenge,
        source: any SpineResonanceSource
    ) throws -> SpineResonanceResult {
        try requireMatching(source)
        guard let expected = PolluxResonator.ask(challenge, from: source) else {
            throw SpineResonanceError.challengeUnavailable
        }
        return try answerAndConfirm(expected)
    }

    /// Compatibility for the already-proven Stage 2 fixture surface. Production resonance
    /// should use the source-labelled entry point above.
    func resonate(
        _ challenge: SpineCelestialChallenge,
        celestialProduct: SpineForgeProduct
    ) throws -> SpineResonanceResult {
        try resonate(challenge, source: celestialProduct)
    }

    func resonate(
        _ challenge: SpineStationChallenge,
        celestialProduct: SpineForgeProduct
    ) throws -> SpineResonanceResult {
        try resonate(challenge, source: celestialProduct)
    }

    private func requireMatching(_ source: any SpineResonanceSource) throws {
        guard source.schematicIdentity == schematic.identity,
              source.schematicVersion == schematic.version,
              source.bone == schematic.bone,
              source.astronomicalAuthority == schematic.astronomicalAuthority,
              source.astronomicalSourceVersion == schematic.astronomicalSourceVersion else {
            throw SpineResonanceError.celestialSourceMismatch
        }
    }

    private func answerAndConfirm(
        _ expected: OrboSpineCelestialCoordinate
    ) throws -> SpineResonanceResult {
        let returned = try CastorResonator.answer(
            body: expected.body,
            at: expected.julianDay,
            from: candidate
        )
        return PolluxResonator.confirm(expected: expected, returned: returned)
    }
}
