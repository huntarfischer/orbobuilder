public struct Hestia: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case nativeAlreadyEstablished
        case savedSubjectAlreadyAdmitted
    }

    public private(set) var hearth: Hearth
    public private(set) var hall: Hall

    public var nativeSubjectID: HermesSubjectID {
        hearth.nativeSubjectID
    }

    public init(nativeSubjectID: HermesSubjectID) {
        self.hearth = Hearth(nativeSubjectID: nativeSubjectID)
        self.hall = Hall()
    }

    public mutating func admit(
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA,
        tapestry: AtroposPackage
    ) throws {
        if subjectID == nativeSubjectID {
            guard hearth.resident == nil else {
                throw Failure.nativeAlreadyEstablished
            }

            try hearth.establish(
                HearthResident(
                    subjectID: subjectID,
                    astroDNA: astroDNA,
                    tapestry: tapestry
                )
            )
            return
        }

        guard hall.resident(for: subjectID) == nil else {
            throw Failure.savedSubjectAlreadyAdmitted
        }

        try hall.admit(
            HallResident(
                subjectID: subjectID,
                astroDNA: astroDNA,
                tapestry: tapestry
            )
        )
    }

    public func native() -> HearthResident? {
        hearth.resident
    }

    public func saved(_ subjectID: HermesSubjectID) -> HallResident? {
        hall.resident(for: subjectID)
    }
}
