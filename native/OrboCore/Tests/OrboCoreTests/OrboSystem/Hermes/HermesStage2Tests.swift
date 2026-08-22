import XCTest
@testable import OrboCore

final class HermesStage2Tests: XCTestCase {
    private let registry = HermesRouteRegistry()
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestia = HermesAddress(rawValue: "orbo.hestia")!
    private let unknownService = HermesAddress(rawValue: "orbo.unknown")!
    private let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
    private let atroposPackage = HermesParcelKind(rawValue: "orbo.atropos-package.v1")!
    private let wrongKind = HermesParcelKind(rawValue: "orbo.wrong.v1")!

    func testKnownServiceContractResolves() {
        let contract = registry.contract(
            for: moirai,
            accepting: natalCommission,
            returning: atroposPackage
        )

        XCTAssertEqual(contract?.serviceDestination, moirai)
        XCTAssertEqual(contract?.acceptedParcelKind, natalCommission)
        XCTAssertEqual(contract?.expectedReturnKind, atroposPackage)
    }

    func testWrongAcceptedParcelKindIsRejected() {
        XCTAssertNil(
            registry.contract(
                for: moirai,
                accepting: wrongKind,
                returning: atroposPackage
            )
        )
    }

    func testWrongExpectedReturnKindIsRejected() {
        XCTAssertNil(
            registry.contract(
                for: moirai,
                accepting: natalCommission,
                returning: wrongKind
            )
        )
    }

    func testKnownFinalAddresseeAcceptsExpectedParcelKind() {
        XCTAssertTrue(registry.finalAddressee(hestia, accepts: atroposPackage))
        XCTAssertFalse(registry.finalAddressee(hestia, accepts: natalCommission))
    }

    func testUnknownRouteDoesNotResolve() {
        XCTAssertNil(
            registry.contract(
                for: unknownService,
                accepting: natalCommission,
                returning: atroposPackage
            )
        )
    }
}
