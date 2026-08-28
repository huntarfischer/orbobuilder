import Foundation
import XCTest
@testable import OrboCore

enum HestiaCanonicalPersistenceFixture {
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

    static func subject(_ rawValue: String) throws -> HermesSubjectID {
        try XCTUnwrap(HermesSubjectID(rawValue: rawValue))
    }

    static func astroDNA(rawValue: Int) throws -> AstroDNA {
        try XCTUnwrap(
            AstroDNA(
                rawSequence: Array(
                    repeating: rawValue,
                    count: AstroDNA.geneCount
                )
            )
        )
    }

    static func legacyTapestry(for astroDNA: AstroDNA) throws -> AtroposPackage {
        let output = LegacyMoiraiBridge.gather(from: astroDNA)
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        return try Atropos.inspect(recipe: output.recipe, grid: grid).get()
    }

    static func canonicalWorkedPackage(
        subjectID: HermesSubjectID
    ) throws -> HermesPackage<Engraving> {
        let commissioned = OrboOnboarding.complete(
            subjectID: subjectID,
            name: "Persistence Native",
            birthDate: CivilDate(year: 1990, month: 5, day: 17)!,
            birthTime: CivilClockTime(hour: 14, minute: 32)!,
            birthLocation: "Madison, WI"
        )

        guard case let .found(resolved) = Atlas().resolve(commissioned.contents) else {
            XCTFail("Expected Atlas to resolve canonical persistence fixture")
            throw FixtureError.atlasResolutionFailed
        }

        let resolvedPackage = try XCTUnwrap(
            HermesPackage(
                packageID: commissioned.packageID,
                subjectID: commissioned.subjectID,
                sender: commissioned.sender,
                kind: commissioned.kind,
                addresses: commissioned.addresses,
                contents: resolved
            )
        )
        var portI = PortIStub(output: try slice(for: resolved))
        return try Moirai.process(resolvedPackage, through: &portI)
    }

    static func litHestia(
        subjectID: HermesSubjectID
    ) throws -> Hestia {
        let worked = try canonicalWorkedPackage(subjectID: subjectID)
        var hestia = Hestia(nativeSubjectID: subjectID)
        _ = try hestia.receive(worked)
        return hestia
    }

    private static func slice(for engraving: Engraving) throws -> HoraeOutput {
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

    private enum FixtureError: Error {
        case atlasResolutionFailed
    }
}
