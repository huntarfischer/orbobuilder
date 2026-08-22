import Foundation

/// One opaque addressable member presented to Port III.
/// D3 does not define the meaning or syntax of the member identity; each Spine owns that.
public struct SpineLinkAddress: Hashable, Codable, Sendable {
    public let spineIdentity: String
    public let memberIdentity: String

    public init?(spineIdentity: String, memberIdentity: String) {
        let spine = spineIdentity.trimmingCharacters(in: .whitespacesAndNewlines)
        let member = memberIdentity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spine.isEmpty, !member.isEmpty else { return nil }
        self.spineIdentity = spine
        self.memberIdentity = member
    }
}

/// Port III input shape. Link is N-way by contract and computes no relationship itself.
/// Member order is preserved so downstream relation engines may assign their own roles later.
public struct SpineLinkSet: Hashable, Sendable {
    public static let port = SpineAccessPort.link

    public let members: [SpineLinkAddress]

    public init?(members: [SpineLinkAddress]) {
        guard members.count >= 2 else { return nil }
        self.members = members
    }
}
