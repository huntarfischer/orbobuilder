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
        XCTAssertTrue(table.rows.allSatisfy { $0.aspect.orb == .exact })
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

    func testKnownLongitudePairUsesAspectPrimitive() throws {
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
        let expected = Hecate.relateAspect(
            CelestialLongitude(0)!,
            CelestialLongitude(20.05)!
        )

        XCTAssertEqual(row.aspect, expected)
        XCTAssertEqual(
            row.angularSeparation.degrees,
            expected.separation.degrees,
            accuracy: 1e-12
        )
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

    func testAspectDefaultsToExactZeroArcminuteOrb() {
        let aspect = Hecate.relateAspect(
            CelestialLongitude(0)!,
            CelestialLongitude(90)!
        )

        XCTAssertEqual(aspect.orb, .exact)
        XCTAssertEqual(aspect.orb.arcminutes, 0)
        XCTAssertEqual(aspect.separation.degrees, 90, accuracy: 1e-12)
        XCTAssertEqual(aspect.nearest.residual, 0, accuracy: 1e-12)
        XCTAssertEqual(aspect.matchedMark, .square)
    }

    func testAspectCanBeExplicitlyWidenedWithoutChangingSeparation() throws {
        let first = CelestialLongitude(0)!
        let second = CelestialLongitude(90 + 1.0 / 60.0)!
        let exact = Hecate.relateAspect(first, second)
        let oneMinute = try XCTUnwrap(HecateAspectOrb(arcminutes: 1))
        let widened = Hecate.relateAspect(first, second, orb: oneMinute)

        XCTAssertNil(exact.matchedMark)
        XCTAssertEqual(widened.matchedMark, .square)
        XCTAssertEqual(exact.separation, widened.separation)
        XCTAssertEqual(widened.orb.arcminutes, 1)
    }

    func testSynastryRitualReturnsTheExistingRelationTable() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second]))

        let generic = try Hecate.relate(link, through: doorIII)
        let synastry = try Hecate.relate(.synastry, link, through: doorIII)

        XCTAssertEqual(synastry, generic)
        XCTAssertTrue(synastry.rows.allSatisfy { $0.aspect.orb == .exact })
    }

    func testSynastryRitualRequiresExactlyTwoParticipants() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let third = OrboSpinePointAddress.occurrence(JulianDay(1_000.5)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second, third]))

        XCTAssertThrowsError(
            try Hecate.relate(.synastry, link, through: doorIII)
        ) { error in
            XCTAssertEqual(
                error as? HecateRelationRitualError,
                .participantCount(expected: 2, actual: 3)
            )
        }
    }

    func testSynastryRitualSurfacesDoorIIIFailureUnchanged() throws {
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
            try Hecate.relate(.synastry, link, through: doorIII)
        ) { error in
            XCTAssertEqual(error as? OrboSpineLinkError, .foreignSpine(foreign))
        }
    }

    func testMidpointUsesArcShortestPathAcrossZero() {
        let first = CelestialLongitude(350)!
        let second = CelestialLongitude(10)!
        let midpoint = Hecate.castMidpoint(first, second)

        XCTAssertEqual(midpoint.first, first)
        XCTAssertEqual(midpoint.second, second)

        guard case let .position(position) = midpoint.result else {
            return XCTFail("Expected one midpoint position across the zero-degree seam")
        }
        XCTAssertEqual(position.degrees, 0, accuracy: 1e-12)
    }

    func testMidpointPreservesArcOppositionSeam() {
        let midpoint = Hecate.castMidpoint(
            CelestialLongitude(0)!,
            CelestialLongitude(180)!
        )

        guard case .seam = midpoint.result else {
            return XCTFail("Exact opposition must preserve Arc's two-pole Seam")
        }
    }

    func testCompositeProducesCorrespondingMidpointForEveryCanonicalBody() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second]))
        let resolved = try HecateLink(link: link).resolve(through: doorIII)

        let composite = try Hecate.castComposite(link, through: doorIII)

        XCTAssertEqual(composite.sources, resolved.points)
        XCTAssertEqual(composite.members.map(\.body), MundaneBody.canonicalOrder)
        XCTAssertEqual(composite.members.count, MundaneBody.canonicalOrder.count)

        for member in composite.members {
            let firstCoordinate = try XCTUnwrap(
                composite.sources[0].celestial.first { $0.body == member.body }
            )
            let secondCoordinate = try XCTUnwrap(
                composite.sources[1].celestial.first { $0.body == member.body }
            )
            let expected = Hecate.castMidpoint(
                CelestialLongitude(firstCoordinate.directionalDegree.physicalDegrees)!,
                CelestialLongitude(secondCoordinate.directionalDegree.physicalDegrees)!
            )

            XCTAssertEqual(member.midpoint, expected)
        }
    }

    func testCompositeRequiresExactlyTwoFields() throws {
        let doorIII = try makeDoorIII()
        let first = OrboSpinePointAddress.occurrence(JulianDay(1_000)!).linkAddress()
        let second = OrboSpinePointAddress.occurrence(JulianDay(1_001)!).linkAddress()
        let third = OrboSpinePointAddress.occurrence(JulianDay(1_000.5)!).linkAddress()
        let link = try XCTUnwrap(SpineLinkSet(members: [first, second, third]))

        XCTAssertThrowsError(
            try Hecate.castComposite(link, through: doorIII)
        ) { error in
            XCTAssertEqual(
                error as? HecateCompositeError,
                .participantCount(expected: 2, actual: 3)
            )
        }
    }

    func testCompositeSurfacesDoorIIIFailureUnchanged() throws {
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
            try Hecate.castComposite(link, through: doorIII)
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
