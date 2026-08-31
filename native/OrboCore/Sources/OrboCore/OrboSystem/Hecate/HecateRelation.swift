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

/// One raw relation between one celestial body on each of two existing participants.
public struct RelationRow: Hashable, Sendable {
    public let leftParticipant: SpineLinkAddress
    public let leftBody: MundaneBody
    public let rightParticipant: SpineLinkAddress
    public let rightBody: MundaneBody
    public let angularSeparation: RingSeparation

    internal init(
        leftParticipant: SpineLinkAddress,
        leftBody: MundaneBody,
        rightParticipant: SpineLinkAddress,
        rightBody: MundaneBody,
        angularSeparation: RingSeparation
    ) {
        self.leftParticipant = leftParticipant
        self.leftBody = leftBody
        self.rightParticipant = rightParticipant
        self.rightBody = rightBody
        self.angularSeparation = angularSeparation
    }
}

/// Named RELATE rituals Hecate can lawfully perform with already-linked matter.
public enum HecateRelationRitual: Hashable, Sendable {
    case momentToMoment
}

/// Explicit ritual eligibility failures. Door III resolution failures remain Door III failures.
public enum HecateRelationRitualError: Error, Hashable, Sendable {
    case participantCount(expected: Int, actual: Int)
}

public extension Hecate {
    /// RELATE preserves the linked points and describes what exists between them.
    ///
    /// Door III resolves the exact 2+ points. Hecate then uses Ring's frozen angular
    /// geometry across every canonical body pairing for each participant pair.
    static func relate(
        _ link: SpineLinkSet,
        through doorIII: OrboSpineLink
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
                        let separation = Ring.separation(
                            from: leftLongitude,
                            to: rightLongitude
                        )

                        rows.append(
                            RelationRow(
                                leftParticipant: leftPoint.sourceAddress,
                                leftBody: leftCoordinate.body,
                                rightParticipant: rightPoint.sourceAddress,
                                rightBody: rightCoordinate.body,
                                angularSeparation: separation
                            )
                        )
                    }
                }
            }
        }

        return RelationTable(participants: points, rows: rows)
    }

    /// Performs one named RELATE ritual without changing the generic relation machinery.
    static func relate(
        _ ritual: HecateRelationRitual,
        _ link: SpineLinkSet,
        through doorIII: OrboSpineLink
    ) throws -> RelationTable {
        switch ritual {
        case .momentToMoment:
            guard link.members.count == 2 else {
                throw HecateRelationRitualError.participantCount(
                    expected: 2,
                    actual: link.members.count
                )
            }
            return try relate(link, through: doorIII)
        }
    }
}
