public enum RingMark: Int, CaseIterable, Codable, Hashable, Sendable {
    case conjunction = 0
    case semisextile = 30
    case semisquare = 45
    case sextile = 60
    case quintile = 72
    case square = 90
    case trine = 120
    case sesquiquadrate = 135
    case biquintile = 144
    case quincunx = 150
    case opposition = 180
}

public enum RingDirection: String, Codable, Hashable, Sendable {
    case minus
    case plus

    internal var tableOffset: Int {
        switch self {
        case .minus: return 0
        case .plus: return 1
        }
    }
}

public enum RingTieRule: String, Codable, Hashable, Sendable {
    case lower
}

public struct RingState: Hashable, Sendable {
    public let rawValue: Int

    public init?(_ rawValue: Int) {
        guard (0..<Ring.states).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    internal init(unchecked rawValue: Int) {
        self.rawValue = rawValue
    }

    public var degree: Int {
        rawValue % Ring.degrees
    }

    public var motion: Motion {
        rawValue >= Ring.degrees ? .retrograde : .direct
    }

    public var isRetrograde: Bool {
        motion == .retrograde
    }
}

public struct RingFineState: Hashable, Sendable {
    public let rawValue: Int

    public init?(_ rawValue: Int) {
        guard (0..<Ring.fineStates).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    internal init(unchecked rawValue: Int) {
        self.rawValue = rawValue
    }

    public var arcsecond: Int {
        rawValue % Ring.arcseconds
    }

    public var motion: Motion {
        rawValue >= Ring.arcseconds ? .retrograde : .direct
    }

    public var isRetrograde: Bool {
        motion == .retrograde
    }

    public var coarseState: RingState {
        let coarseDegree = arcsecond / Ring.arcsecondsPerDegree
        let motionOffset = isRetrograde ? Ring.degrees : 0
        return RingState(unchecked: coarseDegree + motionOffset)
    }

    public var dms: RingDMS {
        let value = arcsecond
        return RingDMS(
            degree: value / Ring.arcsecondsPerDegree,
            minute: (value / 60) % 60,
            second: value % 60
        )
    }
}

public struct RingDMS: Hashable, Sendable {
    public let degree: Int
    public let minute: Int
    public let second: Int

    public init(degree: Int, minute: Int, second: Int) {
        self.degree = degree
        self.minute = minute
        self.second = second
    }
}

public struct RingSeparation: Hashable, Sendable {
    public let degrees: Double

    public init?(_ degrees: Double) {
        guard degrees.isFinite else { return nil }
        self.degrees = Ring.normalizedDegrees(degrees)
    }

    internal init(unchecked degrees: Double) {
        self.degrees = degrees
    }
}

public struct RingNearest: Hashable, Sendable {
    public let arc: Double
    public let mark: RingMark
    public let residual: Double

    internal init(arc: Double, mark: RingMark, residual: Double) {
        self.arc = arc
        self.mark = mark
        self.residual = residual
    }
}

public struct RingTarget: Hashable, Sendable {
    public let degree: Int
    public let direct: RingState
    public let retrograde: RingState

    internal init(degree: Int) {
        self.degree = degree
        self.direct = RingState(unchecked: degree)
        self.retrograde = RingState(unchecked: degree + Ring.degrees)
    }
}

public struct RingRowEntry: Hashable, Sendable {
    public let mark: RingMark
    public let single: Bool
    public let minus: RingTarget
    public let plus: RingTarget

    internal init(mark: RingMark, minus: RingTarget, plus: RingTarget) {
        self.mark = mark
        self.single = mark == .conjunction || mark == .opposition
        self.minus = minus
        self.plus = plus
    }
}
