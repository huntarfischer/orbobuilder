import Foundation

/// A celestial condition with its resolved absolute address.
///
/// The celestial condition is primary. `julianDay` records where that condition
/// occurs so Forge and storage can address it without making civil time the owner.
public struct MundaneCelestialAnchor: Hashable, Codable, Sendable {
    public let body: MundaneBody
    public let longitude: CelestialLongitude
    public let motion: Motion
    public let julianDay: JulianDay

    public init(
        body: MundaneBody,
        longitude: CelestialLongitude,
        motion: Motion,
        julianDay: JulianDay
    ) {
        self.body = body
        self.longitude = longitude
        self.motion = motion
        self.julianDay = julianDay
    }
}

/// A half-open celestial span whose absolute addresses have already been resolved.
public struct MundaneCelestialSpan: Hashable, Codable, Sendable {
    public let start: MundaneCelestialAnchor
    public let end: MundaneCelestialAnchor

    public init?(start: MundaneCelestialAnchor, end: MundaneCelestialAnchor) {
        guard start.julianDay.value < end.julianDay.value else { return nil }
        self.start = start
        self.end = end
    }
}

/// Celestial-first entry point into the existing Forge plan.
///
/// Forge still resolves and stores absolute addresses internally, but callers can
/// define the manufactured range by celestial conditions rather than by civil/JD
/// bounds.
public struct MundaneCelestialForgePlan: Sendable {
    public let span: MundaneCelestialSpan
    internal let storagePlan: MundaneTimespineForgePlan

    public init?(
        version: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        span: MundaneCelestialSpan,
        profiles: [MundaneTimespineProfile],
        motionChronologies: [MundaneBody: MundaneMotionChronology] = [:]
    ) {
        guard let storagePlan = MundaneTimespineForgePlan(
            version: version,
            astronomicalSource: astronomicalSource,
            astronomicalSourceVersion: astronomicalSourceVersion,
            supportedStart: span.start.julianDay,
            supportedEnd: span.end.julianDay,
            profiles: profiles,
            motionChronologies: motionChronologies
        ) else { return nil }

        self.span = span
        self.storagePlan = storagePlan
    }
}

public extension MundaneTimespineForge {
    static func manufacture(
        plan: MundaneCelestialForgePlan,
        reference: any ForgeEphemerisReference
    ) throws -> MundaneTimespine {
        try manufacture(plan: plan.storagePlan, reference: reference)
    }

    static func makeCursor(plan: MundaneCelestialForgePlan) -> Cursor {
        makeCursor(plan: plan.storagePlan)
    }

    static func estimatedPositionPayloadBytes(for plan: MundaneCelestialForgePlan) -> Int {
        estimatedPositionPayloadBytes(for: plan.storagePlan)
    }

    static func expectedSampleCount(for plan: MundaneCelestialForgePlan) -> Int {
        expectedSampleCount(for: plan.storagePlan)
    }
}

/// One complete physical cross-section through the universal Timespine.
public struct MundaneCelestialCrossSection: Sendable {
    public let julianDay: JulianDay
    public let states: [MundaneBody: MundaneCelestialState]

    public subscript(body: MundaneBody) -> MundaneCelestialState? {
        states[body]
    }
}

public extension MundaneTimespine {
    /// Reads every universal body at one temporal address.
    func crossSection(at julianDay: JulianDay) throws -> MundaneCelestialCrossSection {
        var states: [MundaneBody: MundaneCelestialState] = [:]
        states.reserveCapacity(MundaneBody.canonicalOrder.count)
        for body in MundaneBody.canonicalOrder {
            states[body] = try state(of: body, at: julianDay)
        }
        return .init(julianDay: julianDay, states: states)
    }
}

/// A candidate temporal segment reached through a body's longitude tract.
public struct MundaneLongitudeInterval: Hashable, Sendable {
    public let start: JulianDay
    public let end: JulianDay
    public let motion: Motion

    public init?(start: JulianDay, end: JulianDay, motion: Motion) {
        guard start.value < end.value else { return nil }
        self.start = start
        self.end = end
        self.motion = motion
    }
}

/// An exact Timespine occurrence of a celestial longitude condition.
public struct MundaneLongitudeOccurrence: Hashable, Sendable {
    public let body: MundaneBody
    public let longitude: CelestialLongitude
    public let motion: Motion
    public let julianDay: JulianDay
}

/// First-class longitude nerve for reverse Timespine reads.
///
/// It is built once from the body tracts, then body + longitude + motion queries
/// jump into candidate temporal segments instead of scanning the chronology.
public struct MundaneLongitudeIndex: Sendable {
    private struct Segment: Hashable, Sendable {
        let start: JulianDay
        let end: JulianDay
        let startLongitude: Double
        let endLongitude: Double
        let motion: Motion
    }

    private let buckets: [MundaneBody: [Int: [Segment]]]

    public init(timespine: MundaneTimespine) throws {
        var built: [MundaneBody: [Int: [Segment]]] = [:]

        for body in MundaneBody.canonicalOrder {
            guard let series = timespine.seriesByBody[body] else {
                throw MundaneTimespineError.missingBody(body)
            }

            var bodyBuckets: [Int: [Segment]] = [:]
            for region in series.regions {
                guard region.samples.count >= 2 else {
                    throw MundaneTimespineError.malformedSeries(body)
                }

                for index in 0..<(region.samples.count - 1) {
                    let rawStart = region.startJulianDay + Double(index) * region.sampleDays
                    let rawEnd = rawStart + region.sampleDays
                    let startValue = max(rawStart, region.startJulianDay)
                    let endValue = min(rawEnd, region.endJulianDay)
                    guard startValue < endValue else { continue }

                    var cuts = [startValue]
                    cuts.append(contentsOf: series.motionChronology.stations
                        .map(\.julianDay.value)
                        .filter { $0 > startValue && $0 < endValue })
                    cuts.append(endValue)
                    cuts.sort()

                    for pair in zip(cuts, cuts.dropFirst()) {
                        guard let start = JulianDay(pair.0), let end = JulianDay(pair.1) else {
                            throw MundaneTimespineError.malformedMetadata
                        }
                        let midpoint = (pair.0 + pair.1) / 2
                        let motion = Self.motion(in: series.motionChronology, at: midpoint)
                        let startLongitude = try Self.longitude(
                            of: body,
                            at: pair.0,
                            in: timespine,
                            series: series
                        )
                        let endLongitude = try Self.longitude(
                            of: body,
                            at: pair.1,
                            in: timespine,
                            series: series
                        )
                        let segment = Segment(
                            start: start,
                            end: end,
                            startLongitude: startLongitude,
                            endLongitude: endLongitude,
                            motion: motion
                        )
                        for bucket in Self.bucketIDs(for: segment) {
                            bodyBuckets[bucket, default: []].append(segment)
                        }
                    }
                }
            }
            built[body] = bodyBuckets
        }

        self.buckets = built
    }

    /// Returns only the temporal segments in which the requested celestial
    /// longitude can physically occur for the requested body and motion.
    public func candidateIntervals(
        of body: MundaneBody,
        at longitude: CelestialLongitude,
        motion requestedMotion: Motion? = nil
    ) -> [MundaneLongitudeInterval] {
        let bucket = Int(floor(longitude.degrees)) % 360
        let segments = buckets[body]?[bucket] ?? []
        return segments.compactMap { segment in
            guard requestedMotion == nil || segment.motion == requestedMotion,
                  Self.unwrappedTarget(longitude.degrees, in: segment) != nil else { return nil }
            return MundaneLongitudeInterval(
                start: segment.start,
                end: segment.end,
                motion: segment.motion
            )
        }
    }

    /// Solves exact Timespine occurrences inside the indexed candidate segments.
    /// No Ephemeris read is performed.
    public func occurrences(
        of body: MundaneBody,
        at longitude: CelestialLongitude,
        motion requestedMotion: Motion? = nil,
        in timespine: MundaneTimespine
    ) throws -> [MundaneLongitudeOccurrence] {
        let bucket = Int(floor(longitude.degrees)) % 360
        let segments = buckets[body]?[bucket] ?? []
        var occurrences: [MundaneLongitudeOccurrence] = []

        for segment in segments {
            guard requestedMotion == nil || segment.motion == requestedMotion,
                  let target = Self.unwrappedTarget(longitude.degrees, in: segment) else { continue }

            let address = try Self.solve(
                body: body,
                targetUnwrapped: target,
                segment: segment,
                timespine: timespine
            )
            guard timespine.contains(address) else { continue }

            if occurrences.contains(where: { abs($0.julianDay.value - address.value) < 1e-8 }) {
                continue
            }
            occurrences.append(.init(
                body: body,
                longitude: longitude,
                motion: segment.motion,
                julianDay: address
            ))
        }

        return occurrences.sorted { $0.julianDay.value < $1.julianDay.value }
    }

    private static func solve(
        body: MundaneBody,
        targetUnwrapped: Double,
        segment: Segment,
        timespine: MundaneTimespine
    ) throws -> JulianDay {
        var low = segment.start.value
        var high = segment.end.value
        let increasing = segment.motion == .direct

        for _ in 0..<60 {
            let mid = (low + high) / 2
            guard let jd = JulianDay(mid) else {
                throw MundaneTimespineError.malformedMetadata
            }
            let state = try timespine.state(of: body, at: jd)
            let unwrapped = segment.startLongitude + directedDelta(
                from: segment.startLongitude,
                to: state.longitude.degrees,
                motion: segment.motion
            )

            if increasing {
                if unwrapped < targetUnwrapped { low = mid } else { high = mid }
            } else {
                if unwrapped > targetUnwrapped { low = mid } else { high = mid }
            }
        }

        guard let result = JulianDay((low + high) / 2) else {
            throw MundaneTimespineError.malformedMetadata
        }
        return result
    }

    private static func bucketIDs(for segment: Segment) -> [Int] {
        let delta = directedDelta(
            from: segment.startLongitude,
            to: segment.endLongitude,
            motion: segment.motion
        )
        let a = segment.startLongitude
        let b = a + delta
        let lower = Int(floor(min(a, b)))
        let upper = Int(floor(max(a, b)))
        var result: [Int] = []
        result.reserveCapacity(max(1, upper - lower + 1))
        for raw in lower...upper {
            let normalized = ((raw % 360) + 360) % 360
            if !result.contains(normalized) { result.append(normalized) }
        }
        return result
    }

    private static func unwrappedTarget(_ longitude: Double, in segment: Segment) -> Double? {
        let delta = directedDelta(
            from: segment.startLongitude,
            to: segment.endLongitude,
            motion: segment.motion
        )
        let end = segment.startLongitude + delta
        let lower = min(segment.startLongitude, end) - 1e-12
        let upper = max(segment.startLongitude, end) + 1e-12
        let centerK = Int(round((segment.startLongitude - longitude) / 360))
        for k in (centerK - 1)...(centerK + 1) {
            let candidate = longitude + Double(k) * 360
            if candidate >= lower && candidate <= upper { return candidate }
        }
        return nil
    }

    private static func directedDelta(
        from start: Double,
        to end: Double,
        motion: Motion
    ) -> Double {
        var delta = end - start
        switch motion {
        case .direct:
            while delta < 0 { delta += 360 }
        case .retrograde:
            while delta > 0 { delta -= 360 }
        }
        return delta
    }

    private static func motion(
        in chronology: MundaneMotionChronology,
        at julianDay: Double
    ) -> Motion {
        var motion = chronology.initialMotion
        for station in chronology.stations {
            if station.julianDay.value > julianDay { break }
            motion = station.motionAfter
        }
        return motion
    }

    private static func longitude(
        of body: MundaneBody,
        at value: Double,
        in timespine: MundaneTimespine,
        series: MundaneTimespineSeries
    ) throws -> Double {
        if value < timespine.metadata.supportedEnd.value,
           let jd = JulianDay(value) {
            return try timespine.state(of: body, at: jd).longitude.degrees
        }

        guard abs(value - timespine.metadata.supportedEnd.value) < 1e-10,
              let region = series.regions.last else {
            throw MundaneTimespineError.malformedSeries(body)
        }
        let interpolation = try region.interpolated(at: value)
        guard let longitude = CelestialLongitude(interpolation.longitude) else {
            throw MundaneTimespineError.malformedSeries(body)
        }
        return longitude.degrees
    }
}