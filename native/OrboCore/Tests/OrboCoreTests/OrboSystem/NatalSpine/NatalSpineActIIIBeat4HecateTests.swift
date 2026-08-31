import XCTest
@testable import OrboCore

final class NatalSpineActIIIBeat4HecateTests: XCTestCase {
    func testHecateBlessesOnlyTheMatchingSealedAndIndexedSpine() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let before = spine
        let index = Chronos.indexNatalSpine(spine)
        let blessing = try Hecate.blessNatalSpine(spine, indexedBy: index)

        XCTAssertEqual(blessing.packageID, spine.packageID)
        XCTAssertEqual(blessing.subjectID, spine.subjectID)
        XCTAssertEqual(blessing.bounds, spine.bounds)
        XCTAssertEqual(blessing.parentProvenance, spine.seal.parentProvenance)
        XCTAssertEqual(spine, before)
    }

    func testIndexFromAnotherSealedSpineIsRejected() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        var other = try NatalSpineActIIIFixture.sealedSpine()

        // Package IDs are commission identities. Extremely defensively, rebuild
        // if UUID chance ever hands the fixtures the same package ID.
        while other.packageID == spine.packageID {
            other = try NatalSpineActIIIFixture.sealedSpine()
        }

        let wrongIndex = Chronos.indexNatalSpine(other)
        XCTAssertThrowsError(
            try Hecate.blessNatalSpine(spine, indexedBy: wrongIndex)
        ) { error in
            XCTAssertEqual(error as? NatalSpineHecateFailure, .packageMismatch)
        }
    }

    func testBlessingContainsNoReplacementSpineMatter() throws {
        let spine = try NatalSpineActIIIFixture.sealedSpine()
        let blessing = try Hecate.blessNatalSpine(
            spine,
            indexedBy: Chronos.indexNatalSpine(spine)
        )

        // The blessing carries only the identity/provenance needed to accept
        // lawful availability. Titan rows and celestial supports remain on Spine.
        XCTAssertEqual(blessing.packageID, spine.packageID)
        XCTAssertEqual(blessing.subjectID, spine.subjectID)
        XCTAssertEqual(blessing.bounds, spine.bounds)
        XCTAssertEqual(blessing.parentProvenance, spine.seal.parentProvenance)
    }
}
