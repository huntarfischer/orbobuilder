import XCTest
@testable import OrboCore

final class ApolloArtemisPassCTests: XCTestCase {
    func testApolloRemainsThePublicSourceOfWhatArtemisReceivesFromTheAstrolabe() {
        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")

        let received = Apollo.presentToArtemis(onAstrolabe)

        XCTAssertEqual(received, onAstrolabe)
        XCTAssertEqual(received.rawValue, "subject-x")
    }

    func testNeighborClarificationDoesNotReplaceWhatApolloPassedToArtemis() throws {
        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")
        let beforeClarification = Apollo.presentToArtemis(onAstrolabe)

        let fortuneID = try XCTUnwrap(KleisID(rawValue: "Fortune"))
        let clarification = try XCTUnwrap(Artemis.askHecate(fortuneID))

        let afterClarification = Apollo.presentToArtemis(onAstrolabe)

        XCTAssertEqual(clarification, Hecate.inquire(fortuneID))
        XCTAssertEqual(beforeClarification, onAstrolabe)
        XCTAssertEqual(afterClarification, onAstrolabe)
    }

    func testSharedNeighborhoodDoesNotCreateASecondTwinSubject() {
        _ = Artemis.Neighborhood.horae
        _ = Artemis.Neighborhood.hecate
        _ = Artemis.Neighborhood.hestia
        _ = Artemis.Neighborhood.themis
        _ = Artemis.Neighborhood.rhea
        _ = Artemis.Neighborhood.oceanus
        _ = Artemis.Neighborhood.asteria

        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")

        XCTAssertEqual(Apollo.presentToArtemis(onAstrolabe), onAstrolabe)
    }
}
