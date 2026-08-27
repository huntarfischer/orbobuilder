public enum OrboAstrosphereIntroductionProgress: Hashable, Sendable {
    case astrosphereIntroduction
    case layoutIntroduction
}

/// The narrow Front-of-House progression Orbo can perform while Back of House
/// work remains in progress. This value deliberately carries no BOH identity,
/// ticket, package, route, or deity detail.
public struct OrboAstrosphereIntroductionBeat: Hashable, Sendable {
    public let progress: OrboAstrosphereIntroductionProgress

    internal init(progress: OrboAstrosphereIntroductionProgress) {
        self.progress = progress
    }
}

public enum OrboFrontOfHouseFailure: Error, Hashable, Sendable {
    case engravingNotInProgress
    case astrosphereIntroductionNotStarted
    case astrosphereIntroductionComplete
}
