/// Apollo is Orbo's governor of the Astrolabe.
///
/// Pass A establishes ownership only. It does not define Astrolabe state,
/// temporal law, celestial calculations, controls, or manifestation.
public enum Apollo {
    public enum GovernedInstrument: String, Hashable, Sendable {
        case astrolabe
    }

    public static let governedInstrument: GovernedInstrument = .astrolabe
}
