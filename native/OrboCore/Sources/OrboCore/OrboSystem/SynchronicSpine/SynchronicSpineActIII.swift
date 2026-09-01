import Foundation

public enum SynchronicSpineTimeGardenFailure: Error, Hashable, Sendable {
    case unexpectedHermesDestination
    case invalidHoraeScan
    case chronosRequiresHoraeScan
    case hecateRequiresPriorMarks
    case plantingRequiresAllMarks
    case closureRequiresPlantedBlessing
}

public struct SynchronicSpineHoraeScan: Hashable, Sendable {
    public let sealID: UUID
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let start: AbsoluteInstant
    public let natal: AbsoluteInstant
    public let end: AbsoluteInstant
}

public struct SynchronicSpineChronosQuery: Hashable, Sendable {
    public let sealID: UUID
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
}

public enum SynchronicSpineBlessedCapability: String, CaseIterable, Hashable, Sendable {
    case calculations
    case comparisons
}

public struct SynchronicSpineHecateBlessing: Hashable, Sendable {
    public let sealID: UUID
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let capabilities: Set<SynchronicSpineBlessedCapability>
}

public struct PlantedSynchronicSpine: Sendable {
    public let sealed: SealedSynchronicSpine
    public let horaeScan: SynchronicSpineHoraeScan
    public let chronosQuery: SynchronicSpineChronosQuery
    public let blessing: SynchronicSpineHecateBlessing
}

public struct SynchronicSpineBlessingInHermesCustody: Hashable, Sendable {
    public let sealID: UUID
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let blessing: SynchronicSpineHecateBlessing
}

public struct SynchronicSpineAvailabilityAnnouncement: Hashable, Sendable {
    public static let message = "SYNCHRONIC SPINE AVAILABLE"

    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let sealID: UUID
    public let message: String

    internal init(planted: PlantedSynchronicSpine) {
        self.subjectID = planted.sealed.candidate.subjectID
        self.ticketID = planted.sealed.candidate.ticketID
        self.sealID = planted.sealed.sealID
        self.message = Self.message
    }
}

public extension Horae {
    static func scanSynchronicSpine(
        _ sealed: SealedSynchronicSpine
    ) throws -> SynchronicSpineHoraeScan {
        let candidate = sealed.candidate
        let bone = candidate.bone
        guard
            candidate.doors == SynchronicSpineDoor.canonicalOrder,
            bone.start.unixSecondsSince1970 < bone.natal.unixSecondsSince1970,
            bone.natal.unixSecondsSince1970 < bone.end.unixSecondsSince1970,
            candidate.contents.asteria.bone == bone,
            candidate.contents.themis.bone == bone,
            candidate.contents.oceanus.bone == bone,
            candidate.contents.rhea.bone == bone
        else {
            throw SynchronicSpineTimeGardenFailure.invalidHoraeScan
        }

        return SynchronicSpineHoraeScan(
            sealID: sealed.sealID,
            subjectID: candidate.subjectID,
            ticketID: candidate.ticketID,
            start: bone.start,
            natal: bone.natal,
            end: bone.end
        )
    }
}

public extension Chronos {
    static func classifySynchronicSpineForQuery(
        _ sealed: SealedSynchronicSpine,
        after scan: SynchronicSpineHoraeScan
    ) throws -> SynchronicSpineChronosQuery {
        guard scan.sealID == sealed.sealID,
              scan.subjectID == sealed.candidate.subjectID,
              scan.ticketID == sealed.candidate.ticketID else {
            throw SynchronicSpineTimeGardenFailure.chronosRequiresHoraeScan
        }

        return SynchronicSpineChronosQuery(
            sealID: sealed.sealID,
            subjectID: sealed.candidate.subjectID,
            ticketID: sealed.candidate.ticketID
        )
    }
}

public extension Hecate {
    static func blessSynchronicSpine(
        _ sealed: SealedSynchronicSpine,
        after scan: SynchronicSpineHoraeScan,
        query: SynchronicSpineChronosQuery
    ) throws -> SynchronicSpineHecateBlessing {
        guard scan.sealID == sealed.sealID,
              query.sealID == sealed.sealID,
              scan.subjectID == sealed.candidate.subjectID,
              query.subjectID == sealed.candidate.subjectID,
              scan.ticketID == sealed.candidate.ticketID,
              query.ticketID == sealed.candidate.ticketID else {
            throw SynchronicSpineTimeGardenFailure.hecateRequiresPriorMarks
        }

        return SynchronicSpineHecateBlessing(
            sealID: sealed.sealID,
            subjectID: sealed.candidate.subjectID,
            ticketID: sealed.candidate.ticketID,
            capabilities: Set(SynchronicSpineBlessedCapability.allCases)
        )
    }

    static func callHermesWithSynchronicSpineBlessing(
        _ planted: PlantedSynchronicSpine
    ) -> SynchronicSpineBlessingInHermesCustody {
        SynchronicSpineBlessingInHermesCustody(
            sealID: planted.sealed.sealID,
            subjectID: planted.sealed.candidate.subjectID,
            ticketID: planted.sealed.candidate.ticketID,
            blessing: planted.blessing
        )
    }
}

public enum SynchronicSpineTimeGarden {
    public static func plant(
        _ sealed: SealedSynchronicSpine,
        scan: SynchronicSpineHoraeScan,
        query: SynchronicSpineChronosQuery,
        blessing: SynchronicSpineHecateBlessing
    ) throws -> PlantedSynchronicSpine {
        guard scan.sealID == sealed.sealID,
              query.sealID == sealed.sealID,
              blessing.sealID == sealed.sealID,
              blessing.capabilities == Set(SynchronicSpineBlessedCapability.allCases) else {
            throw SynchronicSpineTimeGardenFailure.plantingRequiresAllMarks
        }
        return PlantedSynchronicSpine(
            sealed: sealed,
            horaeScan: scan,
            chronosQuery: query,
            blessing: blessing
        )
    }
}

public extension Hermes {
    static func announceSynchronicSpineAvailable(
        _ planted: PlantedSynchronicSpine
    ) -> SynchronicSpineAvailabilityAnnouncement {
        SynchronicSpineAvailabilityAnnouncement(planted: planted)
    }
}

public struct SynchronicSpineActIIITimeGarden: Sendable {
    public private(set) var courier: HermesCourier

    public init(courier: HermesCourier) {
        self.courier = courier
    }

    public mutating func run(
        sealed: SealedSynchronicSpine,
        occurredAt: AbsoluteInstant
    ) throws -> (PlantedSynchronicSpine, SynchronicSpineAvailabilityAnnouncement) {
        let commission = sealed.candidate.contents.foundation.commission
        let delivered = try courier.deliverNext(
            ticketID: commission.ticketID,
            occurredAt: occurredAt
        )
        guard delivered == SynchronicSpineActIStarter.timeGarden else {
            throw SynchronicSpineTimeGardenFailure.unexpectedHermesDestination
        }

        let scan = try Horae.scanSynchronicSpine(sealed)
        let query = try Chronos.classifySynchronicSpineForQuery(sealed, after: scan)
        let blessing = try Hecate.blessSynchronicSpine(sealed, after: scan, query: query)
        let planted = try SynchronicSpineTimeGarden.plant(
            sealed,
            scan: scan,
            query: query,
            blessing: blessing
        )
        let blessingInCustody = Hecate.callHermesWithSynchronicSpineBlessing(planted)

        guard blessingInCustody.sealID == sealed.sealID,
              blessingInCustody.subjectID == commission.subjectID,
              blessingInCustody.ticketID == commission.ticketID,
              blessingInCustody.blessing == planted.blessing else {
            throw SynchronicSpineTimeGardenFailure.closureRequiresPlantedBlessing
        }

        try courier.recordReceipt(
            ticketID: commission.ticketID,
            packageID: commission.packageID,
            recipient: SynchronicSpineActIStarter.timeGarden,
            receivedAt: occurredAt
        )

        return (planted, Hermes.announceSynchronicSpineAvailable(planted))
    }
}
