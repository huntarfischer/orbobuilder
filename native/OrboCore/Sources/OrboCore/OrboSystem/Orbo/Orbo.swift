public enum OrboCommissionFailure: Error, Hashable, Sendable {
    case insufficientOnboarding
    case alreadyCommissioned
}

public struct Orbo: Hashable, Sendable {
    public private(set) var frontOfHouse: OrboFrontOfHouseState
    public private(set) var backOfHouse: OrboBackOfHouseState
    public private(set) var onboardingSession: OrboOnboardingSession?
    public private(set) var engravingCommission: HermesPackage<Engraving>?

    public init() {
        self.frontOfHouse = .resting
        self.backOfHouse = .idle
        self.onboardingSession = nil
        self.engravingCommission = nil
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

    @discardableResult
    public mutating func commissionEngraving(
        subjectID: HermesSubjectID,
        packageID: HermesPackageID = HermesPackageID()
    ) throws -> HermesPackage<Engraving> {
        guard engravingCommission == nil else {
            throw OrboCommissionFailure.alreadyCommissioned
        }

        guard let input = knownBirthInput(subjectID: subjectID) else {
            throw OrboCommissionFailure.insufficientOnboarding
        }

        let package = OrboOnboarding.complete(
            subjectID: input.subjectID,
            name: input.name,
            birthDate: input.birthDate,
            birthTime: input.birthTime,
            birthLocation: input.birthLocation,
            packageID: packageID
        )

        engravingCommission = package
        backOfHouse = .engravingCommissioned
        return package
    }

    mutating func transitionFrontOfHouse(to state: OrboFrontOfHouseState) {
        frontOfHouse = state
    }

    mutating func transitionBackOfHouse(to state: OrboBackOfHouseState) {
        backOfHouse = state
    }
}
