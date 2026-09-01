import XCTest
@testable import OrboCore

final class SynchronicSpineRheaTests: XCTestCase {
    func testRheaProvidesExactlyTwelveQualifiersInAsteriaOrder() throws {
        let fixture = try makeFixture()
        let field = Lachesis.callRheaForSynchronicSpine(
            foundation: fixture.foundation,
            asteria: fixture.asteria
        )

        XCTAssertEqual(field.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(field.ticketID, fixture.foundation.commission.ticketID)
        XCTAssertEqual(field.bone, fixture.foundation.bone)
        XCTAssertEqual(field.qualifiers.count, 12)
        XCTAssertEqual(field.qualifiers.map(\.body), SynchronicAsteriaBody.canonicalOrder)
        XCTAssertEqual(Set(field.qualifiers.map(\.body)).count, 12)

        for qualifier in field.qualifiers {
            XCTAssertEqual(qualifier.subjectID, fixture.foundation.commission.subjectID)
            XCTAssertEqual(qualifier.ticketID, fixture.foundation.commission.ticketID)
            XCTAssertEqual(qualifier.bone, fixture.foundation.bone)
        }
    }

    func testEachQualifierConsumesItsOwnAsteriaDegreeAndPreservesProvenance() throws {
        let fixture = try makeFixture()
        let field = Lachesis.callRheaForSynchronicSpine(
            foundation: fixture.foundation,
            asteria: fixture.asteria
        )
        let instant = fixture.foundation.bone.natal

        for body in SynchronicAsteriaBody.canonicalOrder {
            let qualifier = try XCTUnwrap(field[body])
            let snapshot = try qualifier.resolve(at: instant)
            let source = try XCTUnwrap(fixture.asteria[body]).resolve(at: instant)

            XCTAssertEqual(snapshot.body, body)
            XCTAssertEqual(snapshot.instant, instant)
            XCTAssertEqual(snapshot.sourceMoment, source)
            XCTAssertEqual(snapshot.declaredRowCount, snapshot.rows.count)

            let expectedPositions = positions(of: source.composite)
            XCTAssertEqual(snapshot.rows.map(\.position), expectedPositions)
            for row in snapshot.rows {
                XCTAssertEqual(row.qualification.longitude, CelestialLongitude(row.position.degrees)!)
                XCTAssertEqual(row.qualification, Rhea.bearDegree(CelestialLongitude(row.position.degrees)!))
            }
        }
    }

    func testRheaDegreeQualificationDelegatesToCanonicalMaterTables() throws {
        let fixture = try makeFixture()
        let field = Lachesis.callRheaForSynchronicSpine(
            foundation: fixture.foundation,
            asteria: fixture.asteria
        )
        let sun = try XCTUnwrap(field[.sun])
        let row = try XCTUnwrap(try sun.resolve(at: fixture.foundation.bone.natal).rows.first)
        let longitude = row.qualification.longitude

        XCTAssertEqual(row.qualification.sign, longitude.sign)
        XCTAssertEqual(row.qualification.degreeInSign, longitude.degreeInSign)
        XCTAssertEqual(row.qualification.element, Mater.element(of: longitude.sign))
        XCTAssertEqual(row.qualification.modality, Mater.modality(of: longitude.sign))
        XCTAssertEqual(row.qualification.domicileRuler, Mater.domicileRuler(of: longitude.sign))
        XCTAssertEqual(row.qualification.exaltation, Mater.exaltation(in: longitude.sign))
        XCTAssertEqual(row.qualification.detrimentRuler, Mater.detrimentRuler(in: longitude.sign))
        XCTAssertEqual(row.qualification.fallRuler, Mater.fallRuler(in: longitude.sign))
        XCTAssertEqual(row.qualification.bound, Mater.bound(at: longitude))
        XCTAssertEqual(row.qualification.face, Mater.face(at: longitude))
        XCTAssertEqual(row.qualification.triplicity, Mater.triplicity(of: longitude.sign))
        XCTAssertNil(row.qualification.triplicity.operativeRuler(for: nil))
    }

    func testNorthNodeAndTerraAreQualifiedWithoutPretendingTheyArePlanets() throws {
        let fixture = try makeFixture()
        let field = Lachesis.callRheaForSynchronicSpine(
            foundation: fixture.foundation,
            asteria: fixture.asteria
        )

        for body in [SynchronicAsteriaBody.northNode, .terra] {
            let qualifier = try XCTUnwrap(field[body])
            let snapshot = try qualifier.resolve(at: fixture.foundation.bone.natal)
            XCTAssertEqual(snapshot.body, body)
            XCTAssertFalse(snapshot.rows.isEmpty)
            XCTAssertTrue(snapshot.rows.allSatisfy {
                $0.qualification.bound == Mater.bound(at: $0.qualification.longitude)
            })
        }
    }

    func testAsteriaSeamRemainsTwoLawfulRheaDegreeRows() throws {
        let fixture = try makeFixture(sunMundaneDegreesAtNatal: 180)
        let source = try XCTUnwrap(fixture.asteria[.sun]).resolve(at: fixture.foundation.bone.natal)
        guard case .seam(let seam) = source.composite else {
            return XCTFail("Expected exact Arc opposition to remain a seam")
        }

        let field = Lachesis.callRheaForSynchronicSpine(
            foundation: fixture.foundation,
            asteria: fixture.asteria
        )
        let snapshot = try XCTUnwrap(field[.sun]).resolve(at: fixture.foundation.bone.natal)

        XCTAssertEqual(snapshot.rows.count, 2)
        XCTAssertEqual(snapshot.declaredRowCount, 2)
        XCTAssertEqual(snapshot.rows.map(\.position), [seam.minusPole, seam.plusPole])
        XCTAssertEqual(
            snapshot.rows.map(\.qualification.longitude),
            [CelestialLongitude(seam.minusPole.degrees)!, CelestialLongitude(seam.plusPole.degrees)!]
        )
    }

    func testQualifierRejectsTemporalFactOutsideBoneThroughAsteria() throws {
        let fixture = try makeFixture()
        let field = Lachesis.callRheaForSynchronicSpine(
            foundation: fixture.foundation,
            asteria: fixture.asteria
        )
        let terra = try XCTUnwrap(field[.terra])
        let before = AbsoluteInstant(
            unixSecondsSince1970: fixture.foundation.bone.start.unixSecondsSince1970 - 1
        )!

        XCTAssertThrowsError(try terra.resolve(at: before)) { error in
            XCTAssertEqual(error as? SynchronicAsteriaFailure, .outsideBone)
        }
    }

    private struct Fixture {
        let foundation: SynchronicSpineFoundation
        let asteria: SynchronicAsteriaField
    }

    private func makeFixture(sunMundaneDegreesAtNatal: Double = 0.01) throws -> Fixture {
        let subject = HermesSubjectID(rawValue: "native-rhea")!
        let natal = instant(year: 2001, month: 6, day: 15, hour: 12)
        var starter = SynchronicSpineActIStarter()
        let commissioned = try starter.start(subjectID: subject, natal: natal, occurredAt: natal)

        let start = AbsoluteInstant(unixSecondsSince1970: natal.unixSecondsSince1970 - 21_600)!
        let end = AbsoluteInstant(unixSecondsSince1970: natal.unixSecondsSince1970 + 21_600)!
        let bone = SynchronicSpineBone(
            subjectID: subject,
            ticketID: commissioned.commission.ticketID,
            start: start,
            natal: natal,
            end: end
        )
        let foundation = SynchronicSpineFoundation(
            commission: commissioned.commission,
            pattern: commissioned.pattern,
            bone: bone
        )

        let sourceStart = try XCTUnwrap(JulianDay(start.julianDay.value - 0.25))
        let sourceEnd = try XCTUnwrap(JulianDay(end.julianDay.value + 0.25))
        let sourceLastSupport = try XCTUnwrap(JulianDay(sourceEnd.value - 1e-6))
        let sourceBone = try XCTUnwrap(OrboSpineBoneSpan(start: sourceStart, end: sourceEnd))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in MundaneBody.canonicalOrder.enumerated() {
            let center = body == .sun ? sunMundaneDegreesAtNatal : Double(index * 10 + 5)
            supports.append(coordinate(body, normalized(center - 0.01), sourceBone.start))
            supports.append(coordinate(body, normalized(center + 0.01), sourceLastSupport))
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 359.99,
                tiltDegrees: 23.4,
                julianDay: sourceBone.start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 0.01,
                tiltDegrees: 23.4,
                julianDay: sourceBone.end
            )),
        ]
        let locate = try XCTUnwrap(OrboSpineLocate(
            bone: sourceBone,
            celestialSupports: supports,
            terraSamples: terra
        ))
        let dna = try XCTUnwrap(AstroDNA(rawSequence: Array(repeating: 0, count: AstroDNA.geneCount)))
        let asteria = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: foundation,
            natalAstroDNA: dna,
            mundaneSpine: locate
        )

        return Fixture(foundation: foundation, asteria: asteria)
    }

    private func positions(of composite: ArcComposite) -> [ArcPosition] {
        switch composite {
        case .position(let position):
            return [position]
        case .seam(let seam):
            return [seam.minusPole, seam.plusPole]
        }
    }

    private func coordinate(
        _ body: MundaneBody,
        _ degrees: Double,
        _ julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: .direct
            )!,
            julianDay: julianDay
        )
    }

    private func normalized(_ degrees: Double) -> Double {
        let remainder = degrees.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }

    private func instant(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0
    ) -> AbsoluteInstant {
        let date = CivilDate(year: year, month: month, day: day)!
        let time = CivilClockTime(hour: hour, minute: minute, second: second)!
        let offset = UTCOffset(secondsEast: 0)!

        switch CivilTime.resolve(date: date, time: time, fixedOffset: offset) {
        case .resolved(let match):
            return match.instant
        default:
            XCTFail("Expected resolvable Gregorian UTC instant")
            return AbsoluteInstant(unixSecondsSince1970: 0)!
        }
    }
}
