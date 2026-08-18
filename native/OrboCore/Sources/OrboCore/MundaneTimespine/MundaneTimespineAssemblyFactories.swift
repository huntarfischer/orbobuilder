import Foundation

/// Narrow construction seams for trusted native fabrication tooling. Ordinary runtime readers do
/// not need to manufacture storage rows, while OrboForgeTool must be able to translate admitted
/// canonical construction matter into the same rich storage image Hephaestus mints.
public extension MundaneTimespineStoredOccurrence {
    static func assembled(
        celestialTick: Int,
        civicOffsetSeconds: Int64,
        sequenceDirection: MundaneCelestialSequenceDirection,
        markerWholeDegrees: [UInt16]
    ) -> Self {
        Self(
            celestialTick: celestialTick,
            civicOffsetSeconds: civicOffsetSeconds,
            sequenceDirection: sequenceDirection,
            markerWholeDegrees: markerWholeDegrees
        )
    }
}

public extension MundaneTimespineStoredStation {
    static func assembled(
        celestialMicrodegrees: UInt32,
        civicOffsetSeconds: Int64,
        motionAfter: Motion
    ) -> Self {
        Self(
            celestialMicrodegrees: celestialMicrodegrees,
            civicOffsetSeconds: civicOffsetSeconds,
            motionAfter: motionAfter
        )
    }
}

public extension MundaneTimespineStoredRetrogradePassage {
    static func assembled(
        startCelestialMicrodegrees: UInt32,
        endCelestialMicrodegrees: UInt32,
        startCivicOffsetSeconds: Int64,
        endCivicOffsetSeconds: Int64
    ) -> Self {
        Self(
            startCelestialMicrodegrees: startCelestialMicrodegrees,
            endCelestialMicrodegrees: endCelestialMicrodegrees,
            startCivicOffsetSeconds: startCivicOffsetSeconds,
            endCivicOffsetSeconds: endCivicOffsetSeconds
        )
    }
}
