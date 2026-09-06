public enum NatalSpineDioscuriFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case boundsMismatch
    case provenanceMismatch
    case celestialSupportMismatch(MundaneBody)
    case stationMismatch
    case boundaryAnchorMismatch(MundaneBody)
    case themisCountMismatch
    case themisRowMismatch(Int)
    case oceanusCountMismatch
    case oceanusRowMismatch(Int)
    case rheaCountMismatch
    case rheaRowMismatch(Int)
}

public struct NatalSpineDioscuriApproval: Sendable {
    public let candidate: NatalSpineCandidate
    public let parentProvenance: OrboSpineRuntimeProvenance

    fileprivate init(
        candidate: NatalSpineCandidate,
        parentProvenance: OrboSpineRuntimeProvenance
    ) {
        self.candidate = candidate
        self.parentProvenance = parentProvenance
    }
}

/// Read-only matter presented to the Dioscuri. Production creates this snapshot
/// from the finished candidate. Tests may construct altered snapshots to prove
/// that forge corruption is rejected without giving the candidate mutation surface.
struct NatalSpineDioscuriMatter: Hashable, Sendable {
    let subjectID: HermesSubjectID
    let bounds: NatalSpineBounds
    let substrate: NatalSpineCelestialSubstrate
    let themis: [NatalSpineForgedThemisSpan]
    let oceanus: [NatalSpineForgedOceanusRealization]
    let rhea: [NatalSpineForgedRheaQualification]

    init(candidate: NatalSpineCandidate) {
        self.subjectID = candidate.subjectID
        self.bounds = candidate.bounds
        self.substrate = candidate.substrate
        self.themis = candidate.themis
        self.oceanus = candidate.oceanus
        self.rhea = candidate.rhea
    }

    init(
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds,
        substrate: NatalSpineCelestialSubstrate,
        themis: [NatalSpineForgedThemisSpan],
        oceanus: [NatalSpineForgedOceanusRealization],
        rhea: [NatalSpineForgedRheaQualification]
    ) {
        self.subjectID = subjectID
        self.bounds = bounds
        self.substrate = substrate
        self.themis = themis
        self.oceanus = oceanus
        self.rhea = rhea
    }
}

public enum Dioscuri {
    /// Compares the completed forge against the exact bounded Threads and three
    /// Atropos-certified Titan tables. The parent Timespine is not reopened here.
    public static func inspectNatalSpine(
        _ candidate: NatalSpineCandidate,
        against schematics: AtroposNatalSpineSchematicsPackage
    ) -> Result<NatalSpineDioscuriApproval, NatalSpineDioscuriFailure> {
        switch inspectNatalSpine(
            NatalSpineDioscuriMatter(candidate: candidate),
            against: schematics
        ) {
        case .success:
            return .success(
                NatalSpineDioscuriApproval(
                    candidate: candidate,
                    parentProvenance: schematics.threads.parentProvenance
                )
            )
        case let .failure(failure):
            return .failure(failure)
        }
    }

    static func inspectNatalSpine(
        _ matter: NatalSpineDioscuriMatter,
        against schematics: AtroposNatalSpineSchematicsPackage
    ) -> Result<Void, NatalSpineDioscuriFailure> {
        guard matter.subjectID == schematics.subjectID,
              matter.substrate.subjectID == schematics.subjectID else {
            return .failure(.subjectMismatch)
        }
        guard matter.bounds == schematics.bounds,
              matter.substrate.bounds == schematics.bounds else {
            return .failure(.boundsMismatch)
        }

        let threads = schematics.threads
        guard matter.substrate.parentProvenance == threads.parentProvenance else {
            return .failure(.provenanceMismatch)
        }
        for body in MundaneBody.canonicalOrder {
            let forgedSupports = matter.substrate.supports.filter { $0.body == body }
            let sealedSupports = threads.supports.filter { $0.body == body }
            guard sameMatter(forgedSupports, sealedSupports) else {
                return .failure(.celestialSupportMismatch(body))
            }
            let forgedAnchors = matter.substrate.boundaryAnchors.filter { $0.body == body }
            let sealedAnchors = threads.boundaryAnchors.filter { $0.body == body }
            guard sameMatter(forgedAnchors, sealedAnchors) else {
                return .failure(.boundaryAnchorMismatch(body))
            }
        }
        guard sameMatter(matter.substrate.stations, threads.stations) else {
            return .failure(.stationMismatch)
        }

        let themisSource = schematics.themis.spans
        guard matter.themis.count == themisSource.count else {
            return .failure(.themisCountMismatch)
        }
        for index in themisSource.indices {
            let forged = matter.themis[index]
            guard forged.sourceRow == index,
                  forged.span == themisSource[index] else {
                return .failure(.themisRowMismatch(index))
            }
        }

        let oceanusSource = schematics.oceanus.realizations
        guard matter.oceanus.count == oceanusSource.count else {
            return .failure(.oceanusCountMismatch)
        }
        for index in oceanusSource.indices {
            let forged = matter.oceanus[index]
            guard forged.sourceRow == index,
                  forged.realization == oceanusSource[index] else {
                return .failure(.oceanusRowMismatch(index))
            }
        }

        let rheaSource = schematics.rhea.qualifications
        guard matter.rhea.count == rheaSource.count else {
            return .failure(.rheaCountMismatch)
        }
        for index in rheaSource.indices {
            let forged = matter.rhea[index]
            guard forged.sourceRow == index,
                  forged.qualification == rheaSource[index] else {
                return .failure(.rheaRowMismatch(index))
            }
        }

        return .success(())
    }

    private static func sameMatter<Value: Hashable>(
        _ lhs: [Value],
        _ rhs: [Value]
    ) -> Bool {
        guard lhs.count == rhs.count else { return false }
        let left = Dictionary(grouping: lhs, by: { $0 }).mapValues { $0.count }
        let right = Dictionary(grouping: rhs, by: { $0 }).mapValues { $0.count }
        return left == right
    }
}
