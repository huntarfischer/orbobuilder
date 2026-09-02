/// One presentation-neutral signal frame authored by Apollo's Astrolabe for Iris.
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
    /// Standard outward Iris port from Apollo's Astrolabe.
    ///
    /// Each call may expose a fresh lawful snapshot, but the supplied Astrolabe
    /// subject crosses the port unchanged.
    static func signalForIris(
        _ subject: AstrolabeSubjectIdentity
    ) -> IrisPort<AstrolabeSignalFrame> {
        IrisPort(signal: AstrolabeSignalFrame(subject: subject))
    }
}
