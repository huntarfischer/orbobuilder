import Foundation
import XCTest
@testable import OrboCore

final class NatalSpineActIBeat1CommissionTests: XCTestCase {
    private let subjectID = HermesSubjectID(rawValue: "natal-spine.native-001")!
    private let packageID = HermesPackageID(
        UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeee0001")!
    )
    private let instant = AbsoluteInstant(unixSecondsSince1970: 1_777_100_000)!

    func testOrboCannotCommissionNatalSpineBeforeNativeTruthIsReady() {
        let orbo = Orbo()
        var courier = HermesCourier()

        XCTAssertThrowsError(
            try orbo.commissionNatalSpine(
                subjectID: subjectID,
                via: &courier,
                occurredAt: instant,
                packageID: packageID
            )
        ) { error in
            XCTAssertEqual(
                error as? OrboNatalSpineCommissionFailure,
                .nativeTruthUnavailable
            )
        }
        XCTAssertTrue(courier.manifest.unresolvedTickets().isEmpty)
    }

    func testOrboAuthorsSchematicsPackageAndHermesOpensOneUnresolvedManifest() throws {
        var orbo = Orbo()
        orbo.transitionBackOfHouse(to: .nativeReady)
        var courier = HermesCourier()

        let handle = try orbo.commissionNatalSpine(
            subjectID: subjectID,
            via: &courier,
            occurredAt: instant,
            packageID: packageID
        )

        XCTAssertEqual(handle.package.packageID, packageID)
        XCTAssertEqual(handle.package.subjectID, subjectID)
        XCTAssertEqual(handle.package.sender, OrboOnboarding.orboAddress)
        XCTAssertEqual(handle.package.kind, NatalSpineCommission.packageKind)
        XCTAssertEqual(handle.package.addresses, NatalSpineCommission.itinerary)
        XCTAssertEqual(handle.package.contents.subjectID, subjectID)

        let events = courier.manifest.events(for: handle.ticketID)
        XCTAssertEqual(events.map(\.kind), [.ticketOpened])
        XCTAssertEqual(events.first?.packageID, packageID)
        XCTAssertEqual(courier.manifest.currentState(for: handle.ticketID), .unresolved)
        XCTAssertEqual(courier.manifest.unresolvedTickets(), [handle.ticketID])
    }

    func testNatalSpineCommissionPrintsCompleteThreeActJourneyAtOpening() {
        XCTAssertEqual(
            NatalSpineCommission.itinerary,
            [
                NatalSpineCommission.moiraiAddress,
                NatalSpineCommission.hephaestusAddress,
                NatalSpineCommission.horaeAddress,
                NatalSpineCommission.chronosAddress,
                NatalSpineCommission.hecateAddress,
            ]
        )
        XCTAssertEqual(NatalSpineCommission.itinerary.last, NatalSpineCommission.hecateAddress)
    }

    func testSameCommissionPackageCannotBeOpenedTwice() throws {
        var orbo = Orbo()
        orbo.transitionBackOfHouse(to: .nativeReady)
        var courier = HermesCourier()

        _ = try orbo.commissionNatalSpine(
            subjectID: subjectID,
            via: &courier,
            occurredAt: instant,
            packageID: packageID
        )

        XCTAssertThrowsError(
            try orbo.commissionNatalSpine(
                subjectID: subjectID,
                via: &courier,
                occurredAt: instant,
                packageID: packageID
            )
        ) { error in
            XCTAssertEqual(
                error as? OrboNatalSpineCommissionFailure,
                .alreadyCommissioned
            )
        }
        XCTAssertEqual(courier.manifest.unresolvedTickets().count, 1)
    }
}
