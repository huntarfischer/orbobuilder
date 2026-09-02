public extension Clotho {
    /// Reuses Hestia's native truth and the proven Gregorian anniversary law.
    /// Parent extent is checked without reading or recalculating Titan matter.
    static func cutSynchronicSpineFoundation(
        commission: SynchronicSpineCommissionHandle,
        hearth: Hestia,
        parent: OrboSpineRuntime
    ) throws -> SynchronicSpineFoundation {
        let package = commission.package
        guard package.sender == OrboOnboarding.orboAddress,
              package.kind == SynchronicSpineCommission.packageKind,
              package.addresses == SynchronicSpineCommission.itinerary,
              package.subjectID == package.contents.subjectID else {
            throw SynchronicSpinePassAFailure.unexpectedPackage
        }
        guard let native = hearth.nativeEngraving() else {
            throw SynchronicSpinePassAFailure.nativeTruthUnavailable
        }
        guard hearth.nativeSubjectID == package.subjectID, native.subjectID == package.subjectID else {
            throw SynchronicSpinePassAFailure.wrongSubject
        }
        let truth = try hearth.natalSpineNativeTruth(for: package.subjectID)
        let bounds = try boundNatalSpine(truth)
        // END is a boundary, not an in-domain occurrence. Equal parent/child
        // ends are lawful; no point read at the excluded endpoint is attempted.
        guard parent.bone.start.value <= bounds.bone.start.value,
              parent.bone.end.value >= bounds.bone.end.value else {
            throw SynchronicSpinePassAFailure.sourceDoesNotCoverBone
        }
        let bone = SynchronicSpineBone(
            packageID: package.packageID,
            ticketID: commission.ticketID,
            bounds: bounds
        )
        return SynchronicSpineFoundation(
            commission: commission,
            pattern: SynchronicSpinePattern(
                subjectID: package.subjectID,
                packageID: package.packageID,
                ticketID: commission.ticketID,
                bone: bone
            ),
            bone: bone,
            native: native,
            parentBone: parent.bone,
            parentProvenance: parent.provenance
        )
    }
}
