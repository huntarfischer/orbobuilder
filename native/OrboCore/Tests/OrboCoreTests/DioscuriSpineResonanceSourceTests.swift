import CryptoKit
import Foundation
import XCTest
@testable import OrboCore

final class DioscuriSpineResonanceSourceTests: XCTestCase {
    func testStage3PolluxAnswersMatchForgeProductAndDurableMatter() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))
        let authority = "fixture authority"
        let sourceVersion = "fixture-1"
        let plan = try XCTUnwrap(SpineSchematicBodyPlan(
            body: .mercury,
            supportDegrees: 1,
            scanStepDays: 0.1
        ))
        let schematic = try XCTUnwrap(SpineSchematic(
            identity: "fixture-spine",
            version: 7,
            bone: bone,
            astronomicalAuthority: authority,
            astronomicalSourceVersion: sourceVersion,
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

        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("orbo-pollux-stage3-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try writeDurableFixture(
            directory: directory,
            schematic: schematic,
            bodyProduct: bodyProduct
        )

        let durable = try OrboSpineDurableCelestialResonanceSource(
            celestialDirectory: directory,
            schematic: schematic
        )

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

    private func writeDurableFixture(
        directory: URL,
        schematic: SpineSchematic,
        bodyProduct: SpineForgeBodyProduct
    ) throws {
        let supportName = "mercury-supports.csv"
        let stationName = "mercury-stations.csv"
        let supportURL = directory.appendingPathComponent(supportName)
        let stationURL = directory.appendingPathComponent(stationName)

        let supportText = """
        directional_degree,physical_degree,navigation_cell,motion,jd_ut,civic_offset_seconds
        10,10,10,direct,1000,0
        11,11,11,direct,1000.25,21600
        371,11,371,retrograde,1000.75,64800
        370,10,370,retrograde,1001,86400
        """ + "\n"
        let stationText = """
        physical_degree,directional_degree_after,navigation_cell_after,lane_before,lane_after,jd_ut
        11.5,371.5,371,direct,retrograde,1000.5
        """ + "\n"

        let supportData = Data(supportText.utf8)
        let stationData = Data(stationText.utf8)
        try supportData.write(to: supportURL, options: .atomic)
        try stationData.write(to: stationURL, options: .atomic)

        let body: [String: Any] = [
            "body": bodyProduct.body.displayName,
            "supportDegrees": bodyProduct.supportDegrees,
            "supportRows": bodyProduct.supports.count,
            "stationRows": bodyProduct.stations.count,
            "astronomicalSourceVersion": schematic.astronomicalSourceVersion,
            "supportedStartJulianDayUT": schematic.bone.start.value,
            "supportedEndJulianDayUT": schematic.bone.end.value,
            "supportFile": supportName,
            "supportFileBytes": supportData.count,
            "supportSHA256": sha256(supportData),
            "stationFile": stationName,
            "stationFileBytes": stationData.count,
            "stationSHA256": sha256(stationData),
        ]
        let manifest: [String: Any] = [
            "identity": schematic.identity,
            "matterFormat": "directional-degree-csv",
            "matterVersion": 1,
            "astronomicalSource": schematic.astronomicalAuthority,
            "astronomicalSourceVersion": schematic.astronomicalSourceVersion,
            "supportedStartJulianDayUT": schematic.bone.start.value,
            "supportedEndJulianDayUT": schematic.bone.end.value,
            "bodies": [body],
        ]
        let manifestData = try JSONSerialization.data(
            withJSONObject: manifest,
            options: [.prettyPrinted, .sortedKeys]
        )
        try manifestData.write(
            to: directory.appendingPathComponent("orbospine-celestial-manifest.json"),
            options: .atomic
        )
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
