public struct HallResident: Hashable, Sendable {
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

public struct Hall: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case duplicateSubject
    }

    public private(set) var residents: [HallResident]

    public init() {
        self.residents = []
    }

    public mutating func admit(_ resident: HallResident) throws {
        guard self.resident(for: resident.subjectID) == nil else {
            throw Failure.duplicateSubject
        }

        residents.append(resident)
    }

    public func resident(for subjectID: HermesSubjectID) -> HallResident? {
        residents.first { $0.subjectID == subjectID }
    }
}
