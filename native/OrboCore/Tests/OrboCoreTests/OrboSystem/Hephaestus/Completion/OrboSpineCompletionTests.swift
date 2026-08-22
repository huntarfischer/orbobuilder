import XCTest
@testable import OrboCore

final class OrboSpineCompletionTests: XCTestCase {
    func testG2AcceptsTestimonyBoundToExactOrboSpineWork() throws {
        let fixture = try makeFixture()
        let testimony = SpineResonanceTestimony(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            candidateIdentity: fixture.candidate.provenance.candidateManifestSHA256,
            result: .confirmed
        )

        XCTAssertEqual(
            try HephaestusOrboSpineCompletion.receive(
                schematic: fixture.schematic,
                candidate: fixture.candidate,
                testimony: testimony
            ),
            testimony
        )
    }

    func testG2FailsClosedOnWrongSchematicIdentity() throws {
        let fixture = try makeFixture()
        let testimony = SpineResonanceTestimony(
            schematicIdentity: "NotOrboSpine",
            schematicVersion: fixture.schematic.version,
            candidateIdentity: fixture.candidate.provenance.candidateManifestSHA256,
            result: .confirmed
        )

        assertInvalidBinding(testimony, fixture: fixture)
    }

    func testG2FailsClosedOnWrongSchematicVersion() throws {
        let fixture = try makeFixture()
        let testimony = SpineResonanceTestimony(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version + 1,
            candidateIdentity: fixture.candidate.provenance.candidateManifestSHA256,
            result: .confirmed
        )

        assertInvalidBinding(testimony, fixture: fixture)
    }

    func testG2FailsClosedOnWrongCandidateIdentity() throws {
        let fixture = try makeFixture()
        let testimony = SpineResonanceTestimony(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            candidateIdentity: String(repeating: "b", count: 64),
            result: .confirmed
        )

        assertInvalidBinding(testimony, fixture: fixture)
    }

    func testG3DivergentTestimonyReturnsReforgeAndPreservesTestimony() throws {
        let fixture = try makeFixture()
        let testimony = SpineResonanceTestimony(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            candidateIdentity: fixture.candidate.provenance.candidateManifestSHA256,
            result: .divergent(
                body: .sun,
                expected: coordinate(.sun, 10, at: 1_000),
                returned: coordinate(.sun, 10.25, at: 1_000)
            )
        )

        XCTAssertEqual(
            try HephaestusOrboSpineCompletion.reforge(
                schematic: fixture.schematic,
                candidate: fixture.candidate,
                testimony: testimony
            ),
            .reforge(testimony)
        )
    }

    func testG3ConfirmedTestimonyDoesNotReforge() throws {
        let fixture = try makeFixture()
        let testimony = SpineResonanceTestimony(
            schematicIdentity: fixture.schematic.identity,
            schematicVersion: fixture.schematic.version,
            candidateIdentity: fixture.candidate.provenance.candidateManifestSHA256,
            result: .confirmed
        )

        XCTAssertThrowsError(
            try HephaestusOrboSpineCompletion.reforge(
                schematic: fixture.schematic,
                candidate: fixture.candidate,
                testimony: testimony
            )
        ) { error in
            XCTAssertEqual(
                error as? OrboSpineCompletionError,
                .testimonyNotDivergent
            )
        }
    }

    private struct Fixture {
        let schematic: SpineSchematic
        let candidate: OrboSpineRuntime
    }

    private func makeFixture() throws -> Fixture {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))
        let authority = "Swiss Ephemeris / DE441"
        let sourceVersion = "2.10.03"
        let plans = MundaneBody.canonicalOrder.map { body in
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
            bodyPlans: plans
        ))

        var supports: [OrboSpineCelestialCoordinate] = []
        for body in MundaneBody.canonicalOrder {
            let step = OrboSpineContract.supportDegrees(for: body)
            supports.append(coordinate(body, 10, at: 1_000))
            supports.append(coordinate(body, 10 + step, at: 1_001))
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
        let candidate = try XCTUnwrap(OrboSpineRuntime(
            bone: bone,
            celestialSupports: supports,
            stations: [],
            retrogradePassages: [],
            ringOccurrences: [],
            eclipses: [],
            shellIntervals: shells,
            terraSamples: terra,
            provenance: provenance
        ))

        return Fixture(schematic: schematic, candidate: candidate)
    }

    private func assertInvalidBinding(
        _ testimony: SpineResonanceTestimony,
        fixture: Fixture,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try HephaestusOrboSpineCompletion.receive(
                schematic: fixture.schematic,
                candidate: fixture.candidate,
                testimony: testimony
            ),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? OrboSpineCompletionError,
                .invalidTestimonyBinding,
                file: file,
                line: line
            )
        }
    }

    private func coordinate(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        at julianDay: Double
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
