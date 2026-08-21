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
    public let threads: [ClothoThread]

    public init(address: DegreeAddress) {
        self.address = address
        self.threads = []
    }

    fileprivate init(address: DegreeAddress, threads: [ClothoThread]) {
        self.address = address
        self.threads = threads
    }
}

public struct DegreeGrid: Hashable, Sendable {
    public let cells: [DegreeCell]

    public init() {
        cells = DegreeAddress.canonicalOrder.map(DegreeCell.init)
    }

    fileprivate init(allottedCells: [DegreeCell]) {
        precondition(allottedCells.count == DegreeAddress.count)
        precondition(allottedCells.map(\.address) == DegreeAddress.canonicalOrder)
        self.cells = allottedCells
    }
}

/// Lachesis is the sole allotment authority for Clotho threads.
///
/// She does not derive thread addresses or astrological meaning. She places each
/// complete Clotho thread into the existing DegreeCell identified by the
/// DegreeAddress Clotho supplied.
public enum Lachesis {
    public static func allot(
        _ packet: ClothoSourcePacket,
        into grid: DegreeGrid
    ) -> DegreeGrid {
        precondition(grid.cells.count == DegreeAddress.count)
        precondition(grid.cells.map(\.address) == DegreeAddress.canonicalOrder)
        precondition(grid.cells.allSatisfy { $0.threads.isEmpty })

        let threadsByAddress = Dictionary(grouping: packet.threads, by: \.degreeAddress)

        let allottedCells = grid.cells.map { cell in
            DegreeCell(
                address: cell.address,
                threads: threadsByAddress[cell.address] ?? []
            )
        }

        let allottedThreads = allottedCells.flatMap(\.threads)
        precondition(allottedThreads.count == packet.threads.count)

        return DegreeGrid(allottedCells: allottedCells)
    }
}
