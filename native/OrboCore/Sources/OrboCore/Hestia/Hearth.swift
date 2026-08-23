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
    }

    public let nativeSubjectID: HermesSubjectID
    public private(set) var resident: HearthResident?

    public init(nativeSubjectID: HermesSubjectID) {
        self.nativeSubjectID = nativeSubjectID
        self.resident = nil
    }

    public mutating func establish(_ resident: HearthResident) throws {
        guard self.resident == nil else {
            throw Failure.alreadyEstablished
        }
        guard resident.subjectID == nativeSubjectID else {
            throw Failure.wrongSubject
        }

        self.resident = resident
    }
}
