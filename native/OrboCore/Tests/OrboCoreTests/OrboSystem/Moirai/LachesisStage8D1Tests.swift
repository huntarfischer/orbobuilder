import XCTest
@testable import OrboCore

final class LachesisStage8D1Tests: XCTestCase {
    func testPatternPacketAllotsSixteenCoordinateValuesIntoPlacement() throws {
        let packet = try makePacket()

        let tapestry = Lachesis.allot(packet, into: Tapestry())
        let values = tapestry.degrees.flatMap(\.placement.values)

        XCTAssertEqual(values.count, AstroDNA.geneCount + 4)
        XCTAssertEqual(Set(values).count, AstroDNA.geneCount + 4)
    }

    func testAstroDNAStatesAreAllottedToTheirSuppliedDegreesUnchanged() throws {
        let packet = try makePacket()
        let tapestry = Lachesis.allot(packet, into: Tapestry())

        for gene in AstroDNAGene.canonicalOrder {
            let expected = TapestryPlacementValue.astroDNA(
                gene: gene,
                state: packet.astroDNA[gene]
            )
            let address = expected.degreeAddress.rawValue

            XCTAssertTrue(tapestry.degrees[address].placement.values.contains(expected))
        }
    }

    func testHecateLotsAreAllottedAtExactPacketLongitudes() throws {
        let packet = try makePacket()
        let tapestry = Lachesis.allot(packet, into: Tapestry())
        let expected: [TapestryPlacementValue] = [
            .fortune(packet.fortune),
            .spirit(packet.spirit),
            .eros(packet.eros),
            .necessity(packet.necessity),
        ]

        for value in expected {
            XCTAssertTrue(
                tapestry.degrees[value.degreeAddress.rawValue]
                    .placement.values.contains(value)
            )
        }
    }

    func testPlacementAllowsMultipleValuesToShareOneDegree() throws {
        let packet = try makePacket()
        let tapestry = Lachesis.allot(packet, into: Tapestry())
        let shared = tapestry.degrees[215].placement.values

        XCTAssertTrue(
            shared.contains(
                .astroDNA(
                    gene: .ascendant,
                    state: packet.astroDNA[.ascendant]
                )
            )
        )
        XCTAssertTrue(shared.contains(.fortune(packet.fortune)))
        XCTAssertEqual(shared.count, 2)
    }

    func testPlacementAllotmentLeavesTitanSubsectionsUntouched() throws {
        let tapestry = Lachesis.allot(try makePacket(), into: Tapestry())

        XCTAssertTrue(tapestry.degrees.allSatisfy { degree in
            degree.tympan.isEmpty
                && degree.mater.isEmpty
                && degree.ring.isEmpty
                && degree.arc.isEmpty
        })
    }

    func testPlacementAllotmentIsDeterministic() throws {
        let packet = try makePacket()

        XCTAssertEqual(
            Lachesis.allot(packet, into: Tapestry()),
            Lachesis.allot(packet, into: Tapestry())
        )
    }

    private func makePacket() throws -> PatternPacket {
        PatternPacket(
            pattern: .engraving,
            astroDNA: try makeSyntheticDNA(),
            sect: .day,
            fortune: try XCTUnwrap(CelestialLongitude(215.25)),
            spirit: try XCTUnwrap(CelestialLongitude(198.5)),
            eros: try XCTUnwrap(CelestialLongitude(301.75)),
            necessity: try XCTUnwrap(CelestialLongitude(87.125))
        )
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
