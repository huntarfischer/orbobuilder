/// One point-level CAST result from two celestial longitudes.
///
/// The original points are retained exactly as supplied. Arc/Asteria owns the
/// composite geometry, including the lawful opposition Seam where no single
/// midpoint position is privileged.
public struct HecateMidpoint: Hashable, Sendable {
    public let first: CelestialLongitude
    public let second: CelestialLongitude
    public let result: ArcComposite

    internal init(
        first: CelestialLongitude,
        second: CelestialLongitude,
        result: ArcComposite
    ) {
        self.first = first
        self.second = second
        self.result = result
    }
}

/// One corresponding body pair inside a field-level Composite cast.
public struct HecateCompositeMember: Hashable, Sendable {
    public let body: MundaneBody
    public let midpoint: HecateMidpoint

    internal init(body: MundaneBody, midpoint: HecateMidpoint) {
        self.body = body
        self.midpoint = midpoint
    }
}

/// New derived celestial field cast from exactly two existing Timespine fields.
///
/// The source fields remain attached as provenance. This derived field has no
/// fabricated JulianDay because the Composite did not occur on the Timespine.
public struct HecateCompositeField: Hashable, Sendable {
    public let sources: [OrboSpinePoint]
    public let members: [HecateCompositeMember]

    internal init(
        sources: [OrboSpinePoint],
        members: [HecateCompositeMember]
    ) {
        self.sources = sources
        self.members = members
    }
}

public enum HecateCompositeError: Error, Hashable, Sendable {
    case participantCount(expected: Int, actual: Int)
    case missingBody(MundaneBody)
}

public extension Hecate {
    /// CAST at point scale: two celestial points produce one lawful Midpoint
    /// result under Arc's existing shortest-arc composite law.
    static func castMidpoint(
        _ first: CelestialLongitude,
        _ second: CelestialLongitude
    ) -> HecateMidpoint {
        let firstCoordinate = arcCoordinate(for: first)
        let secondCoordinate = arcCoordinate(for: second)
        let result = Asteria.refract(firstCoordinate, with: secondCoordinate)

        return HecateMidpoint(
            first: first,
            second: second,
            result: result
        )
    }

    /// CAST at field scale: Composite pairs corresponding canonical bodies and
    /// builds one derived field entirely from the point-level Midpoint primitive.
    static func castComposite(
        _ link: SpineLinkSet,
        through doorIII: OrboSpineLink
    ) throws -> HecateCompositeField {
        guard link.members.count == 2 else {
            throw HecateCompositeError.participantCount(
                expected: 2,
                actual: link.members.count
            )
        }

        let resolved = try HecateLink(link: link).resolve(through: doorIII)
        let firstField = resolved.points[0]
        let secondField = resolved.points[1]

        var members: [HecateCompositeMember] = []
        members.reserveCapacity(MundaneBody.canonicalOrder.count)

        for body in MundaneBody.canonicalOrder {
            guard let firstCoordinate = firstField.celestial.first(where: { $0.body == body }),
                  let secondCoordinate = secondField.celestial.first(where: { $0.body == body }) else {
                throw HecateCompositeError.missingBody(body)
            }

            let firstLongitude = CelestialLongitude(
                firstCoordinate.directionalDegree.physicalDegrees
            )!
            let secondLongitude = CelestialLongitude(
                secondCoordinate.directionalDegree.physicalDegrees
            )!

            members.append(
                HecateCompositeMember(
                    body: body,
                    midpoint: castMidpoint(firstLongitude, secondLongitude)
                )
            )
        }

        return HecateCompositeField(
            sources: resolved.points,
            members: members
        )
    }

    /// Arc admits whole-arcsecond inputs. Preserve the supplied longitude on
    /// HecateMidpoint while presenting Arc the exact fidelity its frozen law owns.
    private static func arcCoordinate(for longitude: CelestialLongitude) -> ArcCoordinate {
        let arcsecond = Int(
            (longitude.degrees * Double(Arc.arcsecondsPerDegree)).rounded(.down)
        )
        return ArcCoordinate(arcsecond)!
    }
}
