public struct Orbo: Hashable, Sendable {
    public private(set) var frontOfHouse: OrboFrontOfHouseState
    public private(set) var backOfHouse: OrboBackOfHouseState
    public private(set) var onboardingSession: OrboOnboardingSession?

    public init() {
        self.frontOfHouse = .resting
        self.backOfHouse = .idle
        self.onboardingSession = nil
    }

    @discardableResult
    public mutating func beginOnboarding() -> OrboOnboardingBeat {
        if onboardingSession == nil {
            onboardingSession = OrboOnboardingSession()
            frontOfHouse = .onboarding
        }

        return onboardingSession!.currentBeat
    }

    @discardableResult
    public mutating func respondToOnboarding(
        _ response: OrboOnboardingResponse
    ) throws -> OrboOnboardingBeat {
        guard var session = onboardingSession else {
            throw OrboOnboardingFailure.notStarted
        }

        try session.respond(response)
        onboardingSession = session
        return session.currentBeat
    }

    func knownBirthInput(subjectID: HermesSubjectID) -> OrboKnownBirthInput? {
        guard let session = onboardingSession,
              session.readyForEngraving,
              session.birthTimeKnowledge == .known,
              let name = session.name,
              let birthDate = session.birthDate,
              let birthTime = session.birthTime,
              let birthLocation = session.birthLocation else {
            return nil
        }

        return OrboKnownBirthInput(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation
        )
    }

    mutating func transitionFrontOfHouse(to state: OrboFrontOfHouseState) {
        frontOfHouse = state
    }

    mutating func transitionBackOfHouse(to state: OrboBackOfHouseState) {
        backOfHouse = state
    }
}
