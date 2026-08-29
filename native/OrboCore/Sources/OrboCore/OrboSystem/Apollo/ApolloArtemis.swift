/// The smallest identity Apollo can place on the Astrolabe in Pass A.
///
/// Its contents are deliberately opaque. Later reconstruction may earn richer
/// Astrolabe state, but this type proves only that the same identity crosses the
/// twin seam unchanged.
public struct AstrolabeSubjectIdentity: Hashable, Sendable {
    public let rawValue: String

    fileprivate init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension Apollo {
    /// Apollo establishes which identity is on the Astrolabe.
    static func placeOnAstrolabe(identity: String) -> AstrolabeSubjectIdentity {
        AstrolabeSubjectIdentity(rawValue: identity)
    }

    /// The twin seam carries the Astrolabe identity to Artemis without changing it.
    static func presentToArtemis(
        _ subject: AstrolabeSubjectIdentity
    ) -> AstrolabeSubjectIdentity {
        Artemis.receiveFromAstrolabe(subject)
    }
}

public extension Artemis {
    /// Artemis receives exactly what Apollo placed on the Astrolabe.
    static func receiveFromAstrolabe(
        _ subject: AstrolabeSubjectIdentity
    ) -> AstrolabeSubjectIdentity {
        subject
    }
}
