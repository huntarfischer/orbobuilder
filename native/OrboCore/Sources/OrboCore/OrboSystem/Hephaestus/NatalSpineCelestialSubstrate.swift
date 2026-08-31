public protocol NatalSpineForgeTimespineSource: NatalSpineTimespinePort, Sendable {
    var sourceBone: OrboSpineBoneSpan { get }
    var sourceStations: [OrboSpineStation] { get }
    var sourceProvenance: OrboSpineRuntimeProvenance { get }
}

extension OrboSpineRuntime: NatalSpineForgeTimespineSource {
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

public struct NatalSpineCelestialSubstrate: Hashable, Sendable {
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
}

public enum NatalSpineSubstrateFailure: Error, Hashable, Sendable {
    case outsideParentBone
    case missingCelestialMatter(MundaneBody)
    case invalidBoundaryAnchor(MundaneBody)
    case invalidSubstrate
}

public extension Hephaestus {
    /// Materializes only already-forged celestial matter from the canonical Mundane OrboSpine.
    /// No Ephemeris or astronomical forge is consulted here.
    static func forgeNatalSpineSubstrate<Source: NatalSpineForgeTimespineSource>(
        for commission: NatalSpineForgeCommission,
        from source: Source
    ) throws -> NatalSpineCelestialSubstrate {
        let bone = commission.schematics.bounds.bone
        guard bone.start.value >= source.sourceBone.start.value,
              bone.end.value < source.sourceBone.end.value else {
            throw NatalSpineSubstrateFailure.outsideParentBone
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
                throw NatalSpineSubstrateFailure.missingCelestialMatter(body)
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
                throw NatalSpineSubstrateFailure.invalidBoundaryAnchor(body)
            }
            anchors.append(startAnchor)
            anchors.append(endAnchor)
        }

        let stations = source.sourceStations
            .filter { bone.contains($0.julianDay) }
            .sorted { $0.julianDay.value < $1.julianDay.value }

        guard let substrate = NatalSpineCelestialSubstrate(
            subjectID: commission.subjectID,
            bounds: commission.schematics.bounds,
            supports: supports,
            stations: stations,
            boundaryAnchors: anchors,
            parentProvenance: source.sourceProvenance
        ) else {
            throw NatalSpineSubstrateFailure.invalidSubstrate
        }
        return substrate
    }
}
