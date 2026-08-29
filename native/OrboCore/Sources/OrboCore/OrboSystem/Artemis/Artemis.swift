/// Artemis is Orbo's governor of the Lunar Pane.
///
/// Pass A establishes ownership only. It does not define Lunar Pane state,
/// interpretation, casting, temporal law, or manifestation.
public enum Artemis {
    public enum GovernedInstrument: String, Hashable, Sendable {
        case lunarPane
    }

    public static let governedInstrument: GovernedInstrument = .lunarPane
}
