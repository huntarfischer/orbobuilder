import XCTest
@testable import OrboCore

final class ApolloArtemisPassDTests: XCTestCase {
    func testApolloIrisPortCarriesExistingAstrolabeSubjectUnchanged() {
        let subject = Apollo.placeOnAstrolabe(identity: "subject-x")

        let port = Apollo.signalForIris(subject)

        XCTAssertEqual(port.signal.subject, subject)
        XCTAssertEqual(port.signal.subject.rawValue, "subject-x")
    }

    func testArtemisIrisPortCarriesApolloSourcedSubjectUnchanged() {
        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")
        let received = Apollo.presentToArtemis(onAstrolabe)

        let port = Artemis.signalForIris(received)

        XCTAssertEqual(port.signal.subject, received)
        XCTAssertEqual(port.signal.subject, onAstrolabe)
    }

    func testTwinPortsMayExposeSuccessiveLawfulFramesWithoutRetainingState() {
        let first = Apollo.placeOnAstrolabe(identity: "subject-a")
        let second = Apollo.placeOnAstrolabe(identity: "subject-b")

        let firstAstrolabePort = Apollo.signalForIris(first)
        let secondAstrolabePort = Apollo.signalForIris(second)
        let firstLunarPort = Artemis.signalForIris(Apollo.presentToArtemis(first))
        let secondLunarPort = Artemis.signalForIris(Apollo.presentToArtemis(second))

        XCTAssertEqual(firstAstrolabePort.signal.subject, first)
        XCTAssertEqual(secondAstrolabePort.signal.subject, second)
        XCTAssertNotEqual(firstAstrolabePort, secondAstrolabePort)
        XCTAssertEqual(firstLunarPort.signal.subject, first)
        XCTAssertEqual(secondLunarPort.signal.subject, second)
        XCTAssertNotEqual(firstLunarPort, secondLunarPort)
    }
}
