import Foundation

/// Controlled deep-astronomy socket used by Forge construction only.
/// Ordinary Ovum consumers read the Mundane Timespine instead.
public protocol ForgeEphemerisReference: Sendable {
    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState
}

public struct MundaneTimespineForgePlan: Sendable {
    public let version: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let profiles: [MundaneTimespineProfile]
    public let motionChronologies: [MundaneBody: MundaneMotionChronology]

    public init?(
        version: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        profiles: [MundaneTimespineProfile],
        motionChronologies: [MundaneBody: MundaneMotionChronology] = [:]
    ) {
        guard !version.isEmpty,
              !astronomicalSource.isEmpty,
              !astronomicalSourceVersion.isEmpty,
              supportedStart.value < supportedEnd.value,
              profiles.map(\.body) == MundaneBody.canonicalOrder else {
            return nil
        }
        if !motionChronologies.isEmpty {
            guard Set(motionChronologies.keys) == Set(MundaneBody.canonicalOrder) else { return nil }
            for chronology in motionChronologies.values {
                guard chronology.stations.allSatisfy({
                    $0.julianDay.value >= supportedStart.value &&
                    $0.julianDay.value < supportedEnd.value
                }) else { return nil }
            }
        }
        self.version = version
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.profiles = profiles
        self.motionChronologies = motionChronologies
    }
}

public struct MundaneTimespineForgeProgress: Hashable, Sendable {
    public let completedSamples: Int
    public let totalSamples: Int
    public let currentBody: MundaneBody?

    public var fractionComplete: Double {
        guard totalSamples > 0 else { return 1 }
        return min(1, Double(completedSamples) / Double(totalSamples))
    }
}

public enum MundaneTimespineForge {
    public static let v1DenseStart = JulianDay(2_433_282.5)! // 1950-01-01 Gregorian
    public static let v1DenseEnd = JulianDay(2_469_807.5)!   // 2050-01-01 Gregorian

    /// Position-first profile. Storage density follows measured apparent motion.
    /// Stations are carried separately as exact temporal data rather than inferred
    /// from sparse endpoint tangents.
    public static let candidateProfiles: [MundaneTimespineProfile] = [
        MundaneTimespineProfile(body: .sun, edgeSampleDays: 2, coreSampleDays: 1)!,
        MundaneTimespineProfile(body: .moon, edgeSampleDays: 0.25, coreSampleDays: 0.125)!,
        MundaneTimespineProfile(body: .mercury, edgeSampleDays: 1.0 / 12.0, coreSampleDays: 1.0 / 48.0)!,
        MundaneTimespineProfile(body: .venus, edgeSampleDays: 0.25, coreSampleDays: 0.0625)!,
        MundaneTimespineProfile(body: .mars, edgeSampleDays: 0.5, coreSampleDays: 0.125)!,
        MundaneTimespineProfile(body: .jupiter, edgeSampleDays: 0.5, coreSampleDays: 0.125)!,
        MundaneTimespineProfile(body: .saturn, edgeSampleDays: 1, coreSampleDays: 0.125)!,
        MundaneTimespineProfile(body: .uranus, edgeSampleDays: 0.25, coreSampleDays: 0.0625)!,
        MundaneTimespineProfile(body: .neptune, edgeSampleDays: 0.5, coreSampleDays: 0.125)!,
        MundaneTimespineProfile(body: .pluto, edgeSampleDays: 0.5, coreSampleDays: 0.125)!,
        MundaneTimespineProfile(body: .trueNorthNode, edgeSampleDays: 0.125, coreSampleDays: 1.0 / 48.0)!,
    ]

    public static func makeCursor(plan: MundaneTimespineForgePlan) -> Cursor {
        Cursor(plan: plan)
    }

    public static func manufacture(
        plan: MundaneTimespineForgePlan,
        reference: any ForgeEphemerisReference
    ) throws -> MundaneTimespine {
        var cursor = Cursor(plan: plan)
        while !cursor.isComplete {
            _ = try cursor.step(reference: reference, sampleBudget: 4_096)
        }
        return try cursor.product()
    }

    public static func estimatedPositionPayloadBytes(for plan: MundaneTimespineForgePlan) -> Int {
        totalSampleCount(for: plan) * MemoryLayout<UInt32>.size
    }

    public static func expectedSampleCount(for plan: MundaneTimespineForgePlan) -> Int {
        totalSampleCount(for: plan)
    }

    public struct Cursor: Sendable {
        public let plan: MundaneTimespineForgePlan

        private var bodyIndex = 0
        private var regionIndex = 0
        private var sampleIndex = 0
        private var completedSamples = 0
        private var samplesByBody: [MundaneBody: [[MundaneTimespineSample]]] = [:]
        private var initialMotionByBody: [MundaneBody: Motion] = [:]

        fileprivate init(plan: MundaneTimespineForgePlan) {
            self.plan = plan
            for body in MundaneBody.canonicalOrder {
                samplesByBody[body] = [[], [], []]
            }
        }

        public var totalSamples: Int { Self.totalSampleCount(for: plan) }
        public var isComplete: Bool { bodyIndex >= plan.profiles.count }

        public var progress: MundaneTimespineForgeProgress {
            MundaneTimespineForgeProgress(
                completedSamples: completedSamples,
                totalSamples: totalSamples,
                currentBody: isComplete ? nil : plan.profiles[bodyIndex].body
            )
        }

        @discardableResult
        public mutating func step(
            reference: any ForgeEphemerisReference,
            sampleBudget: Int = 256
        ) throws -> MundaneTimespineForgeProgress {
            guard sampleBudget > 0 else { return progress }
            var remaining = sampleBudget

            while remaining > 0, !isComplete {
                let profile = plan.profiles[bodyIndex]
                let regions = Self.regionPlans(for: profile, plan: plan)

                if regionIndex >= regions.count {
                    bodyIndex += 1
                    regionIndex = 0
                    sampleIndex = 0
                    continue
                }

                let region = regions[regionIndex]
                let count = Self.sampleCount(start: region.start, end: region.end, step: region.sampleDays)
                if sampleIndex >= count {
                    regionIndex += 1
                    sampleIndex = 0
                    continue
                }

                let jdValue = min(region.start + Double(sampleIndex) * region.sampleDays, region.end)
                guard let jd = JulianDay(jdValue) else { throw MundaneTimespineError.malformedMetadata }
                let state = try reference.state(of: profile.body, at: jd)
                guard let sample = MundaneTimespineSample(longitude: state.longitude) else {
                    throw MundaneTimespineError.sampleOverflow
                }
                if initialMotionByBody[profile.body] == nil {
                    initialMotionByBody[profile.body] = state.motion
                }
                samplesByBody[profile.body]![regionIndex].append(sample)
                sampleIndex += 1
                completedSamples += 1
                remaining -= 1
            }

            while !isComplete {
                let profile = plan.profiles[bodyIndex]
                let regions = Self.regionPlans(for: profile, plan: plan)
                if regionIndex >= regions.count {
                    bodyIndex += 1
                    regionIndex = 0
                    sampleIndex = 0
                    continue
                }
                let region = regions[regionIndex]
                let count = Self.sampleCount(start: region.start, end: region.end, step: region.sampleDays)
                guard sampleIndex >= count else { break }
                regionIndex += 1
                sampleIndex = 0
            }
            return progress
        }

        public func product() throws -> MundaneTimespine {
            guard isComplete else { throw MundaneTimespineError.malformedMetadata }
            var seriesByBody: [MundaneBody: MundaneTimespineSeries] = [:]

            for profile in plan.profiles {
                let plans = Self.regionPlans(for: profile, plan: plan)
                guard let stored = samplesByBody[profile.body], stored.count == 3 else {
                    throw MundaneTimespineError.malformedSeries(profile.body)
                }
                var regions: [MundaneTimespineRegion] = []
                for index in 0..<3 {
                    let regionPlan = plans[index]
                    let expected = Self.sampleCount(start: regionPlan.start, end: regionPlan.end, step: regionPlan.sampleDays)
                    guard stored[index].count == expected, expected >= 4 else {
                        throw MundaneTimespineError.malformedSeries(profile.body)
                    }
                    regions.append(.init(
                        startJulianDay: regionPlan.start,
                        endJulianDay: regionPlan.end,
                        sampleDays: regionPlan.sampleDays,
                        samples: stored[index]
                    ))
                }

                let motionChronology: MundaneMotionChronology
                if let supplied = plan.motionChronologies[profile.body] {
                    motionChronology = supplied
                } else {
                    guard let initial = initialMotionByBody[profile.body],
                          let fallback = MundaneMotionChronology(initialMotion: initial, stations: []) else {
                        throw MundaneTimespineError.malformedSeries(profile.body)
                    }
                    motionChronology = fallback
                }
                seriesByBody[profile.body] = .init(
                    profile: profile,
                    motionChronology: motionChronology,
                    regions: regions
                )
            }

            let bounds = Self.effectiveDenseBounds(plan)
            let metadata = MundaneTimespineMetadata(
                version: plan.version,
                codec: MundaneTimespine.codec,
                astroDNACodec: AstroDNA.codec,
                astronomicalSource: plan.astronomicalSource,
                astronomicalSourceVersion: plan.astronomicalSourceVersion,
                supportedStart: plan.supportedStart,
                denseStart: bounds.start,
                denseEnd: bounds.end,
                supportedEnd: plan.supportedEnd,
                positionUnitsPerDegree: MundaneTimespine.positionUnitsPerDegree,
                profiles: plan.profiles
            )
            return try MundaneTimespine(metadata: metadata, seriesByBody: seriesByBody)
        }

        private struct RegionPlan {
            let start: Double
            let end: Double
            let sampleDays: Double
        }

        private static func effectiveDenseBounds(_ plan: MundaneTimespineForgePlan) -> (start: JulianDay, end: JulianDay) {
            let start = plan.supportedStart.value
            let end = plan.supportedEnd.value
            if start < v1DenseStart.value,
               v1DenseStart.value < v1DenseEnd.value,
               v1DenseEnd.value < end {
                return (v1DenseStart, v1DenseEnd)
            }
            let span = end - start
            return (JulianDay(start + span / 3)!, JulianDay(start + 2 * span / 3)!)
        }

        private static func regionPlans(for profile: MundaneTimespineProfile, plan: MundaneTimespineForgePlan) -> [RegionPlan] {
            let bounds = effectiveDenseBounds(plan)
            return [
                RegionPlan(start: plan.supportedStart.value, end: bounds.start.value, sampleDays: profile.edgeSampleDays),
                RegionPlan(start: bounds.start.value, end: bounds.end.value, sampleDays: profile.coreSampleDays),
                RegionPlan(start: bounds.end.value, end: plan.supportedEnd.value, sampleDays: profile.edgeSampleDays),
            ]
        }

        private static func sampleCount(start: Double, end: Double, step: Double) -> Int {
            Int(ceil((end - start) / step)) + 1
        }

        fileprivate static func totalSampleCount(for plan: MundaneTimespineForgePlan) -> Int {
            plan.profiles.reduce(0) { total, profile in
                total + regionPlans(for: profile, plan: plan).reduce(0) { subtotal, region in
                    subtotal + sampleCount(start: region.start, end: region.end, step: region.sampleDays)
                }
            }
        }
    }

    private static func totalSampleCount(for plan: MundaneTimespineForgePlan) -> Int {
        Cursor.totalSampleCount(for: plan)
    }
}
