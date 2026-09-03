import Foundation

/// One opaque addressable member presented to Port III.
/// `spineIdentity` identifies the specific Spine instance/artifact, not merely its Spine class.
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

public enum SpineLinkFailure: Error, Equatable, Sendable {
    case wrongSpine
    case unavailableMember(String)
    case coordinateMismatch
}

/// Door III bound to one mounted candidate. Celestial members use the same
/// Locate authority as Door I; Link introduces no clock or interpolation.
public struct SpineLink: Sendable {
    public let spineIdentity: String
    private let locate: OrboSpineLocate

    internal init(provenance: OrboSpineRuntimeProvenance, locate: OrboSpineLocate) {
        self.spineIdentity = provenance.candidateManifestSHA256
        self.locate = locate
    }

    /// Addresses an already-resolved celestial member, after checking its source.
    public func address(of coordinate: OrboSpineCelestialCoordinate) throws -> SpineLinkAddress {
        guard try locate.coordinate(of: coordinate.body, at: coordinate.julianDay) == coordinate else {
            throw SpineLinkFailure.coordinateMismatch
        }
        return SpineLinkAddress(
            spineIdentity: spineIdentity,
            memberIdentity: "\(coordinate.body.constructionDataName)@\(coordinate.julianDay.value)"
        )!
    }

    /// Retrieves the existing member named by this candidate's address.
    public func coordinate(at address: SpineLinkAddress) throws -> OrboSpineCelestialCoordinate {
        guard address.spineIdentity == spineIdentity else { throw SpineLinkFailure.wrongSpine }
        let parts = address.memberIdentity.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let body = MundaneBody.canonicalOrder.first(where: { $0.constructionDataName == parts[0] }),
              let value = Double(parts[1]), let julianDay = JulianDay(value) else {
            throw SpineLinkFailure.unavailableMember(address.memberIdentity)
        }
        return try locate.coordinate(of: body, at: julianDay)
    }
}
