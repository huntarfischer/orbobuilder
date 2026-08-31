public struct NatalSpineHouseCrossing: Hashable, Sendable {
    public let body: MundaneBody
    public let fromHouse: House
    public let toHouse: House
    public let occurrence: JulianDay

    public init?(
        body: MundaneBody,
        fromHouse: House,
        toHouse: House,
        occurrence: JulianDay
    ) {
        guard fromHouse != toHouse else { return nil }
        self.body = body
        self.fromHouse = fromHouse
        self.toHouse = toHouse
        self.occurrence = occurrence
    }
}

public enum NatalSpineRheaSource: Hashable, Sendable {
    case houseCrossing(NatalSpineHouseCrossing)
    case ringRealization(NatalSpineRingRealization)

    public var body: MundaneBody {
        switch self {
        case let .houseCrossing(crossing): return crossing.body
        case let .ringRealization(realization): return realization.mundaneBody
        }
    }

    public var julianDay: JulianDay {
        switch self {
        case let .houseCrossing(crossing): return crossing.occurrence
        case let .ringRealization(realization): return realization.occurrence.julianDay
        }
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
    case boundsMismatch
    case malformedThemisTable
    case invalidQualification
}

public extension Rhea {
    /// Qualifies only temporal facts already established by Themis and Oceanus.
    /// Rhea does not perform another chronological search. At each eligible fact,
    /// she reads the already-forged mundane planetary field and applies canonical Mater law.
    static func qualifyNatalSpine<Port: NatalSpineTimespinePort>(
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        themis: NatalSpineThemisTable,
        oceanus: NatalSpineOceanusTable,
        through port: Port
    ) throws -> NatalSpineRheaTable {
        guard truth.subjectID == bounds.subjectID,
              themis.subjectID == truth.subjectID,
              oceanus.subjectID == truth.subjectID else {
            throw NatalSpineRheaFailure.subjectMismatch
        }
        guard themis.bounds == bounds, oceanus.bounds == bounds else {
            throw NatalSpineRheaFailure.boundsMismatch
        }

        var sources: [NatalSpineRheaSource] = []

        for body in MundaneBody.canonicalOrder where body.planet != nil {
            let spans = themis.spans(for: body).sorted { $0.start.value < $1.start.value }
            guard !spans.isEmpty else { continue }

            for index in 1..<spans.count {
                let prior = spans[index - 1]
                let next = spans[index]
                guard prior.body == body,
                      next.body == body,
                      abs(prior.end.value - next.start.value) <= 1e-9 else {
                    throw NatalSpineRheaFailure.malformedThemisTable
                }
                guard prior.house != next.house else { continue }
                guard next.start.value > bounds.bone.start.value,
                      next.start.value < bounds.bone.end.value,
                      let crossing = NatalSpineHouseCrossing(
                        body: body,
                        fromHouse: prior.house,
                        toHouse: next.house,
                        occurrence: next.start
                      ) else {
                    continue
                }
                sources.append(.houseCrossing(crossing))
            }
        }

        for realization in oceanus.realizations where realization.mundaneBody.planet != nil {
            guard bounds.bone.contains(realization.occurrence.julianDay) else { continue }
            sources.append(.ringRealization(realization))
        }

        sources.sort {
            if $0.julianDay.value != $1.julianDay.value {
                return $0.julianDay.value < $1.julianDay.value
            }
            if $0.body.rawValue != $1.body.rawValue {
                return $0.body.rawValue < $1.body.rawValue
            }
            switch ($0, $1) {
            case (.houseCrossing, .ringRealization): return true
            case (.ringRealization, .houseCrossing): return false
            default: return false
            }
        }

        var fieldCache: [Double: Mater.QualifiedField] = [:]
        var qualifications: [NatalSpineMaterQualification] = []
        qualifications.reserveCapacity(sources.count)

        for source in sources {
            guard let planet = source.body.planet else { continue }
            let key = source.julianDay.value
            let field: Mater.QualifiedField
            if let cached = fieldCache[key] {
                field = cached
            } else {
                let longitudes = try planetaryLongitudes(at: source.julianDay, through: port)
                let qualified = Rhea.bear(longitudes, sect: truth.sect)
                fieldCache[key] = qualified
                field = qualified
            }

            guard let qualification = NatalSpineMaterQualification(
                source: source,
                temper: field.temper(for: planet)
            ) else {
                throw NatalSpineRheaFailure.invalidQualification
            }
            qualifications.append(qualification)
        }

        return NatalSpineRheaTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            qualifications: qualifications
        )
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
