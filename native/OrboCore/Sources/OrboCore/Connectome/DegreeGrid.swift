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

public struct DegreeCell: Hashable, Sendable {
    public let address: DegreeAddress

    public init(address: DegreeAddress) {
        self.address = address
    }
}

public struct DegreeGrid: Hashable, Sendable {
    public let cells: [DegreeCell]

    public init() {
        cells = DegreeAddress.canonicalOrder.map(DegreeCell.init)
    }
}
