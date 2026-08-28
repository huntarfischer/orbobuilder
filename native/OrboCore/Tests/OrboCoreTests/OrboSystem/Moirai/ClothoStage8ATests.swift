import XCTest
@testable import OrboCore

final class ClothoStage8ATests: XCTestCase {
    private struct Position {
        let degrees: Double
        let motion: Motion
    }

    private struct PortISpy: ClothoPortI {
        var output: HoraeOutput
        var callCount = 0

        mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
            callCount += 1
            return output
        }
    }

    func testClothoCarriesTheCanonicalHecateAstroDNACastForward() throws {
        let engraving = try resolvedEngraving()
        let sourceSlice = try slice(for: engraving)
        let expectedNodes = try nodeStates(for: engraving, slice: sourceSlice)
        let expectedAstroDNA = try Hecate.castAstroDNA(using: expectedNodes)
        var portI = PortISpy(output: sourceSlice)

        let output = try Clotho.spin(engraving, through: &portI)

        XCTAssertEqual(portI.callCount, 1)
        XCTAssertEqual(output.packet.pattern, .engraving)
        XCTAssertEqual(output.packet.astroDNA, expectedAstroDNA)
        XCTAssertEqual(output.engraving.astroDNA, expectedAstroDNA)
    }

    func testClothoMapsFailedHecateAstroDNACastToExistingFailure() throws {
        let engraving = try resolvedEngraving()
        let badSun = Position(degrees: 20, motion: .retrograde)
        let sourceSlice = try slice(for: engraving, overrides: [.sun: badSun])
        let expectedNodes = try nodeStates(for: engraving, slice: sourceSlice)

        XCTAssertThrowsError(try Hecate.castAstroDNA(using: expectedNodes))

        var portI = PortISpy(output: sourceSlice)
        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .invalidAstroDNA)
        }
        XCTAssertEqual(portI.callCount, 1)
    }

    private func resolvedEngraving() throws -> Engraving {
        let unfinished = OrboOnboarding.complete(
            subjectID: HermesSubjectID(rawValue: "subject.native")!,
            name: "Ean",
            birthDate: CivilDate(year: 1985, month: 4, day: 10)!,
            birthTime: CivilClockTime(hour: 20, minute: 16)!,
            birthLocation: "Madison, WI"
        ).contents

        guard case let .found(engraving) = Atlas().resolve(unfinished) else {
            XCTFail("Expected Atlas to resolve Madison and Tempus")
            throw TestError.unexpectedAtlasResolution
        }
        return engraving
    }

    private func slice(
        for engraving: Engraving,
        overrides: [MundaneBody: Position] = [:]
    ) throws -> HoraeOutput {
        let defaults: [MundaneBody: Position] = [
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
            let position = try XCTUnwrap(overrides[body] ?? defaults[body])
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

    private func nodeStates(
        for engraving: Engraving,
        slice: HoraeOutput
    ) throws -> [AstroDNAGene: RingFineState] {
        var nodes: [AstroDNAGene: RingFineState] = [:]
        for coordinate in slice.celestial {
            let longitude = CelestialLongitude(coordinate.directionalDegree.physicalDegrees)!
            nodes[gene(for: coordinate.body)] = Ring.fineState(
                of: longitude,
                motion: coordinate.directionalDegree.motion
            )
        }
        nodes[.ascendant] = try Hecate.castAscendant(
            terra: slice.terra,
            topos: XCTUnwrap(engraving.topos)
        )
        return nodes
    }

    private func gene(for body: MundaneBody) -> AstroDNAGene {
        switch body {
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
        case .trueNorthNode: return .northNode
        }
    }

    private enum TestError: Error {
        case unexpectedAtlasResolution
    }
}
