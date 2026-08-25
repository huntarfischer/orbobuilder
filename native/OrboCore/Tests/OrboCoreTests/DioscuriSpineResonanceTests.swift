import XCTest
@testable import OrboCore

final class DioscuriSpineResonanceTests: XCTestCase {
    func testE1NamesDioscuriAsTheResonanceAuthority() {
        XCTAssertEqual(DioscuriResonanceAuthority.authorityRole, "resonance authority")
    }

    func testE1FormsAssignmentFromMatchingSchematicAndCandidate() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))
        let authority = "Swiss Ephemeris / DE441"
        let sourceVersion = "2.10.03"
        let candidate = try XCTUnwrap(makeRuntime(
            bone: bone,
            authority: authority,
            sourceVersion: sourceVersion
        ))
        let schematic = try XCTUnwrap(makeSchematic(
            identity: OrboSpineContract.identity,
            bone: bone,
            authority: authority,
            sourceVersion: sourceVersion
        ))

        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: schematic,
            candidate: candidate
        ))

        XCTAssertEqual(assignment.schematic.identity, OrboSpineContract.identity)
        XCTAssertEqual(assignment.schematic.version, 1)
        XCTAssertEqual(
            assignment.candidateIdentity,
            String(repeating: "a", count: 64)
        )
    }

    func testE1FailsClosedWhenSchematicDoesNotMatchCandidate() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))
        let authority = "Swiss Ephemeris / DE441"
        let sourceVersion = "2.10.03"
        let candidate = try XCTUnwrap(makeRuntime(
            bone: bone,
            authority: authority,
            sourceVersion: sourceVersion
        ))

        let wrongIdentity = try XCTUnwrap(makeSchematic(
            identity: "NotOrboSpine",
            bone: bone,
            authority: authority,
            sourceVersion: sourceVersion
        ))
        XCTAssertNil(SpineResonanceAssignment(
            schematic: wrongIdentity,
            candidate: candidate
        ))

        let wrongBone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_003)!
        ))
        let wrongBoneSchematic = try XCTUnwrap(makeSchematic(
            identity: OrboSpineContract.identity,
            bone: wrongBone,
            authority: authority,
            sourceVersion: sourceVersion
        ))
        XCTAssertNil(SpineResonanceAssignment(
            schematic: wrongBoneSchematic,
            candidate: candidate
        ))

        let wrongAuthority = try XCTUnwrap(makeSchematic(
            identity: OrboSpineContract.identity,
            bone: bone,
            authority: "Other authority",
            sourceVersion: sourceVersion
        ))
        XCTAssertNil(SpineResonanceAssignment(
            schematic: wrongAuthority,
            candidate: candidate
        ))

        let wrongSourceVersion = try XCTUnwrap(makeSchematic(
            identity: OrboSpineContract.identity,
            bone: bone,
            authority: authority,
            sourceVersion: "other-version"
        ))
        XCTAssertNil(SpineResonanceAssignment(
            schematic: wrongSourceVersion,
            candidate: candidate
        ))
    }

    func testE2DirectMotionResonates() throws {
        let fixture = try makeE2Fixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let challenge = try XCTUnwrap(SpineCelestialChallenge(
            body: .sun,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10,
                motion: .direct
            ))
        ))

        XCTAssertEqual(
            try assignment.resonate(challenge, celestialProduct: fixture.celestialProduct),
            .confirmed
        )
    }

    func testE2RetrogradeMotionResonates() throws {
        let fixture = try makeE2Fixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let challenge = try XCTUnwrap(SpineCelestialChallenge(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10,
                motion: .retrograde
            ))
        ))

        XCTAssertEqual(
            try assignment.resonate(challenge, celestialProduct: fixture.celestialProduct),
            .confirmed
        )
    }

    func testE2DeliberateDivergenceIsReported() throws {
        let fixture = try makeE2Fixture(candidateMercuryRetrogradePhysicalDegrees: 10.25)
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let challenge = try XCTUnwrap(SpineCelestialChallenge(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10,
                motion: .retrograde
            ))
        ))

        let result = try assignment.resonate(challenge, celestialProduct: fixture.celestialProduct)
        guard case let .divergent(expected, returned) = result else {
            return XCTFail("Expected deliberate E2 divergence.")
        }

        XCTAssertEqual(expected.directionalDegree.degrees, 370, accuracy: 1e-12)
        XCTAssertEqual(returned.directionalDegree.degrees, 370.25, accuracy: 1e-12)
        XCTAssertEqual(expected.julianDay, returned.julianDay)
    }

    func testE2DivergenceIsPreservedWithoutCorrection() throws {
        let fixture = try makeE2Fixture(candidateMercuryRetrogradePhysicalDegrees: 10.25)
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let challenge = try XCTUnwrap(SpineCelestialChallenge(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10,
                motion: .retrograde
            ))
        ))

        let result = try assignment.resonate(challenge, celestialProduct: fixture.celestialProduct)
        guard case let .divergent(expected, returned) = result else {
            return XCTFail("Expected preserved E2 divergence.")
        }

        let candidateTruth = try fixture.candidate.locate.coordinate(
            of: .mercury,
            at: returned.julianDay
        )
        XCTAssertEqual(expected.directionalDegree.degrees, 370, accuracy: 1e-12)
        XCTAssertEqual(returned.directionalDegree.degrees, 370.25, accuracy: 1e-12)
        XCTAssertEqual(candidateTruth, returned)
    }

    func testE3DirectInteriorResonates() throws {
        let fixture = try makeE2Fixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let challenge = try XCTUnwrap(SpineCelestialChallenge(
            body: .sun,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 15,
                motion: .direct
            ))
        ))

        let expected = try XCTUnwrap(PolluxResonator.ask(
            challenge,
            from: fixture.celestialProduct
        ))
        XCTAssertEqual(expected.julianDay.value, 1_000.5, accuracy: 1e-12)
        XCTAssertEqual(
            try assignment.resonate(challenge, celestialProduct: fixture.celestialProduct),
            .confirmed
        )
    }

    func testE3RetrogradeInteriorResonates() throws {
        let fixture = try makeE2Fixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let challenge = try XCTUnwrap(SpineCelestialChallenge(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10.5,
                motion: .retrograde
            ))
        ))

        let expected = try XCTUnwrap(PolluxResonator.ask(
            challenge,
            from: fixture.celestialProduct
        ))
        XCTAssertEqual(expected.julianDay.value, 1_000.875, accuracy: 1e-12)
        XCTAssertEqual(
            try assignment.resonate(challenge, celestialProduct: fixture.celestialProduct),
            .confirmed
        )
    }

    func testE3StationResonates() throws {
        let fixture = try makeE2Fixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let challenge = try XCTUnwrap(SpineStationChallenge(body: .mercury))

        let expected = try XCTUnwrap(PolluxResonator.ask(
            challenge,
            from: fixture.celestialProduct
        ))
        XCTAssertEqual(expected.julianDay.value, 1_000.5, accuracy: 1e-12)
        XCTAssertEqual(expected.directionalDegree.degrees, 372, accuracy: 1e-12)
        XCTAssertEqual(
            try assignment.resonate(challenge, celestialProduct: fixture.celestialProduct),
            .confirmed
        )
    }

    func testE4CampaignRepresentsEveryBodyAndPresentMotionClasses() throws {
        let fixture = try makeE2Fixture()
        let challenges = try SpineResonanceRun.campaign(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct
        )

        XCTAssertEqual(Set(challenges.map(\.body)), Set(MundaneBody.canonicalOrder))

        let mercuryCelestial = challenges.compactMap { challenge -> SpineCelestialChallenge? in
            guard case let .celestial(value) = challenge, value.body == .mercury else { return nil }
            return value
        }
        XCTAssertTrue(mercuryCelestial.contains {
            $0.directionalDegree.motion == .direct
        })
        XCTAssertTrue(mercuryCelestial.contains {
            $0.directionalDegree.motion == .retrograde
        })

        let mercuryStations = challenges.compactMap { challenge -> SpineStationChallenge? in
            guard case let .station(value) = challenge, value.body == .mercury else { return nil }
            return value
        }
        XCTAssertEqual(mercuryStations.map(\.occurrenceIndex), [0])
    }

    func testE4StationDirectionsChooseNearestOccurrenceToBoneMidpoint() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_010)!
        ))
        let stations = [
            station(.mercury, 11, .direct, .retrograde, 1_001),
            station(.mercury, 12, .retrograde, .direct, 1_004),
            station(.mercury, 13, .direct, .retrograde, 1_006),
            station(.mercury, 14, .retrograde, .direct, 1_009),
        ]
        let bodyProduct = SpineForgeBodyProduct(
            body: .mercury,
            supportDegrees: OrboSpineContract.supportDegrees(for: .mercury),
            supports: [
                coordinate(.mercury, 10, .direct, 1_000),
                coordinate(.mercury, 11, .direct, 1_001),
            ],
            stations: stations
        )

        let directToRetrograde = try XCTUnwrap(
            SpineResonanceRun.selectedStationChallenge(
                laneBefore: .direct,
                laneAfter: .retrograde,
                in: bodyProduct,
                bone: bone
            )
        )
        let retrogradeToDirect = try XCTUnwrap(
            SpineResonanceRun.selectedStationChallenge(
                laneBefore: .retrograde,
                laneAfter: .direct,
                in: bodyProduct,
                bone: bone
            )
        )

        XCTAssertEqual(directToRetrograde.occurrenceIndex, 2)
        XCTAssertEqual(retrogradeToDirect.occurrenceIndex, 1)
    }

    func testE4MidpointSelectionPreservesRepeatedOccurrenceIndex() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_006)!
        ))
        let bodyProduct = SpineForgeBodyProduct(
            body: .mercury,
            supportDegrees: OrboSpineContract.supportDegrees(for: .mercury),
            supports: [
                coordinate(.mercury, 10, .direct, 1_000),
                coordinate(.mercury, 11, .direct, 1_001),
                coordinate(.mercury, 11, .retrograde, 1_002),
                coordinate(.mercury, 10, .retrograde, 1_003),
                coordinate(.mercury, 10, .direct, 1_004),
                coordinate(.mercury, 11, .direct, 1_005),
            ],
            stations: [
                station(.mercury, 11.5, .direct, .retrograde, 1_001.5),
                station(.mercury, 9.5, .retrograde, .direct, 1_003.5),
            ]
        )

        let challenge = try XCTUnwrap(
            SpineResonanceRun.selectedInteriorChallenge(
                for: .direct,
                in: bodyProduct,
                bone: bone
            )
        )

        XCTAssertEqual(challenge.directionalDegree.physicalDegrees, 10.5, accuracy: 1e-12)
        XCTAssertEqual(challenge.occurrenceIndex, 1)
        let occurrences = PolluxResonator.occurrences(
            of: challenge.directionalDegree,
            in: bodyProduct
        )
        XCTAssertEqual(occurrences.count, 2)
        XCTAssertEqual(occurrences[1].julianDay.value, 1_004.5, accuracy: 1e-12)
    }

    func testE4SelectsRetrogradeWrapSeam() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(999)!,
            end: JulianDay(1_003)!
        ))
        let bodyProduct = SpineForgeBodyProduct(
            body: .mercury,
            supportDegrees: OrboSpineContract.supportDegrees(for: .mercury),
            supports: [
                coordinate(.mercury, 1, .retrograde, 1_000),
                coordinate(.mercury, 0, .retrograde, 1_001),
                coordinate(.mercury, 359, .retrograde, 1_002),
            ],
            stations: []
        )
        let product = SpineForgeProduct(
            schematicIdentity: "fixture",
            schematicVersion: 1,
            astronomicalAuthority: "fixture sky",
            astronomicalSourceVersion: "1",
            bone: bone,
            bodies: [bodyProduct]
        )

        let challenge = try XCTUnwrap(
            SpineResonanceRun.selectedRetrogradeWrapChallenge(
                in: product,
                bone: bone
            )
        )

        XCTAssertEqual(challenge.body, .mercury)
        XCTAssertEqual(challenge.directionalDegree.motion, .retrograde)
        XCTAssertEqual(challenge.directionalDegree.physicalDegrees, 359.5, accuracy: 1e-12)
        XCTAssertEqual(challenge.occurrenceIndex, 0)
    }

    func testE4SuppliedSchematicBodyOrderDrivesCampaignAndRun() throws {
        let fixture = try makeE2Fixture()
        let reversedPlans = Array(fixture.schematic.bodyPlans.reversed())
        let schematic = try XCTUnwrap(SpineSchematic(
            identity: fixture.schematic.identity,
            version: fixture.schematic.version,
            bone: fixture.schematic.bone,
            astronomicalAuthority: fixture.schematic.astronomicalAuthority,
            astronomicalSourceVersion: fixture.schematic.astronomicalSourceVersion,
            bodyPlans: reversedPlans
        ))
        let byBody = Dictionary(uniqueKeysWithValues: fixture.celestialProduct.bodies.map { ($0.body, $0) })
        let bodies = try reversedPlans.map { try XCTUnwrap(byBody[$0.body]) }
        let celestialProduct = SpineForgeProduct(
            schematicIdentity: schematic.identity,
            schematicVersion: schematic.version,
            astronomicalAuthority: schematic.astronomicalAuthority,
            astronomicalSourceVersion: schematic.astronomicalSourceVersion,
            bone: schematic.bone,
            bodies: bodies
        )
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: schematic,
            candidate: fixture.candidate
        ))

        let challenges = try SpineResonanceRun.campaign(
            schematic: schematic,
            celestialProduct: celestialProduct
        )
        var observedBodyOrder: [MundaneBody] = []
        for challenge in challenges where observedBodyOrder.last != challenge.body {
            observedBodyOrder.append(challenge.body)
        }

        let testimony = try SpineResonanceRun.run(
            schematic: schematic,
            celestialProduct: celestialProduct,
            assignment: assignment
        )

        XCTAssertEqual(observedBodyOrder, reversedPlans.map(\.body))
        XCTAssertEqual(testimony.result, .confirmed)
    }

    func testE4ProductSchematicMismatchFailsClosed() throws {
        let fixture = try makeE2Fixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        var bodies = fixture.celestialProduct.bodies
        let first = bodies[0]
        bodies[0] = SpineForgeBodyProduct(
            body: first.body,
            supportDegrees: first.supportDegrees + 0.5,
            supports: first.supports,
            stations: first.stations
        )
        let celestialProduct = SpineForgeProduct(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            astronomicalAuthority: fixture.schematic.astronomicalAuthority,
            astronomicalSourceVersion: fixture.schematic.astronomicalSourceVersion,
            bone: fixture.schematic.bone,
            bodies: bodies
        )

        XCTAssertThrowsError(
            try SpineResonanceRun.run(
                schematic: fixture.schematic,
                celestialProduct: celestialProduct,
                assignment: assignment
            )
        ) { error in
            XCTAssertEqual(error as? SpineResonanceRunError, .productMismatch)
        }
    }

    func testE4FirstDivergenceStopsRunAndPreservesBothAnswers() throws {
        let fixture = try makeE2Fixture()
        var candidateSupports = fixture.celestialProduct.bodies.flatMap(\.supports)
        let sunUpperIndex = try XCTUnwrap(candidateSupports.firstIndex {
            $0.body == .sun && abs($0.julianDay.value - 1_001) < 1e-12
        })
        candidateSupports[sunUpperIndex] = coordinate(.sun, 19, .direct, 1_001)
        let stations = fixture.celestialProduct.bodies.flatMap(\.stations)
        let candidate = try XCTUnwrap(makeRuntime(
            bone: fixture.schematic.bone,
            authority: fixture.schematic.astronomicalAuthority,
            sourceVersion: fixture.schematic.astronomicalSourceVersion,
            supports: candidateSupports,
            stations: stations
        ))
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: candidate
        ))

        var bodies = fixture.celestialProduct.bodies
        let moonIndex = try XCTUnwrap(bodies.firstIndex { $0.body == .moon })
        let moon = bodies[moonIndex]
        bodies[moonIndex] = SpineForgeBodyProduct(
            body: moon.body,
            supportDegrees: moon.supportDegrees,
            supports: [],
            stations: moon.stations
        )
        let celestialProduct = SpineForgeProduct(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            astronomicalAuthority: fixture.schematic.astronomicalAuthority,
            astronomicalSourceVersion: fixture.schematic.astronomicalSourceVersion,
            bone: fixture.schematic.bone,
            bodies: bodies
        )

        let testimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: celestialProduct,
            assignment: assignment
        )
        guard case let .divergent(body, expected, returned) = testimony.result else {
            return XCTFail("Expected first E4 divergence.")
        }

        XCTAssertEqual(body, .sun)
        XCTAssertEqual(expected.directionalDegree.degrees, 15, accuracy: 1e-12)
        XCTAssertEqual(returned.directionalDegree.degrees, 14.5, accuracy: 1e-12)
        XCTAssertEqual(expected.julianDay, returned.julianDay)
    }

    func testE4IdenticalInputsProduceIdenticalCampaignAndTestimony() throws {
        let fixture = try makeE2Fixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))

        let firstCampaign = try SpineResonanceRun.campaign(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct
        )
        let secondCampaign = try SpineResonanceRun.campaign(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct
        )
        let first = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct,
            assignment: assignment
        )
        let second = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct,
            assignment: assignment
        )

        XCTAssertEqual(firstCampaign, secondCampaign)
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.schematicIdentity, fixture.schematic.identity)
        XCTAssertEqual(first.schematicVersion, fixture.schematic.version)
        XCTAssertEqual(first.candidateIdentity, assignment.candidateIdentity)
        XCTAssertEqual(first.result, .confirmed)
    }

    private struct E2Fixture {
        let schematic: SpineSchematic
        let celestialProduct: SpineForgeProduct
        let candidate: OrboSpineRuntime
    }

    private func makeE2Fixture(
        candidateMercuryRetrogradePhysicalDegrees: Double = 10
    ) throws -> E2Fixture {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))
        let authority = "Swiss Ephemeris / DE441"
        let sourceVersion = "2.10.03"
        let schematic = try XCTUnwrap(makeSchematic(
            identity: OrboSpineContract.identity,
            bone: bone,
            authority: authority,
            sourceVersion: sourceVersion
        ))
        let station = try XCTUnwrap(OrboSpineStation(
            body: .mercury,
            physicalDegrees: 12,
            julianDay: JulianDay(1_000.5)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))

        var forgedBodies: [SpineForgeBodyProduct] = []
        var candidateSupports: [OrboSpineCelestialCoordinate] = []

        for body in MundaneBody.canonicalOrder {
            let supportDegrees = OrboSpineContract.supportDegrees(for: body)
            if body == .mercury {
                let directSupports = [
                    coordinate(body, 10, .direct, 1_000),
                    coordinate(body, 11, .direct, 1_000.25),
                ]
                let forgedRetrogradeSupports = [
                    coordinate(body, 11, .retrograde, 1_000.75),
                    coordinate(body, 10, .retrograde, 1_001),
                    coordinate(body, 9, .retrograde, 1_001.25),
                    coordinate(body, 8, .retrograde, 1_001.5),
                    coordinate(body, 7, .retrograde, 1_001.75),
                ]
                let offset = candidateMercuryRetrogradePhysicalDegrees - 10
                let candidateRetrogradeSupports = [
                    coordinate(body, 11 + offset, .retrograde, 1_000.75),
                    coordinate(body, 10 + offset, .retrograde, 1_001),
                    coordinate(body, 9 + offset, .retrograde, 1_001.25),
                    coordinate(body, 8 + offset, .retrograde, 1_001.5),
                    coordinate(body, 7 + offset, .retrograde, 1_001.75),
                ]
                forgedBodies.append(SpineForgeBodyProduct(
                    body: body,
                    supportDegrees: supportDegrees,
                    supports: directSupports + forgedRetrogradeSupports,
                    stations: [station]
                ))
                candidateSupports.append(contentsOf: directSupports + candidateRetrogradeSupports)
            } else {
                let start = coordinate(body, 10, .direct, 1_000)
                let next = coordinate(body, 10 + supportDegrees, .direct, 1_001)
                forgedBodies.append(SpineForgeBodyProduct(
                    body: body,
                    supportDegrees: supportDegrees,
                    supports: [start, next],
                    stations: []
                ))
                candidateSupports.append(contentsOf: [start, next])
            }
        }

        let celestialProduct = SpineForgeProduct(
            schematicIdentity: schematic.identity,
            schematicVersion: schematic.version,
            astronomicalAuthority: schematic.astronomicalAuthority,
            astronomicalSourceVersion: schematic.astronomicalSourceVersion,
            bone: schematic.bone,
            bodies: forgedBodies
        )
        let candidate = try XCTUnwrap(makeRuntime(
            bone: bone,
            authority: authority,
            sourceVersion: sourceVersion,
            supports: candidateSupports,
            stations: [station]
        ))

        return E2Fixture(
            schematic: schematic,
            celestialProduct: celestialProduct,
            candidate: candidate
        )
    }

    private func makeSchematic(
        identity: String,
        bone: OrboSpineBoneSpan,
        authority: String,
        sourceVersion: String
    ) -> SpineSchematic? {
        let plans = MundaneBody.canonicalOrder.map { body in
            SpineSchematicBodyPlan(
                body: body,
                supportDegrees: OrboSpineContract.supportDegrees(for: body),
                scanStepDays: 1
            )!
        }
        return SpineSchematic(
            identity: identity,
            version: 1,
            bone: bone,
            astronomicalAuthority: authority,
            astronomicalSourceVersion: sourceVersion,
            bodyPlans: plans
        )
    }

    private func makeRuntime(
        bone: OrboSpineBoneSpan,
        authority: String,
        sourceVersion: String,
        supports suppliedSupports: [OrboSpineCelestialCoordinate]? = nil,
        stations: [OrboSpineStation] = []
    ) throws -> OrboSpineRuntime? {
        let supports: [OrboSpineCelestialCoordinate]
        if let suppliedSupports {
            supports = suppliedSupports
        } else {
            var built: [OrboSpineCelestialCoordinate] = []
            for body in MundaneBody.canonicalOrder {
                let step = OrboSpineContract.supportDegrees(for: body)
                built.append(coordinate(body, 10, .direct, 1_000))
                built.append(coordinate(body, 10 + step, .direct, 1_001))
            }
            supports = built
        }

        let shells = try OrboSpineShellFamily.allCases.map { family in
            let id = try XCTUnwrap(OrboSpineShellID(family: family, ordinal: 1))
            return try XCTUnwrap(OrboSpineShellInterval(
                id: id,
                start: JulianDay(999)!,
                end: JulianDay(1_003)!
            ))
        }
        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: JulianDay(1_000)!
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110,
                tiltDegrees: 23.5,
                julianDay: JulianDay(1_002)!
            )),
        ]
        let provenance = try XCTUnwrap(OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "a", count: 64),
            astronomicalAuthority: authority,
            astronomicalSourceVersion: sourceVersion
        ))

        return OrboSpineRuntime(
            bone: bone,
            celestialSupports: supports,
            stations: stations,
            retrogradePassages: [],
            ringOccurrences: [],
            eclipses: [],
            shellIntervals: shells,
            terraSamples: terra,
            provenance: provenance
        )
    }

    private func coordinate(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        _ motion: Motion,
        _ julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }

    private func station(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        _ laneBefore: Motion,
        _ laneAfter: Motion,
        _ julianDay: Double
    ) -> OrboSpineStation {
        OrboSpineStation(
            body: body,
            physicalDegrees: physicalDegrees,
            julianDay: JulianDay(julianDay)!,
            laneBefore: laneBefore,
            laneAfter: laneAfter
        )!
    }
}
