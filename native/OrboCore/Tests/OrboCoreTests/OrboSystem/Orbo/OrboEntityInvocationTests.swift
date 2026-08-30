import XCTest
@testable import OrboCore

final class OrboEntityInvocationTests: XCTestCase {
    func testOrboAsksChronosWithoutChangingOrboState() throws {
        let date = try XCTUnwrap(CivilDate(year: 2000, month: 1, day: 1))
        let time = try XCTUnwrap(CivilClockTime(hour: 12, minute: 0))
        let timezone = try XCTUnwrap(TimezoneIdentifier("Etc/UTC"))
        let orbo = Orbo()
        let before = orbo

        let expected = Chronos.resolveCivilMoment(
            date: date,
            time: time,
            in: timezone
        )
        let actual = orbo.askChronos(
            date: date,
            time: time,
            in: timezone
        )

        XCTAssertEqual(actual, expected)
        XCTAssertEqual(orbo, before)
    }

    func testOrboAsksHoraeWithoutChangingOrboState() throws {
        let horae = try makeHorae()
        let target = try XCTUnwrap(JulianDay(1_000.75))
        let intent = HoraeControlIntent.seekUT(to: target)
        let orbo = Orbo()
        let before = orbo

        let expected = try horae.respond(to: intent)
        let actual = try orbo.askHorae(intent, using: horae)

        XCTAssertEqual(actual, expected)
        XCTAssertEqual(orbo, before)
    }

    func testOrboDoesNotInventWhenAddressedAuthorityCannotAnswer() throws {
        let horae = try makeHorae()
        let outsideBone = try XCTUnwrap(JulianDay(999.0))
        let orbo = Orbo()

        XCTAssertThrowsError(
            try orbo.askHorae(.seekUT(to: outsideBone), using: horae)
        ) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .outsideBone)
        }

        let unknownTimezone = try XCTUnwrap(TimezoneIdentifier("Orbo/Not_A_Zone"))
        let date = try XCTUnwrap(CivilDate(year: 2000, month: 1, day: 1))
        let time = try XCTUnwrap(CivilClockTime(hour: 12, minute: 0))

        XCTAssertEqual(
            orbo.askChronos(date: date, time: time, in: unknownTimezone),
            .unresolved(.unknownTimeZone(unknownTimezone))
        )
    }

    private func makeHorae() throws -> Horae {
        let bone = try XCTUnwrap(
            OrboSpineBoneSpan(
                start: JulianDay(1_000)!,
                end: JulianDay(1_002)!
            )
        )

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let startDegrees = 10.0 + Double(index) * 20.0
            let supportStep = OrboSpineContract.supportDegrees(for: body)
            supports.append(
                coordinate(
                    body: body,
                    physicalDegrees: startDegrees,
                    julianDay: 1_000.0
                )
            )
            supports.append(
                coordinate(
                    body: body,
                    physicalDegrees: startDegrees + supportStep,
                    julianDay: 1_001.0
                )
            )
        }

        let terra = [
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 100.0,
                    tiltDegrees: 23.4,
                    julianDay: bone.start
                )
            ),
            try XCTUnwrap(
                TerraMarrowSample(
                    turnDegrees: 110.0,
                    tiltDegrees: 23.5,
                    julianDay: bone.end
                )
            ),
        ]

        let locate = try XCTUnwrap(
            OrboSpineLocate(
                bone: bone,
                celestialSupports: supports,
                terraSamples: terra
            )
        )
        return Horae(locate: locate)
    }

    private func coordinate(
        body: MundaneBody,
        physicalDegrees: Double,
        julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: .direct
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }
}
