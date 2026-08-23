public struct HearthResident: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let tapestry: AtroposPackage

    public init(
        subjectID: HermesSubjectID,
        tapestry: AtroposPackage
    ) {
        self.subjectID = subjectID
        self.tapestry = tapestry
    }
}
