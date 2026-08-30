import XCTest
@testable import OrboCore

final class OrboSpineLinkResolutionTests: XCTestCase {
    func testDoorIIIResolvesTwoOrMoreExactPointsInCallerOrder() throws {
        let locate = try makeLocate()
        let doorIII = OrboSpineLink(
            spineIdentity: OrboSpineContract.identity,
            locate: locate
        )

        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000.25)!).linkAddress()

        let celestialJD = JulianDay(1_001.25)!
        let celestialCoordinate = try locate.coordinate(of: .sun, at: celestialJD)
        let second = OrboSpinePointAddress.celestialOccurrence(
            body: .sun,
            directionalDegree: celestialCoordinate.directionalDegree,
            julianDay: celestialJD
        ).linkAddress()

        let third = OrboSpinePointAddress.occurrence(JulianDay(1_000.75)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second, third]))

        let resolved = try doorIII.resolve(link)

        XCTAssertEqual(resolved.source, link)
        XCTAssertEqual(resolved.points.map { $0.sourceAddress }, [first, second, third])
        XCTAssertEqual(resolved.points.map { $0.julianDay.value }, [1_000.25, 1_001.25, 1_000.75])
        XCTAssertTrue(resolved.points.allSatisfy { $0.celestial.count == MundaneBody.canonicalOrder.count })
        XCTAssertTrue(resolved.points.allSatisfy { point in
            point.celestial.map(\.body) == MundaneBody.canonicalOrder
        })
    }

    func testOccurrenceAndCelestialOccurrenceAddressesRoundTripWithoutCollapsing() throws {
        let occurrence = OrboSpinePointAddress.occurrence(JulianDay(1_000.5)!)
        XCTAssertEqual(
            OrboSpinePointAddress(memberIdentity: occurrence.memberIdentity),
            occurrence
        )

        let directionalDegree = try XCTUnwrap(OrboSpineDirectionalDegree(381.25))
        let celestial = OrboSpinePointAddress.celestialOccurrence(
            body: .mercury,
            directionalDegree: directionalDegree,
            julianDay: JulianDay(1_001.5)!
        )
        XCTAssertEqual(
            OrboSpinePointAddress(memberIdentity: celestial.memberIdentity),
            celestial
        )
        XCTAssertNotEqual(occurrence.memberIdentity, celestial.memberIdentity)
    }

    func testCelestialOccurrenceMustMatchTheNamedCelestialStateAtThatOccurrence() throws {
        let locate = try makeLocate()
        let doorIII = OrboSpineLink(
            spineIdentity: OrboSpineContract.identity,
            locate: locate
        )
        let julianDay = JulianDay(1_000.5)!
        let actual = try locate.coordinate(of: .sun, at: julianDay)
        let wrongDegree = try XCTUnwrap(
            OrboSpineDirectionalDegree(actual.directionalDegree.degrees + 1)
        )
        let bad = OrboSpinePointAddress.celestialOccurrence(
            body: .sun,
            directionalDegree: wrongDegree,
            julianDay: julianDay
        ).linkAddress()
        let good = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [bad, good]))

        XCTAssertThrowsError(try doorIII.resolve(link)) { error in
            XCTAssertEqual(error as? OrboSpineLinkError, .celestialOccurrenceMismatch(bad))
        }
    }

    func testDoorIIIRejectsForeignOrUnrecognizedMembersRatherThanSearchingForSubstitutes() throws {
        let locate = try makeLocate()
        let doorIII = OrboSpineLink(
            spineIdentity: OrboSpineContract.identity,
            locate: locate
        )
        let local = OrboSpinePointAddress.occurrence(JulianDay(1_000.5)!).linkAddress()
        let foreign = try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: "NatalSpine-A",
                memberIdentity: "occurrence|1000.5"
            )
        )
        let foreignLink = try XCTUnwrap(SpineLinkSet(members: [local, foreign]))

        XCTAssertThrowsError(try doorIII.resolve(foreignLink)) { error in
            XCTAssertEqual(error as? OrboSpineLinkError, .foreignSpine(foreign))
        }

        let unknown = try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: OrboSpineContract.identity,
                memberIdentity: "not-an-orbospine-point"
            )
        )
        let unknownLink = try XCTUnwrap(SpineLinkSet(members: [local, unknown]))

        XCTAssertThrowsError(try doorIII.resolve(unknownLink)) { error in
            XCTAssertEqual(error as? OrboSpineLinkError, .invalidMemberIdentity(unknown))
        }
    }

    private func makeLocate() throws -> OrboSpineLocate {
        let bone = try XCTUnwrap(
            OrboSpineBoneSpan(
                start: JulianDay(1_000)!,
                end: JulianDay(1_002)!
            )
        )

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in MundaneBody.canonicalOrder.enumerated() {
            let base = Double(index) * 20
            let step = min(0.05, OrboSpineContract.supportDegrees(for: body) / 2)
            supports.append(coordinate(body, base, 1_000))
            supports.append(coordinate(body, base + step, 1_001))
        }

        let terra = [
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 100,
                    tiltDegrees: 23.4,
                    julianDay: JulianDay(1_000)!
                )
            ),
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 110,
                    tiltDegrees: 23.5,
                    julianDay: JulianDay(1_001)!
                )
            ),
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 120,
                    tiltDegrees: 23.6,
                    julianDay: JulianDay(1_002)!
                )
            ),
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
        _ body: MundaneBody,
        _ degrees: Double,
        _ julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: .direct
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }
}
