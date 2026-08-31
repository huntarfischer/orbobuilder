public struct NatalSpineRingRealization: Hashable, Sendable {
    public let mundaneBody: MundaneBody
    public let natalGene: AstroDNAGene
    public let natalSource: RingFineState
    public let relation: RingMark
    public let targetArcsecond: Int
    public let occurrence: OrboSpineCelestialCoordinate

    public init?(
        mundaneBody: MundaneBody,
        natalGene: AstroDNAGene,
        natalSource: RingFineState,
        relation: RingMark,
        targetArcsecond: Int,
        occurrence: OrboSpineCelestialCoordinate
    ) {
        guard occurrence.body == mundaneBody,
              targetArcsecond >= 0,
              targetArcsecond < Ring.arcseconds else {
            return nil
        }
        let expectedDegrees = Double(targetArcsecond) / Double(Ring.arcsecondsPerDegree)
        guard abs(occurrence.directionalDegree.physicalDegrees - expectedDegrees) <= 1e-7 else {
            return nil
        }
        self.mundaneBody = mundaneBody
        self.natalGene = natalGene
        self.natalSource = natalSource
        self.relation = relation
        self.targetArcsecond = targetArcsecond
        self.occurrence = occurrence
    }
}

public struct NatalSpineOceanusBodyTable: Hashable, Sendable {
    public let body: MundaneBody
    public let realizations: [NatalSpineRingRealization]
    public let declaredCount: Int

    internal init(
        body: MundaneBody,
        realizations: [NatalSpineRingRealization],
        declaredCount: Int? = nil
    ) {
        self.body = body
        self.realizations = realizations
        self.declaredCount = declaredCount ?? realizations.count
    }
}

public struct NatalSpineOceanusTable: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let bounds: NatalSpineBounds
    public let bodies: [NatalSpineOceanusBodyTable]
    public let declaredCount: Int

    internal init(
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds,
        bodies: [NatalSpineOceanusBodyTable],
        declaredCount: Int? = nil
    ) {
        self.subjectID = subjectID
        self.bounds = bounds
        self.bodies = bodies
        self.declaredCount = declaredCount ?? bodies.reduce(0) { $0 + $1.realizations.count }
    }

    public var realizations: [NatalSpineRingRealization] {
        bodies.flatMap(\.realizations)
    }

    public func table(for body: MundaneBody) -> NatalSpineOceanusBodyTable? {
        bodies.first { $0.body == body }
    }
}

public enum NatalSpineOceanusFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case invalidNativeRing
    case invalidOccurrence
}

public extension Oceanus {
    /// Extrudes the already-established natal Ring through one mundane body.
    /// Each exact Ring target is asked of the universal Timespine in both motion lanes;
    /// every bounded occurrence becomes one native temporal realization.
    static func traceNatalSpineBody<Port: NatalSpineTimespinePort>(
        _ body: MundaneBody,
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        through port: Port
    ) throws -> NatalSpineOceanusBodyTable {
        guard truth.subjectID == bounds.subjectID else {
            throw NatalSpineOceanusFailure.subjectMismatch
        }

        let ringValues = truth.tapestry.tapestry.degrees.flatMap(\.ring.values)
        guard !ringValues.isEmpty else {
            throw NatalSpineOceanusFailure.invalidNativeRing
        }

        var realizations: [NatalSpineRingRealization] = []

        for value in ringValues {
            let targetDegrees = Double(value.targetArcsecond) / Double(Ring.arcsecondsPerDegree)
            for motion in [Motion.direct, Motion.retrograde] {
                let directional = OrboSpineDirectionalDegree(
                    physicalDegrees: targetDegrees,
                    motion: motion
                )!
                for occurrence in try port.occurrences(of: body, at: directional) {
                    guard bounds.bone.contains(occurrence.julianDay) else { continue }
                    guard let realization = NatalSpineRingRealization(
                        mundaneBody: body,
                        natalGene: value.gene,
                        natalSource: value.source,
                        relation: value.mark,
                        targetArcsecond: value.targetArcsecond,
                        occurrence: occurrence
                    ) else {
                        throw NatalSpineOceanusFailure.invalidOccurrence
                    }
                    realizations.append(realization)
                }
            }
        }

        realizations.sort {
            if $0.occurrence.julianDay.value != $1.occurrence.julianDay.value {
                return $0.occurrence.julianDay.value < $1.occurrence.julianDay.value
            }
            if $0.targetArcsecond != $1.targetArcsecond {
                return $0.targetArcsecond < $1.targetArcsecond
            }
            return $0.natalGene.displayName < $1.natalGene.displayName
        }

        return NatalSpineOceanusBodyTable(
            body: body,
            realizations: realizations
        )
    }

    /// Builds the complete Oceanus table one canonical mundane body at a time,
    /// retaining explicit zero-result body tables when no Ring realization occurs.
    static func traceNatalSpine<Port: NatalSpineTimespinePort>(
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        through port: Port
    ) throws -> NatalSpineOceanusTable {
        guard truth.subjectID == bounds.subjectID else {
            throw NatalSpineOceanusFailure.subjectMismatch
        }

        var bodyTables: [NatalSpineOceanusBodyTable] = []
        bodyTables.reserveCapacity(MundaneBody.canonicalOrder.count)
        for body in MundaneBody.canonicalOrder {
            bodyTables.append(
                try traceNatalSpineBody(
                    body,
                    native: truth,
                    bounds: bounds,
                    through: port
                )
            )
        }

        return NatalSpineOceanusTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            bodies: bodyTables
        )
    }
}
