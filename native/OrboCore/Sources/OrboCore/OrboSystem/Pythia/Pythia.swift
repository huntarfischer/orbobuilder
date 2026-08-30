/// Pythia is Orbo's keeper of timing techniques.
///
/// Pass A establishes ownership only. It does not implement timing techniques,
/// petition Chronos or Hecate, or define any calling relationship.
public enum Pythia {
    public enum GovernedDomain: String, Hashable, Sendable {
        case timingTechniques
    }

    public static let governedDomain: GovernedDomain = .timingTechniques
}
