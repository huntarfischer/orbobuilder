public struct Hearth: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case wrongSubject
        case alreadyEstablished
        case alreadyEngraved
    }

    /// The consequence authored only when this Hearth actually transitions
    /// from unlit to lit by hanging its native Engraving.
    public struct Lighting: Hashable, Sendable {
        public let subjectID: HermesSubjectID
        public let engraving: Engraving

        fileprivate init(
            subjectID: HermesSubjectID,
            engraving: Engraving
        ) {
            self.subjectID = subjectID
            self.engraving = engraving
        }
    }

    public let nativeSubjectID: HermesSubjectID
    public private(set) var engraving: Engraving?
    public private(set) var hearthLit: Bool

    public init(nativeSubjectID: HermesSubjectID) {
        self.nativeSubjectID = nativeSubjectID
        self.engraving = nil
        self.hearthLit = false
    }

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
                  engraving.sect != nil,
                  engraving.tapestry != nil else {
                return nil
            }
        } else {
            guard engraving == nil else { return nil }
        }

        self.nativeSubjectID = nativeSubjectID
        self.engraving = engraving
        self.hearthLit = hearthLit
    }

    public mutating func hang(_ engraving: Engraving) throws -> Lighting {
        guard self.engraving == nil else {
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
        return Lighting(
            subjectID: nativeSubjectID,
            engraving: finished
        )
    }
}
