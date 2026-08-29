/// Aether is Orbo's governor of the Astrosphere environment.
///
/// Pass A establishes ownership only. It does not define environmental state,
/// celestial or earthward fields, stars, petitions, or manifestation.
public enum Aether {
    public enum GovernedDomain: String, Hashable, Sendable {
        case astrosphereEnvironment
    }

    public static let governedDomain: GovernedDomain = .astrosphereEnvironment
}
