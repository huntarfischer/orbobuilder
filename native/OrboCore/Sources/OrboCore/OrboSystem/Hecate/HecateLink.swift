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

    /// Hands Hecate's exact Link request to the living Door III resolver and
    /// receives the resolved Timespine points unchanged.
    public func resolve(through doorIII: OrboSpineLink) throws -> OrboSpineResolvedLink {
        try doorIII.resolve(link)
    }
}
