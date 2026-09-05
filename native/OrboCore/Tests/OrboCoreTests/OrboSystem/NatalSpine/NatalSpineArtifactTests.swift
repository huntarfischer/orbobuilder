import Foundation
import XCTest
@testable import OrboCore

final class NatalSpineArtifactTests: XCTestCase {
    func testHephaestusWritesDeterministicArtifactAndExternalReceipt() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let first = temporaryURL("first.natalspine")
        let second = temporaryURL("second.natalspine")
        let receiptURL = temporaryURL("first.natalspine.json")

        let firstReceipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: first)
        let secondReceipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: second)
        try firstReceipt.write(to: receiptURL)

        XCTAssertEqual(firstReceipt, secondReceipt)
        XCTAssertEqual(try Data(contentsOf: first), try Data(contentsOf: second))
        XCTAssertEqual(
            try NatalSpineArtifactReceipt.read(from: receiptURL),
            firstReceipt
        )
        XCTAssertEqual(firstReceipt.formatVersion, NatalSpineArtifactFormat.version)
        XCTAssertEqual(firstReceipt.subjectID, sealed.subjectID.rawValue)
        XCTAssertEqual(
            firstReceipt.parentSpineIdentity,
            sealed.seal.parentProvenance.spineIdentity
        )
    }

    func testArtifactPersistsFinishedLocateNavigationExactly() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("finished-navigation.natalspine")

        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let mounted = try NatalSpineMountedArtifact(url: url)

        XCTAssertEqual(mounted.locateTracts, sealed.candidate.artifactTracts)
        XCTAssertEqual(mounted.locateTracts.map(\.body), MundaneBody.canonicalOrder)
        XCTAssertTrue(mounted.locateTracts.allSatisfy { $0.segmentIndexesByCell.count == 720 })
        XCTAssertEqual(receipt.formatVersion, NatalSpineArtifactFormat.version)
        XCTAssertEqual(receipt.formatVersion, 2)
    }

    func testMountedArtifactPreservesLayersAndBothDirectionsOfAddressability() throws {
        let (sealed, runtime, _) = try mountedFixture()

        XCTAssertEqual(runtime.subjectID, sealed.subjectID)
        XCTAssertEqual(runtime.packageID, sealed.packageID)
        XCTAssertEqual(runtime.bounds, sealed.bounds)
        XCTAssertEqual(runtime.themis.count, sealed.candidate.themis.count)
        XCTAssertEqual(runtime.oceanus.count, sealed.candidate.oceanus.count)
        XCTAssertEqual(runtime.rhea.count, sealed.candidate.rhea.count)

        let moment = runtime.bounds.natal.julianDay
        let mountedAddresses = try Horae.locateNatalSpine(runtime, at: moment)
        let memoryPosition = try Horae.locateNatalSpine(sealed, at: moment)
        XCTAssertEqual(mountedAddresses.count, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(
            mountedAddresses.map(\.coordinate),
            memoryPosition.addresses.map(\.coordinate)
        )

        let sun = try XCTUnwrap(mountedAddresses.first { $0.coordinate.body == .sun })
        let occurrences = try Horae.locateNatalSpine(
            runtime,
            body: .sun,
            at: sun.coordinate.directionalDegree
        )
        XCTAssertFalse(occurrences.isEmpty)
        XCTAssertTrue(occurrences.allSatisfy { runtime.bounds.bone.contains($0.coordinate.julianDay) })
    }

    func testMountFailsClosedOnExternalArtifactOrParentIdentityMismatch() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("identity.natalspine")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)

        XCTAssertThrowsError(
            try NatalSpineRuntime.mount(
                from: url,
                expectedSHA256: String(repeating: "0", count: 64),
                expectedParentSpineIdentity: receipt.parentSpineIdentity
            )
        ) { error in
            guard case NatalSpineArtifactError.artifactIdentityMismatch = error else {
                return XCTFail("Expected artifact identity mismatch, received \(error)")
            }
        }

        XCTAssertThrowsError(
            try NatalSpineRuntime.mount(
                from: url,
                expectedSHA256: receipt.sha256,
                expectedParentSpineIdentity: String(repeating: "1", count: 64)
            )
        ) { error in
            guard case NatalSpineArtifactError.parentIdentityMismatch = error else {
                return XCTFail("Expected parent identity mismatch, received \(error)")
            }
        }
    }

    private func mountedFixture() throws -> (
        SealedNatalSpine,
        NatalSpineRuntime,
        NatalSpineArtifactReceipt
    ) {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("fixture.natalspine")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let runtime = try NatalSpineRuntime.mount(
            from: url,
            expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: receipt.parentSpineIdentity
        )
        return (sealed, runtime, receipt)
    }

    private func temporaryURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("NatalSpineTests-\(UUID().uuidString)-\(name)")
    }
}
