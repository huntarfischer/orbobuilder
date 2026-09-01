public enum SynchronicSpinePassBFailure: Error, Hashable, Sendable {
    case mismatchedConstituent
    case incompletePatternContents
}

/// The finished Pattern constituents held by Lachesis at the end of Pass B.
/// This is not yet a Schematic and does not claim Pattern fulfillment; both
/// judgments remain Atropos's work in Pass C.
public struct SynchronicSpinePatternContents: Sendable {
    public let foundation: SynchronicSpineFoundation
    public let asteria: SynchronicAsteriaField
    public let themis: SynchronicThemisField
    public let oceanus: SynchronicOceanusField
    public let rhea: SynchronicRheaField

    /// Lachesis's declared inventory. Atropos independently compares these
    /// values with the actual constituents rather than trusting the declaration.
    public let boneCount: Int
    public let asteriaPassCount: Int
    public let themisImprintCount: Int
    public let oceanusTideCount: Int
    public let rheaQualifierCount: Int

    internal init(
        foundation: SynchronicSpineFoundation,
        asteria: SynchronicAsteriaField,
        themis: SynchronicThemisField,
        oceanus: SynchronicOceanusField,
        rhea: SynchronicRheaField,
        boneCount: Int = 1,
        asteriaPassCount: Int? = nil,
        themisImprintCount: Int? = nil,
        oceanusTideCount: Int? = nil,
        rheaQualifierCount: Int? = nil
    ) {
        self.foundation = foundation
        self.asteria = asteria
        self.themis = themis
        self.oceanus = oceanus
        self.rhea = rhea
        self.boneCount = boneCount
        self.asteriaPassCount = asteriaPassCount ?? asteria.passes.count
        self.themisImprintCount = themisImprintCount ?? themis.imprints.count
        self.oceanusTideCount = oceanusTideCount ?? oceanus.tides.count
        self.rheaQualifierCount = rheaQualifierCount ?? rhea.qualifiers.count
    }
}

public extension Lachesis {
    /// Holds the already-finished Titan matter under one native, ticket, and
    /// Bone. Lachesis neither certifies it nor recomputes any constituent.
    static func holdSynchronicSpinePatternContents(
        foundation: SynchronicSpineFoundation,
        asteria: SynchronicAsteriaField,
        themis: SynchronicThemisField,
        oceanus: SynchronicOceanusField,
        rhea: SynchronicRheaField
    ) throws -> SynchronicSpinePatternContents {
        let subject = foundation.commission.subjectID
        let ticket = foundation.commission.ticketID
        let bone = foundation.bone

        guard
            asteria.subjectID == subject,
            themis.subjectID == subject,
            oceanus.subjectID == subject,
            rhea.subjectID == subject,
            asteria.ticketID == ticket,
            themis.ticketID == ticket,
            oceanus.ticketID == ticket,
            rhea.ticketID == ticket,
            asteria.bone == bone,
            themis.bone == bone,
            oceanus.bone == bone,
            rhea.bone == bone
        else {
            throw SynchronicSpinePassBFailure.mismatchedConstituent
        }

        let asteriaBodies = asteria.passes.map(\.body)
        let rheaBodies = rhea.qualifiers.map(\.body)
        let themisOffsets = themis.imprints.map(\.offset)
        let oceanusIdentities = oceanus.tides.map(\.identity)

        guard
            foundation.pattern.matchesInventory(
                boneCount: 1,
                asteriaPassCount: asteria.passes.count,
                themisImprintCount: themis.imprints.count,
                oceanusTideCount: oceanus.tides.count,
                rheaQualifierCount: rhea.qualifiers.count
            ),
            asteriaBodies == SynchronicAsteriaBody.canonicalOrder,
            Set(asteriaBodies).count == SynchronicAsteriaBody.canonicalOrder.count,
            rheaBodies == SynchronicAsteriaBody.canonicalOrder,
            Set(rheaBodies).count == SynchronicAsteriaBody.canonicalOrder.count,
            themisOffsets == SynchronicThemisField.canonicalOffsets,
            Set(themisOffsets).count == SynchronicThemisField.canonicalOffsets.count,
            oceanusIdentities == SynchronicOceanusTideIdentity.canonicalOrder,
            Set(oceanusIdentities).count == SynchronicOceanusTideIdentity.canonicalOrder.count
        else {
            throw SynchronicSpinePassBFailure.incompletePatternContents
        }

        return SynchronicSpinePatternContents(
            foundation: foundation,
            asteria: asteria,
            themis: themis,
            oceanus: oceanus,
            rhea: rhea
        )
    }
}
