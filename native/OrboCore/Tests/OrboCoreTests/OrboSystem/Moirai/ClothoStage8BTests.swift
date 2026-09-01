import XCTest
@testable import OrboCore

final class ClothoStage8BTests: XCTestCase {
    private struct Position {
        let degrees: Double
        let motion: Motion
    }

    private struct PortISpy: ClothoPortI {
        var output: HoraeOutput
        var receivedTempus: [Tempus] = []

        mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
            receivedTempus.append(tempus)
            return output
        }
    }

    func testHecateAscendantKleisUsesSuppliedTerraAndTopos() throws {
        let engraving = try resolvedEngraving()
        let topos = try XCTUnwrap(engraving.topos)
        let sourceSlice = try slice(for: engraving)

        XCTAssertNotNil(Kleides.canonical.kleis(AscendantKleis.id))

        let ascendant = try Hecate.castAscendant(
            terra: sourceSlice.terra,
            topos: topos
        )

        XCTAssertEqual(ascendant.motion, .direct)
        XCTAssertEqual(ascendant.dms, RingDMS(degree: 110, minute: 23, second: 52))
    }

    func testHecateSectKleisPreservesFrozenOrboBoundaryLaw() throws {
        let ascendant = CelestialLongitude(0)!

        XCTAssertNotNil(Kleides.canonical.kleis(SectKleis.id))
        XCTAssertEqual(
            try Hecate.castSect(ascendant: ascendant, sun: CelestialLongitude(0)!),
            .day
        )
        XCTAssertEqual(
            try Hecate.castSect(ascendant: ascendant, sun: CelestialLongitude(179.999)!),
            .day
        )
        XCTAssertEqual(
            try Hecate.castSect(ascendant: ascendant, sun: CelestialLongitude(180)!),
            .day
        )
        XCTAssertEqual(
            try Hecate.castSect(ascendant: ascendant, sun: CelestialLongitude(180.001)!),
            .night
        )
    }

    func testClothoGathersOneHoraeSliceAndCarriesCompleteHecateMatterForward() throws {
        let engraving = try resolvedEngraving()
        let topos = try XCTUnwrap(engraving.topos)
        let expectedTempus = try XCTUnwrap(engraving.tempus)
        let sourceSlice = try slice(for: engraving)
        var portI = PortISpy(output: sourceSlice)

        let output = try Clotho.spin(engraving, through: &portI)
        let expectedAscendant = try Hecate.castAscendant(
            terra: sourceSlice.terra,
            topos: topos
        )

        XCTAssertEqual(portI.receivedTempus, [expectedTempus])
        XCTAssertEqual(sourceSlice.celestial.count, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(output.packet.astroDNA.sequence.count, AstroDNA.geneCount)
        XCTAssertEqual(output.packet.astroDNA[.ascendant], expectedAscendant)
        XCTAssertEqual(output.packet.sect, .night)
        XCTAssertEqual(output.packet.fortune.degrees, 210.39777777777778, accuracy: 1e-12)
        XCTAssertEqual(output.packet.spirit.degrees, 10.397777777777776, accuracy: 1e-12)
        XCTAssertEqual(output.packet.eros.degrees, 80.79555555555557, accuracy: 1e-12)
        XCTAssertEqual(output.packet.necessity.degrees, 270, accuracy: 1e-12)
        XCTAssertEqual(output.engraving.astroDNA, output.packet.astroDNA)
    }

    func testClothoLotsUseTheSpiritAndFortuneHecateJustReturned() throws {
        let engraving = try resolvedEngraving()
        let sourceSlice = try slice(for: engraving)
        var portI = PortISpy(output: sourceSlice)

        let output = try Clotho.spin(engraving, through: &portI)
        let ascendantState = output.packet.astroDNA[.ascendant]
        let ascendant = CelestialLongitude(
            Double(ascendantState.arcsecond) / Double(Ring.arcsecondsPerDegree)
        )!
        let expectedEros = try Hecate.castEros(
            ascendant: ascendant,
            venus: CelestialLongitude(40)!,
            spirit: output.packet.spirit,
            sect: output.packet.sect
        )
        let expectedNecessity = try Hecate.castNecessity(
            ascendant: ascendant,
            fortune: output.packet.fortune,
            mercury: CelestialLongitude(10)!,
            sect: output.packet.sect
        )

        XCTAssertEqual(output.packet.eros, expectedEros)
        XCTAssertEqual(output.packet.necessity, expectedNecessity)
    }

    func testClothoRejectsMissingUniversalBodyAfterSingleDoorQuery() throws {
        let engraving = try resolvedEngraving()
        var portI = PortISpy(output: try slice(for: engraving, omitting: .pluto))

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .missingUniversalBody(.pluto))
        }
        XCTAssertEqual(portI.receivedTempus.count, 1)
    }

    func testClothoRejectsUnresolvedTempusBeforeDoorQuery() throws {
        let engraving = try toposOnlyEngraving()
        let resolved = try resolvedEngraving()
        var portI = PortISpy(output: try slice(for: resolved))

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .unresolvedTempus)
        }
        XCTAssertTrue(portI.receivedTempus.isEmpty)
    }

    private func unfinishedEngraving() -> Engraving {
        OrboOnboarding.complete(
            subjectID: HermesSubjectID(rawValue: "subject.native")!,
            name: "Ean",
            birthDate: CivilDate(year: 1985, month: 4, day: 10)!,
            birthTime: CivilClockTime(hour: 20, minute: 16)!,
            birthLocation: "Madison, WI"
        ).contents
    }

    private func toposOnlyEngraving() throws -> Engraving {
        let engraving = unfinishedEngraving()
        guard case let .found(topos) = Atlas().resolve(engraving.birthLocation) else {
            XCTFail("Expected Atlas to resolve Madison")
            throw TestError.unexpectedAtlasResolution
        }
        return engraving.resolving(topos: topos)
    }

    private func resolvedEngraving() throws -> Engraving {
        guard case let .found(engraving) = Atlas().resolve(unfinishedEngraving()) else {
            XCTFail("Expected Atlas to resolve Madison and Tempus")
            throw TestError.unexpectedAtlasResolution
        }
        return engraving
    }

    private func slice(
        for engraving: Engraving,
        omitting omittedBody: MundaneBody? = nil
    ) throws -> HoraeOutput {
        let positions: [MundaneBody: Position] = [
            .sun: Position(degrees: 20, motion: .direct),
            .moon: Position(degrees: 280, motion: .direct),
            .mercury: Position(degrees: 10, motion: .retrograde),
            .venus: Position(degrees: 40, motion: .retrograde),
            .mars: Position(degrees: 50, motion: .direct),
            .jupiter: Position(degrees: 100, motion: .direct),
            .saturn: Position(degrees: 150, motion: .retrograde),
            .uranus: Position(degrees: 200, motion: .retrograde),
            .neptune: Position(degrees: 250, motion: .retrograde),
            .pluto: Position(degrees: 300, motion: .retrograde),
            .trueNorthNode: Position(degrees: 60, motion: .retrograde),
        ]
        let topos = try XCTUnwrap(engraving.topos)
        let julianDay = JulianDay(2_446_166.5)!
        let terra = TerraMarrowSample(
            turnDegrees: CelestialLongitude(-topos.place.longitude.degrees)!.degrees,
            tiltDegrees: 23.44,
            julianDay: julianDay
        )!

        var celestial: [OrboSpineCelestialCoordinate] = []
        for body in MundaneBody.canonicalOrder where body != omittedBody {
            let position = try XCTUnwrap(positions[body])
            celestial.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: try XCTUnwrap(
                        OrboSpineDirectionalDegree(
                            physicalDegrees: position.degrees,
                            motion: position.motion
                        )
                    ),
                    julianDay: julianDay
                )
            )
        }

        return HoraeOutput(
            julianDay: julianDay,
            celestial: celestial,
            terra: terra
        )
    }

    private enum TestError: Error {
        case unexpectedAtlasResolution
    }
}
