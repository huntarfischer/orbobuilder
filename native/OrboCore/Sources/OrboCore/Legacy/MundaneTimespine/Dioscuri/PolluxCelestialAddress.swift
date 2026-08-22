import Foundation

/// One companion-body whole-degree cell used to distinguish a repeating celestial coordinate.
public struct PolluxMarkerCell: Hashable, Sendable {
    public let body: MundaneBody
    public let wholeDegree: UInt16

    public init?(body: MundaneBody, wholeDegree: UInt16) {
        guard wholeDegree < 360 else { return nil }
        self.body = body
        self.wholeDegree = wholeDegree
    }
}

/// Pollux's native address: celestial identity first, with no civic coordinate in the key.
///
/// Forge proved the identity law as focal celestial tick + ordered companion marker cells.
/// Sequence direction is evidence about the occurrence, not part of its identity.
public struct PolluxCelestialAddress: Hashable, Sendable {
    public let body: MundaneBody
    public let celestialTick: Int
    public let ticksPerDegree: Int
    public let markerFingerprint: [PolluxMarkerCell]

    public init?(
        body: MundaneBody,
        celestialTick: Int,
        ticksPerDegree: Int,
        markerFingerprint: [PolluxMarkerCell]
    ) {
        guard ticksPerDegree > 0,
              (0..<(360 * ticksPerDegree)).contains(celestialTick),
              !markerFingerprint.contains(where: { $0.body == body }),
              Set(markerFingerprint.map(\.body)).count == markerFingerprint.count else {
            return nil
        }
        self.body = body
        self.celestialTick = celestialTick
        self.ticksPerDegree = ticksPerDegree
        self.markerFingerprint = markerFingerprint
    }

    public var celestialDegrees: Double {
        Double(celestialTick) / Double(ticksPerDegree)
    }
}
