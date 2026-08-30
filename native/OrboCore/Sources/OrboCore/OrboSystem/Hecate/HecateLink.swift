/// Door III adapter from Hecate into the OrboSpine Link port.
///
/// Hecate reads existing relation/addressability truth here. The adapter does
/// not create relations, expand N-way links into pairs, or expose the wider
/// OrboSpine runtime.
public struct HecateLink: Sendable {
    public let link: SpineLinkSet

    public init(link: SpineLinkSet) {
        self.link = link
    }

    public func links(containing address: SpineLinkAddress) -> [SpineLink] {
        link.links(containing: address)
    }
}
