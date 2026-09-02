import OrboCore

/// Iris's read-only view of one Astrolabe signal frame.
///
/// Iris preserves Apollo's outward signal from the standard Iris port. It does
/// not calculate Astrolabe truth, alter the subject, or send commands back
/// through the manifestation port.
public struct IrisAstrolabeFrame: Hashable, Sendable {
    public let signal: AstrolabeSignalFrame

    public init(port: IrisPort<AstrolabeSignalFrame>) {
        self.signal = port.signal
    }

    public var subject: AstrolabeSubjectIdentity {
        signal.subject
    }
}
