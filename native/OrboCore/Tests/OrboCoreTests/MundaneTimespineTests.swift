import CryptoKit
import Foundation
import XCTest
@testable import OrboCore

final class MundaneTimespineTests: XCTestCase {
    private struct Summary: Decodable {
        struct MarkerAudit: Decodable {
            let selectedMarkers: [String]
            let selectedRepeatedKeys: Int
        }
        struct Body: Decodable {
            let body: String
            let selectedResolutionDegrees: Double
            let selectedRecords: Int
            let stationCount: Int
            let retrogradePassages: Int
            let retrogradeSelectedCrossings: Int
            let selectedResolutionMarkerAudit: MarkerAudit
        }
        let spanName: String
        let startJulianDayUT: Double
        let endJulianDayUT: Double
        let civicOffsetBitsRequired: Int
        let bodyTables: [Body]
        let totalSelectedBodyRecords: Int
    }

    private struct Manifest: Decodable {
        struct FileRecord: Decodable {
            let path: String
            let compressedBytes: Int
            let uncompressedBytes: Int
            let sha256: String
        }
        let span: String
        let bodyTableCount: Int
        let sharedTables: [String]
        let files: [FileRecord]
    }

    private struct CompactAudit: Decodable {
        struct Body: Decodable {
            let body: String
            let resolution: Double
            let records: Int
            let markers: [String]
            let markerUnique: Bool
        }
        let span: String
        let bodies: [Body]
    }

    private struct UniversalEventManifest: Decodable {
        struct FileRecord: Decodable {
            let family: String
            let path: String
            let rows: Int
            let gzipBytes: Int
            let sha256: String
            let ringDegrees: [Int]?
        }
        let span: String
        let celestialTimeFirst: Bool
        let bodyCount: Int
        let totalRows: Int
        let files: [FileRecord]
    }

    func testP22NativeContractIsElevenBodiesAndHalfOpen() {
        XCTAssertEqual(MundaneBody.canonicalOrder.count, 11)
        XCTAssertEqual(MundaneTimespineP22.profiles.map(\.body), MundaneBody.canonicalOrder)
        XCTAssertEqual(MundaneTimespineP22.spanName, "P22 Pluto Zeitgeist")
        XCTAssertEqual(MundaneTimespineP22.startJulianDay.value, 2_386_637.079399706, accuracy: 1e-9)
        XCTAssertEqual(MundaneTimespineP22.endJulianDay.value, 2_475_819.1417904524, accuracy: 1e-9)
        XCTAssertEqual(MundaneTimespineP22.civicOffsetBitsRequired, 33)
        XCTAssertTrue(MundaneTimespineP22.contains(MundaneTimespineP22.startJulianDay))
        XCTAssertFalse(MundaneTimespineP22.contains(MundaneTimespineP22.endJulianDay))
        XCTAssertEqual(MundaneTimespineP22.totalConstructionRecords, 1_811_967)
    }

    func testP22ResolutionAndMarkerLawIsExplicit() {
        let expected: [(MundaneBody, Double, [MundaneBody])] = [
            (.sun, 1, [.pluto, .neptune]),
            (.moon, 1, [.sun, .pluto]),
            (.mercury, 1, [.sun, .pluto, .moon]),
            (.venus, 1, [.sun, .pluto, .mercury]),
            (.mars, 1, [.sun, .pluto]),
            (.jupiter, 0.1, [.sun, .pluto]),
            (.saturn, 0.1, [.sun, .jupiter]),
            (.uranus, 0.1, [.sun]),
            (.neptune, 0.1, [.sun]),
            (.pluto, 0.1, [.sun]),
            (.trueNorthNode, 0.1, [.sun, .moon]),
        ]

        XCTAssertEqual(MundaneTimespineP22.profiles.count, expected.count)
        for (body, resolution, markers) in expected {
            let profile = MundaneTimespineP22.profile(for: body)
            XCTAssertEqual(profile.body, body)
            XCTAssertEqual(profile.celestialResolutionDegrees, resolution, accuracy: 1e-12)
            XCTAssertEqual(profile.markerBodies, markers)
            if body != .sun {
                XCTAssertEqual(markers.first, .sun, "Sun must remain the first companion marker for every non-Sun body")
            }
        }
    }

    func testCommittedP22SummaryMatchesNativeContract() throws {
        let summary = try decode(Summary.self, at: p22Data.appendingPathComponent("summary.json"))
        XCTAssertEqual(summary.spanName, MundaneTimespineP22.spanName)
        XCTAssertEqual(summary.startJulianDayUT, MundaneTimespineP22.startJulianDay.value, accuracy: 1e-9)
        XCTAssertEqual(summary.endJulianDayUT, MundaneTimespineP22.endJulianDay.value, accuracy: 1e-9)
        XCTAssertEqual(summary.civicOffsetBitsRequired, MundaneTimespineP22.civicOffsetBitsRequired)
        XCTAssertEqual(summary.totalSelectedBodyRecords, MundaneTimespineP22.totalConstructionRecords)
        XCTAssertEqual(summary.bodyTables.count, MundaneBody.canonicalOrder.count)

        for profile in MundaneTimespineP22.profiles {
            let body = try XCTUnwrap(summary.bodyTables.first { $0.body == profile.body.constructionDataName })
            XCTAssertEqual(body.selectedResolutionDegrees, profile.celestialResolutionDegrees, accuracy: 1e-12)
            XCTAssertEqual(body.selectedRecords, profile.constructionRecordCount)
            XCTAssertEqual(body.selectedResolutionMarkerAudit.selectedRepeatedKeys, 0)
            XCTAssertEqual(
                body.selectedResolutionMarkerAudit.selectedMarkers,
                profile.markerBodies.map(\.constructionDataName)
            )
        }
    }

    func testCommittedAuditProvesEverySelectedMarkerKeyUnique() throws {
        let audit = try decode(
            CompactAudit.self,
            at: p22Results.appendingPathComponent("substrate-audit-compact.json")
        )
        XCTAssertEqual(audit.span, MundaneTimespineP22.spanName)
        XCTAssertEqual(audit.bodies.count, MundaneBody.canonicalOrder.count)

        for profile in MundaneTimespineP22.profiles {
            let body = try XCTUnwrap(audit.bodies.first { $0.body == profile.body.constructionDataName })
            XCTAssertEqual(body.resolution, profile.celestialResolutionDegrees, accuracy: 1e-12)
            XCTAssertEqual(body.records, profile.constructionRecordCount)
            XCTAssertEqual(body.markers, profile.markerBodies.map(\.constructionDataName))
            XCTAssertTrue(body.markerUnique, "\(body.body) marker key repeats inside P22")
        }
    }

    func testPersistedManifestBindsEveryCompressedP22FileBySizeAndSHA256() throws {
        let manifest = try decode(Manifest.self, at: p22Data.appendingPathComponent("manifest.json"))
        XCTAssertEqual(manifest.span, MundaneTimespineP22.spanName)
        XCTAssertEqual(manifest.bodyTableCount, 11)
        XCTAssertEqual(manifest.sharedTables, ["station-table", "retrograde-passages", "retrograde-crossings"])

        let expectedPaths = Set(
            MundaneTimespineP22.profiles.map { "body-tables/\($0.body.constructionBodyFileName)" }
            + MundaneTimespineP22.sharedMotionTables
        )
        XCTAssertEqual(Set(manifest.files.map(\.path)), expectedPaths)

        for record in manifest.files {
            let url = p22Data.appendingPathComponent(record.path)
            let data = try Data(contentsOf: url)
            XCTAssertEqual(data.count, record.compressedBytes, "compressed byte count changed for \(record.path)")
            XCTAssertGreaterThan(record.uncompressedBytes, 0)
            XCTAssertEqual(sha256Hex(data), record.sha256, "SHA-256 changed for \(record.path)")
        }
    }

    func testP22UniversalEventLayerIsCelestialFirstAndByteBound() throws {
        let manifest = try decode(
            UniversalEventManifest.self,
            at: p22Data.appendingPathComponent(MundaneTimespineP22.universalEventManifestFileName)
        )
        XCTAssertEqual(manifest.span, MundaneTimespineP22.spanName)
        XCTAssertTrue(manifest.celestialTimeFirst)
        XCTAssertEqual(manifest.bodyCount, 11)
        XCTAssertEqual(manifest.totalRows, 771_431)
        XCTAssertEqual(manifest.files.count, 3)
        XCTAssertEqual(MundaneTimespineP22.totalUniversalEventRecords, 771_431)
        XCTAssertEqual(
            Set(MundaneTimespineP22.majorRelationshipMarks + MundaneTimespineP22.minorRelationshipMarks),
            Set(RingMark.allCases)
        )

        for contract in MundaneTimespineP22.universalEventTables {
            let record = try XCTUnwrap(manifest.files.first { $0.family == contract.family.rawValue })
            XCTAssertEqual(record.path, contract.constructionFileName)
            XCTAssertEqual(record.rows, contract.constructionRecordCount)
            XCTAssertEqual(record.gzipBytes, contract.compressedBytes)
            XCTAssertEqual(record.sha256, contract.sha256)
            XCTAssertEqual(record.ringDegrees ?? [], contract.ringMarks.map(\.rawValue))
            let bytes = try Data(contentsOf: p22Data.appendingPathComponent(record.path))
            XCTAssertEqual(bytes.count, contract.compressedBytes)
            XCTAssertEqual(sha256Hex(bytes), contract.sha256)
        }
    }

    func testNativeStorageRoundTripIsCelestialFirstInsideXcodeGate() throws {
        let start = JulianDay(1_000)!
        let end = JulianDay(1_001)!
        let body = try XCTUnwrap(MundaneTimespineStoredBody(
            body: .mercury,
            ticksPerDegree: 1,
            markerBodies: [],
            occurrences: [
                MundaneTimespineStoredOccurrence(celestialTick: 100, civicOffsetSeconds: 0, sequenceDirection: .increasing, markerWholeDegrees: []),
                MundaneTimespineStoredOccurrence(celestialTick: 101, civicOffsetSeconds: 100, sequenceDirection: .increasing, markerWholeDegrees: []),
            ],
            stations: [],
            retrogradePassages: []
        ))
        let major = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .mercury,
            bodyB: .venus,
            mark: .trine,
            orientation: .bodyBAhead,
            bodyACelestialTimeDegrees: 100.1234564,
            bodyBCelestialTimeDegrees: 220.1234564,
            julianDay: JulianDay(start.value + 1_234.4 / 86_400)!,
            exactAspectResidualArcSeconds: 0
        ))
        let minor = try XCTUnwrap(MundaneTimespineRelationshipEvent(
            bodyA: .mars,
            bodyB: .jupiter,
            mark: .semisquare,
            orientation: .bodyAAhead,
            bodyACelestialTimeDegrees: 10.9876546,
            bodyBCelestialTimeDegrees: 325.9876546,
            julianDay: JulianDay(start.value + 2_345.6 / 86_400)!,
            exactAspectResidualArcSeconds: 0
        ))
        let eclipse = try XCTUnwrap(MundaneTimespineEclipseEvent(
            kind: .solar,
            type: .total,
            eclipseDegree: 44.1234566,
            julianDay: JulianDay(start.value + 3_456.2 / 86_400)!,
            centrality: "central"
        ))
        let image = try XCTUnwrap(MundaneTimespineStorageImage(
            spanName: "Xcode storage fixture",
            astronomicalSource: "deterministic XCTest sky",
            astronomicalSourceVersion: "1",
            supportedStart: start,
            supportedEnd: end,
            bodies: [body],
            relationships: [major, minor],
            eclipses: [eclipse]
        ))

        let first = try image.encodedArtifact()
        let second = try image.encodedArtifact()
        XCTAssertEqual(first, second)
        XCTAssertEqual(Array(first.prefix(8)), Array("ORBOTS01".utf8))
        XCTAssertEqual(MundaneTimespineStorageFormat.version, 1)
        XCTAssertTrue(MundaneTimespineStorageFormat.celestialTimeFirst)

        let artifact = try MundaneTimespineArtifact(data: first)
        let decoded = try artifact.storageImage()
        XCTAssertEqual(decoded.relationships.map(\.mark), [.trine, .semisquare])
        XCTAssertEqual(decoded.relationships[0].bodyBCelestialTimeDegrees, 220.123456, accuracy: 0.000001)
        XCTAssertEqual(decoded.eclipses[0].eclipseDegree, 44.123457, accuracy: 0.000001)
        XCTAssertNoThrow(try artifact.runtimeImage())
    }

    func testAstroDNACodecFourRemainsIndependentOfPassFiveRepresentation() {
        XCTAssertEqual(AstroDNA.codec, 4)
        XCTAssertEqual(AstroDNAGene.canonicalOrder.count, 12)
        XCTAssertEqual(AstroDNAGene.canonicalOrder[11], .northNode)
    }

    private var repositoryRoot: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { url.deleteLastPathComponent() }
        return url
    }

    private var p22Data: URL {
        repositoryRoot.appendingPathComponent("tools/pass5/p22-data", isDirectory: true)
    }

    private var p22Results: URL {
        repositoryRoot.appendingPathComponent("tools/pass5/p22-results", isDirectory: true)
    }

    private func decode<T: Decodable>(_ type: T.Type, at url: URL) throws -> T {
        try JSONDecoder().decode(type, from: Data(contentsOf: url))
    }

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
