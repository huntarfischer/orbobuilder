import XCTest
@testable import OrboCore

final class ClothoStage1Tests: XCTestCase {
    private func natalDNA(
        degrees: [Int] = [221, 277, 21, 8, 9, 49, 312, 237, 257, 273, 213, 49],
        retrogradeGenes: Set<AstroDNAGene> = []
    ) throws -> AstroDNA {
        XCTAssertEqual(degrees.count, AstroDNA.geneCount)

        let sequence = try AstroDNAGene.canonicalOrder.map { gene -> RingFineState in
            let degree = degrees[gene.ordinal]
            var rawValue = degree * Ring.arcsecondsPerDegree
            if retrogradeGenes.contains(gene) {
                rawValue += Ring.arcseconds
            }
            return try XCTUnwrap(RingFineState(rawValue))
        }

        return try XCTUnwrap(AstroDNA(sequence: sequence))
    }

    func testClothoTakesNatalAstroDNAAsInputAndReturnsExactlyTwelveFacts() throws {
        let packet = Clotho.gather(from: try natalDNA())
        XCTAssertEqual(packet.natalFacts.count, AstroDNA.geneCount)
        XCTAssertEqual(packet.natalFacts.count, 12)
    }

    func testFactsRemainInCanonicalAstroDNAGeneOrder() throws {
        let packet = Clotho.gather(from: try natalDNA())
        XCTAssertEqual(packet.natalFacts.map(\.gene), AstroDNAGene.canonicalOrder)
    }

    func testEachFactPreservesExactRingFineStateUnchanged() throws {
        let dna = try natalDNA(retrogradeGenes: [.mercury, .saturn, .northNode])
        let packet = Clotho.gather(from: dna)

        for fact in packet.natalFacts {
            XCTAssertEqual(fact.exactState, dna[fact.gene])
            XCTAssertEqual(fact.exactState.rawValue, dna[fact.gene].rawValue)
        }
    }

    func testEachFactUsesTheSameWholeDegreeAddressAsRingProjection() throws {
        let dna = try natalDNA()
        let packet = Clotho.gather(from: dna)

        for fact in packet.natalFacts {
            XCTAssertEqual(
                fact.degreeAddress.rawValue,
                dna[fact.gene].coarseState.degree
            )
        }
    }

    func testRetrogradeMotionDoesNotChangeDegreeAddress() throws {
        let direct = Clotho.gather(from: try natalDNA())
        let retrograde = Clotho.gather(
            from: try natalDNA(retrogradeGenes: [.mercury, .saturn, .northNode])
        )

        for gene in [AstroDNAGene.mercury, .saturn, .northNode] {
            let directFact = try XCTUnwrap(direct.natalFacts.first { $0.gene == gene })
            let retrogradeFact = try XCTUnwrap(retrograde.natalFacts.first { $0.gene == gene })
            XCTAssertEqual(directFact.degreeAddress, retrogradeFact.degreeAddress)
            XCTAssertNotEqual(directFact.exactState, retrogradeFact.exactState)
        }
    }

    func testMultipleGenesMayShareOneDegreeAddress() throws {
        var degrees = [221, 277, 21, 8, 9, 49, 312, 237, 257, 273, 213, 49]
        degrees[AstroDNAGene.sun.ordinal] = 42
        degrees[AstroDNAGene.moon.ordinal] = 42

        let packet = Clotho.gather(from: try natalDNA(degrees: degrees))
        let at42 = packet.natalFacts.filter { $0.degreeAddress.rawValue == 42 }

        XCTAssertEqual(at42.count, 2)
        XCTAssertEqual(Set(at42.map(\.gene)), Set([.sun, .moon]))
    }

    func testClothoDoesNotAlterTheStage0DegreeGrid() throws {
        let gridBefore = DegreeGrid()
        _ = Clotho.gather(from: try natalDNA())
        let gridAfter = DegreeGrid()

        XCTAssertEqual(gridAfter, gridBefore)
        XCTAssertEqual(gridAfter.cells.count, DegreeAddress.count)
    }

    func testSameNatalAstroDNAProducesSamePacket() throws {
        let dna = try natalDNA(retrogradeGenes: [.venus, .pluto])
        XCTAssertEqual(Clotho.gather(from: dna), Clotho.gather(from: dna))
    }
}
