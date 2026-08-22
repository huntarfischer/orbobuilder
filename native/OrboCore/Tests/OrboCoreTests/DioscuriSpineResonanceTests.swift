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
            physicalDegrees: 10.5,
            julianDay: JulianDay(1_000.5)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))

        var forgedBodies: [SpineForgeBodyProduct] = []
        var candidateSupports: [OrboSpineCelestialCoordinate] = []

        for body in MundaneBody.canonicalOrder {
            let supportDegrees = OrboSpineContract.supportDegrees(for: body)
            if body == .mercury {
                let direct = coordinate(body, 10, .direct, 1_000)
                let forgedRetrograde = coordinate(body, 10, .retrograde, 1_001)
                let candidateRetrograde = coordinate(
                    body,
                    candidateMercuryRetrogradePhysicalDegrees,
                    .retrograde,
                    1_001
                )
                forgedBodies.append(SpineForgeBodyProduct(
                    body: body,
                    supportDegrees: supportDegrees,
                    supports: [direct, forgedRetrograde],
                    stations: [station]
                ))
                candidateSupports.append(contentsOf: [direct, candidateRetrograde])
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
}
