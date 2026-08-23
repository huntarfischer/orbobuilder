public struct HermesRouteContract: Hashable, Codable, Sendable {
    public let serviceDestination: HermesAddress
    public let acceptedParcelKind: HermesParcelKind
    public let expectedReturnKind: HermesParcelKind

    public init(
        serviceDestination: HermesAddress,
        acceptedParcelKind: HermesParcelKind,
        expectedReturnKind: HermesParcelKind
    ) {
        self.serviceDestination = serviceDestination
        self.acceptedParcelKind = acceptedParcelKind
        self.expectedReturnKind = expectedReturnKind
    }
}

public struct HermesRouteRegistry: Sendable {
    private let contracts: [HermesRouteContract]
    private let finalAcceptances: [HermesAddress: Set<HermesParcelKind>]

    public init() {
        let moirai = HermesAddress(rawValue: "orbo.moirai")!
        let hestia = HermesAddress(rawValue: "orbo.hestia")!
        let natalCommission = HermesParcelKind(rawValue: "orbo.natal-commission.v1")!
        let moiraiPackage = HermesParcelKind(rawValue: "orbo.moirai-package.v1")!

        self.contracts = [
            HermesRouteContract(
                serviceDestination: moirai,
                acceptedParcelKind: natalCommission,
                expectedReturnKind: moiraiPackage
            ),
        ]
        self.finalAcceptances = [
            hestia: [moiraiPackage],
        ]
    }

    public func contract(
        for serviceDestination: HermesAddress,
        accepting parcelKind: HermesParcelKind,
        returning expectedReturnKind: HermesParcelKind
    ) -> HermesRouteContract? {
        contracts.first {
            $0.serviceDestination == serviceDestination
                && $0.acceptedParcelKind == parcelKind
                && $0.expectedReturnKind == expectedReturnKind
        }
    }

    public func finalAddressee(
        _ address: HermesAddress,
        accepts parcelKind: HermesParcelKind
    ) -> Bool {
        finalAcceptances[address]?.contains(parcelKind) == true
    }
}
