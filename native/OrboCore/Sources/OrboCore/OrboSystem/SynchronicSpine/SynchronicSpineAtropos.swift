import Foundation

public enum SynchronicSpineAtroposFailure: Error, Hashable, Sendable {
    case identityMismatch
    case boneMismatch
    case declaredInventoryMismatch
    case asteriaMismatch
    case themisMismatch
    case oceanusMismatch
    case rheaMismatch
}

public enum SynchronicSpinePatternStatus: String, Hashable, Sendable {
    case fulfilled = "PATTERN FULFILLED"
}

public struct CertifiedSynchronicSpineSchematic: Sendable {
    public let certificationID: UUID
    public let status: SynchronicSpinePatternStatus
    public let contents: SynchronicSpinePatternContents

    internal init(
        certificationID: UUID = UUID(),
        contents: SynchronicSpinePatternContents
    ) {
        self.certificationID = certificationID
        self.status = .fulfilled
        self.contents = contents
    }
}

/// Hashable Hermes grip for the exact certified Schematic. The full Schematic
/// remains the certified object; this reference exists only because Hermes's
/// package manifest stores hashable package contents.
public struct CertifiedSynchronicSpineSchematicReference: Hashable, Sendable {
    public let certificationID: UUID
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID

    internal init(_ schematic: CertifiedSynchronicSpineSchematic) {
        self.certificationID = schematic.certificationID
        self.subjectID = schematic.contents.foundation.commission.subjectID
        self.ticketID = schematic.contents.foundation.commission.ticketID
    }
}

public extension Atropos {
    /// Verifies Lachesis's finished Pattern contents without resolving any
    /// continuous Titan field or recreating any astrology.
    static func certifySynchronicSpine(
        _ contents: SynchronicSpinePatternContents
    ) -> Result<CertifiedSynchronicSpineSchematic, SynchronicSpineAtroposFailure> {
        let foundation = contents.foundation
        let subject = foundation.commission.subjectID
        let ticket = foundation.commission.ticketID
        let bone = foundation.bone

        guard
            foundation.pattern.subjectID == subject,
            foundation.pattern.ticketID == ticket,
            bone.subjectID == subject,
            bone.ticketID == ticket,
            contents.asteria.subjectID == subject,
            contents.themis.subjectID == subject,
            contents.oceanus.subjectID == subject,
            contents.rhea.subjectID == subject,
            contents.asteria.ticketID == ticket,
            contents.themis.ticketID == ticket,
            contents.oceanus.ticketID == ticket,
            contents.rhea.ticketID == ticket
        else {
            return .failure(.identityMismatch)
        }

        guard
            contents.asteria.bone == bone,
            contents.themis.bone == bone,
            contents.oceanus.bone == bone,
            contents.rhea.bone == bone
        else {
            return .failure(.boneMismatch)
        }

        guard
            contents.boneCount == 1,
            contents.asteriaPassCount == contents.asteria.passes.count,
            contents.themisImprintCount == contents.themis.imprints.count,
            contents.oceanusTideCount == contents.oceanus.tides.count,
            contents.rheaQualifierCount == contents.rhea.qualifiers.count,
            foundation.pattern.matchesInventory(
                boneCount: contents.boneCount,
                asteriaPassCount: contents.asteriaPassCount,
                themisImprintCount: contents.themisImprintCount,
                oceanusTideCount: contents.oceanusTideCount,
                rheaQualifierCount: contents.rheaQualifierCount
            )
        else {
            return .failure(.declaredInventoryMismatch)
        }

        let asteriaBodies = contents.asteria.passes.map(\.body)
        guard asteriaBodies == SynchronicAsteriaBody.canonicalOrder,
              Set(asteriaBodies).count == SynchronicAsteriaBody.canonicalOrder.count else {
            return .failure(.asteriaMismatch)
        }

        let themisOffsets = contents.themis.imprints.map(\.offset)
        guard themisOffsets == SynchronicThemisField.canonicalOffsets,
              Set(themisOffsets).count == SynchronicThemisField.canonicalOffsets.count else {
            return .failure(.themisMismatch)
        }

        let oceanusIdentities = contents.oceanus.tides.map(\.identity)
        guard oceanusIdentities == SynchronicOceanusTideIdentity.canonicalOrder,
              Set(oceanusIdentities).count == SynchronicOceanusTideIdentity.canonicalOrder.count else {
            return .failure(.oceanusMismatch)
        }

        let rheaBodies = contents.rhea.qualifiers.map(\.body)
        guard rheaBodies == SynchronicAsteriaBody.canonicalOrder,
              Set(rheaBodies).count == SynchronicAsteriaBody.canonicalOrder.count else {
            return .failure(.rheaMismatch)
        }

        return .success(CertifiedSynchronicSpineSchematic(contents: contents))
    }

    /// Calls Hermes after certification by returning the original commissioned
    /// package to his custody. Delivery to Hephaestus is deliberately not made
    /// here; that begins Act II.
    @discardableResult
    static func callHermesForCertifiedSynchronicSpine(
        _ schematic: CertifiedSynchronicSpineSchematic,
        courier: inout HermesCourier,
        occurredAt: AbsoluteInstant
    ) throws -> CertifiedSynchronicSpineSchematicReference {
        let commission = schematic.contents.foundation.commission
        let reference = CertifiedSynchronicSpineSchematicReference(schematic)
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
        return reference
    }
}
