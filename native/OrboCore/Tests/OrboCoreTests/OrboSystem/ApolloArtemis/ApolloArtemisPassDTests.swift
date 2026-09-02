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

        let frame = Artemis.signalForIris(received)

        XCTAssertEqual(frame.subject, received)
        XCTAssertEqual(frame.subject, onAstrolabe)
    }

    func testTwinPortsMayExposeSuccessiveLawfulFramesWithoutRetainingState() {
        let first = Apollo.placeOnAstrolabe(identity: "subject-a")
        let second = Apollo.placeOnAstrolabe(identity: "subject-b")

        let firstAstrolabePort = Apollo.signalForIris(first)
        let secondAstrolabePort = Apollo.signalForIris(second)
        let firstLunarFrame = Artemis.signalForIris(Apollo.presentToArtemis(first))
        let secondLunarFrame = Artemis.signalForIris(Apollo.presentToArtemis(second))

        XCTAssertEqual(firstAstrolabePort.signal.subject, first)
        XCTAssertEqual(secondAstrolabePort.signal.subject, second)
        XCTAssertNotEqual(firstAstrolabePort, secondAstrolabePort)
        XCTAssertEqual(firstLunarFrame.subject, first)
        XCTAssertEqual(secondLunarFrame.subject, second)
        XCTAssertNotEqual(firstLunarFrame, secondLunarFrame)
    }
}
