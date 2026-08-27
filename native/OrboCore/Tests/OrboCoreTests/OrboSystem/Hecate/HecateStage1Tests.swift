import XCTest
@testable import OrboCore

final class HecateStage1Tests: XCTestCase {
    func testAstroDNAKleisIsRegisteredFromCanonicalAstroDNAGenes() throws {
        let kleis = try XCTUnwrap(Kleides.canonical.kleis(AstroDNAKleis.id))

        XCTAssertEqual(kleis.family, .astroDNA)
        XCTAssertEqual(
            kleis.requiredResources,
            AstroDNAGene.canonicalOrder.map(AstroDNAKleis.resourceKey(for:))
        )
    }

    func testHecateCastsCanonicalAstroDNAFromTwelveSuppliedGenes() throws {
        let supplied = validGeneResources()
        let astroDNA = try Hecate.castAstroDNA(using: supplied)

        XCTAssertEqual(
            astroDNA.sequence,
            AstroDNAGene.canonicalOrder.map { supplied[$0]! }
        )
    }

    func testInputDictionaryOrderCannotChangeAstroDNASequence() throws {
        let canonical = validGeneResources()
        let reversed = Dictionary(
            uniqueKeysWithValues: AstroDNAGene.canonicalOrder.reversed().map { gene in
                (gene, canonical[gene]!)
            }
        )

        XCTAssertEqual(
            try Hecate.castAstroDNA(using: reversed),
            try Hecate.castAstroDNA(using: canonical)
        )
    }

    func testHecateRefusesAstroDNAWhenCanonicalGeneIsMissing() {
        var supplied = validGeneResources()
        supplied.removeValue(forKey: .northNode)

        XCTAssertThrowsError(
            try Hecate.castAstroDNA(using: supplied)
        ) { error in
            XCTAssertEqual(
                error as? HecateFailure,
                .missingResources([
                    AstroDNAKleis.resourceKey(for: .northNode),
                ])
            )
        }
    }

    func testHecateDefersInvalidAstroDNACombinationToExistingAstroDNALaw() {
        var supplied = validGeneResources()
        supplied[.ascendant] = RingFineState(Ring.arcseconds)!

        XCTAssertThrowsError(
            try Hecate.castAstroDNA(using: supplied)
        ) { error in
            XCTAssertEqual(
                error as? HecateFailure,
                .invalidCast(AstroDNAKleis.id)
            )
        }
    }

    private func validGeneResources() -> [AstroDNAGene: RingFineState] {
        Dictionary(
            uniqueKeysWithValues: AstroDNAGene.canonicalOrder.enumerated().map { index, gene in
                (gene, RingFineState(index * 1_000)!)
            }
        )
    }
}
