import XCTest
@testable import OrboCore

final class NatalSpineActIBeat6RheaTests: XCTestCase {
    private struct Match: Sendable {
        let body: MundaneBody
        let degree: OrboSpineDirectionalDegree
        let day: JulianDay
    }

    private struct PortStub: NatalSpineTimespinePort {
        let matches: [Match]

        func coordinate(
            of body: MundaneBody,
            at julianDay: JulianDay
        ) throws -> OrboSpineCelestialCoordinate {
            let degrees = (Double(body.rawValue) * 31.0 + 5.0).truncatingRemainder(dividingBy: 360)
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: degrees,
                    motion: .direct
                )!,
                julianDay: julianDay
            )
        }

        func occurrences(
            of body: MundaneBody,
            at directionalDegree: OrboSpineDirectionalDegree
        ) throws -> [OrboSpineCelestialCoordinate] {
            matches.filter {
                $0.body == body
                    && abs($0.degree.degrees - directionalDegree.degrees) < 1e-10
            }.map {
                OrboSpineCelestialCoordinate(
                    body: $0.body,
                    directionalDegree: $0.degree,
                    julianDay: $0.day
                )
            }
        }
    }

    func testRheaQualifiesItsOwnMaterMomentThroughCanonicalMater() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let day = JulianDay(bounds.bone.start.value + 10)!
        let degree = OrboSpineDirectionalDegree(physicalDegrees: 0, motion: .direct)!
        let port = PortStub(matches: [Match(body: .sun, degree: degree, day: day)])

        let table = try Rhea.qualifyNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )

        XCTAssertEqual(table.subjectID, truth.subjectID)
        XCTAssertEqual(table.bounds, bounds)
        XCTAssertEqual(table.declaredCount, table.qualifications.count)
        XCTAssertEqual(table.qualifications.count, 1)
        XCTAssertEqual(table.qualifications[0].source.body, .sun)
        XCTAssertEqual(table.qualifications[0].source.julianDay, day)

        let expected = Rhea.bear(
            try longitudes(at: day, through: port),
            sect: truth.sect
        ).temper(for: .sun)
        XCTAssertEqual(table.qualifications[0].temper, expected)
        XCTAssertEqual(table.qualifications[0].temper.sectDay, truth.sect == .day)
        XCTAssertEqual(table.qualifications[0].temper.sectNight, truth.sect == .night)
    }

    func testRheaDoesNotInventMaterForTrueNode() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let degree = OrboSpineDirectionalDegree(physicalDegrees: 0, motion: .direct)!
        let port = PortStub(matches: [
            Match(
                body: .trueNorthNode,
                degree: degree,
                day: JulianDay(bounds.bone.start.value + 10)!
            )
        ])

        let table = try Rhea.qualifyNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )

        XCTAssertFalse(table.qualifications.contains { $0.source.body == .trueNorthNode })
        XCTAssertTrue(table.qualifications.allSatisfy { $0.source.body.planet != nil })
    }

    func testRheaKeepsOnlyMomentsInsideClothoBounds() throws {
        let truth = try nativeTruth()
        let bounds = try Clotho.boundNatalSpine(truth)
        let degree = OrboSpineDirectionalDegree(physicalDegrees: 0, motion: .direct)!
        let inside = JulianDay(bounds.bone.start.value + 1)!
        let port = PortStub(matches: [
            Match(body: .sun, degree: degree, day: JulianDay(bounds.bone.start.value - 1)!),
            Match(body: .sun, degree: degree, day: inside),
            Match(body: .sun, degree: degree, day: bounds.bone.end),
        ])

        let table = try Rhea.qualifyNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )

        XCTAssertEqual(table.qualifications.map(\.source.julianDay), [inside])
    }

    func testRheaRejectsBoundsForAnotherNative() throws {
        let truth = try nativeTruth()
        let lawful = try Clotho.boundNatalSpine(truth)
        let foreign = HermesSubjectID(rawValue: "natal-spine.foreign")!
        let wrong = NatalSpineBounds(
            subjectID: foreign,
            start: lawful.start,
            natal: lawful.natal,
            end: lawful.end
        )!

        XCTAssertThrowsError(
            try Rhea.qualifyNatalSpine(
                native: truth,
                bounds: wrong,
                through: PortStub(matches: [])
            )
        ) { error in
            XCTAssertEqual(error as? NatalSpineRheaFailure, .subjectMismatch)
        }
    }

    private func nativeTruth() throws -> NatalSpineNativeTruth {
        let hestia = try NatalSpineTestFixture.litHestia()
        return try hestia.natalSpineNativeTruth(for: NatalSpineTestFixture.subjectID)
    }

    private func longitudes(
        at julianDay: JulianDay,
        through port: PortStub
    ) throws -> [Planet: CelestialLongitude] {
        Dictionary(uniqueKeysWithValues: try MundaneBody.canonicalOrder.compactMap { body in
            guard let planet = body.planet else { return nil }
            let coordinate = try port.coordinate(of: body, at: julianDay)
            return (
                planet,
                CelestialLongitude(coordinate.directionalDegree.physicalDegrees)!
            )
        })
    }
}
