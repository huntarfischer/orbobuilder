/// Clotho's requirement, not a claim that Titan fields have been completed.
public struct SynchronicSpinePattern: Hashable, Sendable {
    public static let requiredBoneCount = 1
    public static let requiredAsteriaPassCount = 12
    public static let requiredThemisImprintCount = 7
    public static let requiredOceanusTideCount = 3
    public static let requiredRheaQualifierCount = 12

    public let subjectID: HermesSubjectID
    public let packageID: HermesPackageID
    public let ticketID: HermesTicketID
    public let bone: SynchronicSpineBone

    public func matchesInventory(
        boneCount: Int,
        asteriaPassCount: Int,
        themisImprintCount: Int,
        oceanusTideCount: Int,
        rheaQualifierCount: Int
    ) -> Bool {
        boneCount == Self.requiredBoneCount
            && asteriaPassCount == Self.requiredAsteriaPassCount
            && themisImprintCount == Self.requiredThemisImprintCount
            && oceanusTideCount == Self.requiredOceanusTideCount
            && rheaQualifierCount == Self.requiredRheaQualifierCount
    }
}

/// The established Clotho life bounds, bound to this Synchronic commission.
/// Its domain is START-inclusive and END-exclusive, exactly as in Natal.
public struct SynchronicSpineBone: Hashable, Sendable {
    public let packageID: HermesPackageID
    public let ticketID: HermesTicketID
    public let bounds: NatalSpineBounds

    public var subjectID: HermesSubjectID { bounds.subjectID }
    public var start: AbsoluteInstant { bounds.start }
    public var natal: AbsoluteInstant { bounds.natal }
    public var end: AbsoluteInstant { bounds.end }
    public var span: OrboSpineBoneSpan { bounds.bone }

    public func contains(_ instant: AbsoluteInstant) -> Bool {
        bounds.contains(instant)
    }
}

/// Pass A ends with this foundation in Lachesis's hands. Only the Bone is
/// fulfilled; no Asteria, Themis, Oceanus, or Rhea result is manufactured here.
public struct SynchronicSpineFoundation: Hashable, Sendable {
    public let commission: SynchronicSpineCommissionHandle
    public let pattern: SynchronicSpinePattern
    public let bone: SynchronicSpineBone
    public let native: Engraving
    public let parentBone: OrboSpineBoneSpan
    public let parentProvenance: OrboSpineRuntimeProvenance
}
