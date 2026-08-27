import XCTest
@testable import OrboCore

final class HecateStage0Tests: XCTestCase {
    private let resourceA = HecateResourceKey(rawValue: "resource-a")!
    private let resourceB = HecateResourceKey(rawValue: "resource-b")!

    func testKleidesBeginsWithAstroDNALotsAndPartsFamilies() {
        XCTAssertEqual(KleisFamily.allCases, [.astroDNA, .lots, .parts])
    }

    func testKleisRequiresAUniqueNonEmptyResourceSet() {
        let id = KleisID(rawValue: "stage-0-kleis")!

        XCTAssertNil(
            Kleis(id: id, family: .lots, requiredResources: [])
        )
        XCTAssertNil(
            Kleis(
                id: id,
                family: .lots,
                requiredResources: [resourceA, resourceA]
            )
        )

        let kleis = Kleis(
            id: id,
            family: .lots,
            requiredResources: [resourceA, resourceB]
        )!

        XCTAssertEqual(kleis.family, .lots)
        XCTAssertEqual(kleis.requiredResources, [resourceA, resourceB])
    }

    func testKleidesRejectsDuplicateKleisIdentities() {
        let id = KleisID(rawValue: "same-kleis")!
        let first = Kleis(
            id: id,
            family: .lots,
            requiredResources: [resourceA]
        )!
        let second = Kleis(
            id: id,
            family: .parts,
            requiredResources: [resourceB]
        )!

        XCTAssertNil(Kleides([first, second]))
    }

    func testHecatePreparesKnownKleisOnlyWhenAllResourcesAreSupplied() throws {
        let id = KleisID(rawValue: "two-resource-kleis")!
        let kleis = Kleis(
            id: id,
            family: .parts,
            requiredResources: [resourceA, resourceB]
        )!
        let kleides = Kleides([kleis])!

        XCTAssertEqual(
            try Hecate.prepareCast(
                id,
                using: [resourceB, resourceA],
                from: kleides
            ),
            kleis
        )

        XCTAssertThrowsError(
            try Hecate.prepareCast(
                id,
                using: [resourceA],
                from: kleides
            )
        ) { error in
            XCTAssertEqual(
                error as? HecateFailure,
                .missingResources([self.resourceB])
            )
        }
    }

    func testHecateRejectsUnknownKleis() {
        let unknown = KleisID(rawValue: "unknown-kleis")!
        let kleides = Kleides()!

        XCTAssertThrowsError(
            try Hecate.prepareCast(
                unknown,
                using: [resourceA, resourceB],
                from: kleides
            )
        ) { error in
            XCTAssertEqual(
                error as? HecateFailure,
                .unknownKleis(unknown)
            )
        }
    }
}
