/// Narrow temporal-address port for Orbo systems that need Shell.sign state
/// without depending on Aion's storage, AstroDNA, or forge representation.
public protocol AionReading: Sendable {
    func resolve(at julianDay: JulianDay) throws -> AionState
}

extension Aion: AionReading {}
