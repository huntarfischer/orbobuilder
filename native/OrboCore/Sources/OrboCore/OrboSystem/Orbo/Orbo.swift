public enum OrboCommissionFailure: Error, Hashable, Sendable {
    case insufficientOnboarding
    case alreadyCommissioned
}

public enum OrboHermesFailure: Error, Hashable, Sendable {
    case noEngravingCommission
    case alreadyEntrusted
}

public struct Orbo: Hashable, Sendable {
    public private(set) var frontOfHouse: OrboFrontOfHouseState
    public private(set) var backOfHouse: OrboBackOfHouseState
    public private(set) var onboardingSession: OrboOnboardingSession?
    public private(set) var engravingCommission: HermesPackage<Engraving>?
    public private(set) var engravingTicketID: HermesTicketID?
    public private(set) var astrosphereIntroductionProgress: OrboAstrosphereIntroductionProgress?

    public init() {
        self.frontOfHouse = .resting
        self.backOfHouse = .idle
        self.onboardingSession = nil
        self.engravingCommission = nil
        self.engravingTicketID = nil
        self.astrosphereIntroductionProgress = nil
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

    /// Entrusts the already-authored Engraving package to the real Hermes courier.
    /// Orbo retains only Hermes' returned ticket identity; Hermes owns manifest and custody truth.
    @discardableResult
    public mutating func entrustEngraving(
        to courier: inout HermesCourier,
        occurredAt: AbsoluteInstant
    ) throws -> HermesTicketID {
        guard engravingTicketID == nil else {
            throw OrboHermesFailure.alreadyEntrusted
        }
        guard let package = engravingCommission else {
            throw OrboHermesFailure.noEngravingCommission
        }

        let ticketID = try courier.accept(package: package, occurredAt: occurredAt)
        engravingTicketID = ticketID
        backOfHouse = .engravingInProgress
        return ticketID
    }

    /// Moves FOH into the Astrosphere introduction after BOH has handed the
    /// Engraving to Hermes. No courier action is performed here.
    @discardableResult
    public mutating func beginAstrosphereIntroduction() throws -> OrboAstrosphereIntroductionBeat {
        guard backOfHouse == .engravingInProgress, engravingTicketID != nil else {
            throw OrboFrontOfHouseFailure.engravingNotInProgress
        }

        if let progress = astrosphereIntroductionProgress {
            return OrboAstrosphereIntroductionBeat(progress: progress)
        }

        astrosphereIntroductionProgress = .astrosphereIntroduction
        frontOfHouse = .introducingAstrosphere
        return OrboAstrosphereIntroductionBeat(progress: .astrosphereIntroduction)
    }

    /// Advances only FOH. BOH, Hermes custody, and the manifest are untouched.
    @discardableResult
    public mutating func advanceAstrosphereIntroduction() throws -> OrboAstrosphereIntroductionBeat {
        guard let progress = astrosphereIntroductionProgress else {
            throw OrboFrontOfHouseFailure.astrosphereIntroductionNotStarted
        }

        switch progress {
        case .astrosphereIntroduction:
            astrosphereIntroductionProgress = .layoutIntroduction
            return OrboAstrosphereIntroductionBeat(progress: .layoutIntroduction)

        case .layoutIntroduction:
            throw OrboFrontOfHouseFailure.astrosphereIntroductionComplete
        }
    }

    mutating func transitionFrontOfHouse(to state: OrboFrontOfHouseState) {
        frontOfHouse = state
    }

    mutating func transitionBackOfHouse(to state: OrboBackOfHouseState) {
        backOfHouse = state
    }
}
