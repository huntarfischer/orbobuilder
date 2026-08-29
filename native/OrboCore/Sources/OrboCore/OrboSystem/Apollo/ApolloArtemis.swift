/// The smallest identity Apollo can place on the Astrolabe in Pass A.
///
/// Its contents are deliberately opaque. Later reconstruction may earn richer
/// Astrolabe state, but this type proves only that the same identity crosses the
/// twin seam unchanged.
///
/// Pass C tightens provenance: this identity is still minted only inside the
/// Apollo/Artemis seam, and Artemis has no public raw intake for it. The public
/// handoff to Artemis belongs to Apollo.
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

    /// The only public twin handoff for what is on the Astrolabe.
    ///
    /// Artemis receives exactly what Apollo presents. Neighbor communication may
    /// clarify that subject later, but it cannot originate or replace this seam.
    static func presentToArtemis(
        _ subject: AstrolabeSubjectIdentity
    ) -> AstrolabeSubjectIdentity {
        Artemis.receiveFromApollo(subject)
    }
}

extension Artemis {
    /// Pass C keeps the lunar receiving aperture inside the twin seam.
    /// Artemis cannot be handed a raw Astrolabe identity through a public neighbor road.
    fileprivate static func receiveFromApollo(
        _ subject: AstrolabeSubjectIdentity
    ) -> AstrolabeSubjectIdentity {
        subject
    }
}
