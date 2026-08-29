import XCTest
@testable import OrboCore

final class ApolloArtemisPassDTests: XCTestCase {
    func testApolloIrisPortCarriesExistingAstrolabeSubjectUnchanged() {
        let subject = Apollo.placeOnAstrolabe(identity: "subject-x")

        let frame = Apollo.signalForIris(subject)

        XCTAssertEqual(frame.subject, subject)
        XCTAssertEqual(frame.subject.rawValue, "subject-x")
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

        let firstAstrolabeFrame = Apollo.signalForIris(first)
        let secondAstrolabeFrame = Apollo.signalForIris(second)
        let firstLunarFrame = Artemis.signalForIris(Apollo.presentToArtemis(first))
        let secondLunarFrame = Artemis.signalForIris(Apollo.presentToArtemis(second))

        XCTAssertEqual(firstAstrolabeFrame.subject, first)
        XCTAssertEqual(secondAstrolabeFrame.subject, second)
        XCTAssertNotEqual(firstAstrolabeFrame, secondAstrolabeFrame)
        XCTAssertEqual(firstLunarFrame.subject, first)
        XCTAssertEqual(secondLunarFrame.subject, second)
        XCTAssertNotEqual(firstLunarFrame, secondLunarFrame)
    }
}
