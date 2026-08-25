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
                coordinate(10, .direct, 1_000),
                coordinate(11, .direct, 1_000.25),
                coordinate(11, .retrograde, 1_000.75),
                coordinate(10, .retrograde, 1_001),
            ],
            stations: [
                station(11.5, .direct, .retrograde, 1_000.5),
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

    private func coordinate(
        _ physicalDegrees: Double,
        _ motion: Motion,
        _ jd: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: .mercury,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: JulianDay(jd)!
        )
    }

    private func station(
        _ physicalDegrees: Double,
        _ laneBefore: Motion,
        _ laneAfter: Motion,
        _ jd: Double
    ) -> OrboSpineStation {
        OrboSpineStation(
            body: .mercury,
            physicalDegrees: physicalDegrees,
            julianDay: JulianDay(jd)!,
            laneBefore: laneBefore,
            laneAfter: laneAfter
        )!
    }
}
