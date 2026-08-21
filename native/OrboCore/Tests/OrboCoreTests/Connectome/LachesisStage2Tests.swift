import XCTest
@testable import OrboCore

final class LachesisStage2Tests: XCTestCase {
    private struct NatalPosition {
        let degree: Int
        let minute: Int
        let second: Int
        let retrograde: Bool

        var arcsecond: Int {
            degree * Ring.arcsecondsPerDegree + minute * 60 + second
        }
    }

    private let natalPositions: [AstroDNAGene: NatalPosition] = [
        .ascendant: NatalPosition(degree: 221, minute: 29, second: 37, retrograde: false),
        .moon: NatalPosition(degree: 277, minute: 34, second: 12, retrograde: false),
        .sun: NatalPosition(degree: 21, minute: 8, second: 19, retrograde: false),
        .mercury: NatalPosition(degree: 8, minute: 20, second: 41, retrograde: true),
        .venus: NatalPosition(degree: 9, minute: 49, second: 22, retrograde: true),
        .mars: NatalPosition(degree: 49, minute: 16, second: 5, retrograde: false),
        .jupiter: NatalPosition(degree: 312, minute: 33, second: 44, retrograde: false),
        .saturn: NatalPosition(degree: 237, minute: 9, second: 17, retrograde: true),
        .uranus: NatalPosition(degree: 257, minute: 49, second: 31, retrograde: true),
        .neptune: NatalPosition(degree: 273, minute: 36, second: 26, retrograde: true),
        .pluto: NatalPosition(degree: 213, minute: 42, second: 14, retrograde: true),
        .northNode: NatalPosition(degree: 49, minute: 50, second: 53, retrograde: true),
    ]

    private func natalDNA() throws -> AstroDNA {
        let sequence = try AstroDNAGene.canonicalOrder.map { gene -> RingFineState in
            let position = try XCTUnwrap(natalPositions[gene])
            var rawValue = position.arcsecond
            if position.retrograde {
                rawValue += Ring.arcseconds
            }
            return try XCTUnwrap(RingFineState(rawValue))
        }

        return try XCTUnwrap(AstroDNA(sequence: sequence))
    }

    private func allottedGrid() throws -> (ClothoSourcePacket, DegreeGrid) {
        let packet = Clotho.gather(from: try natalDNA())
        return (packet, Lachesis.allot(packet, into: DegreeGrid()))
    }

    func testLachesisFillsTheExistingDegreeGridType() throws {
        let (_, grid) = try allottedGrid()
        XCTAssertEqual(grid.cells.count, DegreeAddress.count)
        XCTAssertEqual(grid.cells.map(\.address), DegreeAddress.canonicalOrder)
    }

    func testEveryClothoThreadIsAllottedExactlyOnce() throws {
        let (packet, grid) = try allottedGrid()
        let allotted = grid.cells.flatMap(\.threads)

        XCTAssertEqual(allotted.count, packet.threads.count)
        XCTAssertEqual(allotted.count, AstroDNA.geneCount)

        for thread in packet.threads {
            XCTAssertEqual(allotted.filter { $0 == thread }.count, 1)
        }
    }

    func testEachThreadAppearsOnlyAtItsClothoSuppliedDegreeAddress() throws {
        let (packet, grid) = try allottedGrid()

        for thread in packet.threads {
            let matchingCells = grid.cells.filter { $0.threads.contains(thread) }
            XCTAssertEqual(matchingCells.count, 1)
            XCTAssertEqual(matchingCells.first?.address, thread.degreeAddress)
        }
    }

    func testMultipleThreadsMayOccupyTheSameExistingCell() throws {
        let (_, grid) = try allottedGrid()
        let degree49 = try XCTUnwrap(grid.cells.first { $0.address.rawValue == 49 })

        XCTAssertEqual(degree49.threads.count, 2)
        XCTAssertEqual(Set(degree49.threads.map(\.gene)), Set([.mars, .northNode]))
    }

    func testEmptyCellsRemainValid() throws {
        let (_, grid) = try allottedGrid()
        let degree0 = try XCTUnwrap(grid.cells.first { $0.address.rawValue == 0 })

        XCTAssertTrue(degree0.threads.isEmpty)
    }

    func testExactRingFineStateSurvivesAllotmentUnchanged() throws {
        let (packet, grid) = try allottedGrid()

        for sourceThread in packet.threads {
            let cell = try XCTUnwrap(
                grid.cells.first { $0.address == sourceThread.degreeAddress }
            )
            let allottedThread = try XCTUnwrap(
                cell.threads.first { $0.gene == sourceThread.gene }
            )

            XCTAssertEqual(allottedThread.exactState, sourceThread.exactState)
            XCTAssertEqual(allottedThread.exactState.rawValue, sourceThread.exactState.rawValue)
            XCTAssertEqual(allottedThread.exactState.dms, sourceThread.exactState.dms)
        }
    }

    func testArcsecondPrecisionRemainsInsideWholeDegreeCell() throws {
        let (_, grid) = try allottedGrid()
        let degree221 = try XCTUnwrap(grid.cells.first { $0.address.rawValue == 221 })
        let ascendant = try XCTUnwrap(degree221.threads.first { $0.gene == .ascendant })

        XCTAssertEqual(ascendant.exactState.dms.degree, 221)
        XCTAssertEqual(ascendant.exactState.dms.minute, 29)
        XCTAssertEqual(ascendant.exactState.dms.second, 37)
    }

    func testLachesisDoesNotChangeThreadIdentityOrAddress() throws {
        let (packet, grid) = try allottedGrid()
        let allotted = grid.cells.flatMap(\.threads)

        XCTAssertEqual(Set(allotted), Set(packet.threads))

        for thread in allotted {
            XCTAssertEqual(thread.degreeAddress.rawValue, thread.exactState.coarseState.degree)
        }
    }

    func testSameGridAndPacketProduceSameAllotment() throws {
        let packet = Clotho.gather(from: try natalDNA())
        let first = Lachesis.allot(packet, into: DegreeGrid())
        let second = Lachesis.allot(packet, into: DegreeGrid())

        XCTAssertEqual(first, second)
    }

    func testLachesisMayAllotIntoAnAlreadyAllottedGridWithoutDuplication() throws {
        let packet = Clotho.gather(from: try natalDNA())
        let once = Lachesis.allot(packet, into: DegreeGrid())
        let twice = Lachesis.allot(packet, into: once)

        XCTAssertEqual(twice, once)
        XCTAssertEqual(twice.cells.flatMap(\.threads).count, AstroDNA.geneCount)

        for thread in packet.threads {
            XCTAssertEqual(twice.cells.flatMap(\.threads).filter { $0 == thread }.count, 1)
        }
    }
}
