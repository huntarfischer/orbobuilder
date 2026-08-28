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

    /// Legacy resident storage remains through Pass 9B so codec-1 persistence
    /// can continue to compile unchanged. Canonical onboarding hangs Engraving.
    public private(set) var resident: HearthResident?
    public private(set) var engraving: Engraving?
    public private(set) var hearthLit: Bool

    public init(nativeSubjectID: HermesSubjectID) {
        self.nativeSubjectID = nativeSubjectID
        self.resident = nil
        self.engraving = nil
        self.hearthLit = false
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
