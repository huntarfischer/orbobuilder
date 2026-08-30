import XCTest
@testable import OrboCore

final class AstrolabeFaceOwnershipPassBTests: XCTestCase {
    func testApolloGovernsAegisAndHermesGovernsTabula() {
        XCTAssertEqual(Apollo.governedInstrument, .aegis)
        XCTAssertEqual(Hermes.governedDomain, .tabula)
    }
}
