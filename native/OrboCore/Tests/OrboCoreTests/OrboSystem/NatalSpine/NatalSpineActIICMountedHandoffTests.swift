import Foundation
import XCTest
@testable import OrboCore

final class NatalSpineActIICMountedHandoffTests: XCTestCase {
    func testMountedSpineIsTheAuthorityForHoraeChronosAndHecate() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let mounted = try mount(sealed, name: "three-door")

        let position = try Horae.locateNatalSpine(
            mounted.runtime,
            at: mounted.runtime.bounds.natal.julianDay
        )
        XCTAssertEqual(position.count, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(position.map(\.coordinate.body), MundaneBody.canonicalOrder)

        let index = Chronos.indexNatalSpine(mounted.runtime)
        XCTAssertEqual(index.subjectID, mounted.runtime.subjectID)
        XCTAssertEqual(index.packageID, mounted.runtime.packageID)
        XCTAssertEqual(index.bounds, mounted.runtime.bounds)

        let sample = try XCTUnwrap(mounted.runtime.themis.first)
        let query = try XCTUnwrap(
            ChronosQuery(
                predicate: .natalHousePassage(
                    body: sample.body,
                    house: sample.house
                )
            )
        )
        guard case let .resolved(answer) = try Chronos.resolveNatalSpine(query, using: index) else {
            XCTFail("Chronos did not resolve the mounted Natal Spine")
            return
        }
        XCTAssertFalse(answer.hits.isEmpty)
        XCTAssertTrue(answer.hits.allSatisfy {
            $0.source?.rawValue.contains(mounted.runtime.artifactSHA256) == true
        })

        let blessing = try Hecate.blessNatalSpine(mounted.runtime, indexedBy: index)
        XCTAssertEqual(blessing.packageID, mounted.runtime.packageID)
        XCTAssertEqual(blessing.subjectID, mounted.runtime.subjectID)
        XCTAssertEqual(blessing.bounds, mounted.runtime.bounds)
        XCTAssertEqual(blessing.parentProvenance, mounted.runtime.parentProvenance)
    }

    func testHecateRejectsAChronosIndexFromAnotherMountedNatalSpine() throws {
        let first = try mount(NatalSpineActIIIFixture.sealedSpine(), name: "first")
        var second = try mount(NatalSpineActIIIFixture.sealedSpine(), name: "second")
        while second.runtime.packageID == first.runtime.packageID {
            second = try mount(NatalSpineActIIIFixture.sealedSpine(), name: UUID().uuidString)
        }

        let wrongIndex = Chronos.indexNatalSpine(second.runtime)
        XCTAssertThrowsError(
            try Hecate.blessNatalSpine(first.runtime, indexedBy: wrongIndex)
        ) { error in
            XCTAssertEqual(error as? NatalSpineHecateFailure, .packageMismatch)
        }
    }

    private func mount(
        _ sealed: SealedNatalSpine,
        name: String
    ) throws -> (runtime: NatalSpineRuntime, receipt: NatalSpineArtifactReceipt) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("NatalSpineIIC-\(name)-\(UUID().uuidString).natalspine")
        defer { try? FileManager.default.removeItem(at: url) }
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let runtime = try NatalSpineRuntime.mount(
            from: url,
            expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: receipt.parentSpineIdentity
        )
        return (runtime, receipt)
    }
}
