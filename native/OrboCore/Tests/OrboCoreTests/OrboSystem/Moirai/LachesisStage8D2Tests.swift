import XCTest
@testable import OrboCore

final class LachesisStage8D2Tests: XCTestCase {
    func testCanonicalPacketPetitionGivesAsteriaSixteenSourceSubjects() throws {
        let packet = try makePacket()
        let subjects = Lachesis.petition(packet).asteria.refractions.map(\.subject)

        XCTAssertEqual(subjects.count, AstroDNA.geneCount + 4)
        XCTAssertEqual(subjects.filter { $0.provenance == "AstroDNA" }.count, AstroDNA.geneCount)
        XCTAssertEqual(subjects.filter { $0.provenance == "Hecate" }.count, 4)
        XCTAssertFalse(subjects.contains { $0.provenance == "Ring" })
        XCTAssertFalse(subjects.contains { $0.provenance == "Tympan" })
        XCTAssertFalse(subjects.contains { $0.provenance == "Mater" })
    }

    func testAsteriaReceivesPatternPacketCoordinatesWithoutOceanusTestimony() throws {
        let packet = try makePacket()
        let subjects = Lachesis.petition(packet).asteria.refractions.map(\.subject)

        for gene in AstroDNAGene.canonicalOrder {
            let subject = try XCTUnwrap(subjects.first { $0.identity == gene.displayName })
            XCTAssertEqual(subject.provenance, "AstroDNA")
            XCTAssertEqual(subject.coordinate.arcsecond, packet.astroDNA[gene].arcsecond)
        }

        let expectedLots: [(String, CelestialLongitude)] = [
            ("Fortune", packet.fortune),
            ("Spirit", packet.spirit),
            ("Eros", packet.eros),
            ("Necessity", packet.necessity),
        ]

        for (identity, longitude) in expectedLots {
            let subject = try XCTUnwrap(subjects.first { $0.identity == identity })
            XCTAssertEqual(subject.provenance, "Hecate")
            XCTAssertEqual(
                subject.coordinate.arcsecond,
                Int((longitude.degrees * Double(Arc.arcsecondsPerDegree)).rounded(.down))
            )
        }
    }

    func testThemisRheaAndOceanusRemainDirectKeeperTestimony() throws {
        let packet = try makePacket(sect: .night)
        let pass = Lachesis.petition(packet)

        let directThemis = Themis.testify(packet.astroDNA.sign(of: .ascendant))
        XCTAssertEqual(pass.themis.imprint.risingSign, directThemis.imprint.risingSign)
        XCTAssertEqual(pass.themis.imprint.houses, directThemis.imprint.houses)

        let directRhea = Rhea.testify(
            planetaryLongitudes(from: packet.astroDNA),
            sect: packet.sect
        )
        XCTAssertEqual(pass.rhea.field.longitudes, directRhea.field.longitudes)
        XCTAssertEqual(pass.rhea.field.sect, directRhea.field.sect)
        XCTAssertEqual(pass.rhea.field.tempers, directRhea.field.tempers)
        XCTAssertEqual(pass.rhea.field.byPlanet, directRhea.field.byPlanet)

        let directOceanus = Oceanus.testify(packet.astroDNA)
        XCTAssertEqual(pass.oceanus.objectTemplates, directOceanus.objectTemplates)
    }

    func testChangingLotsCannotContaminateThemisRheaOrOceanus() throws {
        let first = try makePacket(
            fortune: 12.25,
            spirit: 198.5,
            eros: 301.75,
            necessity: 87.125
        )
        let second = try makePacket(
            fortune: 22.25,
            spirit: 208.5,
            eros: 311.75,
            necessity: 97.125
        )

        let firstPass = Lachesis.petition(first)
        let secondPass = Lachesis.petition(second)

        XCTAssertEqual(firstPass.themis.imprint.houses, secondPass.themis.imprint.houses)
        XCTAssertEqual(firstPass.rhea.field.longitudes, secondPass.rhea.field.longitudes)
        XCTAssertEqual(firstPass.rhea.field.sect, secondPass.rhea.field.sect)
        XCTAssertEqual(firstPass.rhea.field.tempers, secondPass.rhea.field.tempers)
        XCTAssertEqual(firstPass.rhea.field.byPlanet, secondPass.rhea.field.byPlanet)
        XCTAssertEqual(firstPass.oceanus.objectTemplates, secondPass.oceanus.objectTemplates)
        XCTAssertNotEqual(firstPass.asteria.refractions, secondPass.asteria.refractions)
    }

    func testChangingSectIsContainedToRhea() throws {
        let day = try makePacket(sect: .day)
        let night = try makePacket(sect: .night)

        let dayPass = Lachesis.petition(day)
        let nightPass = Lachesis.petition(night)

        XCTAssertEqual(dayPass.themis.imprint.houses, nightPass.themis.imprint.houses)
        XCTAssertNotEqual(dayPass.rhea.field.sect, nightPass.rhea.field.sect)
        XCTAssertEqual(dayPass.oceanus.objectTemplates, nightPass.oceanus.objectTemplates)
        XCTAssertEqual(dayPass.asteria.refractions, nightPass.asteria.refractions)
        XCTAssertEqual(dayPass.asteria.projections, nightPass.asteria.projections)
    }

    func testIndependentTitanPassIsDeterministic() throws {
        let packet = try makePacket()
        let first = Lachesis.petition(packet)
        let second = Lachesis.petition(packet)

        XCTAssertEqual(first.themis.imprint.houses, second.themis.imprint.houses)
        XCTAssertEqual(first.rhea.field.longitudes, second.rhea.field.longitudes)
        XCTAssertEqual(first.rhea.field.sect, second.rhea.field.sect)
        XCTAssertEqual(first.rhea.field.tempers, second.rhea.field.tempers)
        XCTAssertEqual(first.rhea.field.byPlanet, second.rhea.field.byPlanet)
        XCTAssertEqual(first.oceanus.objectTemplates, second.oceanus.objectTemplates)
        XCTAssertEqual(first.asteria.refractions, second.asteria.refractions)
        XCTAssertEqual(first.asteria.projections, second.asteria.projections)
    }

    private func makePacket(
        sect: Sect = .day,
        fortune: Double = 12.25,
        spirit: Double = 198.5,
        eros: Double = 301.75,
        necessity: Double = 87.125
    ) throws -> PatternPacket {
        PatternPacket(
            pattern: .engraving,
            astroDNA: try makeSyntheticDNA(),
            sect: sect,
            fortune: try XCTUnwrap(CelestialLongitude(fortune)),
            spirit: try XCTUnwrap(CelestialLongitude(spirit)),
            eros: try XCTUnwrap(CelestialLongitude(eros)),
            necessity: try XCTUnwrap(CelestialLongitude(necessity))
        )
    }

    private func planetaryLongitudes(
        from dna: AstroDNA
    ) -> [Planet: CelestialLongitude] {
        Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, dna.longitude(of: gene(for: planet)))
            }
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

    private func gene(for planet: Planet) -> AstroDNAGene {
        switch planet {
        case .sun: return .sun
        case .moon: return .moon
        case .mercury: return .mercury
        case .venus: return .venus
        case .mars: return .mars
        case .jupiter: return .jupiter
        case .saturn: return .saturn
        case .uranus: return .uranus
        case .neptune: return .neptune
        case .pluto: return .pluto
        }
    }
}
