import XCTest
@testable import OrboCore

final class RingTests: XCTestCase {
    private struct ParityFixture: Decodable {
        struct Constants: Decodable {
            let degrees: Int
            let states: Int
            let arcsecondsPerDegree: Int
            let arcseconds: Int
            let fineStates: Int
            let plateSize: Int
        }
        struct CoarseStateCase: Decodable { let longitude: Double; let motion: Motion; let state: Int }
        struct FineStateCase: Decodable { let longitude: Double; let motion: Motion; let state: Int }
        struct DMSCase: Decodable { let fineState: Int; let degree: Int; let minute: Int; let second: Int }
        struct TargetCase: Decodable { let state: Int; let mark: Int; let direction: RingDirection; let degree: Int }
        struct RelationCase: Decodable { let a: Int; let b: Int; let mark: Int? }
        struct NearestCase: Decodable { let separation: Double; let arc: Double; let mark: Int; let residual: Double }
        struct SupplementCase: Decodable { let mark: Int; let supplement: Int? }
        let marks: [Int]
        let tieRule: String
        let constants: Constants
        let coarseStates: [CoarseStateCase]
        let fineStates: [FineStateCase]
        let dms: [DMSCase]
        let targets: [TargetCase]
        let relations: [RelationCase]
        let nearest: [NearestCase]
        let supplements: [SupplementCase]
    }

    private func fixture() throws -> ParityFixture {
        try FixtureLoader.decode(ParityFixture.self, named: "ring-parity", kind: .parity)
    }

    func testPrototypeParityFixture() throws {
        let fixture = try fixture()
        XCTAssertEqual(Ring.marks.map(\.rawValue), fixture.marks)
        XCTAssertEqual(Ring.tieRule.rawValue, fixture.tieRule)
        XCTAssertEqual(Ring.degrees, fixture.constants.degrees)
        XCTAssertEqual(Ring.states, fixture.constants.states)
        XCTAssertEqual(Ring.arcsecondsPerDegree, fixture.constants.arcsecondsPerDegree)
        XCTAssertEqual(Ring.arcseconds, fixture.constants.arcseconds)
        XCTAssertEqual(Ring.fineStates, fixture.constants.fineStates)
        XCTAssertEqual(Ring.plateSize, fixture.constants.plateSize)

        for item in fixture.coarseStates {
            let longitude = try XCTUnwrap(CelestialLongitude(item.longitude))
            XCTAssertEqual(Ring.state(of: longitude, motion: item.motion).rawValue, item.state)
        }
        for item in fixture.fineStates {
            let longitude = try XCTUnwrap(CelestialLongitude(item.longitude))
            XCTAssertEqual(Ring.fineState(of: longitude, motion: item.motion).rawValue, item.state)
        }
        for item in fixture.dms {
            let state = try XCTUnwrap(RingFineState(item.fineState))
            XCTAssertEqual(state.dms, RingDMS(degree: item.degree, minute: item.minute, second: item.second))
        }
        for item in fixture.targets {
            let state = try XCTUnwrap(RingState(item.state))
            let mark = try XCTUnwrap(RingMark(rawValue: item.mark))
            XCTAssertEqual(Ring.targetDegree(from: state, mark: mark, direction: item.direction), item.degree)
        }
        for item in fixture.relations {
            let a = try XCTUnwrap(RingState(item.a))
            let b = try XCTUnwrap(RingState(item.b))
            let expected = item.mark.flatMap(RingMark.init(rawValue:))
            XCTAssertEqual(Ring.relation(between: a, and: b), expected)
            XCTAssertEqual(Ring.related(a, b), expected != nil)
        }
        for item in fixture.nearest {
            let separation = try XCTUnwrap(RingSeparation(item.separation))
            let result = Ring.nearest(to: separation)
            XCTAssertEqual(result.arc, item.arc, accuracy: 1e-12)
            XCTAssertEqual(result.mark.rawValue, item.mark)
            XCTAssertEqual(result.residual, item.residual, accuracy: 1e-9)
        }
        for item in fixture.supplements {
            let mark = try XCTUnwrap(RingMark(rawValue: item.mark))
            XCTAssertEqual(Ring.supplement(of: mark)?.rawValue, item.supplement)
        }
    }

    func testDieIsTheElevenWholeDegreeMarksWithLowerTieRule() {
        let rawMarks = Ring.marks.map(\.rawValue)
        XCTAssertEqual(rawMarks.count, 11)
        XCTAssertEqual(rawMarks, rawMarks.sorted())
        XCTAssertEqual(Set(rawMarks).count, 11)
        XCTAssertTrue(rawMarks.allSatisfy { mark in
            (1...12).contains { denominator in
                360 % denominator == 0 && (mark * denominator) % 360 == 0
            }
        })
        let seventhTurn: Double = 360.0 / 7.0
        let seventhIsWholeDegreeMark = (1...12).contains { (denominator: Int) -> Bool in
            let turns: Double = seventhTurn * Double(denominator) / 360.0
            return 360 % denominator == 0 && turns.rounded() == turns
        }
        XCTAssertFalse(seventhIsWholeDegreeMark)
        XCTAssertNil(RingMark(rawValue: 51))
        XCTAssertNil(RingMark(rawValue: 108))
        XCTAssertEqual(Ring.tieRule, .lower)
    }

    func testAll720StatesEncodeDegreeAndMotionExactly() {
        for raw in 0..<Ring.states {
            let state = RingState(raw)!
            XCTAssertEqual(state.degree, raw % Ring.degrees)
            XCTAssertEqual(state.motion, raw >= Ring.degrees ? .retrograde : .direct)
        }
        let zero = CelestialLongitude(0.4)!
        let pair = Ring.states(for: zero)
        XCTAssertEqual(pair.direct.rawValue, 0)
        XCTAssertEqual(pair.retrograde.rawValue, 360)
    }

    func testAll720RowsMatchThe14400TargetAtlasLaw() {
        var checkedTargets = 0
        var mismatches = 0
        var pairMismatches = 0
        for rawState in 0..<Ring.states {
            let state = RingState(rawState)!
            let row = Ring.row(for: state)
            if row.count != Ring.marks.count { mismatches += 1 }
            for entry in row {
                let angle = entry.mark.rawValue
                let expectedMinus = (state.degree - angle + Ring.degrees) % Ring.degrees
                let expectedPlus = (state.degree + angle) % Ring.degrees
                if entry.minus.degree != expectedMinus || entry.plus.degree != expectedPlus { mismatches += 1 }
                if entry.minus.retrograde.rawValue != entry.minus.direct.rawValue + Ring.degrees ||
                    entry.plus.retrograde.rawValue != entry.plus.direct.rawValue + Ring.degrees { pairMismatches += 1 }
                if entry.single {
                    if entry.minus.degree != entry.plus.degree { mismatches += 1 }
                    checkedTargets += 1
                } else {
                    checkedTargets += 2
                }
            }
        }
        XCTAssertEqual(checkedTargets, 14_400)
        XCTAssertEqual(mismatches, 0)
        XCTAssertEqual(pairMismatches, 0)
        XCTAssertEqual(Ring.plateSize, 360 * 11 * 2)
        XCTAssertEqual(Ring.exactMarkLookupSize, 360)
    }

    func testRelationIsExactAndMotionBlindAcrossTheWholeCoarseSpace() {
        var expectedByDirectedSeparation: [Int: RingMark] = [:]
        for mark in Ring.marks {
            expectedByDirectedSeparation[mark.rawValue] = mark
            expectedByDirectedSeparation[(Ring.degrees - mark.rawValue) % Ring.degrees] = mark
        }
        var mismatches = 0
        for aDegree in 0..<Ring.degrees {
            for bDegree in 0..<Ring.degrees {
                let expected = expectedByDirectedSeparation[(bDegree - aDegree + Ring.degrees) % Ring.degrees]
                for aOffset in [0, Ring.degrees] {
                    for bOffset in [0, Ring.degrees] {
                        let a = RingState(aDegree + aOffset)!
                        let b = RingState(bDegree + bOffset)!
                        if Ring.relation(between: a, and: b) != expected { mismatches += 1 }
                        if Ring.related(a, b) != (expected != nil) { mismatches += 1 }
                    }
                }
            }
        }
        XCTAssertEqual(mismatches, 0)
        XCTAssertEqual(Ring.relation(between: RingState(0)!, and: RingState(0)!), .conjunction)
        XCTAssertNil(Ring.relation(between: RingState(0)!, and: RingState(91)!))
    }

    func testFineAddressSpaceProjectsExactlyToTheCoarseRing() {
        XCTAssertEqual(Ring.arcsecondsPerDegree, 3_600)
        XCTAssertEqual(Ring.arcseconds, 1_296_000)
        XCTAssertEqual(Ring.fineStates, 2_592_000)
        var mismatches = 0
        for degree in 0..<Ring.degrees {
            for offset in [0, 1, 1_800, 3_599] {
                let direct = RingFineState(degree * 3_600 + offset)!
                let retrograde = RingFineState(Ring.arcseconds + degree * 3_600 + offset)!
                if direct.coarseState.rawValue != degree { mismatches += 1 }
                if retrograde.coarseState.rawValue != degree + Ring.degrees { mismatches += 1 }
            }
        }
        XCTAssertEqual(mismatches, 0)
        for raw in [0.0, 7.5, 116.37, 359.999, -370.5] {
            let longitude = CelestialLongitude(raw)!
            for motion in Motion.allCases {
                XCTAssertEqual(Ring.fineState(of: longitude, motion: motion).coarseState, Ring.state(of: longitude, motion: motion))
            }
        }
    }

    func testNearestUsesExactRealArcAndAllNineTiesChooseTheLowerMark() {
        let ties: [(Double, RingMark)] = [
            (37.5, .semisextile), (52.5, .semisquare), (66, .sextile),
            (81, .quintile), (105, .square), (127.5, .trine),
            (139.5, .sesquiquadrate), (147, .biquintile), (165, .quincunx),
        ]
        for (value, expected) in ties { XCTAssertEqual(Ring.nearest(to: RingSeparation(value)!).mark, expected) }
        let exact = Ring.nearest(to: RingSeparation(120)!)
        XCTAssertEqual(exact.mark, .trine)
        XCTAssertEqual(exact.residual, 0)
        XCTAssertEqual(Ring.exact(RingSeparation(120)!), .trine)
        XCTAssertNil(Ring.exact(RingSeparation(120.01)!))
        let real = Ring.nearest(to: RingSeparation(116.37)!)
        XCTAssertEqual(real.mark, .trine)
        XCTAssertEqual(real.residual, 3.63, accuracy: 1e-9)
        XCTAssertNotEqual(real.residual, Ring.nearest(to: RingSeparation(116)!).residual)
    }

    func testDirectedSeparationAndFoldedArcPreservePrototypeGeometry() {
        let zero = CelestialLongitude(0)!
        let ninety = CelestialLongitude(90)!
        let twoSeventy = CelestialLongitude(270)!
        XCTAssertEqual(Ring.separation(from: zero, to: zero).degrees, 0)
        XCTAssertEqual(Ring.separation(from: zero, to: twoSeventy).degrees, 270)
        XCTAssertEqual(Ring.arc(of: Ring.separation(from: zero, to: twoSeventy)), 90)
        XCTAssertEqual(Ring.arc(of: Ring.separation(from: zero, to: ninety)), 90)
        XCTAssertEqual(Ring.arc(of: RingSeparation(244)!), 116)
        XCTAssertEqual(Ring.arc(of: RingSeparation(-1)!), 1)
        XCTAssertEqual(RingSeparation(720)?.degrees, 0)
    }

    func testSupplementClosureMatchesTheAdmittedMarkSet() {
        XCTAssertEqual(Ring.supplement(of: .conjunction), .opposition)
        XCTAssertEqual(Ring.supplement(of: .semisextile), .quincunx)
        XCTAssertEqual(Ring.supplement(of: .semisquare), .sesquiquadrate)
        XCTAssertEqual(Ring.supplement(of: .sextile), .trine)
        XCTAssertEqual(Ring.supplement(of: .square), .square)
        XCTAssertNil(Ring.supplement(of: .quintile))
        XCTAssertNil(Ring.supplement(of: .biquintile))
        XCTAssertEqual(Ring.supplement(of: .opposition), .conjunction)
    }

    func testNativeTypesRejectMalformedAddressesBeforeRingReads() {
        XCTAssertNil(RingState(-1))
        XCTAssertNil(RingState(720))
        XCTAssertNotNil(RingState(719))
        XCTAssertNil(RingFineState(-1))
        XCTAssertNil(RingFineState(Ring.fineStates))
        XCTAssertNotNil(RingFineState(Ring.fineStates - 1))
        XCTAssertNil(RingSeparation(.nan))
        XCTAssertNil(RingSeparation(.infinity))
        XCTAssertNil(RingSeparation(-.infinity))
        XCTAssertNil(RingMark(rawValue: 999))
    }

    func testStampedAuthorityIsImmutableByValueAndRowsCannotMutateIt() {
        var markCopy = Ring.marks
        markCopy.append(.conjunction)
        XCTAssertEqual(Ring.marks.count, 11)
        XCTAssertEqual(markCopy.count, 12)
        let state = RingState(1)!
        var row = Ring.row(for: state)
        XCTAssertEqual(row.count, 11)
        row.removeAll()
        XCTAssertTrue(row.isEmpty)
        XCTAssertEqual(Ring.row(for: state).count, 11)
        XCTAssertEqual(Ring.targetDegree(from: RingState(0)!, mark: .conjunction, direction: .plus), 0)
    }

    func testTwoMoonDoctrineExampleRemainsUnchanged() {
        let moonA = CelestialLongitude(277)!
        let moonB = CelestialLongitude(33)!
        let separation = Ring.separation(from: moonB, to: moonA)
        XCTAssertEqual(Ring.arc(of: separation), 116)
        XCTAssertEqual(Ring.nearest(to: separation).mark, .trine)
        XCTAssertEqual(Ring.nearest(to: separation).residual, 4)
        let fiftyEight = Ring.nearest(to: RingSeparation(58)!)
        let oneTwentyTwo = Ring.nearest(to: RingSeparation(122)!)
        XCTAssertEqual(fiftyEight.mark, .sextile)
        XCTAssertEqual(fiftyEight.residual, 2)
        XCTAssertEqual(oneTwentyTwo.mark, .trine)
        XCTAssertEqual(oneTwentyTwo.residual, 2)
        XCTAssertEqual(Ring.supplement(of: .sextile), .trine)
    }
}
