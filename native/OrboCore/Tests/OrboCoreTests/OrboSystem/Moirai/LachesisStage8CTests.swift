import XCTest
@testable import OrboCore

final class LachesisStage8CTests: XCTestCase {
    func testLachesisReceivesCompletePatternPacketUnchanged() throws {
        let packet = try makePacket()

        let output = Lachesis.receive(packet)

        XCTAssertEqual(output.packet, packet)
        XCTAssertEqual(output.packet.pattern, .engraving)
        XCTAssertEqual(output.packet.astroDNA, packet.astroDNA)
        XCTAssertEqual(output.packet.sect, packet.sect)
    }

    func testLachesisUsesPacketSectForTitanPass() throws {
        let packet = try makePacket(sect: .night)

        let output = Lachesis.receive(packet)

        XCTAssertEqual(output.titanPass.rhea.field.sect, packet.sect)
    }

    func testLachesisCanonicalIntakeMatchesExistingTitanPetition() throws {
        let packet = try makePacket()
        let expected = Lachesis.petition(packet)

        let actual = Lachesis.receive(packet).titanPass

        XCTAssertEqual(actual.themis.imprint.risingSign, expected.themis.imprint.risingSign)
        XCTAssertEqual(actual.themis.imprint.houses, expected.themis.imprint.houses)
        XCTAssertEqual(
            actual.themis.imprint.traditionalGovernanceLattice,
            expected.themis.imprint.traditionalGovernanceLattice
        )
        XCTAssertEqual(actual.themis.imprint.modernGovernance, expected.themis.imprint.modernGovernance)
        XCTAssertEqual(actual.themis.imprint.houseGovernance, expected.themis.imprint.houseGovernance)

        XCTAssertEqual(actual.rhea.field.longitudes, expected.rhea.field.longitudes)
        XCTAssertEqual(actual.rhea.field.sect, expected.rhea.field.sect)
        XCTAssertEqual(actual.rhea.field.tempers, expected.rhea.field.tempers)
        XCTAssertEqual(actual.rhea.field.byPlanet, expected.rhea.field.byPlanet)

        XCTAssertEqual(actual.oceanus.objectTemplates, expected.oceanus.objectTemplates)
        XCTAssertEqual(actual.asteria.refractions, expected.asteria.refractions)
        XCTAssertEqual(actual.asteria.projections, expected.asteria.projections)
    }

    func testHecateLotsSurviveLachesisIntakeWithoutBeingConsumed() throws {
        let packet = try makePacket()

        let output = Lachesis.receive(packet)

        XCTAssertEqual(output.packet.fortune, packet.fortune)
        XCTAssertEqual(output.packet.spirit, packet.spirit)
        XCTAssertEqual(output.packet.eros, packet.eros)
        XCTAssertEqual(output.packet.necessity, packet.necessity)
    }

    private func makePacket(sect: Sect = .day) throws -> PatternPacket {
        PatternPacket(
            pattern: .engraving,
            astroDNA: try makeSyntheticDNA(),
            sect: sect,
            fortune: try XCTUnwrap(CelestialLongitude(12.25)),
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
