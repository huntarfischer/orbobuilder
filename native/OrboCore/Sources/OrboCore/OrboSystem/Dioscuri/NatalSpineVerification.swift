public enum NatalSpineDioscuriFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case boundsMismatch
    case provenanceMismatch
    case themisCountMismatch
    case themisRowMismatch(Int)
    case oceanusCountMismatch
    case oceanusRowMismatch(Int)
    case rheaCountMismatch
    case rheaRowMismatch(Int)
    case rheaFactMismatch(Int)
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
/// that each kind of forge corruption is rejected without giving the candidate
/// itself any mutation surface.
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
    /// ACT II Beat 7. Compare the completed forge against the external,
    /// Atropos-certified plans and the independently supplied parent provenance.
    /// No astrology, chronology, repair, or sealing occurs here.
    public static func inspectNatalSpine(
        _ candidate: NatalSpineCandidate,
        against schematics: AtroposNatalSpineSchematicsPackage,
        parentProvenance: OrboSpineRuntimeProvenance
    ) -> Result<NatalSpineDioscuriApproval, NatalSpineDioscuriFailure> {
        switch inspectNatalSpine(
            NatalSpineDioscuriMatter(candidate: candidate),
            against: schematics,
            parentProvenance: parentProvenance
        ) {
        case .success:
            return .success(
                NatalSpineDioscuriApproval(
                    candidate: candidate,
                    parentProvenance: parentProvenance
                )
            )
        case let .failure(failure):
            return .failure(failure)
        }
    }

    static func inspectNatalSpine(
        _ matter: NatalSpineDioscuriMatter,
        against schematics: AtroposNatalSpineSchematicsPackage,
        parentProvenance: OrboSpineRuntimeProvenance
    ) -> Result<Void, NatalSpineDioscuriFailure> {
        guard matter.subjectID == schematics.subjectID,
              matter.substrate.subjectID == schematics.subjectID else {
            return .failure(.subjectMismatch)
        }
        guard matter.bounds == schematics.bounds,
              matter.substrate.bounds == schematics.bounds else {
            return .failure(.boundsMismatch)
        }
        guard matter.substrate.parentProvenance == parentProvenance else {
            return .failure(.provenanceMismatch)
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
            guard validFactReference(forged, matter: matter) else {
                return .failure(.rheaFactMismatch(index))
            }
        }

        return .success(())
    }

    private static func validFactReference(
        _ forged: NatalSpineForgedRheaQualification,
        matter: NatalSpineDioscuriMatter
    ) -> Bool {
        switch (forged.qualification.source, forged.fact) {
        case let (.houseCrossing(crossing), .themisCrossing(previousSourceRow, nextSourceRow)):
            guard matter.themis.indices.contains(previousSourceRow),
                  matter.themis.indices.contains(nextSourceRow) else {
                return false
            }
            let previous = matter.themis[previousSourceRow]
            let next = matter.themis[nextSourceRow]
            return previous.sourceRow == previousSourceRow
                && next.sourceRow == nextSourceRow
                && previous.span.body == crossing.body
                && next.span.body == crossing.body
                && previous.span.house == crossing.fromHouse
                && next.span.house == crossing.toHouse
                && abs(previous.span.end.value - crossing.occurrence.value) <= 1e-9
                && abs(next.span.start.value - crossing.occurrence.value) <= 1e-9

        case let (.ringRealization(realization), .oceanusRealization(sourceRow)):
            guard matter.oceanus.indices.contains(sourceRow) else { return false }
            let source = matter.oceanus[sourceRow]
            return source.sourceRow == sourceRow
                && source.realization == realization

        default:
            return false
        }
    }
}
