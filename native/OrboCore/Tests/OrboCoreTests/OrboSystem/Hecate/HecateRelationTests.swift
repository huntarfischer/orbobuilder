import XCTest
@testable import OrboCore

final class HecateRelationTests: XCTestCase {
    func testTwoPointsProduceCompleteRawRelationTable() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second]))

        let table = try Hecate.relate(link, through: doorIII)
        let bodyCount = MundaneBody.canonicalOrder.count

        XCTAssertEqual(table.participants.map(\.sourceAddress), [first, second])
        XCTAssertEqual(table.rows.count, bodyCount * bodyCount)
        XCTAssertTrue(table.rows.allSatisfy { row in
            row.leftParticipant == first && row.rightParticipant == second
        })
    }

    func testThreePointsPreserveAllParticipantPairingsInSourceOrder() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let third = OrboSpinePointAddress.occurrence(JulianDay(1_000.5)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second, third]))

        let table = try Hecate.relate(link, through: doorIII)
        let rowsPerPair = MundaneBody.canonicalOrder.count * MundaneBody.canonicalOrder.count

        XCTAssertEqual(table.participants.map(\.sourceAddress), [first, second, third])
        XCTAssertEqual(table.rows.count, rowsPerPair * 3)
        XCTAssertEqual(table.rows[0].leftParticipant, first)
        XCTAssertEqual(table.rows[0].rightParticipant, second)
        XCTAssertEqual(table.rows[rowsPerPair].leftParticipant, first)
        XCTAssertEqual(table.rows[rowsPerPair].rightParticipant, third)
        XCTAssertEqual(table.rows[rowsPerPair * 2].leftParticipant, second)
        XCTAssertEqual(table.rows[rowsPerPair * 2].rightParticipant, third)
    }

    func testKnownLongitudePairUsesRingSeparation() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second]))

        let table = try Hecate.relate(link, through: doorIII)
        let row = try XCTUnwrap(
            table.rows.first {
                $0.leftBody == .sun && $0.rightBody == .moon
            }
        )
        let expected = Ring.separation(
            from: CelestialLongitude(0)!,
            to: CelestialLongitude(20.05)!
        )

        XCTAssertEqual(row.angularSeparation.degrees, expected.degrees, accuracy: 1e-12)
    }

    func testRelationPreservesResolvedPointDirectionalIdentity() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second]))
        let resolved = try HecateLink(link: link).resolve(through: doorIII)

        let table = try Hecate.relate(link, through: doorIII)

        XCTAssertEqual(table.participants, resolved.points)
        for point in table.participants {
            let mercury = try XCTUnwrap(
                point.celestial.first { $0.body == .mercury }
            )
            XCTAssertEqual(mercury.directionalDegree.motion, .retrograde)
        }
    }

    func testRelationSurfacesDoorIIIFailureWithoutSubstitution() throws {
        let doorIII = try makeDoorIII()
        let local = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let foreign = try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: "NatalSpine-A",
                memberIdentity: "occurrence|1000.0"
            )
        )
        let link = try XCTUnwrap(SpineLinkSet(members: [local, foreign]))

        XCTAssertThrowsError(try Hecate.relate(link, through: doorIII)) { error in
            XCTAssertEqual(error as? OrboSpineLinkError, .foreignSpine(foreign))
        }
    }

    func testMomentToMomentRitualReturnsTheExistingRawRelationTable() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second]))

        let generic = try Hecate.relate(link, through: doorIII)
        let named = try Hecate.relate(.momentToMoment, link, through: doorIII)

        XCTAssertEqual(named, generic)
    }

    func testMomentToMomentRitualRequiresExactlyTwoParticipants() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let third = OrboSpinePointAddress.occurrence(JulianDay(1_000.5)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second, third]))

        XCTAssertThrowsError(
            try Hecate.relate(.momentToMoment, link, through: doorIII)
        ) { error in
            XCTAssertEqual(
                error as? HecateRelationRitualError,
                .participantCount(expected: 2, actual: 3)
            )
        }
    }

    func testMomentToMomentRitualSurfacesDoorIIIFailureUnchanged() throws {
        let doorIII = try makeDoorIII()
        let local = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let foreign = try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: "NatalSpine-A",
                memberIdentity: "occurrence|1000.0"
            )
        )
        let link = try XCTUnwrap(SpineLinkSet(members: [local, foreign]))

        XCTAssertThrowsError(
            try Hecate.relate(.momentToMoment, link, through: doorIII)
        ) { error in
            XCTAssertEqual(error as? OrboSpineLinkError, .foreignSpine(foreign))
        }
    }

    private func makeDoorIII() throws -> OrboSpineLink {
        OrboSpineLink(
            spineIdentity: OrboSpineContract.identity,
            locate: try makeLocate()
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

            if body == .mercury {
                supports.append(coordinate(body, base + step, 1_000, motion: .retrograde))
                supports.append(coordinate(body, base, 1_001, motion: .retrograde))
            } else {
                supports.append(coordinate(body, base, 1_000, motion: .direct))
                supports.append(coordinate(body, base + step, 1_001, motion: .direct))
            }
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
        _ julianDay: Double,
        motion: Motion
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degrees,
                motion: motion
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }
}
