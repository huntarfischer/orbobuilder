import Foundation

public struct MundaneTimespineCivicWindow: Hashable, Sendable {
    public let start: JulianDay
    public let end: JulianDay

    /// Half-open civic window: [start, end).
    public init?(start: JulianDay, end: JulianDay) {
        guard start.value < end.value else { return nil }
        self.start = start
        self.end = end
    }

    public func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= start.value && julianDay.value < end.value
    }
}

public enum MundaneTimespineReadSource: String, Codable, Hashable, Sendable {
    case storedAnchor
    case station
    case interpolated
    case boundaryExtrapolation
}

/// One persisted crossing of a body's stored celestial-time lattice.
public struct MundaneTimespineCelestialAnchor: Hashable, Sendable {
    public let celestialTimeDegrees: Double
    public let julianDay: JulianDay
    public let motion: Motion

    public init?(celestialTimeDegrees: Double, julianDay: JulianDay, motion: Motion) {
        guard celestialTimeDegrees.isFinite else { return nil }
        self.celestialTimeDegrees = Self.normalized(celestialTimeDegrees)
        self.julianDay = julianDay
        self.motion = motion
    }

    private static func normalized(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result == 360 ? 0 : result
    }
}

/// A turn in the mapping between celestial time and civic time.
public struct MundaneTimespineStationAnchor: Hashable, Sendable {
    public let celestialTimeDegrees: Double
    public let julianDay: JulianDay
    public let motionBefore: Motion
    public let motionAfter: Motion

    public init?(
        celestialTimeDegrees: Double,
        julianDay: JulianDay,
        motionBefore: Motion,
        motionAfter: Motion
    ) {
        guard celestialTimeDegrees.isFinite, motionBefore != motionAfter else { return nil }
        var normalized = celestialTimeDegrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        self.celestialTimeDegrees = normalized
        self.julianDay = julianDay
        self.motionBefore = motionBefore
        self.motionAfter = motionAfter
    }
}

public struct MundaneTimespineBodyState: Hashable, Sendable {
    public let body: MundaneBody
    public let celestialTimeDegrees: Double
    public let motion: Motion
    public let source: MundaneTimespineReadSource
    public let isStation: Bool
}

public struct MundaneTimespineMoment: Sendable {
    public let julianDay: JulianDay
    public let civicOffsetSeconds: Int64
    public let states: [MundaneTimespineBodyState]

    public subscript(_ body: MundaneBody) -> MundaneTimespineBodyState? {
        states.first { $0.body == body }
    }
}

public struct MundaneTimespineCelestialOccurrence: Hashable, Sendable {
    public let body: MundaneBody
    public let celestialTimeDegrees: Double
    public let ordinal: Int
    public let julianDay: JulianDay
    public let civicOffsetSeconds: Int64
    public let motion: Motion
}

public enum MundaneTimespineRelationshipOrientation: String, Codable, Hashable, Sendable {
    case sameDegree
    case oppositeDegree
    case bodyAAhead
    case bodyBAhead
}

public struct MundaneTimespineRelationshipEvent: Hashable, Sendable {
    public let bodyA: MundaneBody
    public let bodyB: MundaneBody
    public let mark: RingMark
    public let orientation: MundaneTimespineRelationshipOrientation
    public let bodyACelestialTimeDegrees: Double
    public let bodyBCelestialTimeDegrees: Double
    public let julianDay: JulianDay
    public let exactAspectResidualArcSeconds: Double

    public init?(
        bodyA: MundaneBody,
        bodyB: MundaneBody,
        mark: RingMark,
        orientation: MundaneTimespineRelationshipOrientation,
        bodyACelestialTimeDegrees: Double,
        bodyBCelestialTimeDegrees: Double,
        julianDay: JulianDay,
        exactAspectResidualArcSeconds: Double
    ) {
        guard bodyA != bodyB,
              bodyACelestialTimeDegrees.isFinite,
              bodyBCelestialTimeDegrees.isFinite,
              exactAspectResidualArcSeconds.isFinite,
              exactAspectResidualArcSeconds >= 0 else { return nil }
        self.bodyA = bodyA
        self.bodyB = bodyB
        self.mark = mark
        self.orientation = orientation
        self.bodyACelestialTimeDegrees = Self.normalized(bodyACelestialTimeDegrees)
        self.bodyBCelestialTimeDegrees = Self.normalized(bodyBCelestialTimeDegrees)
        self.julianDay = julianDay
        self.exactAspectResidualArcSeconds = exactAspectResidualArcSeconds
    }

    private static func normalized(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }
}

public enum MundaneTimespineEclipseKind: String, Codable, Hashable, Sendable {
    case solar
    case lunar
}

public enum MundaneTimespineEclipseType: String, Codable, Hashable, Sendable {
    case total
    case annular
    case hybrid
    case partial
    case penumbral
}

public struct MundaneTimespineEclipseEvent: Hashable, Sendable {
    public let kind: MundaneTimespineEclipseKind
    public let type: MundaneTimespineEclipseType
    public let eclipseDegree: Double
    public let julianDay: JulianDay
    public let greatestEclipseJulianDay: JulianDay?
    public let magnitude: Double?
    public let secondaryMagnitude: Double?
    public let centrality: String?

    public init?(
        kind: MundaneTimespineEclipseKind,
        type: MundaneTimespineEclipseType,
        eclipseDegree: Double,
        julianDay: JulianDay,
        greatestEclipseJulianDay: JulianDay? = nil,
        magnitude: Double? = nil,
        secondaryMagnitude: Double? = nil,
        centrality: String? = nil
    ) {
        guard eclipseDegree.isFinite,
              magnitude?.isFinite != false,
              secondaryMagnitude?.isFinite != false else { return nil }
        var normalized = eclipseDegree.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        self.kind = kind
        self.type = type
        self.eclipseDegree = normalized
        self.julianDay = julianDay
        self.greatestEclipseJulianDay = greatestEclipseJulianDay
        self.magnitude = magnitude
        self.secondaryMagnitude = secondaryMagnitude
        self.centrality = centrality
    }
}

public enum MundaneTimespineEvent: Hashable, Sendable {
    case relationship(MundaneTimespineRelationshipEvent)
    case eclipse(MundaneTimespineEclipseEvent)

    public var julianDay: JulianDay {
        switch self {
        case let .relationship(event): return event.julianDay
        case let .eclipse(event): return event.julianDay
        }
    }
}

public enum MundaneTimespineReaderError: Error, Equatable, CustomStringConvertible {
    case outsideSupportedSpan(JulianDay)
    case bodyUnavailable(MundaneBody)
    case insufficientTimeline(MundaneBody)
    case celestialTimeNotStored(body: MundaneBody, requestedDegrees: Double, resolutionDegrees: Double)

    public var description: String {
        switch self {
        case let .outsideSupportedSpan(julianDay):
            return "Julian day \(julianDay.value) is outside the Timespine's supported half-open span."
        case let .bodyUnavailable(body):
            return "The Timespine does not contain \(body.displayName)."
        case let .insufficientTimeline(body):
            return "The Timespine does not contain enough \(body.displayName) anchors to read civic time."
        case let .celestialTimeNotStored(body, requestedDegrees, resolutionDegrees):
            return "\(body.displayName) celestial time \(requestedDegrees) degrees is not on the stored \(resolutionDegrees)-degree lattice."
        }
    }
}

/// Decoded runtime body chronology. Final serialization may change without changing this contract.
public struct MundaneTimespineBodySeries: Sendable {
    public let body: MundaneBody
    public let celestialResolutionDegrees: Double
    public let anchors: [MundaneTimespineCelestialAnchor]
    public let stations: [MundaneTimespineStationAnchor]

    private enum TimelinePoint: Sendable {
        case anchor(MundaneTimespineCelestialAnchor)
        case station(MundaneTimespineStationAnchor)

        var julianDay: JulianDay {
            switch self {
            case let .anchor(value): return value.julianDay
            case let .station(value): return value.julianDay
            }
        }

        var celestialTimeDegrees: Double {
            switch self {
            case let .anchor(value): return value.celestialTimeDegrees
            case let .station(value): return value.celestialTimeDegrees
            }
        }

        var motionBefore: Motion {
            switch self {
            case let .anchor(value): return value.motion
            case let .station(value): return value.motionBefore
            }
        }

        var motionAfter: Motion {
            switch self {
            case let .anchor(value): return value.motion
            case let .station(value): return value.motionAfter
            }
        }

        var readSource: MundaneTimespineReadSource {
            switch self {
            case .anchor: return .storedAnchor
            case .station: return .station
            }
        }

        var isStation: Bool {
            if case .station = self { return true }
            return false
        }
    }

    private let circleTicks: Int
    private let exactByTick: [Int: [MundaneTimespineCelestialAnchor]]
    private let timeline: [TimelinePoint]

    public init?(
        body: MundaneBody,
        celestialResolutionDegrees: Double,
        anchors: [MundaneTimespineCelestialAnchor],
        stations: [MundaneTimespineStationAnchor]
    ) {
        guard celestialResolutionDegrees.isFinite,
              celestialResolutionDegrees > 0,
              anchors.count >= 2 else { return nil }

        let ticks = Int((360 / celestialResolutionDegrees).rounded())
        guard ticks > 0,
              abs(Double(ticks) * celestialResolutionDegrees - 360) < 1e-8 else { return nil }

        let sortedAnchors = anchors.sorted { $0.julianDay.value < $1.julianDay.value }
        let sortedStations = stations.sorted { $0.julianDay.value < $1.julianDay.value }
        var buckets: [Int: [MundaneTimespineCelestialAnchor]] = [:]

        for anchor in sortedAnchors {
            let rawTick = anchor.celestialTimeDegrees / celestialResolutionDegrees
            let nearestTick = Int(rawTick.rounded())
            let canonicalTick = ((nearestTick % ticks) + ticks) % ticks
            let canonicalDegree = Double(canonicalTick) * celestialResolutionDegrees
            guard Self.circularDistance(anchor.celestialTimeDegrees, canonicalDegree) < 1e-6 else { return nil }
            buckets[canonicalTick, default: []].append(anchor)
        }
        for tick in buckets.keys {
            buckets[tick]!.sort { $0.julianDay.value < $1.julianDay.value }
        }

        var merged = sortedAnchors.map(TimelinePoint.anchor) + sortedStations.map(TimelinePoint.station)
        merged.sort {
            if abs($0.julianDay.value - $1.julianDay.value) > 1e-12 {
                return $0.julianDay.value < $1.julianDay.value
            }
            return $0.isStation && !$1.isStation
        }

        self.body = body
        self.celestialResolutionDegrees = celestialResolutionDegrees
        self.anchors = sortedAnchors
        self.stations = sortedStations
        self.circleTicks = ticks
        self.exactByTick = buckets
        self.timeline = merged
    }

    fileprivate func state(at julianDay: JulianDay) throws -> MundaneTimespineBodyState {
        guard timeline.count >= 2 else { throw MundaneTimespineReaderError.insufficientTimeline(body) }
        let value = julianDay.value
        let index = lowerBoundTimeline(value)
        let epsilon = 1e-10

        if index < timeline.count, abs(timeline[index].julianDay.value - value) <= epsilon {
            let point = timeline[index]
            return MundaneTimespineBodyState(
                body: body,
                celestialTimeDegrees: point.celestialTimeDegrees,
                motion: point.motionAfter,
                source: point.readSource,
                isStation: point.isStation
            )
        }

        let lower: TimelinePoint
        let upper: TimelinePoint
        let source: MundaneTimespineReadSource
        let motion: Motion

        if index == 0 {
            lower = timeline[0]
            upper = timeline[1]
            source = .boundaryExtrapolation
            motion = upper.motionBefore
        } else if index == timeline.count {
            lower = timeline[timeline.count - 2]
            upper = timeline[timeline.count - 1]
            source = .boundaryExtrapolation
            motion = lower.motionAfter
        } else {
            lower = timeline[index - 1]
            upper = timeline[index]
            source = .interpolated
            motion = upper.isStation ? upper.motionBefore : lower.motionAfter
        }

        let span = upper.julianDay.value - lower.julianDay.value
        guard abs(span) > 1e-12 else { throw MundaneTimespineReaderError.insufficientTimeline(body) }
        let fraction = (value - lower.julianDay.value) / span
        let lowerDegree = lower.celestialTimeDegrees
        let upperDegree = upper.celestialTimeDegrees
        let traveled: Double
        let degrees: Double

        switch motion {
        case .direct:
            traveled = Self.normalized(upperDegree - lowerDegree)
            degrees = Self.normalized(lowerDegree + traveled * fraction)
        case .retrograde:
            traveled = Self.normalized(lowerDegree - upperDegree)
            degrees = Self.normalized(lowerDegree - traveled * fraction)
        }

        return MundaneTimespineBodyState(
            body: body,
            celestialTimeDegrees: degrees,
            motion: motion,
            source: source,
            isStation: false
        )
    }

    fileprivate func occurrences(
        at celestialTimeDegrees: Double,
        supportedStart: JulianDay
    ) throws -> [MundaneTimespineCelestialOccurrence] {
        guard celestialTimeDegrees.isFinite else {
            throw MundaneTimespineReaderError.celestialTimeNotStored(
                body: body,
                requestedDegrees: celestialTimeDegrees,
                resolutionDegrees: celestialResolutionDegrees
            )
        }
        let normalized = Self.normalized(celestialTimeDegrees)
        let rawTick = normalized / celestialResolutionDegrees
        let nearestTick = Int(rawTick.rounded())
        let canonicalTick = ((nearestTick % circleTicks) + circleTicks) % circleTicks
        let canonicalDegree = Double(canonicalTick) * celestialResolutionDegrees
        guard Self.circularDistance(normalized, canonicalDegree) < 1e-6 else {
            throw MundaneTimespineReaderError.celestialTimeNotStored(
                body: body,
                requestedDegrees: celestialTimeDegrees,
                resolutionDegrees: celestialResolutionDegrees
            )
        }

        return (exactByTick[canonicalTick] ?? []).enumerated().map { offset, anchor in
            MundaneTimespineCelestialOccurrence(
                body: body,
                celestialTimeDegrees: canonicalDegree,
                ordinal: offset + 1,
                julianDay: anchor.julianDay,
                civicOffsetSeconds: Int64(((anchor.julianDay.value - supportedStart.value) * 86_400).rounded()),
                motion: anchor.motion
            )
        }
    }

    private func lowerBoundTimeline(_ julianDay: Double) -> Int {
        var low = 0
        var high = timeline.count
        while low < high {
            let middle = (low + high) / 2
            if timeline[middle].julianDay.value < julianDay {
                low = middle + 1
            } else {
                high = middle
            }
        }
        return low
    }

    private static func normalized(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }

    private static func circularDistance(_ a: Double, _ b: Double) -> Double {
        let delta = abs(normalized(a) - normalized(b))
        return min(delta, 360 - delta)
    }
}

/// The decoded, ephemeris-free image consumed by the runtime reader.
/// A future packed shipping artifact should decode into this contract rather than change reader semantics.
public struct MundaneTimespineRuntimeImage: Sendable {
    public let spanName: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let bodySeries: [MundaneTimespineBodySeries]
    public let relationships: [MundaneTimespineRelationshipEvent]
    public let eclipses: [MundaneTimespineEclipseEvent]

    private let seriesByBody: [MundaneBody: MundaneTimespineBodySeries]

    public init?(
        spanName: String,
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        bodySeries: [MundaneTimespineBodySeries],
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) {
        guard !spanName.isEmpty,
              supportedStart.value < supportedEnd.value,
              !bodySeries.isEmpty,
              Set(bodySeries.map(\.body)).count == bodySeries.count else { return nil }

        self.spanName = spanName
        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.bodySeries = bodySeries.sorted {
            let lhs = MundaneBody.canonicalOrder.firstIndex(of: $0.body) ?? Int.max
            let rhs = MundaneBody.canonicalOrder.firstIndex(of: $1.body) ?? Int.max
            return lhs < rhs
        }
        self.relationships = relationships.sorted { $0.julianDay.value < $1.julianDay.value }
        self.eclipses = eclipses.sorted { $0.julianDay.value < $1.julianDay.value }
        self.seriesByBody = Dictionary(uniqueKeysWithValues: bodySeries.map { ($0.body, $0) })
    }

    public static func p22(
        bodySeries: [MundaneTimespineBodySeries],
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) -> MundaneTimespineRuntimeImage? {
        guard bodySeries.count == MundaneBody.canonicalOrder.count,
              Set(bodySeries.map(\.body)) == Set(MundaneBody.canonicalOrder) else { return nil }
        return MundaneTimespineRuntimeImage(
            spanName: MundaneTimespineP22.spanName,
            supportedStart: MundaneTimespineP22.startJulianDay,
            supportedEnd: MundaneTimespineP22.endJulianDay,
            bodySeries: bodySeries,
            relationships: relationships,
            eclipses: eclipses
        )
    }

    fileprivate func series(for body: MundaneBody) -> MundaneTimespineBodySeries? {
        seriesByBody[body]
    }
}

/// Runtime door into the durable Mundane Timespine.
/// This type has no Forge or ephemeris dependency. It only navigates a decoded Timespine image.
public struct MundaneTimespineReader: Sendable {
    public let image: MundaneTimespineRuntimeImage

    public init(image: MundaneTimespineRuntimeImage) {
        self.image = image
    }

    /// Civic UT -> simultaneous celestial state for every body carried by this image.
    public func state(at julianDay: JulianDay) throws -> MundaneTimespineMoment {
        guard julianDay.value >= image.supportedStart.value,
              julianDay.value < image.supportedEnd.value else {
            throw MundaneTimespineReaderError.outsideSupportedSpan(julianDay)
        }

        var states: [MundaneTimespineBodyState] = []
        states.reserveCapacity(image.bodySeries.count)
        for series in image.bodySeries {
            states.append(try series.state(at: julianDay))
        }
        return MundaneTimespineMoment(
            julianDay: julianDay,
            civicOffsetSeconds: Int64(((julianDay.value - image.supportedStart.value) * 86_400).rounded()),
            states: states
        )
    }

    /// Stored celestial time -> every exact civic occurrence inside the image span.
    /// The requested degree must lie on that body's earned P22 storage lattice.
    public func occurrences(
        of body: MundaneBody,
        at celestialTimeDegrees: Double
    ) throws -> [MundaneTimespineCelestialOccurrence] {
        guard let series = image.series(for: body) else {
            throw MundaneTimespineReaderError.bodyUnavailable(body)
        }
        return try series.occurrences(
            at: celestialTimeDegrees,
            supportedStart: image.supportedStart
        )
    }

    /// Exact object-to-object relationships in a half-open civic window, filtered at read time.
    public func relationships(
        in window: MundaneTimespineCivicWindow,
        involving bodies: Set<MundaneBody>? = nil,
        marks: Set<RingMark>? = nil
    ) -> [MundaneTimespineRelationshipEvent] {
        let rows = image.relationships
        var index = lowerBoundRelationship(window.start.value)
        var result: [MundaneTimespineRelationshipEvent] = []
        while index < rows.count, rows[index].julianDay.value < window.end.value {
            let event = rows[index]
            if let bodies, !bodies.contains(event.bodyA), !bodies.contains(event.bodyB) {
                index += 1
                continue
            }
            if let marks, !marks.contains(event.mark) {
                index += 1
                continue
            }
            result.append(event)
            index += 1
        }
        return result
    }

    /// Eclipse references in a half-open civic window, filtered at read time.
    public func eclipses(
        in window: MundaneTimespineCivicWindow,
        kinds: Set<MundaneTimespineEclipseKind>? = nil
    ) -> [MundaneTimespineEclipseEvent] {
        let rows = image.eclipses
        var index = lowerBoundEclipse(window.start.value)
        var result: [MundaneTimespineEclipseEvent] = []
        while index < rows.count, rows[index].julianDay.value < window.end.value {
            let event = rows[index]
            if let kinds, !kinds.contains(event.kind) {
                index += 1
                continue
            }
            result.append(event)
            index += 1
        }
        return result
    }

    /// Chronological union of exact relationship and eclipse references.
    public func events(in window: MundaneTimespineCivicWindow) -> [MundaneTimespineEvent] {
        let relationshipRows = relationships(in: window).map(MundaneTimespineEvent.relationship)
        let eclipseRows = eclipses(in: window).map(MundaneTimespineEvent.eclipse)
        var left = 0
        var right = 0
        var merged: [MundaneTimespineEvent] = []
        merged.reserveCapacity(relationshipRows.count + eclipseRows.count)

        while left < relationshipRows.count || right < eclipseRows.count {
            if right >= eclipseRows.count ||
                (left < relationshipRows.count && relationshipRows[left].julianDay.value <= eclipseRows[right].julianDay.value) {
                merged.append(relationshipRows[left])
                left += 1
            } else {
                merged.append(eclipseRows[right])
                right += 1
            }
        }
        return merged
    }

    private func lowerBoundRelationship(_ julianDay: Double) -> Int {
        var low = 0
        var high = image.relationships.count
        while low < high {
            let middle = (low + high) / 2
            if image.relationships[middle].julianDay.value < julianDay {
                low = middle + 1
            } else {
                high = middle
            }
        }
        return low
    }

    private func lowerBoundEclipse(_ julianDay: Double) -> Int {
        var low = 0
        var high = image.eclipses.count
        while low < high {
            let middle = (low + high) / 2
            if image.eclipses[middle].julianDay.value < julianDay {
                low = middle + 1
            } else {
                high = middle
            }
        }
        return low
    }
}
