/// Hermes is Orbo's governor of the Tabula, the communicative reverse of the Astrolabe.
///
/// Preparation Pass B establishes Tabula ownership only. It does not turn Tabula
/// requests into Messenger or Courier contracts, and it does not own their answers.
public enum Hermes {
    public enum GovernedDomain: String, Hashable, Sendable {
        case tabula
    }

    public static let governedDomain: GovernedDomain = .tabula
}
