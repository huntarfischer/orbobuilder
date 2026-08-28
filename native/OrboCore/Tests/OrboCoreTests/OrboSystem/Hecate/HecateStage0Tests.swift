import XCTest
@testable import OrboCore

final class HecateStage0Tests: XCTestCase {
    private let resourceA = HecateResourceKey(rawValue: "resource-a")!
    private let resourceB = HecateResourceKey(rawValue: "resource-b")!

    func testKleidesBeginsWithAstroDNALotsPartsAndSectFamilies() {
        XCTAssertEqual(KleisFamily.allCases, [.astroDNA, .lots, .parts, .sect])
    }

    func testFormulaRequiresAUniqueNonEmptyResourceSet() {
        XCTAssertNil(makeFormula(requiredResources: []))
        XCTAssertNil(makeFormula(requiredResources: [resourceA, resourceA]))

        let formula = makeFormula(requiredResources: [resourceA, resourceB])!
        XCTAssertEqual(formula.requiredResources, [resourceA, resourceB])
    }

    func testKleidesRejectsDuplicateKleisIdentities() {
        let id = KleisID(rawValue: "same-kleis")!
        let first = makeKleis(id: id, family: .lots, requiredResources: [resourceA])
        let second = makeKleis(id: id, family: .parts, requiredResources: [resourceB])

        XCTAssertNil(Kleides([first, second]))
    }

    func testHecatePreparesKnownKleisOnlyWhenAllResourcesAreSupplied() throws {
        let id = KleisID(rawValue: "two-resource-kleis")!
        let kleis = makeKleis(
            id: id,
            family: .parts,
            requiredResources: [resourceA, resourceB]
        )
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

    private func makeFormula(
        requiredResources: [HecateResourceKey]
    ) -> KleisFormula? {
        KleisFormula(
            requiredResources: requiredResources,
            formula: "stage-0 test formula",
            tradition: "Stage 0",
            sectRule: .none,
            isOrboDefault: false,
            sources: ["Hecate Stage 0 test"],
            status: .complete
        )
    }

    private func makeKleis(
        id: KleisID,
        family: KleisFamily,
        requiredResources: [HecateResourceKey]
    ) -> Kleis {
        Kleis(
            id: id,
            family: family,
            context: .natal,
            availability: KleisAvailability(l1: false, l2: false, l3: true)!,
            formulas: [makeFormula(requiredResources: requiredResources)!]
        )!
    }
}
