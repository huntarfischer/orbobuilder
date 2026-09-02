import XCTest
@testable import OrboCore

final class HestiaLightingAnnouncementTests: XCTestCase {
    private typealias F = HestiaCanonicalPersistenceFixture

    func testReceiveAndAnnounceAuthorsNoticeFromExactLightingTransition() throws {
        let native = try F.subject("native")
        let worked = try F.canonicalWorkedPackage(subjectID: native)
        var hestia = Hestia(nativeSubjectID: native)
        var hermes = HermesCourier()
        let noticeID = HermesPackageID()
        let occurredAt = AbsoluteInstant(unixSecondsSince1970: 1_777_200_000)!

        let result = try hestia.receiveAndAnnounce(
            worked,
            to: OrboOnboarding.orboAddress,
            via: &hermes,
            occurredAt: occurredAt,
            packageID: noticeID
        )

        XCTAssertTrue(hestia.hearthLit)
        XCTAssertEqual(hestia.nativeEngraving(), result.engraving)
        XCTAssertEqual(result.engraving.subjectID, native)
        XCTAssertTrue(result.engraving.engraved)
        XCTAssertEqual(result.package.packageID, noticeID)
        XCTAssertEqual(result.package.subjectID, result.engraving.subjectID)
        XCTAssertEqual(result.package.sender, Hestia.address)
        XCTAssertEqual(result.package.kind, Hestia.hearthLitNoticeKind)
        XCTAssertEqual(result.package.addresses, [OrboOnboarding.orboAddress])
        XCTAssertEqual(result.package.contents.subjectID, result.engraving.subjectID)
        XCTAssertTrue(result.package.contents.hearthLit)
        XCTAssertEqual(
            hermes.manifest.events(for: result.ticketID).map(\.kind),
            [.ticketOpened]
        )
    }

    func testFailedReceiveAndAnnounceCannotManufactureHermesNotice() throws {
        let native = try F.subject("native")
        let stranger = try F.subject("stranger")
        let worked = try F.canonicalWorkedPackage(subjectID: stranger)
        var hestia = Hestia(nativeSubjectID: native)
        var hermes = HermesCourier()
        let attemptedNoticeID = HermesPackageID()
        let occurredAt = AbsoluteInstant(unixSecondsSince1970: 1_777_200_100)!

        XCTAssertThrowsError(
            try hestia.receiveAndAnnounce(
                worked,
                to: OrboOnboarding.orboAddress,
                via: &hermes,
                occurredAt: occurredAt,
                packageID: attemptedNoticeID
            )
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .engravingSubjectMismatch)
        }
        XCTAssertFalse(hestia.hearthLit)
        XCTAssertNil(hestia.nativeEngraving())

        let proofPackage = try noticeProofPackage(
            packageID: attemptedNoticeID,
            subjectID: native
        )
        XCTAssertNoThrow(
            try hermes.accept(package: proofPackage, occurredAt: occurredAt)
        )
    }

    func testEstablishedHearthCannotAuthorSecondTransitionNotice() throws {
        let native = try F.subject("native")
        let worked = try F.canonicalWorkedPackage(subjectID: native)
        var hestia = Hestia(nativeSubjectID: native)
        var hermes = HermesCourier()
        let firstNoticeID = HermesPackageID()
        let secondNoticeID = HermesPackageID()
        let firstAt = AbsoluteInstant(unixSecondsSince1970: 1_777_200_200)!
        let secondAt = AbsoluteInstant(unixSecondsSince1970: 1_777_200_300)!

        let first = try hestia.receiveAndAnnounce(
            worked,
            to: OrboOnboarding.orboAddress,
            via: &hermes,
            occurredAt: firstAt,
            packageID: firstNoticeID
        )

        XCTAssertThrowsError(
            try hestia.receiveAndAnnounce(
                worked,
                to: OrboOnboarding.orboAddress,
                via: &hermes,
                occurredAt: secondAt,
                packageID: secondNoticeID
            )
        ) { error in
            XCTAssertEqual(error as? Hestia.Failure, .nativeAlreadyEstablished)
        }
        XCTAssertEqual(
            hermes.manifest.events(for: first.ticketID).map(\.kind),
            [.ticketOpened]
        )

        let proofPackage = try noticeProofPackage(
            packageID: secondNoticeID,
            subjectID: native
        )
        XCTAssertNoThrow(
            try hermes.accept(package: proofPackage, occurredAt: secondAt)
        )
    }

    private func noticeProofPackage(
        packageID: HermesPackageID,
        subjectID: HermesSubjectID
    ) throws -> HermesPackage<HearthLitNotice> {
        try XCTUnwrap(
            HermesPackage(
                packageID: packageID,
                subjectID: subjectID,
                sender: Hestia.address,
                kind: Hestia.hearthLitNoticeKind,
                addresses: [OrboOnboarding.orboAddress],
                contents: HearthLitNotice(subjectID: subjectID)
            )
        )
    }
}
