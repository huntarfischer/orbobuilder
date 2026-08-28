public struct HearthResident: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let astroDNA: AstroDNA
    public let tapestry: AtroposPackage

    public init(
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA,
        tapestry: AtroposPackage
    ) {
        self.subjectID = subjectID
        self.astroDNA = astroDNA
        self.tapestry = tapestry
    }
}

public struct Hearth: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case wrongSubject
        case alreadyEstablished
        case alreadyEngraved
    }

    public let nativeSubjectID: HermesSubjectID

    /// Legacy resident storage remains until the Pass 9 legacy sweep.
    /// Canonical onboarding hangs the finished Engraving instead.
    public private(set) var resident: HearthResident?
    public private(set) var engraving: Engraving?
    public private(set) var hearthLit: Bool

    public init(nativeSubjectID: HermesSubjectID) {
        self.nativeSubjectID = nativeSubjectID
        self.resident = nil
        self.engraving = nil
        self.hearthLit = false
    }

    /// Restores canonical kept truth without replaying Hestia's hanging act.
    /// Only the two lawful canonical states are admitted: unlit/empty or
    /// lit/finished-and-complete.
    internal init?(
        restoringNativeSubjectID nativeSubjectID: HermesSubjectID,
        engraving: Engraving?,
        hearthLit: Bool
    ) {
        if hearthLit {
            guard let engraving,
                  engraving.subjectID == nativeSubjectID,
                  engraving.engraved,
                  engraving.topos != nil,
                  engraving.tempus != nil,
                  engraving.astroDNA != nil,
                  engraving.tapestry != nil else {
                return nil
            }
        } else {
            guard engraving == nil else { return nil }
        }

        self.nativeSubjectID = nativeSubjectID
        self.resident = nil
        self.engraving = engraving
        self.hearthLit = hearthLit
    }

    public mutating func establish(_ resident: HearthResident) throws {
        guard self.resident == nil, engraving == nil else {
            throw Failure.alreadyEstablished
        }
        guard resident.subjectID == nativeSubjectID else {
            throw Failure.wrongSubject
        }

        self.resident = resident
    }

    /// Hestia's canonical native act. Hanging the unfinished Engraving completes
    /// it and lights the Hearth in the same mutation.
    public mutating func hang(_ engraving: Engraving) throws -> Engraving {
        guard resident == nil, self.engraving == nil else {
            throw Failure.alreadyEstablished
        }
        guard engraving.subjectID == nativeSubjectID else {
            throw Failure.wrongSubject
        }
        guard !engraving.engraved else {
            throw Failure.alreadyEngraved
        }

        let finished = engraving.hungOnHearth()
        self.engraving = finished
        self.hearthLit = true
        return finished
    }
}
