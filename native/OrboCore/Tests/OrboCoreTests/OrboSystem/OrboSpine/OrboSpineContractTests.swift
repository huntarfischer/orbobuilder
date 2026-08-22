import XCTest
@testable import OrboCore

final class OrboSpineContractTests: XCTestCase {
    func testCanonicalElevenAndSupportLaw() {
        XCTAssertEqual(OrboSpineContract.identity, "OrboSpine")
        XCTAssertEqual(OrboSpineContract.canonicalBodies, MundaneBody.canonicalOrder)
        XCTAssertEqual(OrboSpineContract.canonicalBodies.count, 11)

        let expected: [MundaneBody: Double] = [
            .sun: 10, .moon: 10, .mercury: 1, .venus: 1, .mars: 1,
            .jupiter: 0.5, .saturn: 0.5, .uranus: 0.2,
            .neptune: 0.1, .pluto: 0.1, .trueNorthNode: 0.1,
        ]
        XCTAssertEqual(OrboSpineContract.celestialSupportDegrees, expected)
    }

    func testDirectionalDegreePreservesDecimalLaneAndCell() throws {
        let direct = try XCTUnwrap(OrboSpineDirectionalDegree(19.372))
        XCTAssertEqual(direct.physicalDegrees, 19.372, accuracy: 1e-12)
        XCTAssertEqual(direct.motion, .direct)
        XCTAssertEqual(direct.navigationCell, 19)

        let retrograde = try XCTUnwrap(OrboSpineDirectionalDegree(physicalDegrees: 19.372, motion: .retrograde))
        XCTAssertEqual(retrograde.degrees, 379.372, accuracy: 1e-12)
        XCTAssertEqual(retrograde.physicalDegrees, 19.372, accuracy: 1e-12)
        XCTAssertEqual(retrograde.motion, .retrograde)
        XCTAssertEqual(retrograde.navigationCell, 379)

        XCTAssertNil(OrboSpineDirectionalDegree(-0.001))
        XCTAssertNil(OrboSpineDirectionalDegree(720))
        XCTAssertNil(OrboSpineDirectionalDegree(.nan))
    }

    func testBoneAndReachAreHalfOpenAndMonotonic() throws {
        let start = JulianDay(100)!
        let end = JulianDay(101)!
        let span = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        XCTAssertTrue(span.contains(start))
        XCTAssertFalse(span.contains(end))
        XCTAssertNil(OrboSpineBoneSpan(start: end, end: start))

        let d1 = try XCTUnwrap(OrboSpineDirectionalDegree(379.9))
        let d2 = try XCTUnwrap(OrboSpineDirectionalDegree(378.1))
        let reach = try XCTUnwrap(OrboSpineReach(
            body: .mercury,
            startDirectionalDegree: d1,
            endDirectionalDegree: d2,
            start: start,
            end: end
        ))
        XCTAssertEqual(reach.motion, .retrograde)
        XCTAssertTrue(reach.contains(start))
        XCTAssertFalse(reach.contains(end))
    }

    func testStationBelongsToLaneEnteredAfter() throws {
        let station = try XCTUnwrap(OrboSpineStation(
            body: .pluto,
            physicalDegrees: 19.372,
            julianDay: JulianDay(200)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))
        XCTAssertEqual(station.directionalDegreeAfter.degrees, 379.372, accuracy: 1e-12)
        XCTAssertEqual(station.navigationCellAfter, 379)
        XCTAssertNil(OrboSpineStation(
            body: .pluto,
            physicalDegrees: 19,
            julianDay: JulianDay(200)!,
            laneBefore: .direct,
            laneAfter: .direct
        ))
    }

    func testTerraMarrowIsUniversalTwoFieldOrientationAtUT() throws {
        XCTAssertEqual(TerraMarrowContract.supportIntervalSeconds, 21_600)
        XCTAssertEqual(TerraMarrowContract.refinementLaw, .linear)
        XCTAssertEqual(TerraMarrowContract.sourceModelSeamYears, [1850, 2050])

        let sample = try XCTUnwrap(TerraMarrowSample(
            turnDegrees: 123.456,
            tiltDegrees: 23.44,
            julianDay: JulianDay(2_451_545)!
        ))
        XCTAssertEqual(sample.turnDegrees, 123.456, accuracy: 1e-12)
        XCTAssertEqual(sample.tiltDegrees, 23.44, accuracy: 1e-12)
        XCTAssertNil(TerraMarrowSample(turnDegrees: 360, tiltDegrees: 23.4, julianDay: JulianDay(1)!))
    }

    func testRingOccurrenceIsOnlyAnOccurrenceSeam() throws {
        let a = try XCTUnwrap(OrboSpineDirectionalDegree(10.25))
        let b = try XCTUnwrap(OrboSpineDirectionalDegree(130.25))
        XCTAssertNotNil(OrboSpineRingOccurrence(
            bodyA: .sun,
            bodyB: .jupiter,
            mark: .trine,
            bodyADirectionalDegree: a,
            bodyBDirectionalDegree: b,
            julianDay: JulianDay(300)!
        ))
        XCTAssertNil(OrboSpineRingOccurrence(
            bodyA: .sun,
            bodyB: .sun,
            mark: .conjunction,
            bodyADirectionalDegree: a,
            bodyBDirectionalDegree: a,
            julianDay: JulianDay(300)!
        ))
    }

    func testShellTypesPreserveIndependentFamiliesAndFRWZAddress() throws {
        let f = try XCTUnwrap(OrboSpineShellID(family: .frame, ordinal: 181))
        let r = try XCTUnwrap(OrboSpineShellID(family: .revolt, ordinal: 63))
        let w = try XCTUnwrap(OrboSpineShellID(family: .wave, ordinal: 31))
        let z = try XCTUnwrap(OrboSpineShellID(family: .zeitgeist, ordinal: 22))
        let address = try XCTUnwrap(OrboSpineShellAddress(frame: f, revolt: r, wave: w, zeitgeist: z))
        XCTAssertEqual(address.description, "F181.R63.W31.Z22")

        let interval = try XCTUnwrap(OrboSpineShellInterval(id: z, start: JulianDay(10)!, end: JulianDay(20)!))
        XCTAssertTrue(interval.contains(JulianDay(10)!))
        XCTAssertFalse(interval.contains(JulianDay(20)!))
    }

    func testCelestialSmeldIntentDoesNotBroadenCanonicalEleven() {
        XCTAssertEqual(OrboSpineCelestialSmeldIntent.firstSmeld, [.trueBlackMoonLilith, .chiron])
        XCTAssertEqual(MundaneBody.allCases.count, 11)
    }

    func testEverySpineHasExactlyLocateLibraryAndLink() {
        XCTAssertEqual(SpineAccessPort.allCases, [.locate, .library, .link])
        let ports = OrboSpinePorts()
        XCTAssertEqual(ports.locate, .locate)
        XCTAssertEqual(ports.library, .library)
        XCTAssertEqual(ports.link, .link)
    }

    func testSmeldSeamsAreExactlyCelestialAndStackWithZeroOrOneEach() throws {
        XCTAssertEqual(SpineSmeldSeam.allCases, [.celestial, .stack])
        XCTAssertEqual(SpineSmeldContract.maximumMountedPerSeam, 1)
        XCTAssertEqual(SpineSmeldContract.forgeAuthority, "Hephaestus")
        XCTAssertEqual(SpineSmeldContract.certificationAuthority, "Dioscuri")
        XCTAssertEqual(SpineSmeldContract.sealAuthority, "Hephaestus")
        XCTAssertTrue(SpineSmeldContract.requiresSealBeforeMount)
        XCTAssertEqual(SpineSmeldContract.replacementLaw, "reforge-and-replace")

        let empty = SpineSmeldSeams()
        XCTAssertNil(empty.celestial)
        XCTAssertNil(empty.stack)

        let celestial = try XCTUnwrap(SpineSmeld(identity: "celestial-smeld-v1"))
        let stack = try XCTUnwrap(SpineSmeld(identity: "stack-smeld-v1"))
        let mounted = SpineSmeldSeams(celestial: celestial, stack: stack)
        XCTAssertEqual(mounted.celestial, celestial)
        XCTAssertEqual(mounted.stack, stack)
        XCTAssertNil(SpineSmeld(identity: "   "))
    }

    func testLifecycleBoundaryAndAstroDNAIsolation() {
        XCTAssertEqual(OrboSpineLifecycleBoundary.allCases, [
            .candidate, .dioscuriCertified, .hephaestusSealed, .maintenanceResonance,
        ])
        XCTAssertEqual(Set(OrboSpineResonanceDisposition.allCases), [
            .resonance, .safeNonResonance, .falseResonance,
        ])
        XCTAssertEqual(AstroDNA.codec, 4)
    }
}
