import XCTest
@testable import OrboCore

final class HomerPortTests: XCTestCase {
    private struct SamplePOV: Hashable, Sendable {
        let identifier: Int
        let label: String
    }

    private struct AlternatePOV: Hashable, Sendable {
        let count: Int
    }

    func testHomerPortPreservesTypedPointOfViewExactly() {
        let pointOfView = SamplePOV(identifier: 7, label: "Hermes")

        let port = HomerPort(pointOfView: pointOfView)

        XCTAssertEqual(port.pointOfView, pointOfView)
    }

    func testSameHomerPortStandardCarriesDifferentTypedPointsOfViewWithoutErasure() {
        let first = HomerPort(pointOfView: SamplePOV(identifier: 3, label: "Hecate"))
        let second = HomerPort(pointOfView: AlternatePOV(count: 12))

        XCTAssertEqual(first.pointOfView.label, "Hecate")
        XCTAssertEqual(second.pointOfView.count, 12)
    }

    func testHomerPOVRelaysExactSnapshotIntoStandardIrisPort() {
        let pointOfView = SamplePOV(identifier: 11, label: "Orbo")
        let homerPort = HomerPort(pointOfView: pointOfView)

        let irisPort = Homer.POV(homerPort)

        XCTAssertEqual(irisPort.signal, pointOfView)
    }

    func testSuccessivePOVsRemainIndependentSnapshots() {
        let firstPointOfView = SamplePOV(identifier: 1, label: "first")
        let secondPointOfView = SamplePOV(identifier: 2, label: "second")

        let firstIrisPort = Homer.POV(HomerPort(pointOfView: firstPointOfView))
        let secondIrisPort = Homer.POV(HomerPort(pointOfView: secondPointOfView))

        XCTAssertEqual(firstIrisPort.signal, firstPointOfView)
        XCTAssertEqual(secondIrisPort.signal, secondPointOfView)
        XCTAssertNotEqual(firstIrisPort, secondIrisPort)
    }

    func testSnapshotDoesNotBecomeLeashWhenSourceValueChangesLater() {
        var source = SamplePOV(identifier: 5, label: "before")
        let homerPort = HomerPort(pointOfView: source)
        let irisPort = Homer.POV(homerPort)

        source = SamplePOV(identifier: 6, label: "after")

        XCTAssertEqual(homerPort.pointOfView.label, "before")
        XCTAssertEqual(irisPort.signal.label, "before")
        XCTAssertEqual(source.label, "after")
    }
}
