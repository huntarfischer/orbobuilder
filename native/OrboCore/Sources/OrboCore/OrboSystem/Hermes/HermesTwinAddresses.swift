/// Canonical Hermes addresses for the twins.
///
/// These names establish addressability only. They do not register a service
/// route, accepted parcel kind, expected return, or final-addressee contract.
public extension HermesAddress {
    static let apollo = HermesAddress(rawValue: "orbo.apollo")!
    static let artemis = HermesAddress(rawValue: "orbo.artemis")!
}

public extension Apollo {
    static let address: HermesAddress = .apollo
}

public extension Artemis {
    static let address: HermesAddress = .artemis
}
