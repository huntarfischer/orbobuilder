import OrboCore

/// Iris's read-only view of one Lunar Pane signal frame.
///
/// Iris preserves Artemis's outward signal. It does not interpret the subject,
/// replace Apollo's light, or send commands back through the manifestation port.
public struct IrisLunarPaneFrame: Hashable, Sendable {
    public let signal: LunarPaneSignalFrame

    public init(signal: LunarPaneSignalFrame) {
        self.signal = signal
    }

    public var subject: AstrolabeSubjectIdentity {
        signal.subject
    }
}
