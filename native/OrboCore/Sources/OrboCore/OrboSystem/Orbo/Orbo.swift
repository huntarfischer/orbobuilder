public struct Orbo: Hashable, Sendable {
    public private(set) var frontOfHouse: OrboFrontOfHouseState
    public private(set) var backOfHouse: OrboBackOfHouseState

    public init() {
        self.frontOfHouse = .resting
        self.backOfHouse = .idle
    }

    mutating func transitionFrontOfHouse(to state: OrboFrontOfHouseState) {
        frontOfHouse = state
    }

    mutating func transitionBackOfHouse(to state: OrboBackOfHouseState) {
        backOfHouse = state
    }
}
