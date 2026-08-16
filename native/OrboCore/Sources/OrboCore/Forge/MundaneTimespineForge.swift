import Foundation

/// Controlled deep-astronomy socket used by Forge construction only.
/// A qualified Swiss Ephemeris bridge may conform here in the construction environment;
/// ordinary Ovum consumers must read the Mundane Timespine instead.
public protocol ForgeEphemerisReference: Sendable {
    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState
}

public struct MundaneTimespineForgePlan: Hashable, Sendable {
    public let version: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let profiles: [MundaneTimespineProfile]

    public init?(
        version: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        profiles: [MundaneTimespineProfile]
    ) {
        guard !version.isEmpty,
              !astronomicalSource.isEmpty,
              !astronomicalSourceVersion.isEmpty,
              supportedStart.value < supportedEnd.value,
              profiles.map(\.body) == MundaneBody.canonicalOrder else {
            return nil
        }
        self.version = version
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.profiles = profiles
    }
}

public struct MundaneTimespineForgeProgress: Hashable, Sendable {
    public let completedSegments: Int
    public let totalSegments: Int
    public let currentBody: MundaneBody?

    public var fractionComplete: Double {
        guard totalSegments > 0 else { return 1 }
        return min(1, Double(completedSegments) / Double(totalSegments))
    }
}

public enum MundaneTimespineForge {
    /// Candidate profile earned by the Pass 5 representation study.
    /// This is a manufacturing profile, not a claim that the full v1 artifact is sealed.
    public static let candidateProfiles: [MundaneTimespineProfile] = [
        MundaneTimespineProfile(body: .sun, polynomialDegree: 7, segmentDays: 16)!,
        MundaneTimespineProfile(body: .moon, polynomialDegree: 7, segmentDays: 4)!,
        MundaneTimespineProfile(body: .mercury, polynomialDegree: 7, segmentDays: 1)!,
        MundaneTimespineProfile(body: .venus, polynomialDegree: 7, segmentDays: 16)!,
        MundaneTimespineProfile(body: .mars, polynomialDegree: 7, segmentDays: 8)!,
        MundaneTimespineProfile(body: .jupiter, polynomialDegree: 7, segmentDays: 2)!,
        MundaneTimespineProfile(body: .saturn, polynomialDegree: 7, segmentDays: 8)!,
        MundaneTimespineProfile(body: .uranus, polynomialDegree: 7, segmentDays: 4)!,
        MundaneTimespineProfile(body: .neptune, polynomialDegree: 7, segmentDays: 4)!,
        MundaneTimespineProfile(body: .pluto, polynomialDegree: 7, segmentDays: 8)!,
        MundaneTimespineProfile(body: .trueNorthNode, polynomialDegree: 7, segmentDays: 4)!,
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
            _ = try cursor.step(reference: reference, segmentBudget: 256)
        }
        return try cursor.product()
    }

    public static func estimatedCoefficientBytes(for plan: MundaneTimespineForgePlan) -> Int {
        let span = plan.supportedEnd.value - plan.supportedStart.value
        return plan.profiles.reduce(0) { total, profile in
            let segments = Int(ceil(span / profile.segmentDays))
            return total + segments * (profile.polynomialDegree + 1) * MemoryLayout<Int32>.size
        }
    }

    public struct Cursor: Sendable {
        public let plan: MundaneTimespineForgePlan

        private var bodyIndex = 0
        private var segmentIndex = 0
        private var completedSegments = 0
        private var coefficientsByBody: [MundaneBody: [Int32]] = [:]

        fileprivate init(plan: MundaneTimespineForgePlan) {
            self.plan = plan
            for body in MundaneBody.canonicalOrder {
                coefficientsByBody[body] = []
            }
        }

        public var totalSegments: Int {
            Self.totalSegments(for: plan)
        }

        public var isComplete: Bool {
            bodyIndex >= plan.profiles.count
        }

        public var progress: MundaneTimespineForgeProgress {
            MundaneTimespineForgeProgress(
                completedSegments: completedSegments,
                totalSegments: totalSegments,
                currentBody: isComplete ? nil : plan.profiles[bodyIndex].body
            )
        }

        @discardableResult
        public mutating func step(
            reference: any ForgeEphemerisReference,
            segmentBudget: Int = 64
        ) throws -> MundaneTimespineForgeProgress {
            guard segmentBudget > 0 else { return progress }
            var remaining = segmentBudget

            while remaining > 0, !isComplete {
                let profile = plan.profiles[bodyIndex]
                let count = Self.segmentCount(for: profile, plan: plan)

                if segmentIndex >= count {
                    bodyIndex += 1
                    segmentIndex = 0
                    continue
                }

                let segmentStart = plan.supportedStart.value + Double(segmentIndex) * profile.segmentDays
                let coefficients = try Self.fitSegment(
                    body: profile.body,
                    startJulianDay: segmentStart,
                    durationDays: profile.segmentDays,
                    degree: profile.polynomialDegree,
                    reference: reference
                )
                coefficientsByBody[profile.body, default: []].append(contentsOf: coefficients)
                segmentIndex += 1
                completedSegments += 1
                remaining -= 1
            }

            while !isComplete {
                let profile = plan.profiles[bodyIndex]
                let count = Self.segmentCount(for: profile, plan: plan)
                guard segmentIndex >= count else { break }
                bodyIndex += 1
                segmentIndex = 0
            }

            return progress
        }

        public func product() throws -> MundaneTimespine {
            guard isComplete else {
                throw MundaneTimespineError.malformedMetadata
            }

            var seriesByBody: [MundaneBody: MundaneTimespineSeries] = [:]
            for profile in plan.profiles {
                let segmentCount = Self.segmentCount(for: profile, plan: plan)
                let coefficients = coefficientsByBody[profile.body] ?? []
                guard coefficients.count == segmentCount * (profile.polynomialDegree + 1) else {
                    throw MundaneTimespineError.malformedSeries(profile.body)
                }
                seriesByBody[profile.body] = MundaneTimespineSeries(
                    profile: profile,
                    startJulianDay: plan.supportedStart.value,
                    segmentCount: segmentCount,
                    coefficients: coefficients
                )
            }

            let metadata = MundaneTimespineMetadata(
                version: plan.version,
                codec: MundaneTimespine.codec,
                astroDNACodec: AstroDNA.codec,
                astronomicalSource: plan.astronomicalSource,
                astronomicalSourceVersion: plan.astronomicalSourceVersion,
                supportedStart: plan.supportedStart,
                supportedEnd: plan.supportedEnd,
                coefficientScale: MundaneTimespine.coefficientScale,
                profiles: plan.profiles
            )
            return try MundaneTimespine(metadata: metadata, seriesByBody: seriesByBody)
        }

        private static func totalSegments(for plan: MundaneTimespineForgePlan) -> Int {
            plan.profiles.reduce(0) { $0 + segmentCount(for: $1, plan: plan) }
        }

        private static func segmentCount(
            for profile: MundaneTimespineProfile,
            plan: MundaneTimespineForgePlan
        ) -> Int {
            Int(ceil((plan.supportedEnd.value - plan.supportedStart.value) / profile.segmentDays))
        }

        private static func fitSegment(
            body: MundaneBody,
            startJulianDay: Double,
            durationDays: Double,
            degree: Int,
            reference: any ForgeEphemerisReference
        ) throws -> [Int32] {
            let sampleCount = degree + 1
            var samples: [(x: Double, longitude: Double)] = []
            samples.reserveCapacity(sampleCount)

            // Chebyshev-Gauss nodes avoid endpoint weighting and give a tiny deterministic
            // cosine transform for each segment.
            for j in 0..<sampleCount {
                let theta = Double.pi * (Double(j) + 0.5) / Double(sampleCount)
                let x = cos(theta)
                let jd = startJulianDay + (x + 1) * durationDays / 2
                guard let julianDay = JulianDay(jd) else {
                    throw MundaneTimespineError.malformedMetadata
                }
                let state = try reference.state(of: body, at: julianDay)
                samples.append((x: x, longitude: state.longitude.degrees))
            }

            samples.sort { $0.x < $1.x }

            var unwrapped: [(x: Double, longitude: Double)] = []
            unwrapped.reserveCapacity(sampleCount)
            for sample in samples {
                if let previous = unwrapped.last {
                    let previousCanonical = normalize360(previous.longitude)
                    let delta = wrap180(sample.longitude - previousCanonical)
                    unwrapped.append((sample.x, previous.longitude + delta))
                } else {
                    unwrapped.append(sample)
                }
            }

            var coefficients: [Int32] = []
            coefficients.reserveCapacity(sampleCount)
            let scale = Double(MundaneTimespine.coefficientScale)

            for k in 0..<sampleCount {
                var sum = 0.0
                for sample in unwrapped {
                    let theta = acos(max(-1, min(1, sample.x)))
                    sum += sample.longitude * cos(Double(k) * theta)
                }
                var coefficient = 2 * sum / Double(sampleCount)
                if k == 0 {
                    coefficient *= 0.5
                }

                let scaled = (coefficient * scale).rounded()
                guard scaled >= Double(Int32.min), scaled <= Double(Int32.max) else {
                    throw MundaneTimespineError.coefficientOverflow
                }
                coefficients.append(Int32(scaled))
            }
            return coefficients
        }

        private static func normalize360(_ value: Double) -> Double {
            var result = value.truncatingRemainder(dividingBy: 360)
            if result < 0 { result += 360 }
            return result == 0 ? 0 : result
        }

        private static func wrap180(_ value: Double) -> Double {
            var result = (value + 180).truncatingRemainder(dividingBy: 360)
            if result < 0 { result += 360 }
            return result - 180
        }
    }
}
