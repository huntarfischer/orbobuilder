import XCTest
@testable import OrboCore

final class MoiraiStage8E2Tests: XCTestCase {
    private struct Position {
        let degrees: Double
        let motion: Motion
    }

    private struct PortIStub: ClothoPortI {
        let output: HoraeOutput

        mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
            output
        }
    }

    func testClothoLachesisAtroposCompleteOneCanonicalEngraving() throws {
        let engraving = try resolvedEngraving()
        var portI = PortIStub(output: try slice(for: engraving))

        // Clotho gathers and carries the complete PatternPacket.
        let clotho = try Clotho.spin(engraving, through: &portI)

        // Lachesis preserves Clotho's packet, gathers four independent Titan
        // testimonies, then allots Placement followed by the Titan's Pass.
        let lachesis = Lachesis.receive(clotho.packet)
        let placement = Lachesis.allot(lachesis.packet, into: Tapestry())
        let finished = Lachesis.allot(lachesis.titanPass, into: placement)

        // Atropos compares the finished Tapestry to the exact packet and four
        // testimonies Lachesis received, then seals that same Tapestry.
        let sealed = try Atropos.inspect(
            packet: lachesis.packet,
            titanPass: lachesis.titanPass,
            tapestry: finished
        ).get()

        XCTAssertEqual(clotho.engraving.astroDNA, clotho.packet.astroDNA)
        XCTAssertEqual(lachesis.packet, clotho.packet)
        XCTAssertEqual(sealed.tapestry, finished)
        XCTAssertEqual(sealed.tapestry.degrees.count, DegreeAddress.count)
        XCTAssertEqual(sealed.tapestry.degrees.map(\.address), DegreeAddress.canonicalOrder)

        XCTAssertEqual(
            sealed.tapestry.degrees.flatMap(\.placement.values).count,
            AstroDNA.geneCount + 4
        )
        XCTAssertTrue(sealed.tapestry.degrees.allSatisfy { !$0.tympan.isEmpty })
        XCTAssertEqual(
            sealed.tapestry.degrees.flatMap(\.mater.conditions).count,
            Planet.canonicalOrder.count
        )
        XCTAssertEqual(
            sealed.tapestry.degrees.flatMap(\.arc.values).count,
            lachesis.titanPass.asteria.projections.count * DegreeAddress.count
        )
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

    private func resolvedEngraving() throws -> Engraving {
        guard case let .found(engraving) = Atlas().resolve(unfinishedEngraving()) else {
            XCTFail("Expected Atlas to resolve engraving")
            throw TestError.unexpectedAtlasResolution
        }
        return engraving
    }

    private func slice(for engraving: Engraving) throws -> HoraeOutput {
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

        let celestial = try MundaneBody.canonicalOrder.map { body in
            let position = try XCTUnwrap(positions[body])
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: try XCTUnwrap(
                    OrboSpineDirectionalDegree(
                        physicalDegrees: position.degrees,
                        motion: position.motion
                    )
                ),
                julianDay: julianDay
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
