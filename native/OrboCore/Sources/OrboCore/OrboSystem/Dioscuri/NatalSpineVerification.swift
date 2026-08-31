public enum NatalSpineDioscuriFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case boundsMismatch
    case parentBoneMismatch
    case provenanceMismatch
    case parentMatterUnavailable(MundaneBody)
    case celestialSupportMismatch(MundaneBody)
    case stationMismatch
    case boundaryAnchorMismatch(MundaneBody)
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
    /// ACT II Beat 7. Compare the completed forge against both external sources
    /// of truth: Atropos-certified native schematics and the canonical parent
    /// Mundane OrboSpine. No astrology, chronology, repair, or sealing occurs here.
    public static func inspectNatalSpine<Source: NatalSpineForgeTimespineSource>(
        _ candidate: NatalSpineCandidate,
        against schematics: AtroposNatalSpineSchematicsPackage,
        parent source: Source
    ) -> Result<NatalSpineDioscuriApproval, NatalSpineDioscuriFailure> {
        switch inspectNatalSpine(
            NatalSpineDioscuriMatter(candidate: candidate),
            against: schematics,
            parent: source
        ) {
        case .success:
            return .success(
                NatalSpineDioscuriApproval(
                    candidate: candidate,
                    parentProvenance: source.sourceProvenance
                )
            )
        case let .failure(failure):
            return .failure(failure)
        }
    }

    static func inspectNatalSpine<Source: NatalSpineForgeTimespineSource>(
        _ matter: NatalSpineDioscuriMatter,
        against schematics: AtroposNatalSpineSchematicsPackage,
        parent source: Source
    ) -> Result<Void, NatalSpineDioscuriFailure> {
        guard matter.subjectID == schematics.subjectID,
              matter.substrate.subjectID == schematics.subjectID else {
            return .failure(.subjectMismatch)
        }
        guard matter.bounds == schematics.bounds,
              matter.substrate.bounds == schematics.bounds else {
            return .failure(.boundsMismatch)
        }

        let bone = schematics.bounds.bone
        guard bone.start.value >= source.sourceBone.start.value,
              bone.end.value < source.sourceBone.end.value else {
            return .failure(.parentBoneMismatch)
        }
        guard matter.substrate.parentProvenance == source.sourceProvenance else {
            return .failure(.provenanceMismatch)
        }
        if let failure = verifyCelestialSubstrate(
            matter.substrate,
            bone: bone,
            parent: source
        ) {
            return .failure(failure)
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

    private static func verifyCelestialSubstrate<Source: NatalSpineForgeTimespineSource>(
        _ substrate: NatalSpineCelestialSubstrate,
        bone: OrboSpineBoneSpan,
        parent source: Source
    ) -> NatalSpineDioscuriFailure? {
        for body in MundaneBody.canonicalOrder {
            var expectedSupports: [OrboSpineCelestialCoordinate] = []
            let step = OrboSpineContract.supportDegrees(for: body)
            let count = Int((360.0 / step).rounded())

            for index in 0..<count {
                let physical = Double(index) * step
                for motion in [Motion.direct, Motion.retrograde] {
                    let target = OrboSpineDirectionalDegree(
                        physicalDegrees: physical,
                        motion: motion
                    )!
                    do {
                        expectedSupports.append(contentsOf:
                            try source.occurrences(of: body, at: target)
                                .filter { bone.contains($0.julianDay) }
                        )
                    } catch {
                        return .parentMatterUnavailable(body)
                    }
                }
            }

            expectedSupports = Array(Set(expectedSupports))
            let forgedSupports = substrate.supports.filter { $0.body == body }
            guard sameMatter(forgedSupports, expectedSupports) else {
                return .celestialSupportMismatch(body)
            }

            let start: OrboSpineCelestialCoordinate
            let end: OrboSpineCelestialCoordinate
            do {
                start = try source.coordinate(of: body, at: bone.start)
                end = try source.coordinate(of: body, at: bone.end)
            } catch {
                return .parentMatterUnavailable(body)
            }
            guard start.body == body,
                  end.body == body,
                  let startAnchor = OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: .start,
                    julianDay: bone.start,
                    physicalDegrees: start.directionalDegree.physicalDegrees,
                    motion: start.directionalDegree.motion
                  ),
                  let endAnchor = OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: .endExclusive,
                    julianDay: bone.end,
                    physicalDegrees: end.directionalDegree.physicalDegrees,
                    motion: end.directionalDegree.motion
                  ) else {
                return .parentMatterUnavailable(body)
            }

            let forgedAnchors = substrate.boundaryAnchors.filter { $0.body == body }
            guard sameMatter(forgedAnchors, [startAnchor, endAnchor]) else {
                return .boundaryAnchorMismatch(body)
            }
        }

        let expectedStations = source.sourceStations.filter { bone.contains($0.julianDay) }
        guard sameMatter(substrate.stations, expectedStations) else {
            return .stationMismatch
        }

        return nil
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
