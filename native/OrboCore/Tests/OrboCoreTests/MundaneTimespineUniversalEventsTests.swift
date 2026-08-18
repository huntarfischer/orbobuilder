import CryptoKit
import Foundation
import XCTest
@testable import OrboCore

final class MundaneTimespineUniversalEventsTests: XCTestCase {
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

    func testP22UniversalEventContractIsCelestialTimeFirstAndUsesTheRing() {
        XCTAssertTrue(MundaneTimespineP22.universalEventsAreCelestialTimeFirst)
        XCTAssertEqual(MundaneTimespineP22.universalEventTables.count, 3)
        XCTAssertEqual(MundaneTimespineP22.totalUniversalEventRecords, 771_431)

        XCTAssertEqual(
            MundaneTimespineP22.majorRelationshipMarks.map(\.rawValue),
            [0, 60, 90, 120, 180]
        )
        XCTAssertEqual(
            MundaneTimespineP22.minorRelationshipMarks.map(\.rawValue),
            [30, 45, 72, 135, 144, 150]
        )
        XCTAssertEqual(
            Set(MundaneTimespineP22.majorRelationshipMarks + MundaneTimespineP22.minorRelationshipMarks),
            Set(RingMark.allCases)
        )
    }

    func testCommittedUniversalEventManifestMatchesNativeContractAndBytes() throws {
        let manifest = try JSONDecoder().decode(
            UniversalEventManifest.self,
            from: Data(contentsOf: p22Data.appendingPathComponent(MundaneTimespineP22.universalEventManifestFileName))
        )

        XCTAssertEqual(manifest.span, MundaneTimespineP22.spanName)
        XCTAssertTrue(manifest.celestialTimeFirst)
        XCTAssertEqual(manifest.bodyCount, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(manifest.totalRows, MundaneTimespineP22.totalUniversalEventRecords)
        XCTAssertEqual(manifest.files.count, MundaneTimespineP22.universalEventTables.count)

        for contract in MundaneTimespineP22.universalEventTables {
            let record = try XCTUnwrap(manifest.files.first { $0.family == contract.family.rawValue })
            XCTAssertEqual(record.path, contract.constructionFileName)
            XCTAssertEqual(record.rows, contract.constructionRecordCount)
            XCTAssertEqual(record.gzipBytes, contract.compressedBytes)
            XCTAssertEqual(record.sha256, contract.sha256)
            XCTAssertEqual(record.ringDegrees ?? [], contract.ringMarks.map(\.rawValue))

            let bytes = try Data(contentsOf: p22Data.appendingPathComponent(record.path))
            XCTAssertEqual(bytes.count, contract.compressedBytes, "compressed byte count changed for \(record.path)")
            XCTAssertEqual(sha256Hex(bytes), contract.sha256, "SHA-256 changed for \(record.path)")
        }
    }

    func testUniversalEventFilesStaySeparateFromBodySubstrateManifest() throws {
        struct BodyManifest: Decodable {
            struct FileRecord: Decodable { let path: String }
            let files: [FileRecord]
        }

        let bodyManifest = try JSONDecoder().decode(
            BodyManifest.self,
            from: Data(contentsOf: p22Data.appendingPathComponent("manifest.json"))
        )
        let bodyPaths = Set(bodyManifest.files.map(\.path))
        let eventPaths = Set(MundaneTimespineP22.universalEventTables.map(\.constructionFileName))

        XCTAssertTrue(bodyPaths.isDisjoint(with: eventPaths))
    }

    private var repositoryRoot: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { url.deleteLastPathComponent() }
        return url
    }

    private var p22Data: URL {
        repositoryRoot.appendingPathComponent("tools/pass5/p22-data", isDirectory: true)
    }

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
