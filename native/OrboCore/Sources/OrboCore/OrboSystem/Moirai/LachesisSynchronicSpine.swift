public extension Lachesis {
    /// Receives the exact foundation Clotho cut. Pass B will fill its Pattern.
    static func receiveSynchronicSpineFoundation(
        _ foundation: SynchronicSpineFoundation
    ) throws -> SynchronicSpineFoundation {
        let commission = foundation.commission
        let pattern = foundation.pattern
        let bone = foundation.bone
        guard commission.package.subjectID == pattern.subjectID,
              pattern.subjectID == bone.subjectID,
              bone.subjectID == foundation.native.subjectID,
              commission.package.packageID == pattern.packageID,
              pattern.packageID == bone.packageID,
              commission.ticketID == pattern.ticketID,
              pattern.ticketID == bone.ticketID,
              pattern.bone == bone,
              bone.natal == foundation.native.tempus?.absoluteInstant,
              foundation.parentBone.start.value <= bone.span.start.value,
              foundation.parentBone.end.value >= bone.span.end.value else {
            throw SynchronicSpinePassAFailure.mismatchedFoundation
        }
        return foundation
    }
}
