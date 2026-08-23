public struct Holding: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let astroDNA: AstroDNA

    public init(
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA
    ) {
        self.subjectID = subjectID
        self.astroDNA = astroDNA
    }
}

public struct Holdings: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case duplicateSubject
    }

    public private(set) var holdings: [Holding]

    public init() {
        self.holdings = []
    }

    public mutating func admit(_ holding: Holding) throws {
        guard self.holding(for: holding.subjectID) == nil else {
            throw Failure.duplicateSubject
        }

        holdings.append(holding)
    }

    public func holding(for subjectID: HermesSubjectID) -> Holding? {
        holdings.first { $0.subjectID == subjectID }
    }
}
