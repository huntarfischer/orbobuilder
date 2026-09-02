import XCTest
@testable import OrboCore
@testable import OrboIris

final class IrisTwinPortFrameTests: XCTestCase {
    func testIrisPreservesApolloAstrolabeSignalExactly() {
        let subject = Apollo.placeOnAstrolabe(identity: "subject-x")
        let port = Apollo.signalForIris(subject)

        let frame = IrisAstrolabeFrame(port: port)

        XCTAssertEqual(frame.signal, port.signal)
        XCTAssertEqual(frame.subject, subject)
    }

    func testIrisPreservesArtemisLunarPaneSignalExactly() {
        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")
        let received = Apollo.presentToArtemis(onAstrolabe)
        let port = Artemis.signalForIris(received)

        let frame = IrisLunarPaneFrame(port: port)

        XCTAssertEqual(frame.signal, port.signal)
        XCTAssertEqual(frame.subject, received)
        XCTAssertEqual(frame.subject, onAstrolabe)
    }
}
