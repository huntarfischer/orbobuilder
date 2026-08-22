import Foundation

/// The only information Pollux will later hand to Castor.
/// Expected celestial state is deliberately absent so Castor cannot echo Pollux's answer.
public struct PolluxCivicHandoff: Hashable, Sendable {
    public let candidateSHA256: String
    public let civicOffsetSeconds: Int64

    public init(candidateSHA256: String, civicOffsetSeconds: Int64) {
        self.candidateSHA256 = candidateSHA256
        self.civicOffsetSeconds = civicOffsetSeconds
    }
}

/// One celestial-first challenge prepared by Pollux.
public struct PolluxQuestion: Hashable, Sendable {
    public let celestialAddress: PolluxCelestialAddress
    public let expectedSequenceDirection: MundaneCelestialSequenceDirection
    public let handoff: PolluxCivicHandoff

    init(
        celestialAddress: PolluxCelestialAddress,
        expectedSequenceDirection: MundaneCelestialSequenceDirection,
        handoff: PolluxCivicHandoff
    ) {
        self.celestialAddress = celestialAddress
        self.expectedSequenceDirection = expectedSequenceDirection
        self.handoff = handoff
    }
}
