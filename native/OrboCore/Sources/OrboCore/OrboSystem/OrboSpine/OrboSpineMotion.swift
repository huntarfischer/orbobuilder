import Foundation

public enum OrboSpineRetrogradeBoundary: String, Codable, Hashable, Sendable {
    case station
    case spineStart = "spine-start"
    case spineEnd = "spine-end"
}

/// One half-open retrograde interval derived from exact station topology.
/// Stations remain the truth owner; this is forged motion structure over that truth.
public struct OrboSpineRetrogradePassage: Hashable, Sendable {
    public let body: MundaneBody
    public let start: JulianDay
    public let end: JulianDay
    public let startStationPhysicalDegrees: Double?
    public let endStationPhysicalDegrees: Double?
    public let startBoundary: OrboSpineRetrogradeBoundary
    public let endBoundary: OrboSpineRetrogradeBoundary

    public init?(
        body: MundaneBody,
        start: JulianDay,
        end: JulianDay,
        startStationPhysicalDegrees: Double?,
        endStationPhysicalDegrees: Double?,
        startBoundary: OrboSpineRetrogradeBoundary,
        endBoundary: OrboSpineRetrogradeBoundary
    ) {
        guard start.value < end.value,
              Self.validDegree(startStationPhysicalDegrees),
              Self.validDegree(endStationPhysicalDegrees),
              (startBoundary == .station) == (startStationPhysicalDegrees != nil),
              (endBoundary == .station) == (endStationPhysicalDegrees != nil),
              startBoundary != .spineEnd,
              endBoundary != .spineStart else {
            return nil
        }

        self.body = body
        self.start = start
        self.end = end
        self.startStationPhysicalDegrees = startStationPhysicalDegrees
        self.endStationPhysicalDegrees = endStationPhysicalDegrees
        self.startBoundary = startBoundary
        self.endBoundary = endBoundary
    }

    public func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= start.value && julianDay.value < end.value
    }

    private static func validDegree(_ value: Double?) -> Bool {
        guard let value else { return true }
        return value.isFinite && value >= 0 && value < 360
    }
}

public enum OrboSpineMotionBody {
    /// Derives continuous retrograde passages from exact ordered stations across one Bone span.
    /// Returns nil when station topology is malformed or insufficient to establish motion.
    public static func retrogradePassages(
        body: MundaneBody,
        stations: [OrboSpineStation],
        span: OrboSpineBoneSpan
    ) -> [OrboSpineRetrogradePassage]? {
        if stations.isEmpty {
            return body == .sun || body == .moon ? [] : nil
        }

        for (index, station) in stations.enumerated() {
            guard station.body == body,
                  span.contains(station.julianDay) else {
                return nil
            }

            if index > 0 {
                let previous = stations[index - 1]
                guard previous.julianDay.value < station.julianDay.value,
                      previous.laneAfter == station.laneBefore else {
                    return nil
                }
            }
        }

        var passages: [OrboSpineRetrogradePassage] = []
        var openStart: JulianDay?
        var openDegree: Double?
        var openBoundary: OrboSpineRetrogradeBoundary?

        if stations[0].laneBefore == .retrograde {
            openStart = span.start
            openDegree = nil
            openBoundary = .spineStart
        }

        for station in stations {
            switch (station.laneBefore, station.laneAfter) {
            case (.direct, .retrograde):
                guard openStart == nil else { return nil }
                openStart = station.julianDay
                openDegree = station.physicalDegrees
                openBoundary = .station

            case (.retrograde, .direct):
                guard let start = openStart,
                      let boundary = openBoundary else {
                    return nil
                }

                if start.value < station.julianDay.value {
                    guard let passage = OrboSpineRetrogradePassage(
                        body: body,
                        start: start,
                        end: station.julianDay,
                        startStationPhysicalDegrees: openDegree,
                        endStationPhysicalDegrees: station.physicalDegrees,
                        startBoundary: boundary,
                        endBoundary: .station
                    ) else {
                        return nil
                    }
                    passages.append(passage)
                }

                openStart = nil
                openDegree = nil
                openBoundary = nil

            default:
                return nil
            }
        }

        if let start = openStart,
           let boundary = openBoundary,
           start.value < span.end.value {
            guard let passage = OrboSpineRetrogradePassage(
                body: body,
                start: start,
                end: span.end,
                startStationPhysicalDegrees: openDegree,
                endStationPhysicalDegrees: nil,
                startBoundary: boundary,
                endBoundary: .spineEnd
            ) else {
                return nil
            }
            passages.append(passage)
        }

        return passages
    }
}
