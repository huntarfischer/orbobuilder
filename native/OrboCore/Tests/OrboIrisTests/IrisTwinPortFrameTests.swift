import XCTest
@testable import OrboCore
@testable import OrboIris

final class IrisTwinPortFrameTests: XCTestCase {
    func testIrisPreservesApolloAstrolabeSignalExactly() {
        let subject = Apollo.placeOnAstrolabe(identity: "subject-x")
        let signal = Apollo.signalForIris(subject)

        let frame = IrisAstrolabeFrame(signal: signal)

        XCTAssertEqual(frame.signal, signal)
        XCTAssertEqual(frame.subject, subject)
    }

    func testIrisPreservesArtemisLunarPaneSignalExactly() {
        let onAstrolabe = Apollo.placeOnAstrolabe(identity: "subject-x")
        let received = Apollo.presentToArtemis(onAstrolabe)
        let signal = Artemis.signalForIris(received)

        let frame = IrisLunarPaneFrame(signal: signal)

        XCTAssertEqual(frame.signal, signal)
        XCTAssertEqual(frame.subject, received)
        XCTAssertEqual(frame.subject, onAstrolabe)
    }
}
