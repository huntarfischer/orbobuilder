import XCTest
@testable import OrboCore
@testable import OrboIris

final class HomerSystemTests: XCTestCase {
    private struct CourierPOV: Hashable, Sendable {
        let packageID: String
        let state: String
    }

    private struct AuthorityPOV: Hashable, Sendable {
        let operation: String
        let result: Int
    }

    private enum TestCourierEntity {
        static func signalForHomer(packageID: String, state: String) -> HomerPort<CourierPOV> {
            HomerPort(pointOfView: CourierPOV(packageID: packageID, state: state))
        }
    }

    private enum TestAuthorityEntity {
        static func signalForHomer(operation: String, result: Int) -> HomerPort<AuthorityPOV> {
            HomerPort(pointOfView: AuthorityPOV(operation: operation, result: result))
        }
    }

    func testEntityAuthoredPOVTravelsThroughHomerAndIrisUnchanged() {
        let sourcePort = TestCourierEntity.signalForHomer(
            packageID: "package-7",
            state: "in-custody"
        )

        let homerIrisPort = Homer.POV(sourcePort)
        let irisFrame = IrisHomerFrame(port: homerIrisPort)

        XCTAssertEqual(sourcePort.pointOfView.packageID, "package-7")
        XCTAssertEqual(homerIrisPort.signal, sourcePort.pointOfView)
        XCTAssertEqual(irisFrame.pointOfView, sourcePort.pointOfView)
    }

    func testOneHomerPathCarriesUnrelatedPOVTypesWithoutRegistryOrPantheonEnum() {
        let courierPort = TestCourierEntity.signalForHomer(
            packageID: "package-9",
            state: "resolved"
        )
        let authorityPort = TestAuthorityEntity.signalForHomer(
            operation: "cast",
            result: 42
        )

        let courierFrame = IrisHomerFrame(port: Homer.POV(courierPort))
        let authorityFrame = IrisHomerFrame(port: Homer.POV(authorityPort))

        XCTAssertEqual(courierFrame.pointOfView.state, "resolved")
        XCTAssertEqual(authorityFrame.pointOfView.operation, "cast")
        XCTAssertEqual(authorityFrame.pointOfView.result, 42)
    }

    func testLaterEntitySnapshotCannotRewriteEarlierHomerOrIrisSnapshot() {
        let firstPort = TestCourierEntity.signalForHomer(
            packageID: "package-10",
            state: "opened"
        )
        let firstHomerIrisPort = Homer.POV(firstPort)
        let firstFrame = IrisHomerFrame(port: firstHomerIrisPort)

        let laterPort = TestCourierEntity.signalForHomer(
            packageID: "package-10",
            state: "resolved"
        )
        let laterFrame = IrisHomerFrame(port: Homer.POV(laterPort))

        XCTAssertEqual(firstPort.pointOfView.state, "opened")
        XCTAssertEqual(firstHomerIrisPort.signal.state, "opened")
        XCTAssertEqual(firstFrame.pointOfView.state, "opened")
        XCTAssertEqual(laterFrame.pointOfView.state, "resolved")
    }

    func testHomerAddsNoIdentityOrPresentationMatterToEntityPOV() {
        let sourcePort = TestAuthorityEntity.signalForHomer(
            operation: "verify",
            result: 1
        )

        let frame = IrisHomerFrame(port: Homer.POV(sourcePort))

        XCTAssertEqual(frame.pointOfView, sourcePort.pointOfView)
    }
}
