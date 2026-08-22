import Foundation

/// The Forge's astronomical read boundary. Production may bind this to Swiss Ephemeris;
/// tests may provide a deterministic reference sky.
public protocol SpineForgeEphemerisReference: Sendable {
    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> SpineForgeState
}

/// Raw astronomical state exists only while the Forge is working.
public struct SpineForgeState: Hashable, Sendable {
    public let longitudeDegrees: Double
    public let longitudinalSpeedDegreesPerDay: Double

    public init?(longitudeDegrees: Double, longitudinalSpeedDegreesPerDay: Double) {
        guard longitudeDegrees.isFinite,
              longitudinalSpeedDegreesPerDay.isFinite else { return nil }
        var normalized = longitudeDegrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        self.longitudeDegrees = normalized
        self.longitudinalSpeedDegreesPerDay = longitudinalSpeedDegreesPerDay
    }
}

public struct SpineForgeProgress: Hashable, Sendable {
    public let completedSegments: Int
    public let totalSegments: Int
    public let currentBody: MundaneBody?

    public var fractionComplete: Double {
        guard totalSegments > 0 else { return 1 }
        return min(1, Double(completedSegments) / Double(totalSegments))
    }
}

/// One finished celestial tract manufactured directly into OrboSpine-native matter.
public struct SpineForgeBodyProduct: Sendable {
    public let body: MundaneBody
    public let supportDegrees: Double
    public let supports: [OrboSpineCelestialCoordinate]
    public let stations: [OrboSpineStation]
}

public struct SpineForgeProduct: Sendable {
    public let schematicIdentity: String
    public let schematicVersion: UInt16
    public let astronomicalAuthority: String
    public let astronomicalSourceVersion: String
    public let bone: OrboSpineBoneSpan
    public let bodies: [SpineForgeBodyProduct]

    public var totalSupportCount: Int {
        bodies.reduce(0) { $0 + $1.supports.count }
    }

    public var totalStationCount: Int {
        bodies.reduce(0) { $0 + $1.stations.count }
    }

    public func body(_ body: MundaneBody) -> SpineForgeBodyProduct? {
        bodies.first { $0.body == body }
    }
}

public enum SpineForgeError: Error, Equatable, CustomStringConvertible {
    case incompleteManufacture
    case malformedSchematic
    case malformedState(MundaneBody)
    case boundaryMismatch(index: Int)
    case unsupportedResolution(body: MundaneBody, resolution: Double)

    public var description: String {
        switch self {
        case .incompleteManufacture:
            return "Forge product requested before manufacture completed."
        case .malformedSchematic:
            return "Spine schematic is malformed."
        case let .malformedState(body):
            return "Ephemeris returned a malformed state for \(body.displayName)."
        case let .boundaryMismatch(index):
            return "Spine schematic boundary check \(index) failed."
        case let .unsupportedResolution(body, resolution):
            return "\(body.displayName) Forge support \(resolution) does not partition the zodiac."
        }
    }
}
