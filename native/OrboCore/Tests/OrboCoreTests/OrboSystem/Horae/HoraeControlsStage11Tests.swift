import XCTest
@testable import OrboCore

final class HoraeControlsStage11Tests: XCTestCase {
    func testControlDomainSpeaksExactHalfOpenBoneBounds() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)

        XCTAssertEqual(
            horae.controlDomain,
            HoraeControlDomain(
                start: locate.bone.start,
                endExclusive: locate.bone.end
            )
        )
    }

    func testOccurrenceAvailabilityExactlyMatchesLocateTruth() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let sampleUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let degree = try locate.coordinate(of: .mercury, at: sampleUT).directionalDegree

        let expected = try locate.occurrences(
            of: .mercury,
            at: degree
        ).map(\.julianDay)
        let available = try horae.occurrenceUTs(
            of: .mercury,
            at: degree
        )

        XCTAssertEqual(available, expected)
        XCTAssertFalse(available.isEmpty)
    }

    func testOccurrenceAvailabilityReturnsEmptyWhenBodyNeverOccupiesState() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let unavailable = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 120,
            motion: .retrograde
        ))

        XCTAssertEqual(
            try horae.occurrenceUTs(of: .mercury, at: unavailable),
            []
        )
    }

    func testOccurrenceAvailabilityPreservesBodyUnavailableError() throws {
        let locate = try XCTUnwrap(makeSunOnlyLocate())
        let horae = Horae(locate: locate)
        let degree = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 10,
            motion: .direct
        ))

        XCTAssertThrowsError(
            try horae.occurrenceUTs(of: .mercury, at: degree)
        ) { error in
            XCTAssertEqual(
                error as? OrboSpineLocateError,
                .bodyUnavailable(.mercury)
            )
        }
    }

    func testMatchingBodiesExactlyMatchesCanonicalBodiesAtStateAndUT() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let degree = try locate.coordinate(of: .mars, at: fixedUT).directionalDegree

        var expected: [MundaneBody] = []
        for body in OrboSpineContract.canonicalBodies {
            let coordinate = try locate.coordinate(of: body, at: fixedUT)
            if coordinate.directionalDegree.motion == degree.motion,
               abs(
                   coordinate.directionalDegree.physicalDegrees
                       - degree.physicalDegrees
               ) <= 1e-10 {
                expected.append(body)
            }
        }

        let matching = try horae.matchingBodies(
            at: degree,
            on: fixedUT
        )

        XCTAssertEqual(matching, expected)
        XCTAssertTrue(matching.contains(.mars))
    }

    func testMatchingBodiesReturnsEmptyForNoExactStateMatch() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let unavailable = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 120,
            motion: .retrograde
        ))

        XCTAssertEqual(
            try horae.matchingBodies(at: unavailable, on: fixedUT),
            []
        )
    }

    func testMatchingBodiesRejectsOutsideBoneUT() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let degree = try XCTUnwrap(OrboSpineDirectionalDegree(
            physicalDegrees: 120,
            motion: .direct
        ))

        XCTAssertThrowsError(
            try horae.matchingBodies(
                at: degree,
                on: locate.bone.end
            )
        ) { error in
            XCTAssertEqual(
                error as? OrboSpineLocateError,
                .outsideBone
            )
        }
    }

    func testAvailabilityQueriesAreDeterministicAndDoNotContaminateControls() throws {
        let locate = try XCTUnwrap(makeLocate())
        let horae = Horae(locate: locate)
        let fixedUT = try XCTUnwrap(JulianDay(locate.bone.start.value + 40))
        let degree = try locate.coordinate(of: .venus, at: fixedUT).directionalDegree
        let before = try horae.driveBody(to: .sun, at: fixedUT)

        let firstOccurrences = try horae.occurrenceUTs(
            of: .venus,
            at: degree
        )
        let firstMatches = try horae.matchingBodies(
            at: degree,
            on: fixedUT
        )
        _ = horae.controlDomain
        let secondOccurrences = try horae.occurrenceUTs(
            of: .venus,
            at: degree
        )
        let secondMatches = try horae.matchingBodies(
            at: degree,
            on: fixedUT
        )
        let after = try horae.driveBody(to: .sun, at: fixedUT)

        XCTAssertEqual(secondOccurrences, firstOccurrences)
        XCTAssertEqual(secondMatches, firstMatches)
        XCTAssertEqual(after, before)
    }

    private func makeLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_600_000))
        let end = try XCTUnwrap(JulianDay(2_600_160))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let increment = OrboSpineContract.supportDegrees(for: body) * 0.5
            let startingPhysical = Double(index) * 25

            for day in 0..<160 {
                let physical = normalized(
                    startingPhysical + increment * Double(day)
                )
                let julianDay = try XCTUnwrap(
                    JulianDay(start.value + Double(day))
                )
                supports.append(coordinate(
                    body,
                    physicalDegrees: physical,
                    at: julianDay
                ))
            }
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110,
                tiltDegrees: 23.5,
                julianDay: end
            )),
        ]

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        )
    }

    private func makeSunOnlyLocate() throws -> OrboSpineLocate? {
        let start = try XCTUnwrap(JulianDay(2_700_000))
        let midpoint = try XCTUnwrap(JulianDay(2_700_000.5))
        let end = try XCTUnwrap(JulianDay(2_700_001))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        let supports = [
            coordinate(.sun, physicalDegrees: 10, at: start),
            coordinate(.sun, physicalDegrees: 15, at: midpoint),
        ]

        return OrboSpineLocate(
            bone: bone,
            celestialSupports: supports
        )
    }

    private func normalized(_ physicalDegrees: Double) -> Double {
        let remainder = physicalDegrees.truncatingRemainder(dividingBy: 360)
        return remainder >= 0 ? remainder : remainder + 360
    }

    private func coordinate(
        _ body: MundaneBody,
        physicalDegrees: Double,
        at julianDay: JulianDay
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
}
