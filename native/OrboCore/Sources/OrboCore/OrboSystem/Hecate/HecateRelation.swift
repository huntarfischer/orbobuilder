/// Raw factual result of Hecate's RELATE ritual.
///
/// The participants remain the exact resolved Timespine points supplied through Door III.
/// Rows describe only angular relation among their existing celestial placements.
/// This table performs no cast and carries no interpretation.
public struct RelationTable: Hashable, Sendable {
    public let participants: [OrboSpinePoint]
    public let rows: [RelationRow]

    internal init(participants: [OrboSpinePoint], rows: [RelationRow]) {
        self.participants = participants
        self.rows = rows
    }
}

/// One point-to-point Aspect inside a field-level relation table.
public struct RelationRow: Hashable, Sendable {
    public let leftParticipant: SpineLinkAddress
    public let leftBody: MundaneBody
    public let rightParticipant: SpineLinkAddress
    public let rightBody: MundaneBody
    public let aspect: HecateAspect

    public var angularSeparation: RingSeparation {
        aspect.separation
    }

    internal init(
        leftParticipant: SpineLinkAddress,
        leftBody: MundaneBody,
        rightParticipant: SpineLinkAddress,
        rightBody: MundaneBody,
        aspect: HecateAspect
    ) {
        self.leftParticipant = leftParticipant
        self.leftBody = leftBody
        self.rightParticipant = rightParticipant
        self.rightBody = rightBody
        self.aspect = aspect
    }
}

/// Named field-level RELATE rituals Hecate can lawfully perform with linked matter.
public enum HecateRelationRitual: Hashable, Sendable {
    case synastry
}

/// Explicit ritual eligibility failures. Door III resolution failures remain Door III failures.
public enum HecateRelationRitualError: Error, Hashable, Sendable {
    case participantCount(expected: Int, actual: Int)
}

public extension Hecate {
    /// Generic field relation over already-linked Timespine points.
    ///
    /// Door III resolves the exact 2+ fields. Hecate then composes the table from
    /// the point-level Aspect primitive across every canonical body pairing for
    /// each participant pair. Exact 0′ orb is the default unless explicitly widened.
    static func relate(
        _ link: SpineLinkSet,
        through doorIII: OrboSpineLink,
        orb: HecateAspectOrb = .exact
    ) throws -> RelationTable {
        let resolved = try HecateLink(link: link).resolve(through: doorIII)
        let points = resolved.points
        let participantPairCount = points.count * (points.count - 1) / 2
        let bodiesPerPoint = MundaneBody.canonicalOrder.count

        var rows: [RelationRow] = []
        rows.reserveCapacity(participantPairCount * bodiesPerPoint * bodiesPerPoint)

        for leftIndex in 0..<(points.count - 1) {
            let leftPoint = points[leftIndex]

            for rightIndex in (leftIndex + 1)..<points.count {
                let rightPoint = points[rightIndex]

                for leftCoordinate in leftPoint.celestial {
                    let leftLongitude = CelestialLongitude(
                        leftCoordinate.directionalDegree.physicalDegrees
                    )!

                    for rightCoordinate in rightPoint.celestial {
                        let rightLongitude = CelestialLongitude(
                            rightCoordinate.directionalDegree.physicalDegrees
                        )!
                        let aspect = relateAspect(
                            leftLongitude,
                            rightLongitude,
                            orb: orb
                        )

                        rows.append(
                            RelationRow(
                                leftParticipant: leftPoint.sourceAddress,
                                leftBody: leftCoordinate.body,
                                rightParticipant: rightPoint.sourceAddress,
                                rightBody: rightCoordinate.body,
                                aspect: aspect
                            )
                        )
                    }
                }
            }
        }

        return RelationTable(participants: points, rows: rows)
    }

    /// RELATE at field scale: Synastry preserves exactly two Timespine fields
    /// and returns the complete table of their point-to-point Aspects.
    static func relate(
        _ ritual: HecateRelationRitual,
        _ link: SpineLinkSet,
        through doorIII: OrboSpineLink,
        orb: HecateAspectOrb = .exact
    ) throws -> RelationTable {
        switch ritual {
        case .synastry:
            guard link.members.count == 2 else {
                throw HecateRelationRitualError.participantCount(
                    expected: 2,
                    actual: link.members.count
                )
            }
            return try relate(link, through: doorIII, orb: orb)
        }
    }
}
