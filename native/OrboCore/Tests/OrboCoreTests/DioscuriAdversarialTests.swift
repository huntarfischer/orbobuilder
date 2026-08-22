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

    private func makeRuntime(
        bone: OrboSpineBoneSpan,
        authority: String,
        sourceVersion: String,
        supports: [OrboSpineCelestialCoordinate]
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
            stations: [],
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
