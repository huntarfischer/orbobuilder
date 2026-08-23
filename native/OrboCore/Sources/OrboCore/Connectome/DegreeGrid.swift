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

    internal init(
        restoringAddress address: DegreeAddress,
        threads: [ClothoThread]
    ) {
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

    internal init?(restoringCells cells: [DegreeCell]) {
        guard cells.count == DegreeAddress.count,
              cells.map(\.address) == DegreeAddress.canonicalOrder,
              cells.allSatisfy({ cell in
                  cell.threads.allSatisfy { $0.degreeAddress == cell.address }
              }) else {
            return nil
        }
        self.cells = cells
    }
}

/// Lachesis is the sole allotment authority for Clotho threads.
///
/// She does not derive thread addresses or astrological meaning. She places each
/// complete Clotho thread into the existing DegreeCell identified by the
/// DegreeAddress Clotho supplied. Existing valid allotments are preserved.
public enum Lachesis {
    public static func allot(
        _ packet: ClothoSourcePacket,
        into grid: DegreeGrid
    ) -> DegreeGrid {
        precondition(grid.cells.count == DegreeAddress.count)
        precondition(grid.cells.map(\.address) == DegreeAddress.canonicalOrder)

        let existingThreads = grid.cells.flatMap(\.threads)

        for cell in grid.cells {
            precondition(cell.threads.allSatisfy { $0.degreeAddress == cell.address })
        }

        let existingGenes = existingThreads.map(\.gene)
        precondition(Set(existingGenes).count == existingGenes.count)

        let existingByGene = Dictionary(
            uniqueKeysWithValues: existingThreads.map { ($0.gene, $0) }
        )

        for thread in packet.threads {
            if let existing = existingByGene[thread.gene] {
                precondition(existing == thread)
            }
        }

        let newThreadsByAddress = Dictionary(
            grouping: packet.threads.filter { existingByGene[$0.gene] == nil },
            by: \.degreeAddress
        )

        let allottedCells = grid.cells.map { cell in
            DegreeCell(
                address: cell.address,
                threads: cell.threads + (newThreadsByAddress[cell.address] ?? [])
            )
        }

        let allottedThreads = allottedCells.flatMap(\.threads)
        let expectedCount = existingThreads.count + packet.threads.filter {
            existingByGene[$0.gene] == nil
        }.count

        precondition(allottedThreads.count == expectedCount)
        precondition(Set(allottedThreads.map(\.gene)).count == allottedThreads.count)

        return DegreeGrid(allottedCells: allottedCells)
    }
}
