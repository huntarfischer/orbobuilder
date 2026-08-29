/// One presentation-neutral frame exposed by Apollo's Astrolabe Iris port.
///
/// Pass D carries only truth Apollo already possesses. The frame does not ask a
/// neighbor for new truth, define Astrolabe mechanics, or grant Iris control of
/// the instrument. Later Astrolabe reconstruction may enrich this signal.
public struct AstrolabeSignalFrame: Hashable, Sendable {
    public let subject: AstrolabeSubjectIdentity

    fileprivate init(subject: AstrolabeSubjectIdentity) {
        self.subject = subject
    }
}

public extension Apollo {
    /// HDMI-style outward seam from Apollo's Astrolabe to Iris.
    ///
    /// Each call may expose a fresh lawful frame, but the supplied Astrolabe
    /// subject crosses the port unchanged.
    static func signalForIris(
        _ subject: AstrolabeSubjectIdentity
    ) -> AstrolabeSignalFrame {
        AstrolabeSignalFrame(subject: subject)
    }
}
