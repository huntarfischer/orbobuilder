public struct NatalSpineRheaSource: Hashable, Sendable {
    public let body: MundaneBody
    public let julianDay: JulianDay

    public init?(body: MundaneBody, julianDay: JulianDay) {
        guard body.planet != nil else { return nil }
        self.body = body
        self.julianDay = julianDay
    }
}

public struct NatalSpineMaterQualification: Hashable, Sendable {
    public let source: NatalSpineRheaSource
    public let temper: Mater.QualifiedTemper

    public init?(source: NatalSpineRheaSource, temper: Mater.QualifiedTemper) {
        guard source.body.planet == temper.planet else { return nil }
        self.source = source
        self.temper = temper
    }
}

public struct NatalSpineRheaTable: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let bounds: NatalSpineBounds
    public let qualifications: [NatalSpineMaterQualification]
    public let declaredCount: Int

    internal init(
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds,
        qualifications: [NatalSpineMaterQualification],
        declaredCount: Int? = nil
    ) {
        self.subjectID = subjectID
        self.bounds = bounds
        self.qualifications = qualifications
        self.declaredCount = declaredCount ?? qualifications.count
    }
}

public enum NatalSpineRheaFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case invalidQualification
}

public extension Rhea {
    /// Bears Mater testimony directly from the bounded mundane chronology Clotho supplied.
    /// Rhea receives no Themis or Oceanus testimony. Candidate moments are only the exact
    /// zodiac degrees where this planet's own Mater condition can change under canonical law.
    static func qualifyNatalSpine<Port: NatalSpineTimespinePort>(
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        through port: Port
    ) throws -> NatalSpineRheaTable {
        guard truth.subjectID == bounds.subjectID else {
            throw NatalSpineRheaFailure.subjectMismatch
        }

        var qualifications: [NatalSpineMaterQualification] = []
        var admitted = Set<NatalSpineRheaSource>()

        for body in MundaneBody.canonicalOrder {
            guard let planet = body.planet else { continue }

            for physicalDegrees in materTargetDegrees(for: planet) {
                for motion in [Motion.direct, Motion.retrograde] {
                    let directional = OrboSpineDirectionalDegree(
                        physicalDegrees: physicalDegrees,
                        motion: motion
                    )!
                    for occurrence in try port.occurrences(of: body, at: directional) {
                        guard bounds.bone.contains(occurrence.julianDay),
                              let source = NatalSpineRheaSource(
                                body: body,
                                julianDay: occurrence.julianDay
                              ),
                              admitted.insert(source).inserted else {
                            continue
                        }

                        let field = Rhea.bear(
                            try planetaryLongitudes(at: occurrence.julianDay, through: port),
                            sect: truth.sect
                        )
                        guard let qualification = NatalSpineMaterQualification(
                            source: source,
                            temper: field.temper(for: planet)
                        ) else {
                            throw NatalSpineRheaFailure.invalidQualification
                        }
                        qualifications.append(qualification)
                    }
                }
            }
        }

        qualifications.sort {
            if $0.source.julianDay.value != $1.source.julianDay.value {
                return $0.source.julianDay.value < $1.source.julianDay.value
            }
            return $0.source.body.rawValue < $1.source.body.rawValue
        }

        return NatalSpineRheaTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            qualifications: qualifications
        )
    }

    /// Derives Rhea's temporal targets from Mater itself rather than duplicating
    /// the dignity tables here. Sign changes are field boundaries. Bound and face
    /// boundaries are admitted only when that planet enters or leaves its own dignity.
    /// The exact exaltation degree is a punctual Mater condition and is included too.
    private static func materTargetDegrees(for planet: Planet) -> [Double] {
        let epsilon = 1e-7
        var targets = Set<Double>()

        for degree in 0..<360 {
            let boundary = Double(degree)
            let beforeDegrees = boundary == 0 ? 360 - epsilon : boundary - epsilon
            let afterDegrees = boundary + epsilon >= 360 ? epsilon : boundary + epsilon
            let before = CelestialLongitude(beforeDegrees)!
            let after = CelestialLongitude(afterDegrees)!

            if before.sign != after.sign {
                targets.insert(boundary)
            }

            let beforeBound = Mater.bound(at: before)
            let afterBound = Mater.bound(at: after)
            if beforeBound.ruler != afterBound.ruler,
               beforeBound.ruler == planet || afterBound.ruler == planet {
                targets.insert(boundary)
            }

            let beforeFace = Mater.face(at: before)
            let afterFace = Mater.face(at: after)
            if beforeFace.ruler != afterFace.ruler,
               beforeFace.ruler == planet || afterFace.ruler == planet {
                targets.insert(boundary)
            }
        }

        if let exaltation = Mater.exaltation(of: planet) {
            targets.insert(
                Double(exaltation.sign.rawValue * 30) + exaltation.degree.value
            )
        }

        return targets.sorted()
    }

    private static func planetaryLongitudes<Port: NatalSpineTimespinePort>(
        at julianDay: JulianDay,
        through port: Port
    ) throws -> [Planet: CelestialLongitude] {
        var longitudes: [Planet: CelestialLongitude] = [:]
        longitudes.reserveCapacity(Planet.canonicalOrder.count)

        for body in MundaneBody.canonicalOrder {
            guard let planet = body.planet else { continue }
            let coordinate = try port.coordinate(of: body, at: julianDay)
            longitudes[planet] = CelestialLongitude(
                coordinate.directionalDegree.physicalDegrees
            )!
        }

        precondition(
            Set(longitudes.keys) == Set(Planet.canonicalOrder),
            "Rhea Natal Spine qualification requires the complete canonical planetary field."
        )
        return longitudes
    }
}
