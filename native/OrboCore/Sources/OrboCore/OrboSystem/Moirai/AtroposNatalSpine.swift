/// Atropos's seal around the bounded Natal material and exact three-table schematic she inspected.
/// The Titan tables remain separate; Atropos does not merge, recalculate, or repair them.
public struct AtroposNatalSpineSchematicsPackage: Hashable, Sendable {
    public let threads: NatalSpineThreads
    public let bounds: NatalSpineBounds
    public let themis: NatalSpineThemisTable
    public let oceanus: NatalSpineOceanusTable
    public let rhea: NatalSpineRheaTable

    fileprivate init(
        threads: NatalSpineThreads,
        bounds: NatalSpineBounds,
        themis: NatalSpineThemisTable,
        oceanus: NatalSpineOceanusTable,
        rhea: NatalSpineRheaTable
    ) {
        self.threads = threads
        self.bounds = bounds
        self.themis = themis
        self.oceanus = oceanus
        self.rhea = rhea
    }

    public var subjectID: HermesSubjectID { bounds.subjectID }
}

public enum AtroposNatalSpineFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case boundsMismatch
    case themisCountMismatch
    case themisMissingBody(MundaneBody)
    case themisInvalidCoverage(MundaneBody)
    case oceanusBodySetMismatch
    case oceanusBodyCountMismatch(MundaneBody)
    case oceanusCountMismatch
    case oceanusInvalidRealization(MundaneBody)
    case rheaCountMismatch
    case rheaInvalidQualification
}

public extension Atropos {
    /// Certifies the bounded Threads and three independent temporal Titan tables as one
    /// forgeable Natal Spine package. Atropos checks correspondence only.
    static func inspectNatalSpineSchematics(
        threads: NatalSpineThreads,
        themis: NatalSpineThemisTable,
        oceanus: NatalSpineOceanusTable,
        rhea: NatalSpineRheaTable
    ) -> Result<AtroposNatalSpineSchematicsPackage, AtroposNatalSpineFailure> {
        let bounds = threads.bounds
        guard threads.subjectID == bounds.subjectID,
              themis.subjectID == bounds.subjectID,
              oceanus.subjectID == bounds.subjectID,
              rhea.subjectID == bounds.subjectID else {
            return .failure(.subjectMismatch)
        }
        guard themis.bounds == bounds,
              oceanus.bounds == bounds,
              rhea.bounds == bounds else {
            return .failure(.boundsMismatch)
        }

        guard themis.declaredCount == themis.spans.count else {
            return .failure(.themisCountMismatch)
        }
        for body in MundaneBody.canonicalOrder {
            let spans = themis.spans(for: body).sorted { $0.start.value < $1.start.value }
            guard !spans.isEmpty else {
                return .failure(.themisMissingBody(body))
            }
            guard validCoverage(spans, body: body, bounds: bounds) else {
                return .failure(.themisInvalidCoverage(body))
            }
        }

        let expectedBodies = MundaneBody.canonicalOrder
        guard oceanus.bodies.map(\.body) == expectedBodies else {
            return .failure(.oceanusBodySetMismatch)
        }
        var oceanusTotal = 0
        for table in oceanus.bodies {
            guard table.declaredCount == table.realizations.count else {
                return .failure(.oceanusBodyCountMismatch(table.body))
            }
            for realization in table.realizations {
                guard realization.mundaneBody == table.body,
                      bounds.bone.contains(realization.occurrence.julianDay) else {
                    return .failure(.oceanusInvalidRealization(table.body))
                }
            }
            oceanusTotal += table.realizations.count
        }
        guard oceanus.declaredCount == oceanusTotal else {
            return .failure(.oceanusCountMismatch)
        }

        guard rhea.declaredCount == rhea.qualifications.count else {
            return .failure(.rheaCountMismatch)
        }
        for qualification in rhea.qualifications {
            guard qualification.source.body.planet == qualification.temper.planet,
                  bounds.bone.contains(qualification.source.julianDay) else {
                return .failure(.rheaInvalidQualification)
            }
        }

        return .success(
            AtroposNatalSpineSchematicsPackage(
                threads: threads,
                bounds: bounds,
                themis: themis,
                oceanus: oceanus,
                rhea: rhea
            )
        )
    }

    private static func validCoverage(
        _ spans: [NatalSpineHouseSpan],
        body: MundaneBody,
        bounds: NatalSpineBounds
    ) -> Bool {
        let epsilon = 1e-9
        guard spans.allSatisfy({ $0.body == body }),
              let first = spans.first,
              let last = spans.last,
              abs(first.start.value - bounds.bone.start.value) <= epsilon,
              abs(last.end.value - bounds.bone.end.value) <= epsilon else {
            return false
        }
        for index in 1..<spans.count {
            let previous = spans[index - 1]
            let current = spans[index]
            guard previous.start.value < previous.end.value,
                  current.start.value < current.end.value,
                  abs(previous.end.value - current.start.value) <= epsilon else {
                return false
            }
        }
        return true
    }
}
