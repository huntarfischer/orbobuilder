public struct SynchronicRheaDegreeRow: Hashable, Sendable {
    public let position: ArcPosition
    public let qualification: RheaDegreeQualification

    internal init(position: ArcPosition, qualification: RheaDegreeQualification) {
        self.position = position
        self.qualification = qualification
    }
}

public struct SynchronicRheaSnapshot: Sendable {
    public let body: SynchronicAsteriaBody
    public let instant: AbsoluteInstant
    public let sourceMoment: SynchronicAsteriaMoment
    public let rows: [SynchronicRheaDegreeRow]
    public let declaredRowCount: Int

    internal init(
        body: SynchronicAsteriaBody,
        instant: AbsoluteInstant,
        sourceMoment: SynchronicAsteriaMoment,
        rows: [SynchronicRheaDegreeRow]
    ) {
        self.body = body
        self.instant = instant
        self.sourceMoment = sourceMoment
        self.rows = rows
        self.declaredRowCount = rows.count
    }
}

/// One of the twelve continuous Rhea Qualifiers required by the Synchronic
/// Pattern. Rhea consumes the finished Asteria Pass for this body and qualifies
/// only its actual Synchronic zodiacal degree matter through canonical Mater.
public struct SynchronicRheaQualifier: Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let body: SynchronicAsteriaBody
    public let bone: SynchronicSpineBone

    private let asteriaPass: SynchronicAsteriaPass

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        body: SynchronicAsteriaBody,
        bone: SynchronicSpineBone,
        asteriaPass: SynchronicAsteriaPass
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.body = body
        self.bone = bone
        self.asteriaPass = asteriaPass
    }

    public func resolve(at instant: AbsoluteInstant) throws -> SynchronicRheaSnapshot {
        let moment = try asteriaPass.resolve(at: instant)
        let positions: [ArcPosition]

        switch moment.composite {
        case .position(let position):
            positions = [position]
        case .seam(let seam):
            positions = [seam.minusPole, seam.plusPole]
        }

        let rows = positions.map { position in
            let longitude = CelestialLongitude(position.degrees)!
            return SynchronicRheaDegreeRow(
                position: position,
                qualification: Rhea.bearDegree(longitude)
            )
        }

        return SynchronicRheaSnapshot(
            body: body,
            instant: instant,
            sourceMoment: moment,
            rows: rows
        )
    }
}

public struct SynchronicRheaField: Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let bone: SynchronicSpineBone
    public let qualifiers: [SynchronicRheaQualifier]

    internal init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        bone: SynchronicSpineBone,
        qualifiers: [SynchronicRheaQualifier]
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.bone = bone
        self.qualifiers = qualifiers
    }

    public subscript(_ body: SynchronicAsteriaBody) -> SynchronicRheaQualifier? {
        qualifiers.first { $0.body == body }
    }
}

public extension Lachesis {
    /// Calls Rhea once for each finished Asteria body. No Sect is invented at
    /// this Act I seam; Hecate remains downstream owner of dynamic Sect.
    static func callRheaForSynchronicSpine(
        foundation: SynchronicSpineFoundation,
        asteria: SynchronicAsteriaField
    ) -> SynchronicRheaField {
        let qualifiers = SynchronicAsteriaBody.canonicalOrder.map { body in
            SynchronicRheaQualifier(
                subjectID: foundation.commission.subjectID,
                ticketID: foundation.commission.ticketID,
                body: body,
                bone: foundation.bone,
                asteriaPass: asteria[body]!
            )
        }

        return SynchronicRheaField(
            subjectID: foundation.commission.subjectID,
            ticketID: foundation.commission.ticketID,
            bone: foundation.bone,
            qualifiers: qualifiers
        )
    }
}
