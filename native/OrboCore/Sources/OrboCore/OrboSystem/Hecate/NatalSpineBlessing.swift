public struct NatalSpineHecateBlessing: Hashable, Sendable {
    public let packageID: HermesPackageID
    public let subjectID: HermesSubjectID
    public let bounds: NatalSpineBounds
    public let parentProvenance: OrboSpineRuntimeProvenance

    fileprivate init(
        packageID: HermesPackageID,
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds,
        parentProvenance: OrboSpineRuntimeProvenance
    ) {
        self.packageID = packageID
        self.subjectID = subjectID
        self.bounds = bounds
        self.parentProvenance = parentProvenance
    }
}

public enum NatalSpineHecateFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case packageMismatch
    case boundsMismatch
}

public extension Hecate {
    /// ACT III Beat 4. Hecate blesses availability only after the finished Spine
    /// has a matching Chronos index. She adds no astrology, performs no query,
    /// and does not alter the sealed object.
    static func blessNatalSpine(
        _ spine: SealedNatalSpine,
        indexedBy index: NatalSpineChronosIndex
    ) throws -> NatalSpineHecateBlessing {
        guard index.subjectID == spine.subjectID else {
            throw NatalSpineHecateFailure.subjectMismatch
        }
        guard index.packageID == spine.packageID else {
            throw NatalSpineHecateFailure.packageMismatch
        }
        guard index.bounds == spine.bounds else {
            throw NatalSpineHecateFailure.boundsMismatch
        }

        return NatalSpineHecateBlessing(
            packageID: spine.packageID,
            subjectID: spine.subjectID,
            bounds: spine.bounds,
            parentProvenance: spine.seal.parentProvenance
        )
    }

    /// Mounted Natal Spine handoff. Once the finished artifact has mounted,
    /// Hecate blesses the same runtime Chronos indexed rather than the pre-mount
    /// sealed candidate. The blessing remains identity/provenance only.
    static func blessNatalSpine(
        _ spine: NatalSpineRuntime,
        indexedBy index: NatalSpineMountedChronosIndex
    ) throws -> NatalSpineHecateBlessing {
        guard index.subjectID == spine.subjectID else {
            throw NatalSpineHecateFailure.subjectMismatch
        }
        guard index.packageID == spine.packageID else {
            throw NatalSpineHecateFailure.packageMismatch
        }
        guard index.bounds == spine.bounds else {
            throw NatalSpineHecateFailure.boundsMismatch
        }

        return NatalSpineHecateBlessing(
            packageID: spine.packageID,
            subjectID: spine.subjectID,
            bounds: spine.bounds,
            parentProvenance: spine.parentProvenance
        )
    }
}
