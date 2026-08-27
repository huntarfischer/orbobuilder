public enum OrboFrontOfHouseState: Hashable, Sendable {
    case resting
    case onboarding
    case introducingAstrosphere
    case ready
}

public enum OrboBackOfHouseState: Hashable, Sendable {
    case idle
    case engravingCommissioned
    case engravingInProgress
    case nativeReady
}
