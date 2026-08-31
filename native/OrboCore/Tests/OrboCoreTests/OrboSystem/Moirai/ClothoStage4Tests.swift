import XCTest
@testable import OrboCore

final class ClothoStage4Tests: XCTestCase {
    private struct NatalPosition {
        let degree: Int
        let minute: Int
        let second: Int
        let retrograde: Bool

        var physicalDegrees: Double {
            Double(degree * Ring.arcsecondsPerDegree + minute * 60 + second)
                / Double(Ring.arcsecondsPerDegree)
        }
    }

    private struct PortISpy: ClothoPortI {
        var output: HoraeOutput
        var calls: [Tempus] = []

        mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
            calls.append(tempus)
            return output
        }
    }

    private let subjectID = HermesSubjectID(rawValue: "subject.native")!
    private let birthDate = CivilDate(year: 1985, month: 4, day: 10)!
    private let birthTime = CivilClockTime(hour: 20, minute: 16)!

    private let natalPositions: [MundaneBody: NatalPosition] = [
        .moon: NatalPosition(degree: 277, minute: 34, second: 12, retrograde: false),
        .sun: NatalPosition(degree: 21, minute: 8, second: 19, retrograde: false),
        .mercury: NatalPosition(degree: 8, minute: 20, second: 41, retrograde: true),
        .venus: NatalPosition(degree: 9, minute: 49, second: 22, retrograde: true),
        .mars: NatalPosition(degree: 49, minute: 16, second: 5, retrograde: false),
        .jupiter: NatalPosition(degree: 312, minute: 33, second: 44, retrograde: false),
        .saturn: NatalPosition(degree: 237, minute: 9, second: 17, retrograde: true),
        .uranus: NatalPosition(degree: 257, minute: 49, second: 31, retrograde: true),
        .neptune: NatalPosition(degree: 273, minute: 36, second: 26, retrograde: true),
        .pluto: NatalPosition(degree: 213, minute: 42, second: 14, retrograde: true),
        .trueNorthNode: NatalPosition(degree: 49, minute: 50, second: 53, retrograde: true),
    ]

    func testClothoChoosesEngravingPatternAndMakesOneTempusQuery() throws {
        let engraving = try resolvedEngraving()
        let expectedTempus = try XCTUnwrap(engraving.tempus)
        var portI = PortISpy(output: try slice(for: engraving))

        let output = try Clotho.spin(engraving, through: &portI)

        XCTAssertEqual(output.packet.pattern, .engraving)
        XCTAssertEqual(output.packet.pattern.spanYears, 100)
        XCTAssertEqual(portI.calls, [expectedTempus])
    }

    func testClothoSpinsUniversalBodiesPlusHecateAscendantIntoAstroDNAAndResolvesOnlyAstroDNA() throws {
        let engraving = try resolvedEngraving()
        let originalTopos = try XCTUnwrap(engraving.topos)
        let originalTempus = try XCTUnwrap(engraving.tempus)
        let sourceSlice = try slice(for: engraving)
        var portI = PortISpy(output: sourceSlice)

        let output = try Clotho.spin(engraving, through: &portI)
        let resolvedDNA = try XCTUnwrap(output.engraving.astroDNA)
        let expectedAscendant = try Hecate.castAscendant(
            terra: sourceSlice.terra,
            topos: originalTopos
        )

        XCTAssertEqual(output.packet.astroDNA, resolvedDNA)
        XCTAssertEqual(output.packet.astroDNA.sequence.count, AstroDNA.geneCount)
        XCTAssertEqual(output.packet.astroDNA[.ascendant], expectedAscendant)
        XCTAssertEqual(output.engraving.subjectID, engraving.subjectID)
        XCTAssertEqual(output.engraving.name, engraving.name)
        XCTAssertEqual(output.engraving.birthDate, engraving.birthDate)
        XCTAssertEqual(output.engraving.birthTime, engraving.birthTime)
        XCTAssertEqual(output.engraving.birthLocation, engraving.birthLocation)
        XCTAssertEqual(output.engraving.topos, originalTopos)
        XCTAssertEqual(output.engraving.tempus, originalTempus)
        XCTAssertNil(output.engraving.sect)
        XCTAssertNil(output.engraving.tapestry)
        XCTAssertFalse(output.engraving.engraved)

        for coordinate in sourceSlice.celestial {
            let longitude = CelestialLongitude(coordinate.directionalDegree.physicalDegrees)!
            let expected = Ring.fineState(
                of: longitude,
                motion: coordinate.directionalDegree.motion
            )
            XCTAssertEqual(output.packet.astroDNA[gene(for: coordinate.body)], expected)
        }
    }

    func testClothoPreservesUniversalPrecisionAndRetrogradeState() throws {
        let engraving = try resolvedEngraving()
        let sourceSlice = try slice(for: engraving)
        var portI = PortISpy(output: sourceSlice)

        let output = try Clotho.spin(engraving, through: &portI)
        let mercury = try XCTUnwrap(
            sourceSlice.celestial.first { $0.body == .mercury }
        )
        let node = try XCTUnwrap(
            sourceSlice.celestial.first { $0.body == .trueNorthNode }
        )

        XCTAssertEqual(
            output.packet.astroDNA[.mercury],
            Ring.fineState(
                of: CelestialLongitude(mercury.directionalDegree.physicalDegrees)!,
                motion: mercury.directionalDegree.motion
            )
        )
        XCTAssertTrue(output.packet.astroDNA[.mercury].isRetrograde)
        XCTAssertTrue(output.packet.astroDNA[.northNode].isRetrograde)
        XCTAssertEqual(node.directionalDegree.motion, .retrograde)
    }

    func testClothoRefusesEngravingWithoutToposBeforeQueryingDoorOne() throws {
        let engraving = unfinishedEngraving()
        let resolved = try resolvedEngraving()
        var portI = PortISpy(output: try slice(for: resolved))

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .unresolvedTopos)
        }
        XCTAssertTrue(portI.calls.isEmpty)
    }

    func testClothoRefusesEngravingWithoutTempusBeforeQueryingDoorOne() throws {
        let engraving = try toposOnlyEngraving()
        let resolved = try resolvedEngraving()
        var portI = PortISpy(output: try slice(for: resolved))

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .unresolvedTempus)
        }
        XCTAssertTrue(portI.calls.isEmpty)
    }

    func testClothoRefusesToOverwriteResolvedAstroDNABeforeAnotherQuery() throws {
        let engraving = try resolvedEngraving()
        var portI = PortISpy(output: try slice(for: engraving))
        let first = try Clotho.spin(engraving, through: &portI)

        XCTAssertThrowsError(try Clotho.spin(first.engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .astroDNAAlreadyResolved)
        }
        XCTAssertEqual(portI.calls.count, 1)
    }

    func testClothoRejectsIncompleteUniversalBodySet() throws {
        let engraving = try resolvedEngraving()
        var portI = PortISpy(output: try slice(for: engraving, omitting: .pluto))

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .missingUniversalBody(.pluto))
        }
        XCTAssertEqual(portI.calls.count, 1)
    }

    func testClothoRejectsUniversalStatesThatCannotFormValidAstroDNA() throws {
        let engraving = try resolvedEngraving()
        let badSun = NatalPosition(degree: 21, minute: 8, second: 19, retrograde: true)
        var portI = PortISpy(
            output: try slice(for: engraving, overrides: [.sun: badSun])
        )

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &portI)) { error in
            XCTAssertEqual(error as? ClothoFailure, .invalidAstroDNA)
        }
        XCTAssertEqual(portI.calls.count, 1)
    }

    private func unfinishedEngraving() -> Engraving {
        OrboOnboarding.complete(
            subjectID: subjectID,
            name: "Ean",
            birthDate: birthDate,
            birthTime: birthTime,
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
        overrides: [MundaneBody: NatalPosition] = [:],
        omitting omittedBody: MundaneBody? = nil
    ) throws -> HoraeOutput {
        let topos = try XCTUnwrap(engraving.topos)
        let julianDay = JulianDay(2_446_166.5)!
        let turn = CelestialLongitude(-topos.place.longitude.degrees)!.degrees
        let terra = TerraMarrowSample(
            turnDegrees: turn,
            tiltDegrees: 23.44,
            julianDay: julianDay
        )!

        var celestial: [OrboSpineCelestialCoordinate] = []
        for body in MundaneBody.canonicalOrder where body != omittedBody {
            let position = try XCTUnwrap(overrides[body] ?? natalPositions[body])
            let directionalDegree = try XCTUnwrap(
                OrboSpineDirectionalDegree(
                    physicalDegrees: position.physicalDegrees,
                    motion: position.retrograde ? .retrograde : .direct
                )
            )
            celestial.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directionalDegree,
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
