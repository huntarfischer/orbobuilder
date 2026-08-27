public struct OrboKnownBirthInput: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let name: String
    public let birthDate: CivilDate
    public let birthTime: CivilClockTime
    public let birthLocation: String

    public init(
        subjectID: HermesSubjectID,
        name: String,
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        birthLocation: String
    ) {
        self.subjectID = subjectID
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
    }
}
