/// Door III adapter from Hecate into the OrboSpine Link port.
///
/// Hecate receives existing relation/addressability matter here. The adapter
/// does not create relations, reorder N-way members, or expose the wider
/// OrboSpine runtime.
public struct HecateLink: Sendable {
    public let link: SpineLinkSet

    public init(link: SpineLinkSet) {
        self.link = link
    }

    public var members: [SpineLinkAddress] {
        link.members
    }

    /// Hecate asks the mounted Door III for the exact supplied members.
    /// Their order survives so the caller can supply them to existing Kleides.
    public func coordinates(through source: SpineLink) throws -> [OrboSpineCelestialCoordinate] {
        try members.map { try source.coordinate(at: $0) }
    }
}
