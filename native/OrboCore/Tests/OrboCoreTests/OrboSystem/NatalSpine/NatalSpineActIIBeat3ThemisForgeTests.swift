import XCTest
@testable import OrboCore

final class NatalSpineActIIBeat3ThemisForgeTests: XCTestCase {
    func testHephaestusForgesEveryCertifiedThemisSpanExactlyOnce() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = NatalSpineActIIFixture.substrate(for: commission)

        let layer = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )

        let source = commission.schematics.themis.spans
        XCTAssertEqual(layer.subjectID, commission.subjectID)
        XCTAssertEqual(layer.bounds, commission.schematics.bounds)
        XCTAssertEqual(layer.themis.count, source.count)
        XCTAssertEqual(layer.themis.map(\.sourceRow), Array(source.indices))
        XCTAssertEqual(layer.themis.map(\.span), source)
    }

    func testForgedThemisSpanPreservesBodyHouseAndBoundaries() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let layer = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: NatalSpineActIIFixture.substrate(for: commission)
        )

        for forged in layer.themis {
            let source = commission.schematics.themis.spans[forged.sourceRow]
            XCTAssertEqual(forged.span.body, source.body)
            XCTAssertEqual(forged.span.house, source.house)
            XCTAssertEqual(forged.span.start, source.start)
            XCTAssertEqual(forged.span.end, source.end)
        }
    }

    func testHephaestusRejectsSubstrateFromDifferentNative() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = NatalSpineActIIFixture.substrate(for: commission)
        let foreign = HermesSubjectID(rawValue: "natal-spine.other")!
        let altered = NatalSpineCelestialSubstrate(
            subjectID: foreign,
            bounds: NatalSpineBounds(
                subjectID: foreign,
                start: substrate.bounds.start,
                natal: substrate.bounds.natal,
                end: substrate.bounds.end
            )!,
            supports: substrate.supports,
            stations: substrate.stations,
            boundaryAnchors: substrate.boundaryAnchors,
            parentProvenance: substrate.parentProvenance
        )!

        XCTAssertThrowsError(
            try Hephaestus.forgeNatalSpineThemis(for: commission, on: altered)
        ) { error in
            XCTAssertEqual(error as? NatalSpineThemisForgeFailure, .substrateMismatch)
        }
    }
}
