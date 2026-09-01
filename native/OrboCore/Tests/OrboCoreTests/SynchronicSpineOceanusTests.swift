import XCTest
@testable import OrboCore

final class SynchronicSpineOceanusTests: XCTestCase {
    func testOceanusProvidesExactlyThreeCanonicalTides() throws {
        let fixture = try makeFixture()
        let field = Lachesis.callOceanusForSynchronicSpine(
            foundation: fixture.foundation,
            asteria: fixture.asteria
        )

        XCTAssertEqual(field.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(field.ticketID, fixture.foundation.commission.ticketID)
        XCTAssertEqual(field.bone, fixture.foundation.bone)
        XCTAssertEqual(field.tides.count, 3)
        XCTAssertEqual(field.tides.map(\.identity), [.interChart, .mundane, .natal])
        XCTAssertEqual(Set(field.tides.map(\.identity)).count, 3)
    }

    func testInterChartTideIsOnlySynchronicToSynchronicAndReferencesAsteria() throws {
        let fixture = try makeFixture()
        let tide = try XCTUnwrap(
            Lachesis.callOceanusForSynchronicSpine(
                foundation: fixture.foundation,
                asteria: fixture.asteria
            )[.interChart]
        )
        let snapshot = try tide.resolve(at: fixture.foundation.bone.natal)

        XCTAssertEqual(snapshot.tide, .interChart)
        XCTAssertEqual(snapshot.rows.count, 66)
        XCTAssertEqual(snapshot.declaredRowCount, snapshot.rows.count)
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.left.substance == .synchronic })
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.right.substance == .synchronic })
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.left.sourceMoment.instant == snapshot.instant })
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.right.sourceMoment.instant == snapshot.instant })
        XCTAssertFalse(snapshot.rows.contains { $0.left.substance == .natal || $0.right.substance == .natal })
        XCTAssertFalse(snapshot.rows.contains { $0.left.substance == .mundane || $0.right.substance == .mundane })
    }

    func testMundaneTideIsExactlyMundaneToSynchronic() throws {
        let fixture = try makeFixture()
        let tide = try XCTUnwrap(
            Lachesis.callOceanusForSynchronicSpine(
                foundation: fixture.foundation,
                asteria: fixture.asteria
            )[.mundane]
        )
        let snapshot = try tide.resolve(at: fixture.foundation.bone.natal)

        XCTAssertEqual(snapshot.tide, .mundane)
        XCTAssertEqual(snapshot.rows.count, 144)
        XCTAssertEqual(snapshot.declaredRowCount, snapshot.rows.count)
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.left.substance == .mundane })
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.right.substance == .synchronic })
        XCTAssertFalse(snapshot.rows.contains { $0.left.substance == .natal || $0.right.substance == .natal })
    }

    func testNatalTideIsExactlyNatalToSynchronicForSameNative() throws {
        let fixture = try makeFixture()
        let tide = try XCTUnwrap(
            Lachesis.callOceanusForSynchronicSpine(
                foundation: fixture.foundation,
                asteria: fixture.asteria
            )[.natal]
        )
        let snapshot = try tide.resolve(at: fixture.foundation.bone.natal)

        XCTAssertEqual(snapshot.tide, .natal)
        XCTAssertEqual(snapshot.rows.count, 144)
        XCTAssertEqual(snapshot.declaredRowCount, snapshot.rows.count)
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.left.substance == .natal })
        XCTAssertTrue(snapshot.rows.allSatisfy { $0.right.substance == .synchronic })
        XCTAssertFalse(snapshot.rows.contains { $0.left.substance == .mundane || $0.right.substance == .mundane })
        XCTAssertTrue(snapshot.rows.allSatisfy {
            $0.left.sourceMoment.subjectID == fixture.foundation.commission.subjectID
                && $0.right.sourceMoment.subjectID == fixture.foundation.commission.subjectID
        })
    }

    func testTidesUseCanonicalRingRelationLaw() throws {
        let fixture = try makeFixture()
        let tide = try XCTUnwrap(
            Lachesis.callOceanusForSynchronicSpine(
                foundation: fixture.foundation,
                asteria: fixture.asteria
            )[.natal]
        )
        let snapshot = try tide.resolve(at: fixture.foundation.bone.natal)
        let row = try XCTUnwrap(snapshot.rows.first)
        let relation = try XCTUnwrap(row.relations.first)
        let expectedSeparation = Ring.separation(
            from: CelestialLongitude(relation.leftPosition.degrees)!,
            to: CelestialLongitude(relation.rightPosition.degrees)!
        )

        XCTAssertEqual(relation.separation, expectedSeparation)
        XCTAssertEqual(relation.nearest, Ring.nearest(to: expectedSeparation))
        XCTAssertEqual(relation.exact, Ring.exact(expectedSeparation))
        XCTAssertEqual(relation.exact, .conjunction)
    }

    func testSynchronicSeamRemainsTwoLawfulOceanusPositionsRatherThanBeingCollapsed() throws {
        let fixture = try makeFixture(sunMundaneDegrees: 180)
        let tide = try XCTUnwrap(
            Lachesis.callOceanusForSynchronicSpine(
                foundation: fixture.foundation,
                asteria: fixture.asteria
            )[.interChart]
        )
        let snapshot = try tide.resolve(at: fixture.foundation.bone.natal)
        let sunMoon = try XCTUnwrap(snapshot.rows.first {
            Set([$0.left.body, $0.right.body]) == Set([.sun, .moon])
        })
        let sunEndpoint = sunMoon.left.body == .sun ? sunMoon.left : sunMoon.right

        XCTAssertEqual(sunEndpoint.substance, .synchronic)
        XCTAssertEqual(sunEndpoint.positions.count, 2)
        XCTAssertEqual(sunMoon.relations.count, 2)
    }

    func testTideRejectsTemporalFactOutsideBone() throws {
        let fixture = try makeFixture()
        let tide = try XCTUnwrap(
            Lachesis.callOceanusForSynchronicSpine(
                foundation: fixture.foundation,
                asteria: fixture.asteria
            )[.mundane]
        )
        let before = AbsoluteInstant(
            unixSecondsSince1970: fixture.foundation.bone.start.unixSecondsSince1970 - 1
        )!

        XCTAssertThrowsError(try tide.resolve(at: before)) { error in
            XCTAssertEqual(error as? SynchronicAsteriaFailure, .outsideBone)
        }
    }

    private struct Fixture {
        let foundation: SynchronicSpineFoundation
        let asteria: SynchronicAsteriaField
    }

    private func makeFixture(sunMundaneDegrees: Double = 0) throws -> Fixture {
        let subject = HermesSubjectID(rawValue: "native-oceanus")!
        let natal = instant(year: 2001, month: 6, day: 15, hour: 12)
        var starter = SynchronicSpineActIStarter()
        let foundation = try starter.start(subjectID: subject, natal: natal, occurredAt: natal)

        let sourceBone = try XCTUnwrap(OrboSpineBoneSpan(
            start: foundation.bone.start.julianDay,
            end: foundation.bone.end.julianDay
        ))
        var supports: [OrboSpineCelestialCoordinate] = []
        for body in MundaneBody.canonicalOrder {
            let degree = body == .sun ? sunMundaneDegrees : 0
            supports.append(coordinate(body, degree, sourceBone.start))
            supports.append(coordinate(body, degree, sourceBone.end))
        }
        let terra = [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 0, tiltDegrees: 23.4, julianDay: sourceBone.start)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 0, tiltDegrees: 23.4, julianDay: sourceBone.end)),
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
