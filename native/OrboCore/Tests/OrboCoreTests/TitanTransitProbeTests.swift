import XCTest
@testable import OrboCore

final class TitanTransitProbeTests: XCTestCase {
    func testAstroDNATransitsTheFourFrozenLawsWithoutChangingTheirJobs() throws {
        let dna = try makeSyntheticDNA()
        let result = TitanTransitProbe.run(dna)

        XCTAssertEqual(result.astroDNA, dna)

        // TYMPAN: Ascendant selects one existing whole-sign Imprint.
        XCTAssertEqual(result.tympan.risingSign, dna.sign(of: .ascendant))
        XCTAssertEqual(result.tympan.houses.count, 12)

        // MATER: the ten planetary coordinates are qualified through existing V2 law.
        XCTAssertNil(result.mater.sect)
        XCTAssertEqual(result.mater.tempers.count, Planet.canonicalOrder.count)
        for planet in Planet.canonicalOrder {
            let gene = try XCTUnwrap(AstroDNAGene(rawValue: planet.rawValue))
            XCTAssertEqual(result.mater.temper(for: planet).longitude, dna.longitude(of: gene))
        }

        // RING: all twelve encoded genes retain their existing exact templates.
        XCTAssertEqual(result.ring.count, AstroDNAGene.canonicalOrder.count)
        XCTAssertEqual(result.ring.map(\.gene), AstroDNAGene.canonicalOrder)
        for object in result.ring {
            XCTAssertEqual(object.source, dna[object.gene])
            XCTAssertFalse(object.marks.isEmpty)
        }

        // ARC: every copied coordinate receives the same frozen Cast and 360 projection.
        XCTAssertEqual(result.arcSubjects.count, result.arcCasts.count)
        XCTAssertEqual(result.arcSubjects.count, result.arcGrids.count)
        for index in result.arcSubjects.indices {
            let subject = result.arcSubjects[index]
            let cast = result.arcCasts[index]
            let grid = result.arcGrids[index]

            XCTAssertEqual(cast.subject, subject)
            XCTAssertEqual(cast.field, Arc.cast(subject.coordinate))
            XCTAssertEqual(grid.field, cast.field)
            XCTAssertEqual(grid.cells.count, Arc.degrees)
        }
    }

    func testProbeCopiesOnlyOriginalAndRingCoordinateMatterIntoArc() throws {
        let dna = try makeSyntheticDNA()
        let result = TitanTransitProbe.run(dna)

        let originalSubjects = result.arcSubjects.filter { $0.provenance == "AstroDNA" }
        let ringSubjects = result.arcSubjects.filter { $0.provenance == "Ring" }

        XCTAssertEqual(originalSubjects.count, AstroDNAGene.canonicalOrder.count)
        XCTAssertEqual(
            Set(result.arcSubjects.map(\.provenance)),
            Set(["AstroDNA", "Ring"])
        )

        for (gene, subject) in zip(AstroDNAGene.canonicalOrder, originalSubjects) {
            XCTAssertEqual(subject.identity, gene.displayName)
            XCTAssertEqual(subject.coordinate.arcsecond, dna[gene].arcsecond)
        }

        let expectedRingTargets = result.ring.flatMap { object in
            object.marks.map(\.targetArcsecond)
        }.sorted()
        let copiedRingTargets = ringSubjects.map { $0.coordinate.arcsecond }.sorted()

        XCTAssertEqual(ringSubjects.count, expectedRingTargets.count)
        XCTAssertEqual(copiedRingTargets, expectedRingTargets)

        // Tympan and Mater testify in the result, but neither is converted into
        // invented coordinate matter merely to give Arc something to cast.
        XCTAssertFalse(result.arcSubjects.contains { $0.provenance == "Tympan" })
        XCTAssertFalse(result.arcSubjects.contains { $0.provenance == "Mater" })
    }

    private func makeSyntheticDNA() throws -> AstroDNA {
        let sequence: [RingFineState] = [
            try state(215, 10, 0),
            try state(280, 5, 11),
            try state(15, 20, 22),
            try state(42, 11, 33, retrograde: true),
            try state(73, 22, 44),
            try state(101, 33, 55),
            try state(134, 44, 6, retrograde: true),
            try state(166, 55, 17),
            try state(199, 6, 28, retrograde: true),
            try state(231, 17, 39),
            try state(264, 28, 50, retrograde: true),
            try state(307, 39, 1, retrograde: true),
        ]

        return try XCTUnwrap(AstroDNA(sequence: sequence))
    }

    private func state(
        _ degree: Int,
        _ minute: Int,
        _ second: Int,
        retrograde: Bool = false
    ) throws -> RingFineState {
        let arcsecond = degree * Ring.arcsecondsPerDegree + minute * 60 + second
        let raw = retrograde ? Ring.arcseconds + arcsecond : arcsecond
        return try XCTUnwrap(RingFineState(raw))
    }
}
