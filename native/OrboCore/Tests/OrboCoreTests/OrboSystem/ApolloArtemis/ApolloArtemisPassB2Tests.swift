import XCTest
@testable import OrboCore

final class ApolloArtemisPassB2Tests: XCTestCase {
    func testApolloNamesTheSharedSevenNeighborTypes() {
        XCTAssertTrue(Apollo.Neighborhood.horae == Horae.self)
        XCTAssertTrue(Apollo.Neighborhood.hecate == Hecate.self)
        XCTAssertTrue(Apollo.Neighborhood.hestia == Hestia.self)
        XCTAssertTrue(Apollo.Neighborhood.themis == Themis.self)
        XCTAssertTrue(Apollo.Neighborhood.rhea == Rhea.self)
        XCTAssertTrue(Apollo.Neighborhood.oceanus == Oceanus.self)
        XCTAssertTrue(Apollo.Neighborhood.asteria == Asteria.self)
    }

    func testArtemisNamesTheSharedSevenNeighborTypes() {
        XCTAssertTrue(Artemis.Neighborhood.horae == Horae.self)
        XCTAssertTrue(Artemis.Neighborhood.hecate == Hecate.self)
        XCTAssertTrue(Artemis.Neighborhood.hestia == Hestia.self)
        XCTAssertTrue(Artemis.Neighborhood.themis == Themis.self)
        XCTAssertTrue(Artemis.Neighborhood.rhea == Rhea.self)
        XCTAssertTrue(Artemis.Neighborhood.oceanus == Oceanus.self)
        XCTAssertTrue(Artemis.Neighborhood.asteria == Asteria.self)
    }

    func testTwinNeighborhoodsAreSymmetricByLivingType() {
        XCTAssertTrue(Apollo.Neighborhood.horae == Artemis.Neighborhood.horae)
        XCTAssertTrue(Apollo.Neighborhood.hecate == Artemis.Neighborhood.hecate)
        XCTAssertTrue(Apollo.Neighborhood.hestia == Artemis.Neighborhood.hestia)
        XCTAssertTrue(Apollo.Neighborhood.themis == Artemis.Neighborhood.themis)
        XCTAssertTrue(Apollo.Neighborhood.rhea == Artemis.Neighborhood.rhea)
        XCTAssertTrue(Apollo.Neighborhood.oceanus == Artemis.Neighborhood.oceanus)
        XCTAssertTrue(Apollo.Neighborhood.asteria == Artemis.Neighborhood.asteria)
    }
}
