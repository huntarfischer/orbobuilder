public enum SynchronicOceanusTideIdentity: String, CaseIterable, Hashable, Sendable {
    case interChart
    case mundane
    case natal

    public static let canonicalOrder: [SynchronicOceanusTideIdentity] = [
        .interChart, .mundane, .natal,
    ]
}

public enum SynchronicOceanusSubstance: String, Hashable, Sendable {
    case natal
    case mundane
    case synchronic
}

public struct SynchronicOceanusEndpoint: Hashable, Sendable {
    public let substance: SynchronicOceanusSubstance
    public let body: SynchronicAsteriaBody
    public let sourceMoment: SynchronicAsteriaMoment
    public let positions: [ArcPosition]

    internal init(
        substance: SynchronicOceanusSubstance,
        body: SynchronicAsteriaBody,
        sourceMoment: SynchronicAsteriaMoment,
        positions: [ArcPosition]
    ) {
        self.substance = substance
        self.body = body
        self.sourceMoment = sourceMoment
        self.positions = positions
    }
}

public struct SynchronicOceanusRelation: Hashable, Sendable {
    public let leftPosition: ArcPosition
    public let rightPosition: ArcPosition
    public let separation: RingSeparation
    public let nearest: RingNearest
    public let exact: RingMark?

    internal init(
        leftPosition: ArcPosition,
        rightPosition: ArcPosition,
        separation: RingSeparation,
        nearest: RingNearest,
        exact: RingMark?
    ) {
        self.leftPosition = leftPosition
        self.rightPosition = rightPosition
        self.separation = separation
        self.nearest = nearest
        self.exact = exact
    }
}

public struct SynchronicOceanusRow: Hashable, Sendable {
    public let tide: SynchronicOceanusTideIdentity
    public let instant: AbsoluteInstant
    public let left: SynchronicOceanusEndpoint
    public let right: SynchronicOceanusEndpoint
    public let relations: [SynchronicOceanusRelation]

    internal init(
        tide: SynchronicOceanusTideIdentity,
        instant: AbsoluteInstant,
        left: SynchronicOceanusEndpoint,
        right: SynchronicOceanusEndpoint,
        relations: [SynchronicOceanusRelation]
    ) {
        self.tide = tide
        self.instant = instant
        self.left = left
        self.right = right
        self.relations = relations
    }
}

public struct SynchronicOceanusSnapshot: Sendable {
    public let tide: SynchronicOceanusTideIdentity
    public let instant: AbsoluteInstant
    public let rows: [SynchronicOceanusRow]
    public let declaredRowCount: Int

    internal init(
        tide: SynchronicOceanusTideIdentity,
        instant: AbsoluteInstant,
        rows: [SynchronicOceanusRow]
    ) {
        self.tide = tide
        self.instant = instant
        self.rows = rows
        self.declaredRowCount = rows.count
    }
}

/// One of Oceanus's three relation families. It consumes finished Asteria
/// matter only. Natal and mundane endpoints come from the source coordinates
/// Asteria already preserved; Synchronic endpoints come from Asteria's Arc
/// composite. Oceanus therefore performs no second celestial sweep.
public struct SynchronicOceanusTide: Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let bone: SynchronicSpineBone
    public let identity: SynchronicOceanusTideIdentity

    private let asteria: SynchronicAsteriaField

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        bone: SynchronicSpineBone,
        identity: SynchronicOceanusTideIdentity,
        asteria: SynchronicAsteriaField
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.bone = bone
        self.identity = identity
        self.asteria = asteria
    }

    public func resolve(at instant: AbsoluteInstant) throws -> SynchronicOceanusSnapshot {
        guard bone.contains(instant) else { throw SynchronicAsteriaFailure.outsideBone }

        let moments = try SynchronicAsteriaBody.canonicalOrder.map { body in
            try asteria[body]!.resolve(at: instant)
        }

        let rows: [SynchronicOceanusRow]
        switch identity {
        case .interChart:
            rows = interChartRows(moments: moments, instant: instant)
        case .mundane:
            rows = crossRows(
                moments: moments,
                leftSubstance: .mundane,
                rightSubstance: .synchronic,
                instant: instant
            )
        case .natal:
            rows = crossRows(
                moments: moments,
                leftSubstance: .natal,
                rightSubstance: .synchronic,
                instant: instant
            )
        }

        return SynchronicOceanusSnapshot(tide: identity, instant: instant, rows: rows)
    }

    private func interChartRows(
        moments: [SynchronicAsteriaMoment],
        instant: AbsoluteInstant
    ) -> [SynchronicOceanusRow] {
        var rows: [SynchronicOceanusRow] = []
        rows.reserveCapacity(66)

        for leftIndex in 0..<moments.count {
            for rightIndex in (leftIndex + 1)..<moments.count {
                rows.append(makeRow(
                    leftMoment: moments[leftIndex],
                    leftSubstance: .synchronic,
                    rightMoment: moments[rightIndex],
                    rightSubstance: .synchronic,
                    instant: instant
                ))
            }
        }
        return rows
    }

    private func crossRows(
        moments: [SynchronicAsteriaMoment],
        leftSubstance: SynchronicOceanusSubstance,
        rightSubstance: SynchronicOceanusSubstance,
        instant: AbsoluteInstant
    ) -> [SynchronicOceanusRow] {
        var rows: [SynchronicOceanusRow] = []
        rows.reserveCapacity(moments.count * moments.count)

        for left in moments {
            for right in moments {
                rows.append(makeRow(
                    leftMoment: left,
                    leftSubstance: leftSubstance,
                    rightMoment: right,
                    rightSubstance: rightSubstance,
                    instant: instant
                ))
            }
        }
        return rows
    }

    private func makeRow(
        leftMoment: SynchronicAsteriaMoment,
        leftSubstance: SynchronicOceanusSubstance,
        rightMoment: SynchronicAsteriaMoment,
        rightSubstance: SynchronicOceanusSubstance,
        instant: AbsoluteInstant
    ) -> SynchronicOceanusRow {
        let left = endpoint(from: leftMoment, substance: leftSubstance)
        let right = endpoint(from: rightMoment, substance: rightSubstance)

        let relations = left.positions.flatMap { leftPosition in
            right.positions.map { rightPosition in
                let separation = Ring.separation(
                    from: CelestialLongitude(leftPosition.degrees)!,
                    to: CelestialLongitude(rightPosition.degrees)!
                )
                return SynchronicOceanusRelation(
                    leftPosition: leftPosition,
                    rightPosition: rightPosition,
                    separation: separation,
                    nearest: Ring.nearest(to: separation),
                    exact: Ring.exact(separation)
                )
            }
        }

        return SynchronicOceanusRow(
            tide: identity,
            instant: instant,
            left: left,
            right: right,
            relations: relations
        )
    }

    private func endpoint(
        from moment: SynchronicAsteriaMoment,
        substance: SynchronicOceanusSubstance
    ) -> SynchronicOceanusEndpoint {
        let positions: [ArcPosition]
        switch substance {
        case .natal:
            positions = [ArcPosition(moment.natalAnchor.arcsecond * 2)!]
        case .mundane:
            positions = [ArcPosition(moment.mundanePartner.arcsecond * 2)!]
        case .synchronic:
            switch moment.composite {
            case .position(let position):
                positions = [position]
            case .seam(let seam):
                positions = [seam.minusPole, seam.plusPole]
            }
        }

        return SynchronicOceanusEndpoint(
            substance: substance,
            body: moment.body,
            sourceMoment: moment,
            positions: positions
        )
    }
}

public struct SynchronicOceanusField: Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let bone: SynchronicSpineBone
    public let tides: [SynchronicOceanusTide]

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        bone: SynchronicSpineBone,
        tides: [SynchronicOceanusTide]
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.bone = bone
        self.tides = tides
    }

    public subscript(_ identity: SynchronicOceanusTideIdentity) -> SynchronicOceanusTide? {
        tides.first { $0.identity == identity }
    }
}

public extension Lachesis {
    static func callOceanusForSynchronicSpine(
        foundation: SynchronicSpineFoundation,
        asteria: SynchronicAsteriaField
    ) -> SynchronicOceanusField {
        let tides = SynchronicOceanusTideIdentity.canonicalOrder.map { identity in
            SynchronicOceanusTide(
                subjectID: foundation.commission.subjectID,
                ticketID: foundation.commission.ticketID,
                bone: foundation.bone,
                identity: identity,
                asteria: asteria
            )
        }

        return SynchronicOceanusField(
            subjectID: foundation.commission.subjectID,
            ticketID: foundation.commission.ticketID,
            bone: foundation.bone,
            tides: tides
        )
    }
}
