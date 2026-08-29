public struct DegreeAddress: RawRepresentable, Hashable, Sendable, Comparable {
    public static let count = 360

    public let rawValue: Int

    public init?(rawValue: Int) {
        guard (0..<Self.count).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    public static let canonicalOrder: [DegreeAddress] =
        (0..<count).map { DegreeAddress(rawValue: $0)! }

    public static func < (lhs: DegreeAddress, rhs: DegreeAddress) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
