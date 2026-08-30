/// Apollo is Orbo's governor of the Aegis, the celestial face of the Astrolabe.
///
/// Preparation Pass B narrows Apollo's ownership to the front face. It does not
/// define Aegis state, temporal law, celestial calculations, controls, or manifestation.
public enum Apollo {
    public enum GovernedInstrument: String, Hashable, Sendable {
        case aegis
    }

    public static let governedInstrument: GovernedInstrument = .aegis
}
