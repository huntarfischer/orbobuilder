import XCTest
@testable import OrboCore

final class LachesisTitanPassTests: XCTestCase {
    func testLachesisPetitionsThemisWithoutChangingHerTestimony() throws {
        let dna = try makeSyntheticDNA()
        let pass = Lachesis.petition(dna, sect: nil)
        let direct = Themis.testify(dna.sign(of: .ascendant))

        XCTAssertEqual(pass.themis.imprint.risingSign, direct.imprint.risingSign)
        XCTAssertEqual(pass.themis.imprint.houses, direct.imprint.houses)
        XCTAssertEqual(
            pass.themis.imprint.traditionalGovernanceLattice,
            direct.imprint.traditionalGovernanceLattice
        )
        XCTAssertEqual(pass.themis.imprint.modernGovernance, direct.imprint.modernGovernance)
        XCTAssertEqual(pass.themis.imprint.houseGovernance, direct.imprint.houseGovernance)
    }

    func testLachesisPetitionsRheaWithoutChangingHerTestimony() throws {
        let dna = try makeSyntheticDNA()
        let pass = Lachesis.petition(dna, sect: nil)
        let longitudes = planetaryLongitudes(from: dna)
        let direct = Rhea.testify(longitudes, sect: nil)

        XCTAssertEqual(pass.rhea.field.longitudes, direct.field.longitudes)
        XCTAssertEqual(pass.rhea.field.sect, direct.field.sect)
        XCTAssertEqual(pass.rhea.field.tempers, direct.field.tempers)
        XCTAssertEqual(pass.rhea.field.byPlanet, direct.field.byPlanet)
    }

    func testLachesisPetitionsOceanusWithoutChangingHisTestimony() throws {
        let dna = try makeSyntheticDNA()
        let pass = Lachesis.petition(dna, sect: nil)
        let direct = Oceanus.testify(dna)

        XCTAssertEqual(pass.oceanus.objectTemplates, direct.objectTemplates)
        XCTAssertEqual(pass.oceanus.objectTemplates.map(\.gene), AstroDNAGene.canonicalOrder)
    }

    func testLachesisPresentsOnlyLawfulCoordinateMatterToAsteria() throws {
        let dna = try makeSyntheticDNA()
        let pass = Lachesis.petition(dna, sect: nil)
        let subjects = pass.asteria.refractions.map(\.subject)

        let astroDNASubjects = subjects.filter { $0.provenance == "AstroDNA" }
        let ringSubjects = subjects.filter { $0.provenance == "Ring" }

        XCTAssertEqual(astroDNASubjects.count, AstroDNAGene.canonicalOrder.count)
        XCTAssertEqual(Set(subjects.map(\.provenance)), Set(["AstroDNA", "Ring"]))
        XCTAssertFalse(subjects.contains { $0.provenance == "Tympan" })
        XCTAssertFalse(subjects.contains { $0.provenance == "Mater" })

        for (gene, subject) in zip(AstroDNAGene.canonicalOrder, astroDNASubjects) {
            XCTAssertEqual(subject.identity, gene.displayName)
            XCTAssertEqual(subject.coordinate.arcsecond, dna[gene].arcsecond)
        }

        let expectedRingTargets = pass.oceanus.objectTemplates.flatMap { object in
            object.marks.map(\.targetArcsecond)
        }.sorted()
        let actualRingTargets = ringSubjects.map { $0.coordinate.arcsecond }.sorted()

        XCTAssertEqual(ringSubjects.count, expectedRingTargets.count)
        XCTAssertEqual(actualRingTargets, expectedRingTargets)

        let expectedSubjects = makeAsteriaSubjects(
            from: dna,
            oceanus: Oceanus.testify(dna)
        )
        let direct = Asteria.testify(expectedSubjects)

        XCTAssertEqual(pass.asteria.refractions, direct.refractions)
        XCTAssertEqual(pass.asteria.projections, direct.projections)
    }

    func testLachesisTitanPassMatchesTemporaryTransitProbeExactly() throws {
        let dna = try makeSyntheticDNA()
        let probe = TitanTransitProbe.run(dna)
        let pass = Lachesis.petition(dna, sect: nil)

        XCTAssertEqual(pass.themis.imprint.risingSign, probe.themis.imprint.risingSign)
        XCTAssertEqual(pass.themis.imprint.houses, probe.themis.imprint.houses)
        XCTAssertEqual(
            pass.themis.imprint.traditionalGovernanceLattice,
            probe.themis.imprint.traditionalGovernanceLattice
        )
        XCTAssertEqual(
            pass.themis.imprint.modernGovernance,
            probe.themis.imprint.modernGovernance
        )
        XCTAssertEqual(
            pass.themis.imprint.houseGovernance,
            probe.themis.imprint.houseGovernance
        )

        XCTAssertEqual(pass.rhea.field.longitudes, probe.rhea.field.longitudes)
        XCTAssertEqual(pass.rhea.field.sect, probe.rhea.field.sect)
        XCTAssertEqual(pass.rhea.field.tempers, probe.rhea.field.tempers)
        XCTAssertEqual(pass.rhea.field.byPlanet, probe.rhea.field.byPlanet)

        XCTAssertEqual(pass.oceanus.objectTemplates, probe.oceanus.objectTemplates)
        XCTAssertEqual(pass.asteria.refractions, probe.asteria.refractions)
        XCTAssertEqual(pass.asteria.projections, probe.asteria.projections)
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

    private func makeAsteriaSubjects(
        from dna: AstroDNA,
        oceanus: OceanusPass
    ) -> [ArcSubject] {
        var subjects = AstroDNAGene.canonicalOrder.map { gene in
            ArcSubject(
                identity: gene.displayName,
                provenance: "AstroDNA",
                coordinate: ArcCoordinate(dna[gene].arcsecond)!
            )
        }

        for object in oceanus.objectTemplates {
            for mark in object.marks {
                subjects.append(
                    ArcSubject(
                        identity: "\(object.gene.displayName):\(mark.mark.rawValue):\(mark.targetArcsecond)",
                        provenance: "Ring",
                        coordinate: ArcCoordinate(mark.targetArcsecond)!
                    )
                )
            }
        }

        return subjects
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
