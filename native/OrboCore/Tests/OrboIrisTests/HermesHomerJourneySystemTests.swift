import XCTest
@testable import OrboCore
@testable import OrboIris

final class HermesHomerJourneySystemTests: XCTestCase {
    func testHearthLitJourneyHistoryIsVisibleOnlyAsHermesOwnedManifestTruth() throws {
        let native = try XCTUnwrap(HermesSubjectID(rawValue: "homer-hermes-real-journey"))
        let worked = try HestiaCanonicalPersistenceFixture.canonicalWorkedPackage(
            subjectID: native
        )
        var hestia = Hestia(nativeSubjectID: native)
        var courier = HermesCourier()

        let notice = try hestia.receiveAndAnnounce(
            worked,
            to: OrboOnboarding.orboAddress,
            via: &courier,
            occurredAt: instant(0)
        )

        let opened = IrisHomerFrame(
            port: Homer.POV(try XCTUnwrap(courier.signalForHomer(ticketID: notice.ticketID)))
        )
        XCTAssertEqual(opened.pointOfView.currentState, .unresolved)
        XCTAssertEqual(opened.pointOfView.events.map(\.kind), [.ticketOpened])
        XCTAssertEqual(opened.pointOfView.events.first?.packageID, notice.package.packageID)

        let recipient = try courier.deliverNext(
            ticketID: notice.ticketID,
            occurredAt: instant(60)
        )
        XCTAssertEqual(recipient, OrboOnboarding.orboAddress)

        let delivered = IrisHomerFrame(
            port: Homer.POV(try XCTUnwrap(courier.signalForHomer(ticketID: notice.ticketID)))
        )
        XCTAssertEqual(
            delivered.pointOfView.events.map(\.kind),
            [.ticketOpened, .deliveredToAddressee]
        )
        XCTAssertEqual(delivered.pointOfView.events.last?.address, OrboOnboarding.orboAddress)

        try courier.recordReceipt(
            ticketID: notice.ticketID,
            packageID: notice.package.packageID,
            recipient: recipient,
            receivedAt: instant(120)
        )

        let resolved = IrisHomerFrame(
            port: Homer.POV(try XCTUnwrap(courier.signalForHomer(ticketID: notice.ticketID)))
        )
        XCTAssertEqual(resolved.pointOfView.currentState, .resolved)
        XCTAssertEqual(
            resolved.pointOfView.events.map(\.kind),
            [.ticketOpened, .deliveredToAddressee, .receiptRecorded, .resolved]
        )

        XCTAssertEqual(opened.pointOfView.events.map(\.kind), [.ticketOpened])
        XCTAssertEqual(
            Mirror(reflecting: resolved.pointOfView).children.compactMap(\.label),
            ["ticketID", "currentState", "events"]
        )
    }

    private func instant(_ offset: Double) -> AbsoluteInstant {
        AbsoluteInstant(unixSecondsSince1970: 1_777_300_000 + offset)!
    }
}
