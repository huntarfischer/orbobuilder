import XCTest
@testable import OrboCore

final class OrboSpineForgeTests: XCTestCase {
    private struct LinearReference: SpineForgeEphemerisReference {
        let origin: Double
        let baseLongitude: Double
        let speed: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> SpineForgeState {
            SpineForgeState(
                longitudeDegrees: baseLongitude + speed * (julianDay.value - origin),
                longitudinalSpeedDegreesPerDay: speed
            )!
        }
    }

    private struct TurningReference: SpineForgeEphemerisReference {
        let origin: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> SpineForgeState {
            let t = julianDay.value - origin
            let x = t - 2
            return SpineForgeState(
                longitudeDegrees: 10 + x * x,
                longitudinalSpeedDegreesPerDay: 2 * x
            )!
        }
    }

    private struct ConstantReference: SpineForgeEphemerisReference {
        let longitude: Double
        let speed: Double

        func state(of body: MundaneBody, at julianDay: JulianDay) throws -> SpineForgeState {
            SpineForgeState(
                longitudeDegrees: longitude,
                longitudinalSpeedDegreesPerDay: speed
            )!
        }
    }

    func testOrboSpineSchematicOwnsFrozenCelestialManufactureLaw() {
        let schematic = OrboSpineSchematic.current

        XCTAssertEqual(schematic.identity, "OrboSpine")
        XCTAssertEqual(schematic.version, 1)
        XCTAssertEqual(schematic.astronomicalSourceVersion, "2.10.03")
        XCTAssertTrue(schematic.astronomicalAuthority.contains("DE441"))
        XCTAssertEqual(schematic.bone.start, OrboSpineSchematic.z21.start)
        XCTAssertEqual(schematic.bone.end, OrboSpineSchematic.z23.end)
        XCTAssertEqual(schematic.bodyPlans.map(\.body), MundaneBody.canonicalOrder)
        XCTAssertEqual(schematic.bodyPlans.count, 11)
        XCTAssertEqual(
            Dictionary(uniqueKeysWithValues: schematic.bodyPlans.map { ($0.body, $0.supportDegrees) }),
            OrboSpineContract.celestialSupportDegrees
        )
        XCTAssertEqual(Set(schematic.bodyPlans.map(\.body)), Set(OrboSpineSchematic.scanStepDays.keys))
        XCTAssertEqual(schematic.boundaryChecks.count, 4)
        XCTAssertTrue(schematic.boundaryChecks.allSatisfy {
            $0.body == .pluto && $0.physicalDegrees == 0 && $0.motion == .direct
        })
    }

    func testForgeFollowsSchematicForEveryFinalSupportGrid() throws {
        let start = JulianDay(10_000)!
        let end = JulianDay(10_040)!
        let reference = LinearReference(origin: start.value, baseLongitude: 0, speed: 1)
        let supports: [(Double, Int)] = [
            (10, 4),
            (1, 40),
            (0.5, 80),
            (0.2, 200),
            (0.1, 400),
        ]

        for (resolution, expectedCount) in supports {
            let schematic = try fixtureSchematic(
                start: start,
                end: end,
                body: .sun,
                supportDegrees: resolution,
                scanStepDays: 0.25
            )
            let product = try SpineForge.manufacture(schematic: schematic, reference: reference)
            let body = try XCTUnwrap(product.body(.sun))
            let first = try XCTUnwrap(body.supports.first)
            let last = try XCTUnwrap(body.supports.last)

            XCTAssertEqual(body.supports.count, expectedCount, "support \(resolution)")
            XCTAssertEqual(first.directionalDegree.physicalDegrees, 0, accuracy: 1e-12)
            XCTAssertEqual(
                last.directionalDegree.physicalDegrees,
                Double(expectedCount - 1) * resolution,
                accuracy: 1e-10
            )
            XCTAssertTrue(body.supports.allSatisfy { $0.directionalDegree.motion == .direct })
        }
    }

    func testForgeRejectsSupportThatDoesNotPartitionZodiac() throws {
        let start = JulianDay(20_000)!
        let end = JulianDay(20_010)!
        let schematic = try fixtureSchematic(
            start: start,
            end: end,
            body: .sun,
            supportDegrees: 7,
            scanStepDays: 0.25
        )

        XCTAssertThrowsError(
            try SpineForge.manufacture(
                schematic: schematic,
                reference: LinearReference(origin: start.value, baseLongitude: 0, speed: 1)
            )
        ) { error in
            XCTAssertEqual(
                error as? SpineForgeError,
                .unsupportedResolution(body: .sun, resolution: 7)
            )
        }
    }

    func testForgeFindsStationAndChangesDirectionalLane() throws {
        let start = JulianDay(2_000)!
        let end = JulianDay(2_004)!
        let schematic = try fixtureSchematic(
            start: start,
            end: end,
            body: .mercury,
            supportDegrees: 1,
            scanStepDays: 0.5
        )

        let product = try SpineForge.manufacture(
            schematic: schematic,
            reference: TurningReference(origin: start.value)
        )
        let body = try XCTUnwrap(product.body(.mercury))
        let station = try XCTUnwrap(body.stations.first)

        XCTAssertEqual(body.supports.count, 8)
        XCTAssertEqual(body.stations.count, 1)
        XCTAssertEqual(station.julianDay.value, start.value + 2, accuracy: 1e-10)
        XCTAssertEqual(station.physicalDegrees, 10, accuracy: 1e-10)
        XCTAssertEqual(station.laneBefore, .retrograde)
        XCTAssertEqual(station.laneAfter, .direct)
        XCTAssertEqual(station.directionalDegreeAfter.degrees, 10, accuracy: 1e-10)
    }

    func testOrboSpineSchematicPreflightRequiresFourDirectPlutoZeroAriesFences() throws {
        let schematic = OrboSpineSchematic.current

        XCTAssertNoThrow(
            try SpineForge.preflight(
                schematic: schematic,
                reference: ConstantReference(longitude: 0, speed: 0.01)
            )
        )
        XCTAssertThrowsError(
            try SpineForge.preflight(
                schematic: schematic,
                reference: ConstantReference(longitude: 1, speed: 0.01)
            )
        ) { error in
            XCTAssertEqual(error as? SpineForgeError, .boundaryMismatch(index: 0))
        }
        XCTAssertThrowsError(
            try SpineForge.preflight(
                schematic: schematic,
                reference: ConstantReference(longitude: 0, speed: -0.01)
            )
        ) { error in
            XCTAssertEqual(error as? SpineForgeError, .boundaryMismatch(index: 0))
        }
    }

    func testBodySchematicPreservesParentIdentityAndBone() throws {
        let parent = OrboSpineSchematic.current
        let mercury = try XCTUnwrap(parent.bodySchematic(for: .mercury))

        XCTAssertEqual(mercury.identity, parent.identity)
        XCTAssertEqual(mercury.version, parent.version)
        XCTAssertEqual(mercury.bone, parent.bone)
        XCTAssertEqual(mercury.astronomicalAuthority, parent.astronomicalAuthority)
        XCTAssertEqual(mercury.astronomicalSourceVersion, parent.astronomicalSourceVersion)
        XCTAssertEqual(mercury.bodyPlans.map(\.body), [.mercury])
        XCTAssertEqual(mercury.boundaryChecks, parent.boundaryChecks)
    }

    func testForgeProductIsOrboSpineNativeMatter() throws {
        let start = JulianDay(30_000)!
        let end = JulianDay(30_002)!
        let schematic = try fixtureSchematic(
            start: start,
            end: end,
            body: .sun,
            supportDegrees: 1,
            scanStepDays: 0.25
        )

        let product = try SpineForge.manufacture(
            schematic: schematic,
            reference: LinearReference(origin: start.value, baseLongitude: 0, speed: 1)
        )
        let body = try XCTUnwrap(product.body(.sun))
        let support: OrboSpineCelestialCoordinate = try XCTUnwrap(body.supports.first)

        XCTAssertEqual(product.schematicIdentity, schematic.identity)
        XCTAssertEqual(product.schematicVersion, schematic.version)
        XCTAssertEqual(product.bone, schematic.bone)
        XCTAssertEqual(support.body, .sun)
        XCTAssertEqual(support.julianDay, start)
        XCTAssertEqual(support.directionalDegree.degrees, 0, accuracy: 1e-12)
    }

    private func fixtureSchematic(
        start: JulianDay,
        end: JulianDay,
        body: MundaneBody,
        supportDegrees: Double,
        scanStepDays: Double
    ) throws -> SpineSchematic {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))
        let bodyPlan = try XCTUnwrap(SpineSchematicBodyPlan(
            body: body,
            supportDegrees: supportDegrees,
            scanStepDays: scanStepDays
        ))
        return try XCTUnwrap(SpineSchematic(
            identity: "fixture-spine",
            version: 1,
            bone: bone,
            astronomicalAuthority: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            bodyPlans: [bodyPlan]
        ))
    }
}
