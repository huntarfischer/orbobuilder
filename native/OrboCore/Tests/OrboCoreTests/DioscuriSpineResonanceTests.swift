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
        sourceVersion: String
    ) throws -> OrboSpineRuntime? {
        var supports: [OrboSpineCelestialCoordinate] = []
        for body in MundaneBody.canonicalOrder {
            let step = OrboSpineContract.supportDegrees(for: body)
            supports.append(coordinate(body, 10, 1_000))
            supports.append(coordinate(body, 10 + step, 1_001))
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
        _ julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: .direct
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }
}
