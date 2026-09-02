import XCTest
@testable import OrboCore
@testable import OrboIris

final class HermesHomerPortTests: XCTestCase {
    func testUnknownTicketProducesNoHomerPOV() {
        let courier = HermesCourier()

        XCTAssertNil(courier.signalForHomer(ticketID: HermesTicketID()))
    }

    func testRealHermesJourneyTravelsThroughHomerAndIrisUnchanged() throws {
        var courier = HermesCourier()
        let package = try makePackage()
        let openedAt = instant(0)
        let ticketID = try courier.accept(package: package, occurredAt: openedAt)

        let port = try XCTUnwrap(courier.signalForHomer(ticketID: ticketID))
        let frame = IrisHomerFrame(port: Homer.POV(port))

        XCTAssertEqual(frame.pointOfView.ticketID, ticketID)
        XCTAssertEqual(frame.pointOfView.currentState, .unresolved)
        XCTAssertEqual(frame.pointOfView.events, courier.manifest.events(for: ticketID))
        XCTAssertEqual(frame.pointOfView.events.map(\.kind), [.ticketOpened])
        XCTAssertEqual(frame.pointOfView.events.first?.packageID, package.packageID)
        XCTAssertEqual(frame.pointOfView.events.first?.occurredAt, openedAt)
    }

    func testEarlierHermesHomerSnapshotDoesNotChangeAsJourneyAdvances() throws {
        var courier = HermesCourier()
        let package = try makePackage()
        let ticketID = try courier.accept(package: package, occurredAt: instant(0))

        let first = IrisHomerFrame(
            port: Homer.POV(try XCTUnwrap(courier.signalForHomer(ticketID: ticketID)))
        )

        let recipient = try courier.deliverNext(
            ticketID: ticketID,
            occurredAt: instant(60)
        )
        try courier.recordReceipt(
            ticketID: ticketID,
            packageID: package.packageID,
            recipient: recipient,
            receivedAt: instant(120)
        )

        let later = IrisHomerFrame(
            port: Homer.POV(try XCTUnwrap(courier.signalForHomer(ticketID: ticketID)))
        )

        XCTAssertEqual(first.pointOfView.currentState, .unresolved)
        XCTAssertEqual(first.pointOfView.events.map(\.kind), [.ticketOpened])

        XCTAssertEqual(later.pointOfView.currentState, .resolved)
        XCTAssertEqual(
            later.pointOfView.events.map(\.kind),
            [.ticketOpened, .deliveredToAddressee, .receiptRecorded, .resolved]
        )
    }

    private func makePackage() throws -> HermesPackage<HearthLitNotice> {
        let subjectID = try XCTUnwrap(HermesSubjectID(rawValue: "homer-hermes-subject"))
        return try XCTUnwrap(
            HermesPackage(
                packageID: HermesPackageID(),
                subjectID: subjectID,
                sender: Hestia.address,
                kind: Hestia.hearthLitNoticeKind,
                addresses: [OrboOnboarding.orboAddress],
                contents: HearthLitNotice(subjectID: subjectID)
            )
        )
    }

    private func instant(_ offset: Double) -> AbsoluteInstant {
        AbsoluteInstant(unixSecondsSince1970: 1_777_200_000 + offset)!
    }
}
