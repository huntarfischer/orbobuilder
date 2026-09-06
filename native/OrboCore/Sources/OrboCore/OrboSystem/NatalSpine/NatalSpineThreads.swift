/// The parent-Timespine surface Clotho may gather from for a Natal commission.
/// It exposes only already-forged mundane matter and provenance.
public protocol NatalSpineTimespineSource: NatalSpineTimespinePort, Sendable {
    var sourceBone: OrboSpineBoneSpan { get }
    var sourceStations: [OrboSpineStation] { get }
    var sourceProvenance: OrboSpineRuntimeProvenance { get }
}

extension OrboSpineRuntime: NatalSpineTimespineSource {
    public var sourceBone: OrboSpineBoneSpan { bone }
    public var sourceStations: [OrboSpineStation] { stations }
    public var sourceProvenance: OrboSpineRuntimeProvenance { provenance }

    public func coordinate(
        of body: MundaneBody,
        at julianDay: JulianDay
    ) throws -> OrboSpineCelestialCoordinate {
        try locate.coordinate(of: body, at: julianDay)
    }

    public func occurrences(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [OrboSpineCelestialCoordinate] {
        try locate.occurrences(of: body, at: directionalDegree)
    }
}

/// The large bounded Threads Clotho cuts from the already-forged Mundane Timespine.
/// This is self-contained celestial matter for the Natal commission, not a live parent handle.
public struct NatalSpineThreads: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let bounds: NatalSpineBounds
    public let supports: [OrboSpineCelestialCoordinate]
    public let stations: [OrboSpineStation]
    public let boundaryAnchors: [OrboSpineBoundaryAnchor]
    public let parentProvenance: OrboSpineRuntimeProvenance

    public init?(
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds,
        supports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation],
        boundaryAnchors: [OrboSpineBoundaryAnchor],
        parentProvenance: OrboSpineRuntimeProvenance
    ) {
        let canonical = Set(MundaneBody.canonicalOrder)
        guard subjectID == bounds.subjectID,
              Set(supports.map(\.body)) == canonical,
              supports.allSatisfy({ bounds.bone.contains($0.julianDay) }),
              stations.allSatisfy({ canonical.contains($0.body) && bounds.bone.contains($0.julianDay) }),
              boundaryAnchors.count == MundaneBody.canonicalOrder.count * 2 else {
            return nil
        }
        self.subjectID = subjectID
        self.bounds = bounds
        self.supports = supports
        self.stations = stations
        self.boundaryAnchors = boundaryAnchors
        self.parentProvenance = parentProvenance
    }

    /// Reconstitutes Door-I reads entirely from the bounded Threads.
    /// No parent runtime is retained or consulted.
    public func locate() throws -> OrboSpineLocate {
        guard let locate = OrboSpineLocate(
            bone: bounds.bone,
            celestialSupports: supports,
            stations: stations,
            boundaryAnchors: boundaryAnchors
        ) else {
            throw NatalSpineThreadsFailure.invalidThreads
        }
        return locate
    }
}

public enum NatalSpineThreadsFailure: Error, Hashable, Sendable {
    case outsideParentBone
    case missingCelestialMatter(MundaneBody)
    case invalidBoundaryAnchor(MundaneBody)
    case invalidThreads
}

public extension Clotho {
    /// Cuts one self-contained 101-year body of already-forged mundane matter.
    /// Parent Timespine custody terminates when this value is returned.
    static func gatherNatalSpineThreads<Source: NatalSpineTimespineSource>(
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        from source: Source
    ) throws -> NatalSpineThreads {
        guard truth.subjectID == bounds.subjectID else {
            throw NatalSpineThreadsFailure.invalidThreads
        }

        let bone = bounds.bone
        guard bone.start.value >= source.sourceBone.start.value,
              bone.end.value < source.sourceBone.end.value else {
            throw NatalSpineThreadsFailure.outsideParentBone
        }

        var supports: [OrboSpineCelestialCoordinate] = []
        var anchors: [OrboSpineBoundaryAnchor] = []

        for body in MundaneBody.canonicalOrder {
            let step = OrboSpineContract.supportDegrees(for: body)
            let count = Int((360.0 / step).rounded())
            var bodySupports: [OrboSpineCelestialCoordinate] = []

            for index in 0..<count {
                let physical = Double(index) * step
                for motion in [Motion.direct, Motion.retrograde] {
                    let target = OrboSpineDirectionalDegree(
                        physicalDegrees: physical,
                        motion: motion
                    )!
                    bodySupports.append(contentsOf:
                        try source.occurrences(of: body, at: target)
                            .filter { bone.contains($0.julianDay) }
                    )
                }
            }

            bodySupports = Array(Set(bodySupports)).sorted { lhs, rhs in
                if lhs.julianDay.value != rhs.julianDay.value {
                    return lhs.julianDay.value < rhs.julianDay.value
                }
                return lhs.directionalDegree.degrees < rhs.directionalDegree.degrees
            }
            guard bodySupports.count >= 2 else {
                throw NatalSpineThreadsFailure.missingCelestialMatter(body)
            }
            supports.append(contentsOf: bodySupports)

            let start = try source.coordinate(of: body, at: bone.start)
            let end = try source.coordinate(of: body, at: bone.end)
            guard let startAnchor = OrboSpineBoundaryAnchor(
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
                throw NatalSpineThreadsFailure.invalidBoundaryAnchor(body)
            }
            anchors.append(startAnchor)
            anchors.append(endAnchor)
        }

        let stations = source.sourceStations
            .filter { bone.contains($0.julianDay) }
            .sorted { $0.julianDay.value < $1.julianDay.value }

        guard let threads = NatalSpineThreads(
            subjectID: truth.subjectID,
            bounds: bounds,
            supports: supports,
            stations: stations,
            boundaryAnchors: anchors,
            parentProvenance: source.sourceProvenance
        ) else {
            throw NatalSpineThreadsFailure.invalidThreads
        }
        return threads
    }
}
