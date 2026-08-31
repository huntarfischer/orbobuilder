import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat8SealTests: XCTestCase {
    func testHephaestusSealsOnlyTheDioscuriApprovedCandidate() throws {
        let candidate = try NatalSpineActIIFixture.addressableCandidate()
        let parent = NatalSpineActIIFixture.parentSource(for: candidate.substrate)
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: candidate.commission.schematics,
            parent: parent
        ).get()

        let sealed = Hephaestus.sealNatalSpine(approval)

        XCTAssertEqual(sealed.packageID, candidate.commission.packageID)
        XCTAssertEqual(sealed.subjectID, candidate.subjectID)
        XCTAssertEqual(sealed.bounds, candidate.bounds)
        XCTAssertEqual(sealed.seal.parentProvenance, candidate.substrate.parentProvenance)
        XCTAssertEqual(sealed.seal.themisCount, candidate.themis.count)
        XCTAssertEqual(sealed.seal.oceanusCount, candidate.oceanus.count)
        XCTAssertEqual(sealed.seal.rheaCount, candidate.rhea.count)
        XCTAssertEqual(sealed.candidate.themis, candidate.themis)
        XCTAssertEqual(sealed.candidate.oceanus, candidate.oceanus)
        XCTAssertEqual(sealed.candidate.rhea, candidate.rhea)
    }

    func testDioscuriRejectionCannotProduceApprovalForSeal() throws {
        let candidate = try NatalSpineActIIFixture.addressableCandidate()
        let parent = NatalSpineActIIFixture.parentSource(for: candidate.substrate)
        let matter = NatalSpineDioscuriMatter(
            subjectID: candidate.subjectID,
            bounds: candidate.bounds,
            substrate: candidate.substrate,
            themis: Array(candidate.themis.dropLast()),
            oceanus: candidate.oceanus,
            rhea: candidate.rhea
        )

        switch Dioscuri.inspectNatalSpine(
            matter,
            against: candidate.commission.schematics,
            parent: parent
        ) {
        case .success:
            XCTFail("A divergent candidate must not cross the Dioscuri boundary to Hephaestus sealing.")
        case let .failure(failure):
            XCTAssertEqual(failure, .themisCountMismatch)
        }
    }

    func testSealBindsCertifiedSourceCardinalitiesNotNewForgeMatter() throws {
        let candidate = try NatalSpineActIIFixture.addressableCandidate()
        let parent = NatalSpineActIIFixture.parentSource(for: candidate.substrate)
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: candidate.commission.schematics,
            parent: parent
        ).get()
        let sealed = Hephaestus.sealNatalSpine(approval)

        XCTAssertEqual(sealed.seal.themisCount, candidate.commission.schematics.themis.declaredCount)
        XCTAssertEqual(sealed.seal.oceanusCount, candidate.commission.schematics.oceanus.declaredCount)
        XCTAssertEqual(sealed.seal.rheaCount, candidate.commission.schematics.rhea.declaredCount)
    }
}
