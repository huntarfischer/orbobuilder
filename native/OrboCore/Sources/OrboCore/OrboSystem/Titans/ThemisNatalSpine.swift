public struct NatalSpineHouseSpan: Hashable, Sendable {
    public let body: MundaneBody
    public let house: House
    public let start: JulianDay
    public let end: JulianDay

    public init?(
        body: MundaneBody,
        house: House,
        start: JulianDay,
        end: JulianDay
    ) {
        guard start.value < end.value else { return nil }
        self.body = body
        self.house = house
        self.start = start
        self.end = end
    }
}

public struct NatalSpineThemisTable: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let bounds: NatalSpineBounds
    public let spans: [NatalSpineHouseSpan]
    public let declaredCount: Int

    internal init(
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds,
        spans: [NatalSpineHouseSpan],
        declaredCount: Int? = nil
    ) {
        self.subjectID = subjectID
        self.bounds = bounds
        self.spans = spans
        self.declaredCount = declaredCount ?? spans.count
    }

    public func spans(for body: MundaneBody) -> [NatalSpineHouseSpan] {
        spans.filter { $0.body == body }
    }
}

public enum NatalSpineThemisFailure: Error, Hashable, Sendable {
    case subjectMismatch
    case invalidNativeTympan
    case invalidSpan
}

public extension Themis {
    /// Extrudes the already-established native Tympan through one mundane body.
    /// Exact sign-boundary occurrences come from the canonical Timespine port;
    /// Themis does not sample astronomy or rebuild the natal house imprint.
    static func traceNatalSpineBody<Port: NatalSpineTimespinePort>(
        _ body: MundaneBody,
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        through port: Port
    ) throws -> [NatalSpineHouseSpan] {
        guard truth.subjectID == bounds.subjectID else {
            throw NatalSpineThemisFailure.subjectMismatch
        }
        let houseBySign = try nativeHouseBySign(from: truth.tapestry)
        let start = bounds.bone.start
        let end = bounds.bone.end

        var crossings: [JulianDay] = []
        crossings.reserveCapacity(48)

        for boundary in stride(from: 0, to: 360, by: 30) {
            for motion in [Motion.direct, Motion.retrograde] {
                let directional = OrboSpineDirectionalDegree(
                    physicalDegrees: Double(boundary),
                    motion: motion
                )!
                for occurrence in try port.occurrences(of: body, at: directional) {
                    let value = occurrence.julianDay.value
                    if value > start.value && value < end.value {
                        crossings.append(occurrence.julianDay)
                    }
                }
            }
        }

        let orderedCrossings = collapsedCrossings(crossings)
        let boundaries = [start] + orderedCrossings + [end]
        var spans: [NatalSpineHouseSpan] = []
        spans.reserveCapacity(boundaries.count - 1)

        for index in 0..<(boundaries.count - 1) {
            let lower = boundaries[index]
            let upper = boundaries[index + 1]
            guard lower.value < upper.value else {
                throw NatalSpineThemisFailure.invalidSpan
            }

            let midpoint = JulianDay((lower.value + upper.value) / 2)!
            let coordinate = try port.coordinate(of: body, at: midpoint)
            let longitude = CelestialLongitude(
                coordinate.directionalDegree.physicalDegrees
            )!
            guard let house = houseBySign[longitude.sign],
                  let span = NatalSpineHouseSpan(
                    body: body,
                    house: house,
                    start: lower,
                    end: upper
                  ) else {
                throw NatalSpineThemisFailure.invalidSpan
            }
            spans.append(span)
        }

        return spans
    }

    /// Builds the complete Themis table one canonical mundane body at a time.
    static func traceNatalSpine<Port: NatalSpineTimespinePort>(
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        through port: Port
    ) throws -> NatalSpineThemisTable {
        guard truth.subjectID == bounds.subjectID else {
            throw NatalSpineThemisFailure.subjectMismatch
        }

        var spans: [NatalSpineHouseSpan] = []
        for body in MundaneBody.canonicalOrder {
            spans.append(
                contentsOf: try traceNatalSpineBody(
                    body,
                    native: truth,
                    bounds: bounds,
                    through: port
                )
            )
        }

        return NatalSpineThemisTable(
            subjectID: truth.subjectID,
            bounds: bounds,
            spans: spans
        )
    }

    private static func nativeHouseBySign(
        from package: AtroposTapestryPackage
    ) throws -> [Sign: House] {
        var result: [Sign: House] = [:]

        for sign in Sign.canonicalOrder {
            let lower = sign.rawValue * 30
            let upper = lower + 30
            let degrees = package.tapestry.degrees.filter {
                $0.address.rawValue >= lower && $0.address.rawValue < upper
            }
            guard degrees.count == 30,
                  let house = degrees.first?.tympan.house,
                  degrees.allSatisfy({ $0.tympan.house == house }) else {
                throw NatalSpineThemisFailure.invalidNativeTympan
            }
            result[sign] = house
        }

        guard result.count == Sign.canonicalOrder.count else {
            throw NatalSpineThemisFailure.invalidNativeTympan
        }
        return result
    }

    private static func collapsedCrossings(_ crossings: [JulianDay]) -> [JulianDay] {
        let epsilon = 1e-9
        let ordered = crossings.sorted { $0.value < $1.value }
        var result: [JulianDay] = []
        result.reserveCapacity(ordered.count)

        for value in ordered {
            if let last = result.last,
               abs(last.value - value.value) <= epsilon {
                continue
            }
            result.append(value)
        }
        return result
    }
}
