/// One presentation-neutral signal frame authored by Artemis's Lunar Pane for Iris.
///
/// The subject must remain Apollo-sourced under the Pass C light law. This frame
/// does not ask neighbors for clarification, interpret the subject, or grant Iris
/// control of the Lunar Pane. Later Lunar Pane reconstruction may enrich it.
public struct LunarPaneSignalFrame: Hashable, Sendable {
    public let subject: AstrolabeSubjectIdentity

    fileprivate init(subject: AstrolabeSubjectIdentity) {
        self.subject = subject
    }
}

public extension Artemis {
    /// Standard outward Iris port from Artemis's Lunar Pane.
    ///
    /// The supplied subject is already Apollo-sourced. Artemis exposes that same
    /// subject without replacing it or acquiring another source of light.
    static func signalForIris(
        _ subject: AstrolabeSubjectIdentity
    ) -> IrisPort<LunarPaneSignalFrame> {
        IrisPort(signal: LunarPaneSignalFrame(subject: subject))
    }
}
