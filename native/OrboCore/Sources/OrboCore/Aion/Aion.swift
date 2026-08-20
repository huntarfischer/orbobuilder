import Foundation

/// The four independent long-duration clocks carried by the Ovum.
public enum AionFamily: String, CaseIterable, Codable, Hashable, Sendable {
    case frame = "F"
    case revolt = "R"
    case wave = "W"
    case zeitgeist = "Z"

    public static let addressOrder: [AionFamily] = [.frame, .revolt, .wave, .zeitgeist]

    public var astroDNAGene: AstroDNAGene {
        switch self {
        case .frame: return .saturn
        case .revolt: return .uranus
        case .wave: return .neptune
        case .zeitgeist: return .pluto
        }
    }
}

public enum AionCrossingMotion: String, Codable, Hashable, Sendable {
    case direct
    case retrograde
}

public struct AionCrossing: Hashable, Codable, Sendable {
    public let julianDay: JulianDay
    public let motion: AionCrossingMotion

    public init(julianDay: JulianDay, motion: AionCrossingMotion) {
        self.julianDay = julianDay
        self.motion = motion
    }
}

/// One canonical Shell.sign ownership interval.
public struct AionSegment: Hashable, Sendable {
    public let family: AionFamily
    public let shellID: String
    public let shellOrdinal: Int
    public let shellSignID: String
    public let sign: Sign
    public let signOrdinal: Int
    public let start: JulianDay
    public let end: JulianDay
    public let crossings: [AionCrossing]

    public init?(
        family: AionFamily,
        shellID: String,
        shellOrdinal: Int,
        shellSignID: String,
        sign: Sign,
        signOrdinal: Int,
        start: JulianDay,
        end: JulianDay,
        crossings: [AionCrossing]
    ) {
        guard signOrdinal == sign.rawValue + 1,
              (1...12).contains(signOrdinal),
              shellID == "\(family.rawValue)\(shellOrdinal)",
              shellSignID == "\(shellID).\(String(format: "%02d", signOrdinal))",
              start.value < end.value,
              !crossings.isEmpty,
              crossings[0].motion == .direct,
              abs(crossings[0].julianDay.value - start.value) <= 1e-7,
              zip(crossings, crossings.dropFirst()).allSatisfy({
                  $0.julianDay.value < $1.julianDay.value
              }) else {
            return nil
        }
        self.family = family
        self.shellID = shellID
        self.shellOrdinal = shellOrdinal
        self.shellSignID = shellSignID
        self.sign = sign
        self.signOrdinal = signOrdinal
        self.start = start
        self.end = end
        self.crossings = crossings
    }
}

public enum AionError: Error, Equatable, Sendable {
    case unsupportedJulianDay(Double)
    case malformedIndex(String)
    case missingFamily(AionFamily)
    case noSegmentMatch(AionFamily, Double)
}

/// Versioned runtime projection of the canonical Pass 5 Shell.sign tables.
///
/// AionIndex is not a second temporal authority. It is a compact read surface
/// manufactured from the canonical construction tables and validated on load.
public struct AionIndex: Sendable {
    public static let schemaVersion = 1

    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    private let rowsByFamily: [AionFamily: [AionSegment]]

    public init(
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        rowsByFamily: [AionFamily: [AionSegment]]
    ) throws {
        guard supportedStart.value < supportedEnd.value else {
            throw AionError.malformedIndex("supported range is not increasing")
        }

        for family in AionFamily.addressOrder {
            guard let rows = rowsByFamily[family], !rows.isEmpty else {
                throw AionError.missingFamily(family)
            }
            guard rows.allSatisfy({ $0.family == family }) else {
                throw AionError.malformedIndex("family row mismatch for \(family.rawValue)")
            }
            guard rows[0].start.value <= supportedStart.value + 1e-9,
                  rows[rows.count - 1].end.value >= supportedEnd.value - 1e-9 else {
                throw AionError.malformedIndex("\(family.rawValue) does not cover supported range")
            }
            for (left, right) in zip(rows, rows.dropFirst()) {
                guard abs(left.end.value - right.start.value) <= 1e-7 else {
                    throw AionError.malformedIndex(
                        "gap or overlap: \(left.shellSignID) -> \(right.shellSignID)"
                    )
                }
            }
        }

        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.rowsByFamily = rowsByFamily
    }

    public func segments(for family: AionFamily) -> [AionSegment] {
        rowsByFamily[family] ?? []
    }

    public func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= supportedStart.value && julianDay.value < supportedEnd.value
    }

    internal func segment(for family: AionFamily, at julianDay: JulianDay) throws -> AionSegment {
        guard contains(julianDay) else {
            throw AionError.unsupportedJulianDay(julianDay.value)
        }
        guard let rows = rowsByFamily[family], !rows.isEmpty else {
            throw AionError.missingFamily(family)
        }

        var low = 0
        var high = rows.count
        while low < high {
            let mid = (low + high) / 2
            if rows[mid].start.value <= julianDay.value {
                low = mid + 1
            } else {
                high = mid
            }
        }

        let index = low - 1
        guard index >= 0,
              index < rows.count,
              julianDay.value < rows[index].end.value else {
            throw AionError.noSegmentMatch(family, julianDay.value)
        }
        return rows[index]
    }
}

public struct AionCoordinate: Hashable, Sendable {
    public let family: AionFamily
    public let shellID: String
    public let shellOrdinal: Int
    public let shellSignID: String
    public let sign: Sign
    public let signOrdinal: Int
    public let segmentStart: JulianDay
    public let segmentEnd: JulianDay
    public let progress: Double

    internal init(segment: AionSegment, at julianDay: JulianDay) {
        family = segment.family
        shellID = segment.shellID
        shellOrdinal = segment.shellOrdinal
        shellSignID = segment.shellSignID
        sign = segment.sign
        signOrdinal = segment.signOrdinal
        segmentStart = segment.start
        segmentEnd = segment.end
        let denominator = segment.end.value - segment.start.value
        let rawProgress = (julianDay.value - segment.start.value) / denominator
        progress = min(max(rawProgress, 0), 1)
    }
}

public struct AionState: Hashable, Sendable {
    public let julianDay: JulianDay
    public let frame: AionCoordinate
    public let revolt: AionCoordinate
    public let wave: AionCoordinate
    public let zeitgeist: AionCoordinate

    public subscript(_ family: AionFamily) -> AionCoordinate {
        switch family {
        case .frame: return frame
        case .revolt: return revolt
        case .wave: return wave
        case .zeitgeist: return zeitgeist
        }
    }

    public var shellAddress: String {
        AionFamily.addressOrder.map { self[$0].shellID }.joined(separator: ".")
    }

    public var shellSignAddress: String {
        AionFamily.addressOrder.map { self[$0].shellSignID }.joined(separator: ".")
    }
}

public enum AionTransitionState: String, Codable, Hashable, Sendable {
    case stable
    case retrogradeRecross
    case directRecross
}

public struct AionFamilyVerification: Hashable, Sendable {
    public let family: AionFamily
    public let shellSignID: String
    public let ownershipSign: Sign
    public let expectedPhysicalSign: Sign
    public let astroDNAPhysicalSign: Sign
    public let transitionState: AionTransitionState
    public let matches: Bool
}

public struct AionVerification: Hashable, Sendable {
    public let state: AionState
    public let families: [AionFamilyVerification]

    public var passed: Bool {
        families.allSatisfy(\.matches)
    }
}

/// Ovum service for resolving a Julian Day into the four independent temporal clocks.
///
/// The primary port is JD-only so any Orbo engine can consume Aion without first
/// constructing AstroDNA. The AstroDNA overload is a verification adapter, not the
/// ownership path.
public struct Aion: Sendable {
    public let index: AionIndex

    public init(index: AionIndex) {
        self.index = index
    }

    public func resolve(at julianDay: JulianDay) throws -> AionState {
        let frame = AionCoordinate(segment: try index.segment(for: .frame, at: julianDay), at: julianDay)
        let revolt = AionCoordinate(segment: try index.segment(for: .revolt, at: julianDay), at: julianDay)
        let wave = AionCoordinate(segment: try index.segment(for: .wave, at: julianDay), at: julianDay)
        let zeitgeist = AionCoordinate(segment: try index.segment(for: .zeitgeist, at: julianDay), at: julianDay)
        return AionState(
            julianDay: julianDay,
            frame: frame,
            revolt: revolt,
            wave: wave,
            zeitgeist: zeitgeist
        )
    }

    /// Verifies the sign-resolution temporal ownership against the four corresponding
    /// AstroDNA genes. This deliberately verifies only what Shell.sign can prove:
    /// physical sign compatibility, including legal retrograde recrosses.
    /// Arcsecond position and instantaneous motion remain the responsibility of the
    /// Mundane Timespine / Resonator proof path.
    public func verify(_ astroDNA: AstroDNA, at julianDay: JulianDay) throws -> AionVerification {
        let state = try resolve(at: julianDay)
        let checks = try AionFamily.addressOrder.map { family -> AionFamilyVerification in
            let segment = try index.segment(for: family, at: julianDay)
            let expected = physicalExpectation(for: segment, at: julianDay)
            let physicalSign = astroDNA.sign(of: family.astroDNAGene)
            return AionFamilyVerification(
                family: family,
                shellSignID: segment.shellSignID,
                ownershipSign: segment.sign,
                expectedPhysicalSign: expected.sign,
                astroDNAPhysicalSign: physicalSign,
                transitionState: expected.state,
                matches: physicalSign == expected.sign
            )
        }
        return AionVerification(state: state, families: checks)
    }

    private func physicalExpectation(
        for segment: AionSegment,
        at julianDay: JulianDay
    ) -> (sign: Sign, state: AionTransitionState) {
        var lastIndex = 0
        for (index, crossing) in segment.crossings.enumerated() {
            if crossing.julianDay.value <= julianDay.value {
                lastIndex = index
            } else {
                break
            }
        }

        let last = segment.crossings[lastIndex]
        if last.motion == .retrograde {
            let previousRaw = (segment.sign.rawValue + 11) % 12
            return (Sign(rawValue: previousRaw)!, .retrogradeRecross)
        }
        if lastIndex > 0 {
            return (segment.sign, .directRecross)
        }
        return (segment.sign, .stable)
    }
}
