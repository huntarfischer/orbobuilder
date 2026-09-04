/// Hermes governs transport and interconnection between Orbo's owners.
///
/// Hermes may carry a request initiated at Apollo's Tabula, but the Tabula is
/// part of Apollo's Astrolabe. Transport does not confer device ownership.
public enum Hermes {
    public enum GovernedDomain: String, Hashable, Sendable {
        case interconnection
    }

    public static let governedDomain: GovernedDomain = .interconnection
}
