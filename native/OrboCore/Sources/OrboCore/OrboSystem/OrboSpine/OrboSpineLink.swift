import Foundation

/// One exact OrboSpine point address admitted at Door III.
///
/// Door III may be entered from chronological occurrence or from celestial time.
/// A celestial address retains the civic/UT occurrence binding so repeated visits to
/// the same celestial degree remain distinct exact points on the Spine.
public enum OrboSpinePointAddress: Hashable, Sendable {
    case occurrence(JulianDay)
    case celestialOccurrence(
        body: MundaneBody,
        directionalDegree: OrboSpineDirectionalDegree,
        julianDay: JulianDay
    )

    public var julianDay: JulianDay {
        switch self {
        case let .occurrence(julianDay):
            return julianDay
        case let .celestialOccurrence(_, _, julianDay):
            return julianDay
        }
    }

    /// OrboSpine-owned serialization into the generic opaque Link member identity.
    /// This syntax is an implementation detail of OrboSpine, not a universal Spine law.
    public var memberIdentity: String {
        switch self {
        case let .occurrence(julianDay):
            return "occurrence|\(julianDay.value)"
        case let .celestialOccurrence(body, directionalDegree, julianDay):
            return "celestial|\(body.rawValue)|\(directionalDegree.degrees)|\(julianDay.value)"
        }
    }

    public init?(memberIdentity: String) {
        let fields = memberIdentity.split(separator: "|", omittingEmptySubsequences: false)

        if fields.count == 2,
           fields[0] == "occurrence",
           let value = Double(fields[1]),
           let julianDay = JulianDay(value) {
            self = .occurrence(julianDay)
            return
        }

        if fields.count == 4,
           fields[0] == "celestial",
           let rawBody = UInt8(fields[1]),
           let body = MundaneBody(rawValue: rawBody),
           let directionalValue = Double(fields[2]),
           let directionalDegree = OrboSpineDirectionalDegree(directionalValue),
           let julianValue = Double(fields[3]),
           let julianDay = JulianDay(julianValue) {
            self = .celestialOccurrence(
                body: body,
                directionalDegree: directionalDegree,
                julianDay: julianDay
            )
            return
        }

        return nil
    }

    public func linkAddress(
        spineIdentity: String = OrboSpineContract.identity
    ) -> SpineLinkAddress {
        SpineLinkAddress(
            spineIdentity: spineIdentity,
            memberIdentity: memberIdentity
        )!
    }
}

/// One full immutable cross-section of OrboSpine truth resolved for Door III.
/// Hecate may later decide what relational ritual to perform with multiple points;
/// this type performs no relation, cast, summon, or interpretation.
public struct OrboSpinePoint: Hashable, Sendable {
    public let sourceAddress: SpineLinkAddress
    public let pointAddress: OrboSpinePointAddress
    public let julianDay: JulianDay
    public let celestial: [OrboSpineCelestialCoordinate]
    public let terra: TerraMarrowSample

    internal init(
        sourceAddress: SpineLinkAddress,
        pointAddress: OrboSpinePointAddress,
        celestial: [OrboSpineCelestialCoordinate],
        terra: TerraMarrowSample
    ) {
        self.sourceAddress = sourceAddress
        self.pointAddress = pointAddress
        self.julianDay = pointAddress.julianDay
        self.celestial = celestial
        self.terra = terra
    }
}

/// Door III's resolved factual answer for one Link request.
/// Source member identity and order are preserved exactly.
public struct OrboSpineResolvedLink: Hashable, Sendable {
    public let source: SpineLinkSet
    public let points: [OrboSpinePoint]

    internal init(source: SpineLinkSet, points: [OrboSpinePoint]) {
        self.source = source
        self.points = points
    }
}

public enum OrboSpineLinkError: Error, Hashable, Sendable {
    case foreignSpine(SpineLinkAddress)
    case invalidMemberIdentity(SpineLinkAddress)
    case celestialOccurrenceMismatch(SpineLinkAddress)
    case unresolvedMember(SpineLinkAddress)
}

/// OrboSpine's implementation of the generic Door III / Link port.
///
/// Link resolves exactly the 2+ members named by the caller and preserves their order.
/// It does not search for substitutes and computes no relationship among the points.
public struct OrboSpineLink: Sendable {
    public let spineIdentity: String

    private let locate: OrboSpineLocate

    public init(spineIdentity: String, locate: OrboSpineLocate) {
        self.spineIdentity = spineIdentity
        self.locate = locate
    }

    public func resolve(_ link: SpineLinkSet) throws -> OrboSpineResolvedLink {
        var points: [OrboSpinePoint] = []
        points.reserveCapacity(link.members.count)

        for member in link.members {
            guard member.spineIdentity == spineIdentity else {
                throw OrboSpineLinkError.foreignSpine(member)
            }
            guard let pointAddress = OrboSpinePointAddress(memberIdentity: member.memberIdentity) else {
                throw OrboSpineLinkError.invalidMemberIdentity(member)
            }

            do {
                if case let .celestialOccurrence(body, directionalDegree, julianDay) = pointAddress {
                    let resolved = try locate.coordinate(of: body, at: julianDay)
                    guard abs(resolved.directionalDegree.degrees - directionalDegree.degrees) <= 1e-9 else {
                        throw OrboSpineLinkError.celestialOccurrenceMismatch(member)
                    }
                }

                let celestial = try MundaneBody.canonicalOrder.map {
                    try locate.coordinate(of: $0, at: pointAddress.julianDay)
                }
                let terra = try locate.terra(at: pointAddress.julianDay)

                points.append(
                    OrboSpinePoint(
                        sourceAddress: member,
                        pointAddress: pointAddress,
                        celestial: celestial,
                        terra: terra
                    )
                )
            } catch let error as OrboSpineLinkError {
                throw error
            } catch {
                throw OrboSpineLinkError.unresolvedMember(member)
            }
        }

        return OrboSpineResolvedLink(source: link, points: points)
    }
}

public extension OrboSpineRuntime {
    /// Living Door III over this assembled OrboSpine.
    var link: OrboSpineLink {
        OrboSpineLink(spineIdentity: identity, locate: locate)
    }
}
