import XCTest
@testable import OrboCore

final class DioscuriAdversarialTests: XCTestCase {
    func testF0BaselineAttackFixtureResonates() throws {
        let fixture = try makeBaselineFixture()

        let testimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct,
            assignment: fixture.assignment
        )

        XCTAssertEqual(testimony.schematicIdentity, fixture.schematic.identity)
        XCTAssertEqual(testimony.schematicVersion, fixture.schematic.version)
        XCTAssertEqual(testimony.candidateIdentity, fixture.assignment.candidateIdentity)
        XCTAssertEqual(testimony.result, .confirmed)
    }

    func testF1PolluxSideCorruptionProducesDivergence() throws {
        let fixture = try makeBaselineFixture()
        var bodies = fixture.celestialProduct.bodies
        let sunIndex = try XCTUnwrap(bodies.firstIndex { $0.body == .sun })
        let sun = bodies[sunIndex]
        bodies[sunIndex] = SpineForgeBodyProduct(
            body: sun.body,
            supportDegrees: sun.supportDegrees,
            supports: [
                coordinate(.sun, 10, .direct, 1_000),
                coordinate(.sun, 19, .direct, 1_001),
            ],
            stations: sun.stations
        )
        let corruptedProduct = SpineForgeProduct(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            astronomicalAuthority: fixture.schematic.astronomicalAuthority,
            astronomicalSourceVersion: fixture.schematic.astronomicalSourceVersion,
            bone: fixture.schematic.bone,
            bodies: bodies
        )

        let testimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: corruptedProduct,
            assignment: fixture.assignment
        )
        guard case let .divergent(body, expected, returned) = testimony.result else {
            return XCTFail("Expected Pollux-side corruption to diverge.")
        }

        XCTAssertEqual(body, .sun)
        XCTAssertEqual(expected.directionalDegree.degrees, 14.5, accuracy: 1e-12)
        XCTAssertEqual(returned.directionalDegree.degrees, 15, accuracy: 1e-12)
        XCTAssertEqual(expected.julianDay, returned.julianDay)
    }

    func testF1CastorSideCorruptionProducesDivergence() throws {
        let fixture = try makeBaselineFixture()
        var candidateSupports = fixture.celestialProduct.bodies.flatMap(\.supports)
        let sunUpperIndex = try XCTUnwrap(candidateSupports.firstIndex {
            $0.body == .sun && abs($0.julianDay.value - 1_001) < 1e-12
        })
        candidateSupports[sunUpperIndex] = coordinate(.sun, 19, .direct, 1_001)

        let corruptedCandidate = try XCTUnwrap(makeRuntime(
            bone: fixture.schematic.bone,
            authority: fixture.schematic.astronomicalAuthority,
            sourceVersion: fixture.schematic.astronomicalSourceVersion,
            supports: candidateSupports
        ))
        let corruptedAssignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: corruptedCandidate
        ))

        let testimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct,
            assignment: corruptedAssignment
        )
        guard case let .divergent(body, expected, returned) = testimony.result else {
            return XCTFail("Expected Castor-side corruption to diverge.")
        }

        XCTAssertEqual(body, .sun)
        XCTAssertEqual(expected.directionalDegree.degrees, 15, accuracy: 1e-12)
        XCTAssertEqual(returned.directionalDegree.degrees, 14.5, accuracy: 1e-12)
        XCTAssertEqual(expected.julianDay, returned.julianDay)
    }

    func testF2InteriorCorruptionBetweenMatchingEndpointsProducesDivergence() throws {
        let fixture = try makeBaselineFixture()
        var candidateSupports = fixture.celestialProduct.bodies.flatMap(\.supports)
        candidateSupports.removeAll { $0.body == .sun }
        candidateSupports.append(contentsOf: [
            coordinate(.sun, 10, .direct, 1_000),
            coordinate(.sun, 14, .direct, 1_000.5),
            coordinate(.sun, 20, .direct, 1_001),
            coordinate(.sun, 25, .direct, 1_001.5),
        ])

        let corruptedCandidate = try XCTUnwrap(makeRuntime(
            bone: fixture.schematic.bone,
            authority: fixture.schematic.astronomicalAuthority,
            sourceVersion: fixture.schematic.astronomicalSourceVersion,
            supports: candidateSupports
        ))
        let corruptedAssignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: corruptedCandidate
        ))

        let testimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: fixture.celestialProduct,
            assignment: corruptedAssignment
        )
        guard case let .divergent(body, expected, returned) = testimony.result else {
            return XCTFail("Expected interior corruption to diverge.")
        }

        XCTAssertEqual(body, .sun)
        XCTAssertEqual(expected.directionalDegree.degrees, 15, accuracy: 1e-12)
        XCTAssertEqual(returned.directionalDegree.degrees, 14, accuracy: 1e-12)
        XCTAssertEqual(expected.julianDay.value, 1_000.5, accuracy: 1e-12)
        XCTAssertEqual(expected.julianDay, returned.julianDay)
    }

    func testF2StationCorruptionProducesDivergence() throws {
        let fixture = try makeStationFixture()
        var bodies = fixture.celestialProduct.bodies
        let mercuryIndex = try XCTUnwrap(bodies.firstIndex { $0.body == .mercury })
        let mercury = bodies[mercuryIndex]
        let corruptedStation = try XCTUnwrap(OrboSpineStation(
            body: .mercury,
            physicalDegrees: 12.25,
            julianDay: JulianDay(1_000.5)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))
        bodies[mercuryIndex] = SpineForgeBodyProduct(
            body: mercury.body,
            supportDegrees: mercury.supportDegrees,
            supports: mercury.supports,
            stations: [corruptedStation]
        )
        let corruptedProduct = SpineForgeProduct(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            astronomicalAuthority: fixture.schematic.astronomicalAuthority,
            astronomicalSourceVersion: fixture.schematic.astronomicalSourceVersion,
            bone: fixture.schematic.bone,
            bodies: bodies
        )
        let challenge = try XCTUnwrap(SpineStationChallenge(body: .mercury))

        let result = try fixture.assignment.resonate(
            challenge,
            celestialProduct: corruptedProduct
        )
        guard case let .divergent(expected, returned) = result else {
            return XCTFail("Expected station corruption to diverge.")
        }

        XCTAssertEqual(expected.directionalDegree.degrees, 372.25, accuracy: 1e-12)
        XCTAssertEqual(returned.directionalDegree.degrees, 372, accuracy: 1e-12)
        XCTAssertEqual(expected.julianDay, returned.julianDay)
    }

    func testF2StationBetweenSupportsBlocksPolluxInterpolation() throws {
        let fixture = try makeBaselineFixture()
        let station = try XCTUnwrap(OrboSpineStation(
            body: .mercury,
            physicalDegrees: 10.5,
            julianDay: JulianDay(1_000.5)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))
        let bodyProduct = SpineForgeBodyProduct(
            body: .mercury,
            supportDegrees: OrboSpineContract.supportDegrees(for: .mercury),
            supports: [
                coordinate(.mercury, 10, .direct, 1_000),
                coordinate(.mercury, 11, .direct, 1_001),
            ],
            stations: [station]
        )
        let product = SpineForgeProduct(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            astronomicalAuthority: fixture.schematic.astronomicalAuthority,
            astronomicalSourceVersion: fixture.schematic.astronomicalSourceVersion,
            bone: fixture.schematic.bone,
            bodies: [bodyProduct]
        )
        let challenge = try XCTUnwrap(SpineCelestialChallenge(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10.5,
                motion: .direct
            ))
        ))

        XCTAssertNil(PolluxResonator.ask(challenge, from: product))
    }

    private struct AttackFixture {
        let schematic: SpineSchematic
        let celestialProduct: SpineForgeProduct
        let candidate: OrboSpineRuntime
        let assignment: SpineResonanceAssignment
    }

    private func makeBaselineFixture() throws -> AttackFixture {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))
        let authority = "Swiss Ephemeris / DE441"
        let sourceVersion = "2.10.03"

        let bodyPlans = MundaneBody.canonicalOrder.map { body in
            SpineSchematicBodyPlan(
                body: body,
                supportDegrees: OrboSpineContract.supportDegrees(for: body),
                scanStepDays: 1
            )!
        }
        let schematic = try XCTUnwrap(SpineSchematic(
            identity: OrboSpineContract.identity,
            version: 1,
            bone: bone,
            astronomicalAuthority: authority,
            astronomicalSourceVersion: sourceVersion,
            bodyPlans: bodyPlans
        ))

        var forgedBodies: [SpineForgeBodyProduct] = []
        var candidateSupports: [OrboSpineCelestialCoordinate] = []

        for bodyPlan in bodyPlans {
            let start = coordinate(bodyPlan.body, 10, .direct, 1_000)
            let next = coordinate(
                bodyPlan.body,
                10 + bodyPlan.supportDegrees,
                .direct,
                1_001
            )
            let supports = [start, next]
            forgedBodies.append(SpineForgeBodyProduct(
                body: bodyPlan.body,
                supportDegrees: bodyPlan.supportDegrees,
                supports: supports,
                stations: []
            ))
            candidateSupports.append(contentsOf: supports)
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
            supports: candidateSupports
        ))
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: schematic,
            candidate: candidate
        ))

        return AttackFixture(
            schematic: schematic,
            celestialProduct: celestialProduct,
            candidate: candidate,
            assignment: assignment
        )
    }

    private func makeStationFixture() throws -> AttackFixture {
        let baseline = try makeBaselineFixture()
        let station = try XCTUnwrap(OrboSpineStation(
            body: .mercury,
            physicalDegrees: 12,
            julianDay: JulianDay(1_000.5)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))
        let mercurySupports = [
            coordinate(.mercury, 10, .direct, 1_000),
            coordinate(.mercury, 11, .direct, 1_000.25),
            coordinate(.mercury, 11, .retrograde, 1_000.75),
            coordinate(.mercury, 10, .retrograde, 1_001),
            coordinate(.mercury, 9, .retrograde, 1_001.25),
            coordinate(.mercury, 8, .retrograde, 1_001.5),
            coordinate(.mercury, 7, .retrograde, 1_001.75),
        ]

        var bodies = baseline.celestialProduct.bodies
        let mercuryIndex = try XCTUnwrap(bodies.firstIndex { $0.body == .mercury })
        let mercury = bodies[mercuryIndex]
        bodies[mercuryIndex] = SpineForgeBodyProduct(
            body: .mercury,
            supportDegrees: mercury.supportDegrees,
            supports: mercurySupports,
            stations: [station]
        )
        let celestialProduct = SpineForgeProduct(
            schematicIdentity: baseline.schematic.identity,
            schematicVersion: baseline.schematic.version,
            astronomicalAuthority: baseline.schematic.astronomicalAuthority,
            astronomicalSourceVersion: baseline.schematic.astronomicalSourceVersion,
            bone: baseline.schematic.bone,
            bodies: bodies
        )
        let candidate = try XCTUnwrap(makeRuntime(
            bone: baseline.schematic.bone,
            authority: baseline.schematic.astronomicalAuthority,
            sourceVersion: baseline.schematic.astronomicalSourceVersion,
            supports: bodies.flatMap(\.supports),
            stations: [station]
        ))
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: baseline.schematic,
            candidate: candidate
        ))

        return AttackFixture(
            schematic: baseline.schematic,
            celestialProduct: celestialProduct,
            candidate: candidate,
            assignment: assignment
        )
    }

    private func makeRuntime(
        bone: OrboSpineBoneSpan,
        authority: String,
        sourceVersion: String,
        supports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation] = []
    ) throws -> OrboSpineRuntime? {
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
            candidateManifestSHA256: String(repeating: "f", count: 64),
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
}
