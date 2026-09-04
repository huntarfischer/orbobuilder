/// Apollo owns Orbo's Astrolabe as a device: its Aegis, Tabula, body, pose,
/// and the meaning of its controls.
///
/// Apollo does not calculate celestial truth. Horae carry one Timespine
/// cross-section to Apollo, which seats that truth in the device. Iris remains
/// a monitor of the signal Apollo chooses to expose.
public enum Apollo {
    public enum GovernedInstrument: String, Hashable, Sendable {
        case astrolabe
    }

    public static let governedInstrument: GovernedInstrument = .astrolabe
}
