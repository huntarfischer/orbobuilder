import XCTest
@testable import OrboCore
@testable import OrboIris

final class HomerDiagnosticSessionTests: XCTestCase {
    private enum OtherLocation: HomerDiagnosticLocation {
        static let homerLocationID = HomerLocationID(rawValue: "Other")!
    }

    func testHomerOccupiesExactlyOneLocationAtATime() throws {
        var homer = HomerDiagnosticSession()

        XCTAssertNil(homer.currentLocation)
        XCTAssertTrue(homer.history.isEmpty)

        try homer.enter(HermesHomerLocation.self, occurredAt: instant(0))
        XCTAssertEqual(homer.currentLocation, HermesHomerLocation.homerLocationID)
        XCTAssertEqual(homer.history.map(\.kind), [.entered])

        XCTAssertThrowsError(
            try homer.enter(OtherLocation.self, occurredAt: instant(10))
        ) { error in
            XCTAssertEqual(error as? HomerDiagnosticSession.Failure, .alreadyLocated)
        }

        try homer.leave(occurredAt: instant(20))
        XCTAssertNil(homer.currentLocation)
        XCTAssertEqual(homer.history.map(\.kind), [.entered, .left])
        XCTAssertEqual(homer.history.map(\.sequence), [1, 2])

        try homer.enter(OtherLocation.self, occurredAt: instant(30))
        XCTAssertEqual(homer.currentLocation, OtherLocation.homerLocationID)
        XCTAssertEqual(homer.history.map(\.kind), [.entered, .left, .entered])
    }

    func testHermesControlsCannotBeUsedFromAnotherLocation() throws {
        var homer = HomerDiagnosticSession()
        var courier = HermesCourier()
        let package = try makePackage()

        try homer.enter(OtherLocation.self, occurredAt: instant(0))

        XCTAssertThrowsError(
            try HermesHomerControls.accept(
                session: &homer,
                courier: &courier,
                package: package,
                occurredAt: instant(10)
            )
        ) { error in
            XCTAssertEqual(error as? HomerDiagnosticSession.Failure, .wrongLocation)
        }

        XCTAssertTrue(courier.manifest.unresolvedTickets().isEmpty)
        XCTAssertEqual(homer.history.map(\.kind), [.entered])
    }

    func testHermesSeatDrivesTheRealCourierAndRecordsOnlyHomersOwnJourney() throws {
        var homer = HomerDiagnosticSession()
        var courier = HermesCourier()
        let package = try makePackage()

        try homer.enter(HermesHomerLocation.self, occurredAt: instant(0))

        let ticketID = try HermesHomerControls.accept(
            session: &homer,
            courier: &courier,
            package: package,
            occurredAt: instant(10)
        )

        let openedPort = try HermesHomerControls.inspectJourney(
            session: &homer,
            courier: courier,
            ticketID: ticketID,
            occurredAt: instant(20)
        )
        let opened = IrisHomerFrame(port: Homer.POV(openedPort))
        XCTAssertEqual(opened.pointOfView.events.map(\.kind), [.ticketOpened])

        let stop = try HermesHomerControls.deliverNext(
            session: &homer,
            courier: &courier,
            ticketID: ticketID,
            occurredAt: instant(30)
        )
        XCTAssertEqual(stop, package.addresses[0])

        try HermesHomerControls.recover(
            session: &homer,
            courier: &courier,
            ticketID: ticketID,
            package: package,
            occurredAt: instant(40)
        )

        let recipient = try HermesHomerControls.deliverNext(
            session: &homer,
            courier: &courier,
            ticketID: ticketID,
            occurredAt: instant(50)
        )
        XCTAssertEqual(recipient, package.addresses[1])

        try HermesHomerControls.recordReceipt(
            session: &homer,
            courier: &courier,
            ticketID: ticketID,
            packageID: package.packageID,
            recipient: recipient,
            receivedAt: instant(60)
        )

        let resolvedPort = try HermesHomerControls.inspectJourney(
            session: &homer,
            courier: courier,
            ticketID: ticketID,
            occurredAt: instant(70)
        )
        let resolved = IrisHomerFrame(port: Homer.POV(resolvedPort))
        XCTAssertEqual(resolved.pointOfView.currentState, .resolved)
        XCTAssertEqual(
            resolved.pointOfView.events.map(\.kind),
            [
                .ticketOpened,
                .deliveredToStop,
                .recoveredFromStop,
                .deliveredToAddressee,
                .receiptRecorded,
                .resolved,
            ]
        )

        try homer.leave(occurredAt: instant(80))

        XCTAssertNil(homer.currentLocation)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .resolved)
        XCTAssertEqual(
            homer.history.map(\.kind),
            [.entered, .acted, .inspected, .acted, .acted, .acted, .acted, .inspected, .left]
        )
        XCTAssertEqual(
            homer.history.map(\.actionID),
            [
                nil,
                HermesHomerControls.acceptPackageAction,
                HermesHomerControls.inspectJourneyAction,
                HermesHomerControls.deliverNextAction,
                HermesHomerControls.recoverPackageAction,
                HermesHomerControls.deliverNextAction,
                HermesHomerControls.recordReceiptAction,
                HermesHomerControls.inspectJourneyAction,
                nil,
            ]
        )
        XCTAssertEqual(homer.history.map(\.sequence), Array(1...9))
        XCTAssertEqual(
            Mirror(reflecting: homer.history[1]).children.compactMap(\.label),
            ["sequence", "kind", "locationID", "actionID", "occurredAt"]
        )
    }

    private func makePackage() throws -> HermesPackage<String> {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: "homer-driver-seat"))
        let sender = try XCTUnwrap(HermesAddress(rawValue: "driver-seat-sender"))
        let stop = try XCTUnwrap(HermesAddress(rawValue: "driver-seat-stop"))
        let recipient = try XCTUnwrap(HermesAddress(rawValue: "driver-seat-recipient"))
        let kind = try XCTUnwrap(HermesPackageKind(rawValue: "driver-seat-package"))

        return try XCTUnwrap(
            HermesPackage(
                packageID: HermesPackageID(),
                subjectID: subjectID,
                sender: sender,
                kind: kind,
                addresses: [stop, recipient],
                contents: "payload"
            )
        )
    }

    private func instant(_ offset: Double) -> AbsoluteInstant {
        AbsoluteInstant(unixSecondsSince1970: 1_777_400_000 + offset)!
    }
}
