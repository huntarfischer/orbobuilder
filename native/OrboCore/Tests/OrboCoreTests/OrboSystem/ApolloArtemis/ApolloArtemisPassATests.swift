import XCTest
@testable import OrboCore

final class ApolloArtemisPassATests: XCTestCase {
    func testApolloExistsAndGovernsAstrolabe() {
        XCTAssertEqual(Apollo.governedInstrument, .astrolabe)
    }

    func testArtemisExistsAndGovernsLunarPane() {
        XCTAssertEqual(Artemis.governedInstrument, .lunarPane)
    }

    func testApolloEstablishesWhatIsOnTheAstrolabe() {
        let subject = Apollo.placeOnAstrolabe(identity: "subject-x")

        XCTAssertEqual(subject.rawValue, "subject-x")
    }

    func testArtemisReceivesExactlyWhatApolloPlacedOnTheAstrolabe() {
        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")
        let received = Apollo.presentToArtemis(onAstrolabe)

        XCTAssertEqual(received, onAstrolabe)
        XCTAssertEqual(received.rawValue, "subject-x")
    }
}
