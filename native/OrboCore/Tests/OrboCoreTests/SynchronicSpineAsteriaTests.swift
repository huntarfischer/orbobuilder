import XCTest
@testable import OrboCore

final class SynchronicSpineAsteriaTests: XCTestCase {
    func testLachesisReceivesExactlyTwelveAsteriaPassesInCanonicalOrder() throws {
        let fixture = try makeFixture()
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )

        XCTAssertEqual(field.subjectID, fixture.foundation.commission.subjectID)
        XCTAssertEqual(field.ticketID, fixture.foundation.commission.ticketID)
        XCTAssertEqual(field.bone, fixture.foundation.bone)
        XCTAssertEqual(field.passes.count, 12)
        XCTAssertEqual(field.passes.map(\.body), SynchronicAsteriaBody.canonicalOrder)
        XCTAssertEqual(Set(field.passes.map(\.body)).count, 12)

        for pass in field.passes {
            XCTAssertEqual(pass.subjectID, fixture.foundation.commission.subjectID)
            XCTAssertEqual(pass.ticketID, fixture.foundation.commission.ticketID)
            XCTAssertEqual(pass.bone, fixture.foundation.bone)
            XCTAssertEqual(pass.natalAnchor.arcsecond, fixture.astroDNA[pass.body.natalGene].arcsecond)
        }
    }

    func testEachCelestialPassPairsNatalGeneWithSameMundaneBodyAndUsesAsteriaArc() throws {
        let fixture = try makeFixture()
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )
        let instant = fixture.foundation.bone.natal

        for body in SynchronicAsteriaBody.canonicalOrder where body != .terra {
            let pass = try XCTUnwrap(field[body])
            let moment = try pass.resolve(at: instant)
            let expectedMundane = try XCTUnwrap(body.mundaneBody)

            guard case .celestial(let source) = moment.mundaneSource else {
                return XCTFail("Expected celestial OrboSpine source for \(body)")
            }
            XCTAssertEqual(source.body, expectedMundane)
            XCTAssertEqual(source.julianDay, instant.julianDay)
            XCTAssertEqual(moment.body, body)
            XCTAssertEqual(moment.natalAnchor.arcsecond, fixture.astroDNA[body.natalGene].arcsecond)
            XCTAssertEqual(
                moment.composite,
                Asteria.refract(moment.natalAnchor, with: moment.mundanePartner)
            )
        }
    }

    func testTerraPassPairsNatalAscendantWithMundaneTerra() throws {
        let fixture = try makeFixture()
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )
        let pass = try XCTUnwrap(field[.terra])
        let moment = try pass.resolve(at: fixture.foundation.bone.natal)

        XCTAssertEqual(pass.natalAnchor.arcsecond, fixture.astroDNA[.ascendant].arcsecond)
        XCTAssertNil(SynchronicAsteriaBody.terra.mundaneBody)
        guard case .terra(let source) = moment.mundaneSource else {
            return XCTFail("Expected Terra Marrow as the mundane source")
        }
        XCTAssertEqual(source.julianDay, fixture.foundation.bone.natal.julianDay)
        XCTAssertEqual(moment.composite, Asteria.refract(moment.natalAnchor, with: moment.mundanePartner))
    }

    func testPassResolvesArbitraryUTWithoutASecondSamplingGrid() throws {
        let fixture = try makeFixture()
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )
        let mercury = try XCTUnwrap(field[.mercury])
        let arbitrary = AbsoluteInstant(
            unixSecondsSince1970: fixture.foundation.bone.start.unixSecondsSince1970 + 12_347
        )!

        let moment = try mercury.resolve(at: arbitrary)
        guard case .celestial(let source) = moment.mundaneSource else {
            return XCTFail("Expected Mercury OrboSpine source")
        }

        XCTAssertEqual(moment.instant, arbitrary)
        XCTAssertEqual(source.julianDay, arbitrary.julianDay)
        XCTAssertEqual(source.body, .mercury)
        XCTAssertEqual(moment.composite, Asteria.refract(moment.natalAnchor, with: moment.mundanePartner))
    }

    func testStartNatalAndEndOfClosedSynchronicBoneResolveAgainstWiderMundaneBone() throws {
        let fixture = try makeFixture()
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )
        let sun = try XCTUnwrap(field[.sun])

        XCTAssertNoThrow(try sun.resolve(at: fixture.foundation.bone.start))
        XCTAssertNoThrow(try sun.resolve(at: fixture.foundation.bone.natal))
        XCTAssertNoThrow(try sun.resolve(at: fixture.foundation.bone.end))
    }

    func testPassRejectsInstantOutsideItsSynchronicBone() throws {
        let fixture = try makeFixture()
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )
        let sun = try XCTUnwrap(field[.sun])
        let before = AbsoluteInstant(
            unixSecondsSince1970: fixture.foundation.bone.start.unixSecondsSince1970 - 1
        )!

        XCTAssertThrowsError(try sun.resolve(at: before)) { error in
            XCTAssertEqual(error as? SynchronicAsteriaFailure, .outsideBone)
        }
    }

    func testFormationRejectsMundaneSpineThatDoesNotCoverWholeSynchronicBone() throws {
        let fixture = try makeFixture()
        let shortEnd = fixture.foundation.bone.end.julianDay
        let shortBone = try XCTUnwrap(OrboSpineBoneSpan(
            start: fixture.sourceBone.start,
            end: shortEnd
        ))
        let shortLocate = try makeLocate(bone: shortBone, includeAllBodies: true, includeTerra: true)

        XCTAssertThrowsError(
            try Lachesis.callAsteriaForSynchronicSpine(
                foundation: fixture.foundation,
                natalAstroDNA: fixture.astroDNA,
                mundaneSpine: shortLocate
            )
        ) { error in
            XCTAssertEqual(error as? SynchronicAsteriaFailure, .sourceDoesNotCoverBone)
        }
    }

    func testMissingMundaneBodyIsRejectedByThatPassWithoutCrossBodySubstitution() throws {
        let fixture = try makeFixture(includeAllBodies: false)
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )
        let mercury = try XCTUnwrap(field[.mercury])

        XCTAssertThrowsError(try mercury.resolve(at: fixture.foundation.bone.natal)) { error in
            XCTAssertEqual(error as? SynchronicAsteriaFailure, .bodyUnavailable)
        }

        let venus = try XCTUnwrap(field[.venus])
        let venusMoment = try venus.resolve(at: fixture.foundation.bone.natal)
        guard case .celestial(let source) = venusMoment.mundaneSource else {
            return XCTFail("Expected Venus source")
        }
        XCTAssertEqual(source.body, .venus)
    }

    func testMissingTerraIsRejectedByTerraPass() throws {
        let fixture = try makeFixture(includeTerra: false)
        let field = try Lachesis.callAsteriaForSynchronicSpine(
            foundation: fixture.foundation,
            natalAstroDNA: fixture.astroDNA,
            mundaneSpine: fixture.locate
        )
        let terra = try XCTUnwrap(field[.terra])

        XCTAssertThrowsError(try terra.resolve(at: fixture.foundation.bone.natal)) { error in
            XCTAssertEqual(error as? SynchronicAsteriaFailure, .bodyUnavailable)
        }
    }

    private struct Fixture {
        let foundation: SynchronicSpineFoundation
        let astroDNA: AstroDNA
        let locate: OrboSpineLocate
        let sourceBone: OrboSpineBoneSpan
    }

    private func makeFixture(
        includeAllBodies: Bool = true,
        includeTerra: Bool = true
    ) throws -> Fixture {
        let subject = HermesSubjectID(rawValue: "native-asteria")!
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

        let sourceBone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(start.julianDay.value - 0.25)!,
            end: JulianDay(end.julianDay.value + 0.25)!
        ))
        let locate = try makeLocate(
            bone: sourceBone,
            includeAllBodies: includeAllBodies,
            includeTerra: includeTerra
        )

        // Twelve distinct direct states make every natal/body mapping observable.
        let rawSequence = (0..<AstroDNA.geneCount).map { $0 * 7_200 }
        let astroDNA = try XCTUnwrap(AstroDNA(rawSequence: rawSequence))

        return Fixture(
            foundation: foundation,
            astroDNA: astroDNA,
            locate: locate,
            sourceBone: sourceBone
        )
    }

    private func makeLocate(
        bone: OrboSpineBoneSpan,
        includeAllBodies: Bool,
        includeTerra: Bool
    ) throws -> OrboSpineLocate {
        let bodies = includeAllBodies
            ? MundaneBody.canonicalOrder
            : MundaneBody.canonicalOrder.filter { $0 != .mercury }
        let middle = try XCTUnwrap(JulianDay((bone.start.value + bone.end.value) / 2))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in bodies.enumerated() {
            let base = Double(index * 20 + 5)
            supports.append(coordinate(body, base, bone.start))
            supports.append(coordinate(body, base + 0.02, middle))
        }

        let terraSamples: [TerraMarrowSample]
        if includeTerra {
            terraSamples = [
                try XCTUnwrap(TerraMarrowSample(
                    turnDegrees: 350,
                    tiltDegrees: 23.4,
                    julianDay: bone.start
                )),
                try XCTUnwrap(TerraMarrowSample(
                    turnDegrees: 10,
                    tiltDegrees: 23.6,
                    julianDay: bone.end
                )),
            ]
        } else {
            terraSamples = []
        }

        return try XCTUnwrap(OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terraSamples
        ))
    }

    private func coordinate(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        _ julianDay: JulianDay
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
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
