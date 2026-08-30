import XCTest
@testable import OrboCore

final class ClothoHoraeGraftTests: XCTestCase {
    func testHoraeAnswersClothoAtExactResolvedTempus() throws {
        let engraving = try resolvedEngraving()
        let tempus = try XCTUnwrap(engraving.tempus)
        var horae = Horae(locate: try makeLocate(centeredAt: tempus.absoluteInstant.julianDay))

        let expected = try horae.seek(to: tempus.absoluteInstant.julianDay)
        let answer = try horae.queryNatalSlice(at: tempus)

        XCTAssertEqual(answer, expected)
        XCTAssertEqual(answer.julianDay, tempus.absoluteInstant.julianDay)
    }

    func testClothoSpinsFromRealHoraeDoorOneWithoutInjectedSlice() throws {
        let engraving = try resolvedEngraving()
        let tempus = try XCTUnwrap(engraving.tempus)
        let topos = try XCTUnwrap(engraving.topos)
        var horae = Horae(locate: try makeLocate(centeredAt: tempus.absoluteInstant.julianDay))
        let doorOneTruth = try horae.seek(to: tempus.absoluteInstant.julianDay)

        let output = try Clotho.spin(engraving, through: &horae)
        let expectedAscendant = try Hecate.castAscendant(
            terra: doorOneTruth.terra,
            topos: topos
        )

        XCTAssertEqual(output.packet.astroDNA[.ascendant], expectedAscendant)
        for coordinate in doorOneTruth.celestial {
            let longitude = try XCTUnwrap(
                CelestialLongitude(coordinate.directionalDegree.physicalDegrees)
            )
            XCTAssertEqual(
                output.packet.astroDNA[gene(for: coordinate.body)],
                Ring.fineState(
                    of: longitude,
                    motion: coordinate.directionalDegree.motion
                )
            )
        }
    }

    func testClothoHoraePreservesDoorOneOutsideBoneFailure() throws {
        let engraving = try resolvedEngraving()
        let tempus = try XCTUnwrap(engraving.tempus)
        let distantCenter = try XCTUnwrap(
            JulianDay(tempus.absoluteInstant.julianDay.value + 11.0)
        )
        var horae = Horae(locate: try makeLocate(centeredAt: distantCenter))

        XCTAssertThrowsError(try Clotho.spin(engraving, through: &horae)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }
    }

    private func resolvedEngraving() throws -> Engraving {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: "subject.pass3"))
        let date = try XCTUnwrap(CivilDate(year: 1985, month: 4, day: 10))
        let time = try XCTUnwrap(CivilClockTime(hour: 20, minute: 16))
        let engraving = OrboOnboarding.complete(
            subjectID: subjectID,
            name: "Ean",
            birthDate: date,
            birthTime: time,
            birthLocation: "Madison, WI"
        ).contents

        guard case let .found(resolved) = Atlas().resolve(engraving) else {
            XCTFail("Expected Atlas to resolve Madison and Tempus")
            throw TestError.unexpectedAtlasResolution
        }
        return resolved
    }

    private func makeLocate(centeredAt center: JulianDay) throws -> OrboSpineLocate {
        let start = try XCTUnwrap(JulianDay(center.value - 1.0))
        let end = try XCTUnwrap(JulianDay(center.value + 1.0))
        let firstUT = try XCTUnwrap(JulianDay(center.value - 0.5))
        let secondUT = try XCTUnwrap(JulianDay(center.value + 0.5))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let base = 10.0 + Double(index * 25)
            let motion: Motion = body == .trueNorthNode ? .retrograde : .direct
            let firstDegrees = motion == .retrograde ? base + 1.0 : base
            let secondDegrees = motion == .retrograde ? base : base + 1.0
            supports.append(
                coordinate(
                    body: body,
                    degrees: firstDegrees,
                    motion: motion,
                    julianDay: firstUT
                )
            )
            supports.append(
                coordinate(
                    body: body,
                    degrees: secondDegrees,
                    motion: motion,
                    julianDay: secondUT
                )
            )
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100.0,
                tiltDegrees: 23.4,
                julianDay: start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 102.0,
                tiltDegrees: 23.5,
                julianDay: end
            )),
        ]

        return try XCTUnwrap(
            OrboSpineLocate(
                bone: bone,
                celestialSupports: supports,
                terraSamples: terra
            )
        )
    }

    private func coordinate(
        body: MundaneBody,
        degrees: Double,
        motion: Motion,
        julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: motion
            )!,
            julianDay: julianDay
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
