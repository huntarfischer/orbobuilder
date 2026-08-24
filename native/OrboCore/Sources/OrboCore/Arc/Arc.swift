public enum Arc {
    public static let degrees = 360
    public static let arcsecondsPerDegree = 60 * 60
    public static let inputStates = degrees * arcsecondsPerDegree
    public static let halfCircleArcseconds = inputStates / 2
    public static let quarterCircleArcseconds = inputStates / 4

    /// Arc outputs may land on half-arcseconds, so the output circle is stored
    /// as exact half-arcsecond ticks rather than floating-point degrees.
    public static let outputTicks = inputStates * 2
    public static let quarterCircleTicks = quarterCircleArcseconds * 2

    /// Casts the complete composite possibility field centered on one lawful
    /// zodiacal coordinate.
    public static func cast(_ anchor: ArcCoordinate) -> ArcField {
        let center = ArcPosition(unchecked: anchor.arcsecond * 2)
        let plusPole = ArcPosition(
            unchecked: normalizedOutputTick(center.rawValue + quarterCircleTicks)
        )
        let minusPole = ArcPosition(
            unchecked: normalizedOutputTick(center.rawValue - quarterCircleTicks)
        )

        return ArcField(
            anchor: anchor,
            center: center,
            minusPole: minusPole,
            plusPole: plusPole
        )
    }

    /// Composes two lawful coordinates along their shortest arc. At exact
    /// opposition, neither half-arc is privileged and Arc returns the Seam.
    public static func compose(_ anchor: ArcCoordinate, _ partner: ArcCoordinate) -> ArcComposite {
        let directed = normalizedInputArcsecond(partner.arcsecond - anchor.arcsecond)

        if directed == halfCircleArcseconds {
            let field = cast(anchor)
            return .seam(
                ArcSeam(minusPole: field.minusPole, plusPole: field.plusPole)
            )
        }

        let signedDisplacement = directed < halfCircleArcseconds
            ? directed
            : directed - inputStates

        // The anchor is converted to half-arcsecond ticks. Adding one whole
        // source arcsecond of displacement advances the composite by one
        // half-arcsecond tick, exactly encoding the half-arc law.
        let rawOutput = anchor.arcsecond * 2 + signedDisplacement
        return .position(
            ArcPosition(unchecked: normalizedOutputTick(rawOutput))
        )
    }

    internal static func normalizedInputArcsecond(_ value: Int) -> Int {
        let remainder = value % inputStates
        return remainder < 0 ? remainder + inputStates : remainder
    }

    internal static func normalizedOutputTick(_ value: Int) -> Int {
        let remainder = value % outputTicks
        return remainder < 0 ? remainder + outputTicks : remainder
    }
}

/// Exact lawful Arc input at whole-arcsecond fidelity.
public struct ArcCoordinate: Hashable, Sendable, Codable {
    public let arcsecond: Int

    public init?(_ arcsecond: Int) {
        guard (0..<Arc.inputStates).contains(arcsecond) else { return nil }
        self.arcsecond = arcsecond
    }

    public init?(degree: Int, minute: Int = 0, second: Int = 0) {
        guard (0..<Arc.degrees).contains(degree),
              (0..<60).contains(minute),
              (0..<60).contains(second)
        else { return nil }

        self.arcsecond = degree * Arc.arcsecondsPerDegree + minute * 60 + second
    }

    public var degree: Int {
        arcsecond / Arc.arcsecondsPerDegree
    }

    public var minute: Int {
        (arcsecond / 60) % 60
    }

    public var second: Int {
        arcsecond % 60
    }

    public var longitude: CelestialLongitude {
        CelestialLongitude(Double(arcsecond) / Double(Arc.arcsecondsPerDegree))!
    }
}

/// Exact Arc output on a 2,592,000-state half-arcsecond circle.
public struct ArcPosition: Hashable, Sendable, Codable {
    public let rawValue: Int

    public init?(_ rawValue: Int) {
        guard (0..<Arc.outputTicks).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    internal init(unchecked rawValue: Int) {
        self.rawValue = rawValue
    }

    public var degrees: Double {
        Double(rawValue) / Double(Arc.arcsecondsPerDegree * 2)
    }

    public var isWholeArcsecond: Bool {
        rawValue.isMultiple(of: 2)
    }

    public var wholeArcsecond: Int? {
        isWholeArcsecond ? rawValue / 2 : nil
    }

    public var degree: Int {
        rawValue / (Arc.arcsecondsPerDegree * 2)
    }

    public var minute: Int {
        (rawValue / (60 * 2)) % 60
    }

    public var second: Int {
        (rawValue / 2) % 60
    }

    /// 0 for an exact whole arcsecond, 1 for the +1/2 arcsecond subvalue.
    public var halfSecond: Int {
        rawValue % 2
    }
}

public struct ArcSeam: Hashable, Sendable, Codable {
    public let minusPole: ArcPosition
    public let plusPole: ArcPosition

    internal init(minusPole: ArcPosition, plusPole: ArcPosition) {
        self.minusPole = minusPole
        self.plusPole = plusPole
    }
}

public enum ArcComposite: Hashable, Sendable, Codable {
    case position(ArcPosition)
    case seam(ArcSeam)
}

/// The complete ±90° composite possibility field cast from one fixed anchor.
/// Both poles are lawful boundary positions; the complementary half of the
/// zodiac is impossible composite space for this anchor.
public struct ArcField: Hashable, Sendable, Codable {
    public let anchor: ArcCoordinate
    public let center: ArcPosition
    public let minusPole: ArcPosition
    public let plusPole: ArcPosition

    internal init(
        anchor: ArcCoordinate,
        center: ArcPosition,
        minusPole: ArcPosition,
        plusPole: ArcPosition
    ) {
        self.anchor = anchor
        self.center = center
        self.minusPole = minusPole
        self.plusPole = plusPole
    }

    public func contains(_ position: ArcPosition) -> Bool {
        let directed = Arc.normalizedOutputTick(position.rawValue - center.rawValue)
        let folded = min(directed, Arc.outputTicks - directed)
        return folded <= Arc.quarterCircleTicks
    }
}
