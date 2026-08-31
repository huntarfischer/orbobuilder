public struct NatalSpineSeal: Hashable, Sendable {
    public let packageID: HermesPackageID
    public let subjectID: HermesSubjectID
    public let bounds: NatalSpineBounds
    public let parentProvenance: OrboSpineRuntimeProvenance
    public let themisCount: Int
    public let oceanusCount: Int
    public let rheaCount: Int

    fileprivate init(
        packageID: HermesPackageID,
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds,
        parentProvenance: OrboSpineRuntimeProvenance,
        themisCount: Int,
        oceanusCount: Int,
        rheaCount: Int
    ) {
        self.packageID = packageID
        self.subjectID = subjectID
        self.bounds = bounds
        self.parentProvenance = parentProvenance
        self.themisCount = themisCount
        self.oceanusCount = oceanusCount
        self.rheaCount = rheaCount
    }
}

/// The exact candidate approved by the Dioscuri, now under Hephaestus's seal.
/// The candidate itself remains the source of truth; the seal binds its commission,
/// native, bounds, parent provenance, and certified layer cardinalities.
public struct SealedNatalSpine: Sendable {
    public let candidate: NatalSpineCandidate
    public let seal: NatalSpineSeal

    fileprivate init(candidate: NatalSpineCandidate, seal: NatalSpineSeal) {
        self.candidate = candidate
        self.seal = seal
    }

    public var subjectID: HermesSubjectID { seal.subjectID }
    public var bounds: NatalSpineBounds { seal.bounds }
    public var packageID: HermesPackageID { seal.packageID }
}

public extension Hephaestus {
    /// ACT II Beat 8. Sealing accepts only a Dioscuri approval, making successful
    /// independent verification the type-level prerequisite for completion.
    static func sealNatalSpine(
        _ approval: NatalSpineDioscuriApproval
    ) -> SealedNatalSpine {
        let candidate = approval.candidate
        let seal = NatalSpineSeal(
            packageID: candidate.commission.packageID,
            subjectID: candidate.subjectID,
            bounds: candidate.bounds,
            parentProvenance: approval.parentProvenance,
            themisCount: candidate.themis.count,
            oceanusCount: candidate.oceanus.count,
            rheaCount: candidate.rhea.count
        )
        return SealedNatalSpine(candidate: candidate, seal: seal)
    }
}
