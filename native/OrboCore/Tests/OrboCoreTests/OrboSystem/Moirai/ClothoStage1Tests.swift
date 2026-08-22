import XCTest
@testable import OrboCore

final class ClothoStage1Tests: XCTestCase {
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
        .ascendant: NatalPosition(degree: 221, minute: 29, second: 0, retrograde: false),
        .moon: NatalPosition(degree: 277, minute: 34, second: 0, retrograde: false),
        .sun: NatalPosition(degree: 21, minute: 8, second: 0, retrograde: false),
        .mercury: NatalPosition(degree: 8, minute: 20, second: 0, retrograde: true),
        .venus: NatalPosition(degree: 9, minute: 49, second: 0, retrograde: true),
        .mars: NatalPosition(degree: 49, minute: 16, second: 0, retrograde: false),
        .jupiter: NatalPosition(degree: 312, minute: 33, second: 0, retrograde: false),
        .saturn: NatalPosition(degree: 237, minute: 9, second: 0, retrograde: true),
        .uranus: NatalPosition(degree: 257, minute: 49, second: 0, retrograde: true),
        .neptune: NatalPosition(degree: 273, minute: 36, second: 0, retrograde: true),
        .pluto: NatalPosition(degree: 213, minute: 42, second: 0, retrograde: true),
        .northNode: NatalPosition(degree: 49, minute: 50, second: 0, retrograde: true),
    ]

    private func natalDNA(
        overrides: [AstroDNAGene: NatalPosition] = [:]
    ) throws -> AstroDNA {
        let sequence = try AstroDNAGene.canonicalOrder.map { gene -> RingFineState in
            let position = try XCTUnwrap(overrides[gene] ?? natalPositions[gene])
            var rawValue = position.arcsecond
            if position.retrograde {
                rawValue += Ring.arcseconds
            }
            return try XCTUnwrap(RingFineState(rawValue))
        }

        return try XCTUnwrap(AstroDNA(sequence: sequence))
    }

    func testClothoTakesNatalAstroDNAAsInputAndCreatesExactlyTwelveThreads() throws {
        let output = Clotho.gather(from: try natalDNA())
        XCTAssertEqual(output.packet.threads.count, AstroDNA.geneCount)
        XCTAssertEqual(output.packet.threads.count, 12)
    }

    func testThreadsRemainInCanonicalAstroDNAGeneOrder() throws {
        let output = Clotho.gather(from: try natalDNA())
        XCTAssertEqual(output.packet.threads.map(\.gene), AstroDNAGene.canonicalOrder)
    }

    func testEachThreadPreservesExactRingFineStateUnchanged() throws {
        let dna = try natalDNA()
        let output = Clotho.gather(from: dna)

        for thread in output.packet.threads {
            XCTAssertEqual(thread.exactState, dna[thread.gene])
            XCTAssertEqual(thread.exactState.rawValue, dna[thread.gene].rawValue)
        }
    }

    func testEachThreadUsesTheSameWholeDegreeAddressAsRingProjection() throws {
        let dna = try natalDNA()
        let output = Clotho.gather(from: dna)

        for thread in output.packet.threads {
            XCTAssertEqual(
                thread.degreeAddress.rawValue,
                dna[thread.gene].coarseState.degree
            )
        }
    }

    func testNatalAscendantKeepsSubDegreePrecisionWhileAddressingDegree221() throws {
        let output = Clotho.gather(from: try natalDNA())
        let ascendant = try XCTUnwrap(output.packet.threads.first { $0.gene == .ascendant })

        XCTAssertEqual(ascendant.degreeAddress.rawValue, 221)
        XCTAssertEqual(ascendant.exactState.dms.degree, 221)
        XCTAssertEqual(ascendant.exactState.dms.minute, 29)
        XCTAssertEqual(ascendant.exactState.dms.second, 0)
    }

    func testArcsecondPrecisionSurvivesClothoWithoutChangingDegreeAddress() throws {
        let preciseAscendant = NatalPosition(
            degree: 221,
            minute: 29,
            second: 37,
            retrograde: false
        )
        let output = Clotho.gather(
            from: try natalDNA(overrides: [.ascendant: preciseAscendant])
        )
        let ascendant = try XCTUnwrap(output.packet.threads.first { $0.gene == .ascendant })

        XCTAssertEqual(ascendant.degreeAddress.rawValue, 221)
        XCTAssertEqual(ascendant.exactState.arcsecond, preciseAscendant.arcsecond)
        XCTAssertEqual(ascendant.exactState.dms.minute, 29)
        XCTAssertEqual(ascendant.exactState.dms.second, 37)
    }

    func testRetrogradeMotionDoesNotChangeDegreeAddress() throws {
        let directMercury = NatalPosition(degree: 8, minute: 20, second: 41, retrograde: false)
        let retrogradeMercury = NatalPosition(degree: 8, minute: 20, second: 41, retrograde: true)

        let direct = Clotho.gather(from: try natalDNA(overrides: [.mercury: directMercury]))
        let retrograde = Clotho.gather(from: try natalDNA(overrides: [.mercury: retrogradeMercury]))

        let directThread = try XCTUnwrap(direct.packet.threads.first { $0.gene == .mercury })
        let retrogradeThread = try XCTUnwrap(retrograde.packet.threads.first { $0.gene == .mercury })

        XCTAssertEqual(directThread.degreeAddress, retrogradeThread.degreeAddress)
        XCTAssertEqual(directThread.exactState.arcsecond, retrogradeThread.exactState.arcsecond)
        XCTAssertNotEqual(directThread.exactState, retrogradeThread.exactState)
    }

    func testMultipleGenesMayShareOneDegreeAddressWithoutLosingExactState() throws {
        let sun = NatalPosition(degree: 42, minute: 11, second: 13, retrograde: false)
        let moon = NatalPosition(degree: 42, minute: 58, second: 47, retrograde: false)
        let output = Clotho.gather(
            from: try natalDNA(overrides: [.sun: sun, .moon: moon])
        )
        let at42 = output.packet.threads.filter { $0.degreeAddress.rawValue == 42 }

        XCTAssertEqual(at42.count, 2)
        XCTAssertEqual(Set(at42.map(\.gene)), Set([.sun, .moon]))
        XCTAssertEqual(Set(at42.map { $0.exactState.arcsecond }).count, 2)
    }

    func testClothoDoesNotAlterTheStage0DegreeGrid() throws {
        let gridBefore = DegreeGrid()
        _ = Clotho.gather(from: try natalDNA())
        let gridAfter = DegreeGrid()

        XCTAssertEqual(gridAfter, gridBefore)
        XCTAssertEqual(gridAfter.cells.count, DegreeAddress.count)
    }

    func testClothoCreatesRecipeFromTheSameGatheringOperation() throws {
        let output = Clotho.gather(from: try natalDNA())

        XCTAssertEqual(output.recipe.entries.count, output.packet.threads.count)
        XCTAssertEqual(output.recipe.entries.map(\.gene), AstroDNAGene.canonicalOrder)

        for thread in output.packet.threads {
            let entry = try XCTUnwrap(output.recipe.entries.first { $0.gene == thread.gene })
            XCTAssertEqual(entry.exactState, thread.exactState)
            XCTAssertEqual(entry.degreeAddress, thread.degreeAddress)
        }
    }

    func testSameNatalAstroDNAProducesSameOutput() throws {
        let dna = try natalDNA()
        XCTAssertEqual(Clotho.gather(from: dna), Clotho.gather(from: dna))
    }
}
