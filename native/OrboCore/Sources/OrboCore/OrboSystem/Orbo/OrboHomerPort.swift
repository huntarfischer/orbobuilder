/// Orbo's own lifecycle truth as a read-only point-of-view snapshot for Homer.
///
/// This snapshot describes only what has become true for Orbo. It carries no
/// downstream chart matter, deity state, courier manifest, forge detail, or
/// verification detail.
public struct OrboLifecycleSnapshot: Hashable, Sendable {
    public let frontOfHouse: OrboFrontOfHouseState
    public let backOfHouse: OrboBackOfHouseState
    public let onboardingProgress: OrboOnboardingProgress?
    public let engravingCommissioned: Bool
    public let engravingEntrusted: Bool
    public let astrosphereIntroductionProgress: OrboAstrosphereIntroductionProgress?
    public let bigThreeProgress: OrboBigThreeProgress?
    public let canEnterBigThree: Bool

    fileprivate init(orbo: Orbo) {
        self.frontOfHouse = orbo.frontOfHouse
        self.backOfHouse = orbo.backOfHouse
        self.onboardingProgress = orbo.onboardingSession?.progress
        self.engravingCommissioned = orbo.engravingCommission != nil
        self.engravingEntrusted = orbo.engravingTicketID != nil
        self.astrosphereIntroductionProgress = orbo.astrosphereIntroductionProgress
        self.bigThreeProgress = orbo.bigThreeSession?.progress
        self.canEnterBigThree = orbo.canEnterBigThree
    }
}

public extension Orbo {
    /// Standard outward Homer port for Orbo's own lifecycle consequence state.
    ///
    /// Orbo does not inspect downstream owners to author this snapshot. Homer
    /// receives only the state Orbo itself already owns.
    func signalForHomer() -> HomerPort<OrboLifecycleSnapshot> {
        HomerPort(pointOfView: OrboLifecycleSnapshot(orbo: self))
    }
}
