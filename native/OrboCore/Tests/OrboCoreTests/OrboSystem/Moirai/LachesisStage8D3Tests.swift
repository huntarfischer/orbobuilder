import XCTest
@testable import OrboCore

final class LachesisStage8D3Tests: XCTestCase {
    func testThemisStageAllotsOnlyTympan() throws {
        let packet = try makePacket()
        let titanPass = Lachesis.petition(packet)
        let before = Lachesis.allot(packet, into: Tapestry())

        let after = Lachesis.allotThemis(titanPass.themis, into: before)
        let houseBySign = Dictionary(
            uniqueKeysWithValues: titanPass.themis.imprint.houses.map { ($0.sign, $0.house) }
        )

        for degree in after.degrees {
            let sign = Sign(rawValue: degree.address.rawValue / 30)!
            XCTAssertEqual(degree.tympan.house, houseBySign[sign])
        }

        XCTAssertEqual(after.degrees.map(\.placement), before.degrees.map(\.placement))
        XCTAssertTrue(after.degrees.allSatisfy { !$0.tympan.isEmpty })
        XCTAssertTrue(after.degrees.allSatisfy { $0.mater.isEmpty && $0.ring.isEmpty && $0.arc.isEmpty })
    }

    func testRheaStageAllotsOnlyRheaTestimonyAfterThemis() throws {
        let packet = try makePacket()
        let titanPass = Lachesis.petition(packet)
        let placement = Lachesis.allot(packet, into: Tapestry())
        let afterThemis = Lachesis.allotThemis(titanPass.themis, into: placement)

        let afterRhea = Lachesis.allotRhea(titanPass.rhea, into: afterThemis)
        let actual = afterRhea.degrees.flatMap(\.mater.conditions)

        XCTAssertEqual(actual.count, titanPass.rhea.field.tempers.count)
        XCTAssertEqual(Set(actual), Set(titanPass.rhea.field.tempers))

        for condition in actual {
            let address = Int(condition.longitude.degrees.rounded(.down))
            XCTAssertTrue(afterRhea.degrees[address].mater.conditions.contains(condition))
        }

        XCTAssertEqual(afterRhea.degrees.map(\.placement), afterThemis.degrees.map(\.placement))
        XCTAssertEqual(afterRhea.degrees.map(\.tympan), afterThemis.degrees.map(\.tympan))
        XCTAssertTrue(afterRhea.degrees.allSatisfy { $0.ring.isEmpty && $0.arc.isEmpty })
    }

    func testOceanusStageAllotsOnlyOceanusTestimonyAfterRhea() throws {
        let packet = try makePacket()
        let titanPass = Lachesis.petition(packet)
        let afterRhea = throughRhea(packet: packet, titanPass: titanPass)

        let afterOceanus = Lachesis.allotOceanus(titanPass.oceanus, into: afterRhea)
        let actual = afterOceanus.degrees.flatMap(\.ring.values)
        let expected = titanPass.oceanus.objectTemplates.flatMap { object in
            object.marks.map { mark in
                TapestryRingValue(
                    gene: object.gene,
                    source: object.source,
                    mark: mark.mark,
                    targetArcsecond: mark.targetArcsecond
                )
            }
        }

        XCTAssertEqual(actual.count, expected.count)
        XCTAssertEqual(Set(actual), Set(expected))

        for value in actual {
            XCTAssertTrue(
                afterOceanus.degrees[value.degreeAddress.rawValue]
                    .ring.values.contains(value)
            )
        }

        XCTAssertEqual(afterOceanus.degrees.map(\.placement), afterRhea.degrees.map(\.placement))
        XCTAssertEqual(afterOceanus.degrees.map(\.tympan), afterRhea.degrees.map(\.tympan))
        XCTAssertEqual(afterOceanus.degrees.map(\.mater), afterRhea.degrees.map(\.mater))
        XCTAssertTrue(afterOceanus.degrees.allSatisfy { $0.arc.isEmpty })
    }

    func testAsteriaStageAllotsOnlyAsteriaTestimonyAfterOceanus() throws {
        let packet = try makePacket()
        let titanPass = Lachesis.petition(packet)
        let afterOceanus = throughOceanus(packet: packet, titanPass: titanPass)

        let afterAsteria = Lachesis.allotAsteria(titanPass.asteria, into: afterOceanus)

        XCTAssertEqual(titanPass.asteria.refractions.count, 16)
        XCTAssertEqual(titanPass.asteria.projections.count, 16)

        for degree in 0..<DegreeAddress.count {
            let values = afterAsteria.degrees[degree].arc.values
            XCTAssertEqual(values.count, titanPass.asteria.projections.count)

            for index in titanPass.asteria.projections.indices {
                XCTAssertEqual(values[index].subject, titanPass.asteria.refractions[index].subject)
                XCTAssertEqual(values[index].cell, titanPass.asteria.projections[index].cells[degree])
            }
        }

        XCTAssertEqual(afterAsteria.degrees.map(\.placement), afterOceanus.degrees.map(\.placement))
        XCTAssertEqual(afterAsteria.degrees.map(\.tympan), afterOceanus.degrees.map(\.tympan))
        XCTAssertEqual(afterAsteria.degrees.map(\.mater), afterOceanus.degrees.map(\.mater))
        XCTAssertEqual(afterAsteria.degrees.map(\.ring), afterOceanus.degrees.map(\.ring))
    }

    func testCanonicalTitanAllotmentMatchesFourOrderedStages() throws {
        let packet = try makePacket()
        let titanPass = Lachesis.petition(packet)
        let placement = Lachesis.allot(packet, into: Tapestry())

        let manualThemis = Lachesis.allotThemis(titanPass.themis, into: placement)
        let manualRhea = Lachesis.allotRhea(titanPass.rhea, into: manualThemis)
        let manualOceanus = Lachesis.allotOceanus(titanPass.oceanus, into: manualRhea)
        let manualAsteria = Lachesis.allotAsteria(titanPass.asteria, into: manualOceanus)

        XCTAssertEqual(
            Lachesis.allot(titanPass, into: placement),
            manualAsteria
        )
    }

    func testFourTitanTestimoniesRemainSeparatelyInspectableAfterAllotment() throws {
        let packet = try makePacket()
        let titanPass = Lachesis.petition(packet)
        let themisBefore = titanPass.themis.imprint.houses
        let rheaBefore = titanPass.rhea.field.tempers
        let oceanusBefore = titanPass.oceanus.objectTemplates
        let asteriaRefractionsBefore = titanPass.asteria.refractions
        let asteriaProjectionsBefore = titanPass.asteria.projections

        let placement = Lachesis.allot(packet, into: Tapestry())
        _ = Lachesis.allot(titanPass, into: placement)

        XCTAssertEqual(titanPass.themis.imprint.houses, themisBefore)
        XCTAssertEqual(titanPass.rhea.field.tempers, rheaBefore)
        XCTAssertEqual(titanPass.oceanus.objectTemplates, oceanusBefore)
        XCTAssertEqual(titanPass.asteria.refractions, asteriaRefractionsBefore)
        XCTAssertEqual(titanPass.asteria.projections, asteriaProjectionsBefore)
    }

    private func throughRhea(
        packet: PatternPacket,
        titanPass: LachesisTitanPass
    ) -> Tapestry {
        let placement = Lachesis.allot(packet, into: Tapestry())
        let afterThemis = Lachesis.allotThemis(titanPass.themis, into: placement)
        return Lachesis.allotRhea(titanPass.rhea, into: afterThemis)
    }

    private func throughOceanus(
        packet: PatternPacket,
        titanPass: LachesisTitanPass
    ) -> Tapestry {
        Lachesis.allotOceanus(
            titanPass.oceanus,
            into: throughRhea(packet: packet, titanPass: titanPass)
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
