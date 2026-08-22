import Foundation

/// The Forge's astronomical read boundary. Production manufacture may bind this to
/// Swiss Ephemeris, while tests may supply a deterministic reference sky.
public protocol ForgeEphemerisReference: Sendable {
    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState
}

/// Raw astronomical state used only by Forge while manufacturing a durable chronology.
public struct MundaneForgeState: Hashable, Sendable {
    public let longitudeDegrees: Double
    public let longitudinalSpeedDegreesPerDay: Double

    public init?(longitudeDegrees: Double, longitudinalSpeedDegreesPerDay: Double) {
        guard longitudeDegrees.isFinite, longitudinalSpeedDegreesPerDay.isFinite else { return nil }
        var normalized = longitudeDegrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        self.longitudeDegrees = normalized
        self.longitudinalSpeedDegreesPerDay = longitudinalSpeedDegreesPerDay
    }
}

/// Internal sequence direction of a body's celestial clock. User-facing astrology
/// continues to use Motion.direct / Motion.retrograde.
public enum MundaneCelestialSequenceDirection: String, Codable, Hashable, Sendable {
    case increasing
    case decreasing

    public var motion: Motion {
        switch self {
        case .increasing: return .direct
        case .decreasing: return .retrograde
        }
    }

    static func from(speed: Double) -> Self {
        speed < 0 ? .decreasing : .increasing
    }
}

public struct MundaneForgeMarker: Codable, Hashable, Sendable {
    public let body: MundaneBody
    public let wholeDegree: UInt16
}

/// One occurrence of a repeating celestial-time coordinate bound to civic UT.
public struct MundaneForgedOccurrence: Codable, Hashable, Sendable {
    public let focalCelestialTick: Int
    public let focalCelestialDegrees: Double
    public let occurrence: Int
    public let civicOffsetSeconds: Int64
    public let julianDay: JulianDay
    public let sequenceDirection: MundaneCelestialSequenceDirection
    public let markers: [MundaneForgeMarker]
}

/// A station is a turn in the mapping between a body's celestial time and civic UT.
public struct MundaneForgedStation: Codable, Hashable, Sendable {
    public let body: MundaneBody
    public let celestialTimeDegrees: Double
    public let julianDay: JulianDay
    public let sequenceBefore: MundaneCelestialSequenceDirection
    public let sequenceAfter: MundaneCelestialSequenceDirection

    public var motionAfter: Motion { sequenceAfter.motion }
}

public struct MundaneForgedRetrogradePassage: Codable, Hashable, Sendable {
    public let body: MundaneBody
    public let startCelestialTimeDegrees: Double
    public let endCelestialTimeDegrees: Double
    public let startJulianDay: JulianDay
    public let endJulianDay: JulianDay
}

public struct MundaneTimespineForgedBody: Codable, Sendable {
    public let body: MundaneBody
    public let celestialResolutionDegrees: Double
    public let markerBodies: [MundaneBody]
    public let occurrences: [MundaneForgedOccurrence]
    public let stations: [MundaneForgedStation]
    public let retrogradePassages: [MundaneForgedRetrogradePassage]

    public var retrogradeCrossingCount: Int {
        occurrences.reduce(0) { $0 + ($1.sequenceDirection == .decreasing ? 1 : 0) }
    }
}

public struct MundaneTimespineForgeProduct: Sendable {
    public let spanName: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let bodies: [MundaneTimespineForgedBody]

    public var totalOccurrenceCount: Int {
        bodies.reduce(0) { $0 + $1.occurrences.count }
    }

    public var totalStationCount: Int {
        bodies.reduce(0) { $0 + $1.stations.count }
    }

    public var totalRetrogradePassageCount: Int {
        bodies.reduce(0) { $0 + $1.retrogradePassages.count }
    }

    public func body(_ body: MundaneBody) -> MundaneTimespineForgedBody? {
        bodies.first { $0.body == body }
    }
}

public struct MundaneTimespineForgeBodyPlan: Hashable, Sendable {
    public let contract: MundaneTimespineBodyContract
    public let scanStepDays: Double

    public init?(contract: MundaneTimespineBodyContract, scanStepDays: Double) {
        guard scanStepDays.isFinite, scanStepDays > 0 else { return nil }
        self.contract = contract
        self.scanStepDays = scanStepDays
    }
}

/// Generic Forge manufacture plan. It describes a proven span and body recipes only.
/// Span-specific astronomical certification belongs to the recipe that creates this plan.
public struct MundaneTimespineForgePlan: Sendable {
    public let spanName: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let bodyPlans: [MundaneTimespineForgeBodyPlan]
    public let verifiesConstructionRecordCounts: Bool
    public let verifiesMarkerUniqueness: Bool

    public init?(
        spanName: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        bodyPlans: [MundaneTimespineForgeBodyPlan],
        verifiesConstructionRecordCounts: Bool = false,
        verifiesMarkerUniqueness: Bool = true
    ) {
        let bodies = bodyPlans.map { $0.contract.body }
        guard !spanName.isEmpty,
              !astronomicalSource.isEmpty,
              !astronomicalSourceVersion.isEmpty,
              supportedStart.value < supportedEnd.value,
              !bodyPlans.isEmpty,
              Set(bodies).count == bodies.count else { return nil }

        let availableBodies = Set(bodies)
        for bodyPlan in bodyPlans {
            guard bodyPlan.contract.markerBodies.allSatisfy({ availableBodies.contains($0) }) else { return nil }
        }

        self.spanName = spanName
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.bodyPlans = bodyPlans
        self.verifiesConstructionRecordCounts = verifiesConstructionRecordCounts
        self.verifiesMarkerUniqueness = verifiesMarkerUniqueness
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

public enum MundaneTimespineForgeError: Error, Equatable, CustomStringConvertible {
    case incompleteManufacture
    case malformedPlan
    case malformedState(MundaneBody)
    case recordCountMismatch(body: MundaneBody, expected: Int, actual: Int)
    case markerCollision(body: MundaneBody)
    case unsupportedResolution(body: MundaneBody, resolution: Double)

    public var description: String {
        switch self {
        case .incompleteManufacture:
            return "Forge product requested before manufacture completed."
        case .malformedPlan:
            return "Mundane Timespine Forge plan is malformed."
        case let .malformedState(body):
            return "Ephemeris returned a malformed state for \(body.displayName)."
        case let .recordCountMismatch(body, expected, actual):
            return "\(body.displayName) forged \(actual) records; expected \(expected)."
        case let .markerCollision(body):
            return "\(body.displayName) companion marker key repeats inside the Forge span."
        case let .unsupportedResolution(body, resolution):
            return "\(body.displayName) Forge resolution \(resolution) cannot produce whole-degree marker cells."
        }
    }
}
