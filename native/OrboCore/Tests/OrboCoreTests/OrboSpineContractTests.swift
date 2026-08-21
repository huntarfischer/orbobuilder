import XCTest
@testable import OrboCore

final class OrboSpineContractTests: XCTestCase {
    private struct LinearForgeReference: ForgeEphemerisReference {
        let origin: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
            MundaneForgeState(
                longitudeDegrees: julianDay.value - origin,
                longitudinalSpeedDegreesPerDay: 1
            )!
        }
    }

    private struct ConstantPlutoReference: ForgeEphemerisReference {
        let longitude: Double
        let speed: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
            MundaneForgeState(
                longitudeDegrees: longitude,
                longitudinalSpeedDegreesPerDay: speed
            )!
        }
    }

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

    func testAuxiliarySocketDoesNotBroadenCanonicalEleven() {
        _ = OrboSpineAuxiliarySocket()
        XCTAssertEqual(OrboSpineAuxiliaryIntent.firstPack, [.trueBlackMoonLilith, .chiron])
        XCTAssertEqual(MundaneBody.allCases.count, 11)
    }

    func testExactlyThreeNeutralPortTypesExist() {
        let ports = OrboSpinePorts()
        XCTAssertEqual(ports.chronos, ChronosPort())
        XCTAssertEqual(ports.horae, HoraePort())
        XCTAssertEqual(ports.clotho, ClothoPort())
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

    func testForgeAcceptsEveryFinalOrboSpineSupportGrid() throws {
        let start = JulianDay(10_000)!
        let end = JulianDay(10_040)!
        let reference = LinearForgeReference(origin: start.value)
        let supports: [(Double, Int)] = [
            (10, 4),
            (1, 40),
            (0.5, 80),
            (0.2, 200),
            (0.1, 400),
        ]

        for (resolution, expectedCount) in supports {
            let contract = try XCTUnwrap(MundaneTimespineBodyContract(
                body: .sun,
                celestialResolutionDegrees: resolution,
                markerBodies: [],
                constructionRecordCount: expectedCount
            ))
            let bodyPlan = try XCTUnwrap(MundaneTimespineForgeBodyPlan(
                contract: contract,
                scanStepDays: 0.25
            ))
            let plan = try XCTUnwrap(MundaneTimespineForgePlan(
                spanName: "OrboSpine support fixture",
                astronomicalSource: "deterministic XCTest sky",
                astronomicalSourceVersion: "1",
                supportedStart: start,
                supportedEnd: end,
                bodyPlans: [bodyPlan],
                verifiesConstructionRecordCounts: true,
                verifiesMarkerUniqueness: true
            ))

            let product = try MundaneTimespineForge.manufacture(plan: plan, reference: reference)
            let body = try XCTUnwrap(product.body(.sun))
            let last = try XCTUnwrap(body.occurrences.last)
            XCTAssertEqual(body.occurrences.count, expectedCount, "support \(resolution)")
            XCTAssertEqual(body.occurrences.first?.focalCelestialTick, 0, "support \(resolution)")
            XCTAssertEqual(last.focalCelestialTick, expectedCount - 1, "support \(resolution)")
            XCTAssertEqual(last.focalCelestialDegrees, Double(expectedCount - 1) * resolution, accuracy: 1e-12)
        }
    }

    func testForgeRejectsGridThatDoesNotPartitionCircle() throws {
        let start = JulianDay(20_000)!
        let end = JulianDay(20_010)!
        let contract = try XCTUnwrap(MundaneTimespineBodyContract(
            body: .sun,
            celestialResolutionDegrees: 7,
            markerBodies: [],
            constructionRecordCount: 2
        ))
        let bodyPlan = try XCTUnwrap(MundaneTimespineForgeBodyPlan(
            contract: contract,
            scanStepDays: 0.25
        ))
        let plan = try XCTUnwrap(MundaneTimespineForgePlan(
            spanName: "invalid support fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodyPlans: [bodyPlan]
        ))

        XCTAssertThrowsError(
            try MundaneTimespineForge.manufacture(
                plan: plan,
                reference: LinearForgeReference(origin: start.value)
            )
        ) { error in
            XCTAssertEqual(
                error as? MundaneTimespineForgeError,
                .unsupportedResolution(body: .sun, resolution: 7)
            )
        }
    }

    func testManufactureContractOwnsExactlyZ21ThroughZ23() {
        let spans = OrboSpineManufactureContract.zeitgeists
        XCTAssertEqual(spans.map { $0.shell.description }, ["Z21", "Z22", "Z23"])
        XCTAssertEqual(spans.count, 3)
        XCTAssertEqual(OrboSpineManufactureContract.supportedStart, spans[0].start)
        XCTAssertEqual(OrboSpineManufactureContract.supportedEnd, spans[2].end)
        XCTAssertEqual(spans[0].end, spans[1].start)
        XCTAssertEqual(spans[1].end, spans[2].start)
        XCTAssertEqual(spans[0].startUTC, "1577-05-05T05:46:50.976Z")
        XCTAssertEqual(spans[0].endUTC, "1822-04-16T13:54:20.135Z")
        XCTAssertEqual(spans[1].endUTC, "2066-06-17T15:24:10.695Z")
        XCTAssertEqual(spans[2].endUTC, "2311-06-10T14:16:12.881Z")
        XCTAssertEqual(OrboSpineManufactureContract.zeitgeistBoundaryJulianDays.count, 4)
    }

    func testManufactureContractUsesFrozenAuthorityAndElevenSupportLaw() {
        XCTAssertTrue(OrboSpineManufactureContract.astronomicalSource.contains("DE441"))
        XCTAssertEqual(OrboSpineManufactureContract.canonicalAstronomicalSourceVersion, "2.10.03")
        XCTAssertEqual(
            OrboSpineManufactureContract.celestialSupportDegrees,
            OrboSpineContract.celestialSupportDegrees
        )
        XCTAssertEqual(
            Set(OrboSpineManufactureContract.scanStepDays.keys),
            Set(MundaneBody.canonicalOrder)
        )
    }

    func testManufactureContractRequiresDirectPlutoZeroAriesAtAllFourFences() throws {
        XCTAssertNoThrow(
            try OrboSpineManufactureContract.validateZeitgeistBoundaries(
                reference: ConstantPlutoReference(longitude: 0, speed: 0.01)
            )
        )

        XCTAssertThrowsError(
            try OrboSpineManufactureContract.validateZeitgeistBoundaries(
                reference: ConstantPlutoReference(longitude: 1, speed: 0.01)
            )
        ) { error in
            XCTAssertEqual(error as? OrboSpineManufactureError, .zeitgeistBoundaryMismatch(21))
        }
    }
}
