import OrboCore

/// Iris's read-only view of one Astrolabe signal frame.
///
/// Iris preserves Apollo's outward signal. It does not calculate Astrolabe truth,
/// alter the subject, or send commands back through the manifestation port.
public struct IrisAstrolabeFrame: Hashable, Sendable {
    public let signal: AstrolabeSignalFrame

    public init(signal: AstrolabeSignalFrame) {
        self.signal = signal
    }

    public var subject: AstrolabeSubjectIdentity {
        signal.subject
    }
}
