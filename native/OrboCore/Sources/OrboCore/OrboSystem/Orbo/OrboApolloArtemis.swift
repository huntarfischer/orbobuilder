/// Pass E gives Orbo the smallest direct summons for the twin instrument governors.
///
/// Orbo learns whom to call. It does not acquire Astrolabe or Lunar Pane state,
/// neighbor access, manifestation authority, or any of the twins' domain law.
public extension Orbo {
    func summonApollo() -> Apollo.Type {
        Apollo.self
    }

    func summonArtemis() -> Artemis.Type {
        Artemis.self
    }
}
