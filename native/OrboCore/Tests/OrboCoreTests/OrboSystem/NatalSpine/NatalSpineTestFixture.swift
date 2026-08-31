import Foundation
@testable import OrboCore

enum NatalSpineTestFixture {
    struct Position {
        let degrees: Double
        let motion: Motion
    }

    struct PortIStub: ClothoPortI {
        let output: HoraeOutput

        mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
            output
        }
    }

    enum Failure: Error {
        case atlasResolution
        case missingTopos
        case missingPosition
    }

    static let subjectID = HermesSubjectID(rawValue: "natal-spine.fixture.native")!
    static let packageID = HermesPackageID(
        UUID(uuidString: "bbbbbbbb-cccc-dddd-eeee-ffffffff0001")!
    )
    static let name = "Natal Spine Fixture"
    static let birthDate = CivilDate(year: 1990, month: 5, day: 17)!
    static let birthTime = CivilClockTime(hour: 14, minute: 32)!
    static let birthLocation = "Madison, WI"

    static func commissionedPackage() -> HermesPackage<Engraving> {
        OrboOnboarding.complete(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation,
            packageID: packageID
        )
    }

    static func atlasResolvedPackage() throws -> HermesPackage<Engraving> {
        let package = commissionedPackage()
        guard case let .found(engraving) = Atlas().resolve(package.contents) else {
            throw Failure.atlasResolution
        }
        return HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: engraving
        )!
    }

    static func moiraiWorkedPackage() throws -> HermesPackage<Engraving> {
        let atlasResolved = try atlasResolvedPackage()
        var port = PortIStub(output: try slice(for: atlasResolved.contents))
        return try Moirai.process(atlasResolved, through: &port)
    }

    static func litHestia() throws -> Hestia {
        let worked = try moiraiWorkedPackage()
        var hestia = Hestia(nativeSubjectID: subjectID)
        _ = try hestia.receive(worked)
        return hestia
    }

    static func slice(for engraving: Engraving) throws -> HoraeOutput {
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

        guard let topos = engraving.topos else {
            throw Failure.missingTopos
        }
        let julianDay = JulianDay(2_446_166.5)!
        let terra = TerraMarrowSample(
            turnDegrees: CelestialLongitude(-topos.place.longitude.degrees)!.degrees,
            tiltDegrees: 23.44,
            julianDay: julianDay
        )!

        var celestial: [OrboSpineCelestialCoordinate] = []
        celestial.reserveCapacity(MundaneBody.canonicalOrder.count)
        for body in MundaneBody.canonicalOrder {
            guard let position = positions[body] else {
                throw Failure.missingPosition
            }
            celestial.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: OrboSpineDirectionalDegree(
                        physicalDegrees: position.degrees,
                        motion: position.motion
                    )!,
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
}
