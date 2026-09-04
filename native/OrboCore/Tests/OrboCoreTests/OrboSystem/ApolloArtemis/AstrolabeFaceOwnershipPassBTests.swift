import XCTest
@testable import OrboCore

final class AstrolabeFaceOwnershipPassBTests: XCTestCase {
    func testApolloGovernsBothFacesWhileHermesGovernsInterconnection() {
        XCTAssertEqual(Apollo.governedInstrument, .astrolabe)
        XCTAssertEqual(Hermes.governedDomain, .interconnection)
    }
}
