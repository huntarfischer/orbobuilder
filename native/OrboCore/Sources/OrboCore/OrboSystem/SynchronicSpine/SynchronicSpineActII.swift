import Foundation

public enum SynchronicSpineDoor: String, CaseIterable, Hashable, Sendable {
    case horae = "Door I — Horae"
    case chronos = "Door II — Chronos"
    case hecate = "Door III — Hecate"

    public static let canonicalOrder: [SynchronicSpineDoor] = [.horae, .chronos, .hecate]
}

public struct SynchronicSpineCandidate: Sendable {
    public let candidateID: UUID
    public let certificationID: UUID
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let bone: SynchronicSpineBone
    public let contents: SynchronicSpinePatternContents
    public let doors: [SynchronicSpineDoor]

    internal init(
        candidateID: UUID = UUID(),
        schematic: CertifiedSynchronicSpineSchematic,
        doors: [SynchronicSpineDoor] = SynchronicSpineDoor.canonicalOrder
    ) {
        self.candidateID = candidateID
        self.certificationID = schematic.certificationID
        self.subjectID = schematic.contents.foundation.commission.subjectID
        self.ticketID = schematic.contents.foundation.commission.ticketID
        self.bone = schematic.contents.foundation.bone
        self.contents = schematic.contents
        self.doors = doors
    }
}

public enum SynchronicSpineForgeFailureReason: Hashable, Sendable {
    case certificationMismatch
    case subjectMismatch
    case ticketMismatch
    case boneMismatch
    case asteriaMismatch
    case themisMismatch
    case oceanusMismatch
    case rheaMismatch
    case doorMismatch
}

public struct SynchronicSpineDioscuriTestimony: Hashable, Sendable {
    public let candidateID: UUID
    public let certificationID: UUID

    internal init(candidate: SynchronicSpineCandidate) {
        self.candidateID = candidate.candidateID
        self.certificationID = candidate.certificationID
    }
}

public enum SynchronicSpineForgeVerdict: Sendable {
    case inconsistent(candidate: SynchronicSpineCandidate, reasons: [SynchronicSpineForgeFailureReason])
    case consistent(candidate: SynchronicSpineCandidate, testimony: SynchronicSpineDioscuriTestimony)
}

public struct SealedSynchronicSpine: Sendable {
    public let sealID: UUID
    public let candidate: SynchronicSpineCandidate
    public let testimony: SynchronicSpineDioscuriTestimony

    internal init(
        sealID: UUID = UUID(),
        candidate: SynchronicSpineCandidate,
        testimony: SynchronicSpineDioscuriTestimony
    ) {
        self.sealID = sealID
        self.candidate = candidate
        self.testimony = testimony
    }
}

public struct SealedSynchronicSpineReference: Hashable, Sendable {
    public let sealID: UUID
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID

    internal init(_ spine: SealedSynchronicSpine) {
        self.sealID = spine.sealID
        self.subjectID = spine.candidate.subjectID
        self.ticketID = spine.candidate.ticketID
    }
}

public enum SynchronicSpineActIIFailure: Error, Hashable, Sendable {
    case unexpectedHermesDestination
    case inconsistentCandidate([SynchronicSpineForgeFailureReason])
    case testimonyMismatch
}

public enum SynchronicSpineHephaestus {
    public static func forge(
        schematic: CertifiedSynchronicSpineSchematic
    ) -> SynchronicSpineCandidate {
        SynchronicSpineCandidate(schematic: schematic)
    }

    public static func reforge(
        schematic: CertifiedSynchronicSpineSchematic
    ) -> SynchronicSpineCandidate {
        SynchronicSpineCandidate(schematic: schematic)
    }

    public static func seal(
        candidate: SynchronicSpineCandidate,
        testimony: SynchronicSpineDioscuriTestimony
    ) throws -> SealedSynchronicSpine {
        guard testimony.candidateID == candidate.candidateID,
              testimony.certificationID == candidate.certificationID else {
            throw SynchronicSpineActIIFailure.testimonyMismatch
        }
        return SealedSynchronicSpine(candidate: candidate, testimony: testimony)
    }
}

public enum SynchronicSpineDioscuri {
    public static func verify(
        candidate: SynchronicSpineCandidate,
        against schematic: CertifiedSynchronicSpineSchematic
    ) -> SynchronicSpineForgeVerdict {
        var reasons: [SynchronicSpineForgeFailureReason] = []
        let expected = schematic.contents

        if candidate.certificationID != schematic.certificationID { reasons.append(.certificationMismatch) }
        if candidate.subjectID != expected.foundation.commission.subjectID { reasons.append(.subjectMismatch) }
        if candidate.ticketID != expected.foundation.commission.ticketID { reasons.append(.ticketMismatch) }
        if candidate.bone != expected.foundation.bone { reasons.append(.boneMismatch) }
        if candidate.contents.asteria.passes.map(\.body) != expected.asteria.passes.map(\.body) { reasons.append(.asteriaMismatch) }
        if candidate.contents.themis.imprints.map(\.offset) != expected.themis.imprints.map(\.offset) { reasons.append(.themisMismatch) }
        if candidate.contents.oceanus.tides.map(\.identity) != expected.oceanus.tides.map(\.identity) { reasons.append(.oceanusMismatch) }
        if candidate.contents.rhea.qualifiers.map(\.body) != expected.rhea.qualifiers.map(\.body) { reasons.append(.rheaMismatch) }
        if candidate.doors != SynchronicSpineDoor.canonicalOrder { reasons.append(.doorMismatch) }

        if reasons.isEmpty {
            return .consistent(
                candidate: candidate,
                testimony: SynchronicSpineDioscuriTestimony(candidate: candidate)
            )
        }
        return .inconsistent(candidate: candidate, reasons: reasons)
    }
}

public struct SynchronicSpineActIIForge: Sendable {
    public private(set) var courier: HermesCourier

    public init(courier: HermesCourier) {
        self.courier = courier
    }

    /// Executes Act II exactly: Hermes delivers to Hephaestus, Hephaestus forges,
    /// Dioscuri verify, Hephaestus seals, and Hermes recovers the sealed Spine
    /// for the final Time Garden leg. The original Schematic never changes.
    public mutating func run(
        schematic: CertifiedSynchronicSpineSchematic,
        occurredAt: AbsoluteInstant
    ) throws -> SealedSynchronicSpine {
        let commission = schematic.contents.foundation.commission

        let delivered = try courier.deliverNext(
            ticketID: commission.ticketID,
            occurredAt: occurredAt
        )
        guard delivered == SynchronicSpineActIStarter.hephaestus else {
            throw SynchronicSpineActIIFailure.unexpectedHermesDestination
        }

        var candidate = SynchronicSpineHephaestus.forge(schematic: schematic)
        var verdict = SynchronicSpineDioscuri.verify(candidate: candidate, against: schematic)

        if case .inconsistent(_, let reasons) = verdict {
            candidate = SynchronicSpineHephaestus.reforge(schematic: schematic)
            verdict = SynchronicSpineDioscuri.verify(candidate: candidate, against: schematic)
            if case .inconsistent(_, let secondReasons) = verdict {
                throw SynchronicSpineActIIFailure.inconsistentCandidate(secondReasons.isEmpty ? reasons : secondReasons)
            }
        }

        guard case .consistent(let verified, let testimony) = verdict else {
            throw SynchronicSpineActIIFailure.inconsistentCandidate([])
        }

        let sealed = try SynchronicSpineHephaestus.seal(
            candidate: verified,
            testimony: testimony
        )

        let reference = SealedSynchronicSpineReference(sealed)
        let package = HermesPackage(
            packageID: commission.packageID,
            subjectID: commission.subjectID,
            sender: SynchronicSpineActIStarter.orbo,
            kind: commission.packageKind,
            addresses: commission.addresses,
            contents: reference
        )!
        try courier.recover(
            ticketID: commission.ticketID,
            package: package,
            occurredAt: occurredAt
        )

        return sealed
    }
}
