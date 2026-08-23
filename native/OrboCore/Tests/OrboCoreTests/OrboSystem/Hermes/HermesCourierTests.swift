import XCTest
@testable import OrboCore

final class HermesCourierTests: XCTestCase {
    private let packageID = HermesPackageID(UUID(uuidString: "00000000-0000-0000-0000-000000000301")!)
    private let otherPackageID = HermesPackageID(UUID(uuidString: "00000000-0000-0000-0000-000000000302")!)
    private let subject = HermesSubjectID(rawValue: "subject.native")!
    private let otherSubject = HermesSubjectID(rawValue: "subject.other")!
    private let orbo = HermesAddress(rawValue: "orbo")!
    private let otherSender = HermesAddress(rawValue: "orbo.other")!
    private let atlas = HermesAddress(rawValue: "orbo.atlas")!
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestia = HermesAddress(rawValue: "orbo.hestia")!
    private let instant = AbsoluteInstant(unixSecondsSince1970: 0)!

    private var itinerary: [HermesAddress] { [atlas, moirai, hestia] }

    func testPackagePreservesIdentityItineraryAndContents() {
        let package = makePackage(contents: "engraving")

        XCTAssertEqual(package.packageID, packageID)
        XCTAssertEqual(package.subjectID, subject)
        XCTAssertEqual(package.sender, orbo)
        XCTAssertEqual(package.addresses, itinerary)
        XCTAssertEqual(package.contents, "engraving")
    }

    func testPackageRequiresAtLeastOneAddress() {
        XCTAssertNil(
            HermesPackage(
                packageID: packageID,
                subjectID: subject,
                sender: orbo,
                addresses: [],
                contents: "engraving"
            )
        )
    }

    func testAcceptOpensManifestTicketForEntrustedPackage() throws {
        var courier = HermesCourier()
        let package = makePackage(contents: "engraving")

        let ticketID = try courier.accept(package: package, occurredAt: instant)
        let events = courier.manifest.events(for: ticketID)

        XCTAssertEqual(events.map(\.kind), [.ticketOpened])
        XCTAssertEqual(events.first?.packageID, packageID)
        XCTAssertNil(events.first?.address)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .unresolved)
    }

    func testFirstDeliveryUsesFirstPrintedAddress() throws {
        var (courier, ticketID, _) = try acceptedCourier()

        let deliveredAddress = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        let event = courier.manifest.events(for: ticketID).last

        XCTAssertEqual(deliveredAddress, atlas)
        XCTAssertEqual(event?.kind, .deliveredToStop)
        XCTAssertEqual(event?.packageID, packageID)
        XCTAssertEqual(event?.address, atlas)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .unresolved)
    }

    func testCannotAdvanceUntilIntermediatePackageIsRecovered() throws {
        var (courier, ticketID, _) = try acceptedCourier()
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)

        XCTAssertThrowsError(
            try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).filter { $0.kind == .deliveredToStop }.count,
            1
        )
    }

    func testRecoveryMayChangeContentsWithoutChangingEnvelope() throws {
        var (courier, ticketID, _) = try acceptedCourier()
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        let augmented = makePackage(contents: 42)

        try courier.recover(
            ticketID: ticketID,
            package: augmented,
            occurredAt: instant
        )

        let event = courier.manifest.events(for: ticketID).last
        XCTAssertEqual(event?.kind, .recoveredFromStop)
        XCTAssertEqual(event?.address, atlas)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .unresolved)

        let nextAddress = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        XCTAssertEqual(nextAddress, moirai)
    }

    func testRecoveryRejectsChangedPackageIdentity() throws {
        var (courier, ticketID, _) = try acceptedCourier()
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        let changed = makePackage(contents: "changed", packageID: otherPackageID)

        XCTAssertThrowsError(
            try courier.recover(ticketID: ticketID, package: changed, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .packageMismatch)
        }
    }

    func testRecoveryRejectsChangedSubject() throws {
        var (courier, ticketID, _) = try acceptedCourier()
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        let changed = makePackage(contents: "changed", subjectID: otherSubject)

        XCTAssertThrowsError(
            try courier.recover(ticketID: ticketID, package: changed, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .subjectMismatch)
        }
    }

    func testRecoveryRejectsChangedSender() throws {
        var (courier, ticketID, _) = try acceptedCourier()
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        let changed = makePackage(contents: "changed", sender: otherSender)

        XCTAssertThrowsError(
            try courier.recover(ticketID: ticketID, package: changed, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .senderMismatch)
        }
    }

    func testRecoveryRejectsChangedItinerary() throws {
        var (courier, ticketID, _) = try acceptedCourier()
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        let changed = makePackage(contents: "changed", addresses: [moirai, atlas, hestia])

        XCTAssertThrowsError(
            try courier.recover(ticketID: ticketID, package: changed, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .itineraryMismatch)
        }
    }

    func testCourierFollowsAllPrintedAddressesInOrder() throws {
        var (courier, ticketID, package) = try acceptedCourier()

        XCTAssertEqual(try courier.deliverNext(ticketID: ticketID, occurredAt: instant), atlas)
        try courier.recover(ticketID: ticketID, package: package, occurredAt: instant)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .unresolved)

        package = makePackage(contents: "atlas augmented")
        XCTAssertEqual(try courier.deliverNext(ticketID: ticketID, occurredAt: instant), moirai)
        try courier.recover(ticketID: ticketID, package: package, occurredAt: instant)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .unresolved)

        XCTAssertEqual(try courier.deliverNext(ticketID: ticketID, occurredAt: instant), hestia)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .unresolved)

        let routedEvents = courier.manifest.events(for: ticketID).filter {
            $0.kind == .deliveredToStop || $0.kind == .deliveredToAddressee
        }
        XCTAssertEqual(routedEvents.map(\.address), [atlas, moirai, hestia])
        XCTAssertEqual(routedEvents.map(\.kind), [.deliveredToStop, .deliveredToStop, .deliveredToAddressee])
    }

    func testReceiptCannotBeRecordedBeforeFinalDelivery() throws {
        var (courier, ticketID, _) = try acceptedCourier()

        XCTAssertThrowsError(
            try courier.recordReceipt(
                ticketID: ticketID,
                packageID: packageID,
                recipient: hestia,
                receivedAt: instant
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }
    }

    func testFinalReceiptRejectsWrongPackageIdentity() throws {
        var (courier, ticketID, _) = try courierAfterFinalDelivery()

        XCTAssertThrowsError(
            try courier.recordReceipt(
                ticketID: ticketID,
                packageID: otherPackageID,
                recipient: hestia,
                receivedAt: instant
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .packageMismatch)
        }
    }

    func testFinalReceiptRejectsWrongRecipient() throws {
        var (courier, ticketID, _) = try courierAfterFinalDelivery()

        XCTAssertThrowsError(
            try courier.recordReceipt(
                ticketID: ticketID,
                packageID: packageID,
                recipient: moirai,
                receivedAt: instant
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .addressMismatch)
        }
    }

    func testOnlyFinalReceiptResolvesTicket() throws {
        var (courier, ticketID, _) = try courierAfterFinalDelivery()

        try courier.recordReceipt(
            ticketID: ticketID,
            packageID: packageID,
            recipient: hestia,
            receivedAt: instant
        )

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).suffix(2).map(\.kind),
            [.receiptRecorded, .resolved]
        )
        XCTAssertEqual(courier.manifest.events(for: ticketID).last?.address, hestia)
        XCTAssertEqual(courier.manifest.currentState(for: ticketID), .resolved)
        XCTAssertFalse(courier.manifest.unresolvedTickets().contains(ticketID))
    }

    func testDuplicateReceiptCannotResolveTwice() throws {
        var (courier, ticketID, _) = try courierAfterFinalDelivery()

        try courier.recordReceipt(
            ticketID: ticketID,
            packageID: packageID,
            recipient: hestia,
            receivedAt: instant
        )

        XCTAssertThrowsError(
            try courier.recordReceipt(
                ticketID: ticketID,
                packageID: packageID,
                recipient: hestia,
                receivedAt: instant
            )
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .invalidState)
        }

        XCTAssertEqual(
            courier.manifest.events(for: ticketID).filter { $0.kind == .resolved }.count,
            1
        )
    }

    func testSamePackageCannotOpenSecondCourierTicket() throws {
        var courier = HermesCourier()
        let package = makePackage(contents: "engraving")
        _ = try courier.accept(package: package, occurredAt: instant)

        XCTAssertThrowsError(
            try courier.accept(package: package, occurredAt: instant)
        ) { error in
            XCTAssertEqual(error as? HermesCourier.Failure, .packageAlreadyAccepted)
        }
    }

    private func acceptedCourier() throws -> (HermesCourier, HermesTicketID, HermesPackage<String>) {
        var courier = HermesCourier()
        let package = makePackage(contents: "engraving")
        let ticketID = try courier.accept(package: package, occurredAt: instant)
        return (courier, ticketID, package)
    }

    private func courierAfterFinalDelivery() throws -> (HermesCourier, HermesTicketID, HermesPackage<String>) {
        var (courier, ticketID, package) = try acceptedCourier()
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        try courier.recover(ticketID: ticketID, package: package, occurredAt: instant)

        package = makePackage(contents: "after Atlas")
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        try courier.recover(ticketID: ticketID, package: package, occurredAt: instant)

        package = makePackage(contents: "after Moirai")
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant)
        return (courier, ticketID, package)
    }

    private func makePackage<Contents: Hashable & Sendable>(
        contents: Contents,
        packageID: HermesPackageID? = nil,
        subjectID: HermesSubjectID? = nil,
        sender: HermesAddress? = nil,
        addresses: [HermesAddress]? = nil
    ) -> HermesPackage<Contents> {
        HermesPackage(
            packageID: packageID ?? self.packageID,
            subjectID: subjectID ?? subject,
            sender: sender ?? orbo,
            addresses: addresses ?? itinerary,
            contents: contents
        )!
    }
}
