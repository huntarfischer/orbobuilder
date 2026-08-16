import Foundation

public enum MundaneBody: UInt8, CaseIterable, Codable, Hashable, Sendable {
    case sun = 0
    case moon = 1
    case mercury = 2
    case venus = 3
    case mars = 4
    case jupiter = 5
    case saturn = 6
    case uranus = 7
    case neptune = 8
    case pluto = 9
    case trueNorthNode = 10

    public static let canonicalOrder: [MundaneBody] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
        .uranus, .neptune, .pluto, .trueNorthNode,
    ]

    public var displayName: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .uranus: return "Uranus"
        case .neptune: return "Neptune"
        case .pluto: return "Pluto"
        case .trueNorthNode: return "True North Node"
        }
    }

    public var planet: Planet? {
        switch self {
        case .sun: return .sun
        case .moon: return .moon
        case .mercury: return .mercury
        case .venus: return .venus
        case .mars: return .mars
        case .jupiter: return .jupiter
        case .saturn: return .saturn
        case .uranus: return .uranus
        case .neptune: return .neptune
        case .pluto: return .pluto
        case .trueNorthNode: return nil
        }
    }
}

public struct MundaneCelestialState: Hashable, Sendable {
    public let longitude: CelestialLongitude
    public let longitudinalSpeedDegreesPerDay: Double

    public init?(longitude: CelestialLongitude, longitudinalSpeedDegreesPerDay: Double) {
        guard longitudinalSpeedDegreesPerDay.isFinite else { return nil }
        self.longitude = longitude
        self.longitudinalSpeedDegreesPerDay = longitudinalSpeedDegreesPerDay
    }

    public var motion: Motion {
        longitudinalSpeedDegreesPerDay < 0 ? .retrograde : .direct
    }
}

public struct MundaneTimespineProfile: Hashable, Codable, Sendable {
    public let body: MundaneBody
    public let polynomialDegree: Int
    public let segmentDays: Double

    public init?(body: MundaneBody, polynomialDegree: Int, segmentDays: Double) {
        guard (1...15).contains(polynomialDegree), segmentDays.isFinite, segmentDays > 0 else {
            return nil
        }
        self.body = body
        self.polynomialDegree = polynomialDegree
        self.segmentDays = segmentDays
    }
}

public struct MundaneTimespineMetadata: Hashable, Sendable {
    public let version: String
    public let codec: Int
    public let astroDNACodec: Int
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let coefficientScale: Int
    public let profiles: [MundaneTimespineProfile]

    internal init(
        version: String,
        codec: Int,
        astroDNACodec: Int,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        coefficientScale: Int,
        profiles: [MundaneTimespineProfile]
    ) {
        self.version = version
        self.codec = codec
        self.astroDNACodec = astroDNACodec
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.coefficientScale = coefficientScale
        self.profiles = profiles
    }
}

public enum MundaneTimespineError: Error, Equatable, Sendable {
    case unsupportedJulianDay(Double)
    case missingBody(MundaneBody)
    case malformedSeries(MundaneBody)
    case malformedMetadata
    case coefficientOverflow
    case invalidArtifactMagic
    case unsupportedCodec(Int)
    case truncatedArtifact
    case invalidUTF8
}

internal struct MundaneTimespineSeries: Sendable {
    let profile: MundaneTimespineProfile
    let startJulianDay: Double
    let segmentCount: Int
    let coefficients: [Int32]

    var coefficientsPerSegment: Int {
        profile.polynomialDegree + 1
    }

    func state(at julianDay: Double, coefficientScale: Double) throws -> MundaneCelestialState {
        guard segmentCount > 0,
              coefficients.count == segmentCount * coefficientsPerSegment else {
            throw MundaneTimespineError.malformedSeries(profile.body)
        }

        let relative = max(0, julianDay - startJulianDay)
        let rawIndex = Int(floor(relative / profile.segmentDays))
        let segmentIndex = min(max(0, rawIndex), segmentCount - 1)
        let segmentStart = startJulianDay + Double(segmentIndex) * profile.segmentDays
        let u = (julianDay - segmentStart) / profile.segmentDays
        let x = max(-1, min(1, 2 * u - 1))
        let offset = segmentIndex * coefficientsPerSegment

        var c = [Double]()
        c.reserveCapacity(coefficientsPerSegment)
        for index in 0..<coefficientsPerSegment {
            c.append(Double(coefficients[offset + index]) / coefficientScale)
        }

        let unwrappedLongitude = Self.chebyshevValue(coefficients: c, x: x)
        let speedInX = Self.chebyshevDerivative(coefficients: c, x: x)
        let speedPerDay = speedInX * 2 / profile.segmentDays

        guard let longitude = CelestialLongitude(unwrappedLongitude),
              let state = MundaneCelestialState(
                longitude: longitude,
                longitudinalSpeedDegreesPerDay: speedPerDay
              ) else {
            throw MundaneTimespineError.malformedSeries(profile.body)
        }
        return state
    }

    private static func chebyshevValue(coefficients: [Double], x: Double) -> Double {
        guard !coefficients.isEmpty else { return 0 }
        if coefficients.count == 1 { return coefficients[0] }

        var t0 = 1.0
        var t1 = x
        var value = coefficients[0] + coefficients[1] * x

        if coefficients.count > 2 {
            for k in 2..<coefficients.count {
                let tk = 2 * x * t1 - t0
                value += coefficients[k] * tk
                t0 = t1
                t1 = tk
            }
        }
        return value
    }

    private static func chebyshevDerivative(coefficients: [Double], x: Double) -> Double {
        guard coefficients.count > 1 else { return 0 }

        // dT_k/dx = k U_(k-1). Build U directly so the stored polynomial remains
        // the only state authority and no independent velocity coefficients are needed.
        var uPrevious = 1.0
        var derivative = coefficients[1]
        guard coefficients.count > 2 else { return derivative }

        var uCurrent = 2 * x
        derivative += 2 * coefficients[2] * uCurrent

        if coefficients.count > 3 {
            for k in 3..<coefficients.count {
                let uNext = 2 * x * uCurrent - uPrevious
                derivative += Double(k) * coefficients[k] * uNext
                uPrevious = uCurrent
                uCurrent = uNext
            }
        }
        return derivative
    }
}

public struct MundaneTimespine: Sendable {
    public static let codec = 1
    public static let coefficientScale = 1_000_000
    public static let representation = "fixed-point Chebyshev segments"

    public let metadata: MundaneTimespineMetadata
    internal let seriesByBody: [MundaneBody: MundaneTimespineSeries]

    internal init(
        metadata: MundaneTimespineMetadata,
        seriesByBody: [MundaneBody: MundaneTimespineSeries]
    ) throws {
        guard metadata.codec == Self.codec,
              metadata.astroDNACodec == AstroDNA.codec,
              metadata.coefficientScale == Self.coefficientScale,
              metadata.supportedStart.value < metadata.supportedEnd.value,
              metadata.profiles.map(\.body) == MundaneBody.canonicalOrder,
              Set(seriesByBody.keys) == Set(MundaneBody.canonicalOrder) else {
            throw MundaneTimespineError.malformedMetadata
        }
        self.metadata = metadata
        self.seriesByBody = seriesByBody
    }

    public var bodies: [MundaneBody] {
        MundaneBody.canonicalOrder
    }

    public var supportedRangeDescription: String {
        String(format: "%.5f..<%.5f", metadata.supportedStart.value, metadata.supportedEnd.value)
    }

    public func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= metadata.supportedStart.value &&
            julianDay.value < metadata.supportedEnd.value
    }

    public func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneCelestialState {
        guard contains(julianDay) else {
            throw MundaneTimespineError.unsupportedJulianDay(julianDay.value)
        }
        guard let series = seriesByBody[body] else {
            throw MundaneTimespineError.missingBody(body)
        }
        return try series.state(
            at: julianDay.value,
            coefficientScale: Double(metadata.coefficientScale)
        )
    }

    public func encodedArtifact() -> Data {
        MundaneTimespineCodec.encode(self)
    }

    public var checksum: String {
        MundaneTimespineCodec.sha256Hex(encodedArtifact())
    }

    public static func decodeArtifact(_ data: Data) throws -> MundaneTimespine {
        try MundaneTimespineCodec.decode(data)
    }
}
