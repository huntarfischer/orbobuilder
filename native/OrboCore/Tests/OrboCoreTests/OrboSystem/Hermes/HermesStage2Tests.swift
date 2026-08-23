import XCTest
@testable import OrboCore

final class HermesStage2Tests: XCTestCase {
    private let registry = HermesRouteRegistry()
    private let moirai = HermesAddress(rawValue: "orbo.moirai")!
    private let hestia = HermesAddress(rawValue: "orbo.hestia")!
    private let unknownService = HermesAddress(rawValue: "orbo.unknown")!
    private let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
    private let moiraiPackage = HermesParcelKind(rawValue: "orbo.moirai-package.v1")!
    private let wrongKind = HermesParcelKind(rawValue: "orbo.wrong.v1")!

    func testKnownServiceContractResolves() {
        let contract = registry.contract(
            for: moirai,
            accepting: natalCommission,
            returning: moiraiPackage
        )

        XCTAssertEqual(contract?.serviceDestination, moirai)
        XCTAssertEqual(contract?.acceptedParcelKind, natalCommission)
        XCTAssertEqual(contract?.expectedReturnKind, moiraiPackage)
    }

    func testWrongAcceptedParcelKindIsRejected() {
        XCTAssertNil(
            registry.contract(
                for: moirai,
                accepting: wrongKind,
                returning: moiraiPackage
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
        XCTAssertTrue(registry.finalAddressee(hestia, accepts: moiraiPackage))
        XCTAssertFalse(registry.finalAddressee(hestia, accepts: natalCommission))
    }

    func testUnknownRouteDoesNotResolve() {
        XCTAssertNil(
            registry.contract(
                for: unknownService,
                accepting: natalCommission,
                returning: moiraiPackage
            )
        )
    }
}
