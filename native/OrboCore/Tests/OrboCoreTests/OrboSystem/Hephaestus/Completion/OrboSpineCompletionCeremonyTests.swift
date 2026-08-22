import XCTest
@testable import OrboCore

final class OrboSpineCompletionCeremonyTests: XCTestCase {
    private struct LinearReference: SpineForgeEphemerisReference {
        let origin: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> SpineForgeState {
            SpineForgeState(
                longitudeDegrees: 10 + 10 * (julianDay.value - origin),
                longitudinalSpeedDegreesPerDay: 10
            )!
        }
    }

    private struct CeremonyFixture {
        let schematic: SpineSchematic
        let product: SpineForgeProduct
        let candidate: OrboSpineRuntime
    }

    func testG6WholeConfirmedCeremonySealsOrboSpine() throws {
        let fixture = try makeCeremonyFixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let testimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: fixture.product,
            assignment: assignment
        )

        XCTAssertEqual(testimony.result, .confirmed)
        XCTAssertEqual(
            try HephaestusOrboSpineCompletion.complete(
                schematic: fixture.schematic,
                candidate: fixture.candidate,
                testimony: testimony
            ),
            .sealed(OrboSpineSeal(
                schematicIdentity: fixture.schematic.identity,
                schematicVersion: fixture.schematic.version,
                candidateIdentity: fixture.candidate.provenance.candidateManifestSHA256
            ))
        )
    }

    func testG6WholeDivergentCeremonyReturnsToHephaestusForReforge() throws {
        let fixture = try makeCeremonyFixture(corruptCandidateSun: true)
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))
        let testimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            celestialProduct: fixture.product,
            assignment: assignment
        )

        guard case let .divergent(body, _, _) = testimony.result else {
            return XCTFail("Expected whole-ceremony divergence.")
        }
        XCTAssertEqual(body, .sun)
        XCTAssertEqual(
            try HephaestusOrboSpineCompletion.complete(
                schematic: fixture.schematic,
                candidate: fixture.candidate,
                testimony: testimony
            ),
            .reforge(testimony)
        )
    }

    private func makeCeremonyFixture(
        corruptCandidateSun: Bool = false
    ) throws -> CeremonyFixture {
        let start = JulianDay(1_000)!
        let end = JulianDay(1_002)!
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        let authority = "deterministic G6 sky"
        let sourceVersion = "1"
        let plans = try MundaneBody.canonicalOrder.map { body in
            try XCTUnwrap(SpineSchematicBodyPlan(
                body: body,
                supportDegrees: 10,
                scanStepDays: 0.25
            ))
        }
        let schematic = try XCTUnwrap(SpineSchematic(
            identity: OrboSpineContract.identity,
            version: 1,
            bone: bone,
            astronomicalAuthority: authority,
            astronomicalSourceVersion: sourceVersion,
            bodyPlans: plans
        ))
        let product = try SpineForge.manufacture(
            schematic: schematic,
            reference: LinearReference(origin: start.value)
        )

        var candidateSupports = product.bodies.flatMap(\.supports)
        if corruptCandidateSun {
            let sunIndices = candidateSupports.indices.filter {
                candidateSupports[$0].body == .sun
            }
            XCTAssertGreaterThanOrEqual(sunIndices.count, 2)
            let upperIndex = try XCTUnwrap(sunIndices.dropFirst().first)
            let original = candidateSupports[upperIndex]
            candidateSupports[upperIndex] = OrboSpineCelestialCoordinate(
                body: original.body,
                directionalDegree: OrboSpineDirectionalDegree(
                    physicalDegrees: original.directionalDegree.physicalDegrees - 1,
                    motion: original.directionalDegree.motion
                )!,
                julianDay: original.julianDay
            )
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
                julianDay: start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110,
                tiltDegrees: 23.5,
                julianDay: end
            )),
        ]
        let provenance = try XCTUnwrap(OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "c", count: 64),
            astronomicalAuthority: authority,
            astronomicalSourceVersion: sourceVersion
        ))
        let candidate = try XCTUnwrap(OrboSpineRuntime(
            bone: bone,
            celestialSupports: candidateSupports,
            stations: product.bodies.flatMap(\.stations),
            retrogradePassages: [],
            ringOccurrences: [],
            eclipses: [],
            shellIntervals: shells,
            terraSamples: terra,
            provenance: provenance
        ))

        return CeremonyFixture(
            schematic: schematic,
            product: product,
            candidate: candidate
        )
    }
}
