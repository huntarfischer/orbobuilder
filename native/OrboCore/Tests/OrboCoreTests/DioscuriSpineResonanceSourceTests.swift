import XCTest
@testable import OrboCore

final class DioscuriSpineResonanceSourceTests: XCTestCase {
    func testStage3PolluxAnswersMatchForgeProductAndDurableMatter() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))
        let plan = try XCTUnwrap(SpineSchematicBodyPlan(
            body: .mercury,
            supportDegrees: 1,
            scanStepDays: 0.1
        ))
        let schematic = try XCTUnwrap(SpineSchematic(
            identity: "fixture-spine",
            version: 7,
            bone: bone,
            astronomicalAuthority: "fixture authority",
            astronomicalSourceVersion: "fixture-1",
            bodyPlans: [plan]
        ))
        let bodyProduct = SpineForgeBodyProduct(
            body: .mercury,
            supportDegrees: 1,
            supports: [
                coordinate(.mercury, 10, .direct, 1_000),
                coordinate(.mercury, 11, .direct, 1_000.25),
                coordinate(.mercury, 11, .retrograde, 1_000.75),
                coordinate(.mercury, 10, .retrograde, 1_001),
            ],
            stations: [
                station(.mercury, 11.5, .direct, .retrograde, 1_000.5),
            ]
        )
        let forgeProduct = SpineForgeProduct(
            schematicIdentity: schematic.identity,
            schematicVersion: schematic.version,
            astronomicalAuthority: schematic.astronomicalAuthority,
            astronomicalSourceVersion: schematic.astronomicalSourceVersion,
            bone: schematic.bone,
            bodies: [bodyProduct]
        )
        let durable = try XCTUnwrap(OrboSpineDurableCelestialResonanceSource(
            schematic: schematic,
            supports: bodyProduct.supports,
            stations: bodyProduct.stations
        ))

        let direct = try XCTUnwrap(SpineCelestialChallenge(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10.5,
                motion: .direct
            ))
        ))
        let retrograde = try XCTUnwrap(SpineCelestialChallenge(
            body: .mercury,
            directionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(
                physicalDegrees: 10.5,
                motion: .retrograde
            ))
        ))
        let stationChallenge = try XCTUnwrap(SpineStationChallenge(body: .mercury))

        XCTAssertEqual(
            PolluxResonator.ask(direct, from: forgeProduct),
            PolluxResonator.ask(direct, from: durable)
        )
        XCTAssertEqual(
            PolluxResonator.ask(retrograde, from: forgeProduct),
            PolluxResonator.ask(retrograde, from: durable)
        )
        XCTAssertEqual(
            PolluxResonator.ask(stationChallenge, from: forgeProduct),
            PolluxResonator.ask(stationChallenge, from: durable)
        )
    }

    func testStage3CampaignAndTestimonyMatchForgeProductAndDurableMatter() throws {
        let fixture = try makeCampaignFixture()
        let assignment = try XCTUnwrap(SpineResonanceAssignment(
            schematic: fixture.schematic,
            candidate: fixture.candidate
        ))

        let forgeCampaign = try SpineResonanceRun.campaign(
            schematic: fixture.schematic,
            source: fixture.forgeProduct
        )
        let durableCampaign = try SpineResonanceRun.campaign(
            schematic: fixture.schematic,
            source: fixture.durableSource
        )
        let forgeTestimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            source: fixture.forgeProduct,
            assignment: assignment
        )
        let durableTestimony = try SpineResonanceRun.run(
            schematic: fixture.schematic,
            source: fixture.durableSource,
            assignment: assignment
        )

        XCTAssertEqual(forgeCampaign, durableCampaign)
        XCTAssertEqual(forgeTestimony, durableTestimony)
        XCTAssertEqual(forgeTestimony.result, .confirmed)
    }

    private struct CampaignFixture {
        let schematic: SpineSchematic
        let forgeProduct: SpineForgeProduct
        let durableSource: OrboSpineDurableCelestialResonanceSource
        let candidate: OrboSpineRuntime
    }

    private func makeCampaignFixture() throws -> CampaignFixture {
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
        let mercuryStation = station(
            .mercury,
            12,
            .direct,
            .retrograde,
            1_000.5
        )

        var bodies: [SpineForgeBodyProduct] = []
        var candidateSupports: [OrboSpineCelestialCoordinate] = []

        for body in MundaneBody.canonicalOrder {
            let supportDegrees = OrboSpineContract.supportDegrees(for: body)
            if body == .mercury {
                let supports = [
                    coordinate(body, 10, .direct, 1_000),
                    coordinate(body, 11, .direct, 1_000.25),
                    coordinate(body, 11, .retrograde, 1_000.75),
                    coordinate(body, 10, .retrograde, 1_001),
                    coordinate(body, 9, .retrograde, 1_001.25),
                    coordinate(body, 8, .retrograde, 1_001.5),
                    coordinate(body, 7, .retrograde, 1_001.75),
                ]
                bodies.append(SpineForgeBodyProduct(
                    body: body,
                    supportDegrees: supportDegrees,
                    supports: supports,
                    stations: [mercuryStation]
                ))
                candidateSupports.append(contentsOf: supports)
            } else {
                let supports = [
                    coordinate(body, 10, .direct, 1_000),
                    coordinate(body, 10 + supportDegrees, .direct, 1_001),
                ]
                bodies.append(SpineForgeBodyProduct(
                    body: body,
                    supportDegrees: supportDegrees,
                    supports: supports,
                    stations: []
                ))
                candidateSupports.append(contentsOf: supports)
            }
        }

        let forgeProduct = SpineForgeProduct(
            schematicIdentity: schematic.identity,
            schematicVersion: schematic.version,
            astronomicalAuthority: schematic.astronomicalAuthority,
            astronomicalSourceVersion: schematic.astronomicalSourceVersion,
            bone: schematic.bone,
            bodies: bodies
        )
        let durableSource = try XCTUnwrap(OrboSpineDurableCelestialResonanceSource(
            schematic: schematic,
            supports: bodies.flatMap(\.supports),
            stations: bodies.flatMap(\.stations)
        ))
        let candidate = try XCTUnwrap(makeRuntime(
            bone: bone,
            authority: authority,
            sourceVersion: sourceVersion,
            supports: candidateSupports,
            stations: [mercuryStation]
        ))

        return CampaignFixture(
            schematic: schematic,
            forgeProduct: forgeProduct,
            durableSource: durableSource,
            candidate: candidate
        )
    }

    private func makeRuntime(
        bone: OrboSpineBoneSpan,
        authority: String,
        sourceVersion: String,
        supports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation]
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
        _ jd: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: JulianDay(jd)!
        )
    }

    private func station(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        _ laneBefore: Motion,
        _ laneAfter: Motion,
        _ jd: Double
    ) -> OrboSpineStation {
        OrboSpineStation(
            body: body,
            physicalDegrees: physicalDegrees,
            julianDay: JulianDay(jd)!,
            laneBefore: laneBefore,
            laneAfter: laneAfter
        )!
    }
}
