import XCTest
@testable import OrboCore

final class IrisPortTests: XCTestCase {
    private struct SampleSignal: Hashable, Sendable {
        let identifier: Int
        let label: String
    }

    func testPortPreservesTypedSignalExactly() {
        let signal = SampleSignal(identifier: 7, label: "Horae")
        let port = IrisPort(signal: signal)

        XCTAssertEqual(port.signal, signal)
    }

    func testSameConnectorCarriesDifferentTypedSignalsWithoutErasure() {
        let numericPort = IrisPort(signal: 42)
        let samplePort = IrisPort(
            signal: SampleSignal(identifier: 3, label: "Artemis")
        )

        XCTAssertEqual(numericPort.signal, 42)
        XCTAssertEqual(samplePort.signal.identifier, 3)
        XCTAssertEqual(samplePort.signal.label, "Artemis")
    }
}
