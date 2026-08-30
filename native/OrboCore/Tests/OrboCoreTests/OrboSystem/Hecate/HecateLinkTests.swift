import XCTest
@testable import OrboCore

final class HecateLinkTests: XCTestCase {
    func testHecateReceivesTheExactDoorThreeLinkSet() throws {
        let mundaneSun = try address("mundane-timespine", "sun@2451545")
        let natalSun = try address("natal-spine", "sun")
        let doorIII = try XCTUnwrap(SpineLinkSet(members: [mundaneSun, natalSun]))

        let hecate = HecateLink(link: doorIII)

        XCTAssertEqual(hecate.link, doorIII)
        XCTAssertEqual(SpineLinkSet.port, .link)
    }

    func testHecatePreservesNWayMemberOrderAcrossSpines() throws {
        let mundaneSun = try address("mundane-timespine", "sun@2451545")
        let natalMoon = try address("natal-spine", "moon")
        let synchronicAscendant = try address(
            "synchronic-spine",
            "ascendant@2451545"
        )
        let doorIII = try XCTUnwrap(
            SpineLinkSet(members: [mundaneSun, natalMoon, synchronicAscendant])
        )

        let hecate = HecateLink(link: doorIII)

        XCTAssertEqual(
            hecate.members,
            [mundaneSun, natalMoon, synchronicAscendant]
        )
        XCTAssertEqual(hecate.members.count, 3)
    }

    func testHecateHandsExactLinkToDoorIIIAndReceivesResolvedPointsInOrder() throws {
        let locate = try makeLocate()
        let doorIII = OrboSpineLink(
            spineIdentity: OrboSpineContract.identity,
            locate: locate
        )
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000.25)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001.25)!).linkAddress()
        let third = OrboSpinePointAddress.occurrence(JulianDay(1_000.75)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second, third]))

        let resolved = try HecateLink(link: link).resolve(through: doorIII)

        XCTAssertEqual(resolved.source, link)
        XCTAssertEqual(resolved.points.map(\.sourceAddress), [first, second, third])
        XCTAssertEqual(
            resolved.points.map { $0.julianDay.value },
            [1_000.25, 1_001.25, 1_000.75]
        )
    }

    func testHecateSurfacesDoorIIIFailureWithoutSubstitution() throws {
        let locate = try makeLocate()
        let doorIII = OrboSpineLink(
            spineIdentity: OrboSpineContract.identity,
            locate: locate
        )
        let local = OrboSpinePointAddress.occurrence(JulianDay(1_000.5)!).linkAddress()
        let foreign = try address("NatalSpine-A", "occurrence|1000.5")
        let link = try XCTUnwrap(SpineLinkSet(members: [local, foreign]))

        XCTAssertThrowsError(try HecateLink(link: link).resolve(through: doorIII)) { error in
            XCTAssertEqual(error as? OrboSpineLinkError, .foreignSpine(foreign))
        }
    }

    private func address(
        _ spine: String,
        _ member: String
    ) throws -> SpineLinkAddress {
        try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: spine,
                memberIdentity: member
            )
        )
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
