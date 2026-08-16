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

    public var artifactFileName: String {
        switch self {
        case .sun: return "sun.orbbody"
        case .moon: return "moon.orbbody"
        case .mercury: return "mercury.orbbody"
        case .venus: return "venus.orbbody"
        case .mars: return "mars.orbbody"
        case .jupiter: return "jupiter.orbbody"
        case .saturn: return "saturn.orbbody"
        case .uranus: return "uranus.orbbody"
        case .neptune: return "neptune.orbbody"
        case .pluto: return "pluto.orbbody"
        case .trueNorthNode: return "true-north-node.orbbody"
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
    public let edgeSampleDays: Double
    public let coreSampleDays: Double

    public init?(body: MundaneBody, edgeSampleDays: Double, coreSampleDays: Double) {
        guard edgeSampleDays.isFinite,
              coreSampleDays.isFinite,
              edgeSampleDays > 0,
              coreSampleDays > 0,
              coreSampleDays <= edgeSampleDays else {
            return nil
        }
        self.body = body
        self.edgeSampleDays = edgeSampleDays
        self.coreSampleDays = coreSampleDays
    }
}

public struct MundaneTimespineMetadata: Hashable, Sendable {
    public let version: String
    public let codec: Int
    public let astroDNACodec: Int
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let denseStart: JulianDay
    public let denseEnd: JulianDay
    public let supportedEnd: JulianDay
    public let positionUnitsPerDegree: Int
    public let speedUnitsPerDegreePerDay: Int
    public let profiles: [MundaneTimespineProfile]

    internal init(
        version: String,
        codec: Int,
        astroDNACodec: Int,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        supportedStart: JulianDay,
        denseStart: JulianDay,
        denseEnd: JulianDay,
        supportedEnd: JulianDay,
        positionUnitsPerDegree: Int,
        speedUnitsPerDegreePerDay: Int,
        profiles: [MundaneTimespineProfile]
    ) {
        self.version = version
        self.codec = codec
        self.astroDNACodec = astroDNACodec
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.supportedStart = supportedStart
        self.denseStart = denseStart
        self.denseEnd = denseEnd
        self.supportedEnd = supportedEnd
        self.positionUnitsPerDegree = positionUnitsPerDegree
        self.speedUnitsPerDegreePerDay = speedUnitsPerDegreePerDay
        self.profiles = profiles
    }
}

public enum MundaneTimespineError: Error, Equatable, Sendable {
    case unsupportedJulianDay(Double)
    case missingBody(MundaneBody)
    case malformedSeries(MundaneBody)
    case malformedMetadata
    case sampleOverflow
    case invalidArtifactMagic
    case unsupportedCodec(Int)
    case truncatedArtifact
    case invalidUTF8
    case invalidManifest
    case checksumMismatch(MundaneBody)
}

internal struct MundaneTimespineSample: Hashable, Sendable {
    let positionUnits: UInt32
    let speedUnitsPerDay: Int32

    init(positionUnits: UInt32, speedUnitsPerDay: Int32) {
        self.positionUnits = positionUnits
        self.speedUnitsPerDay = speedUnitsPerDay
    }

    init?(state: MundaneCelestialState) {
        let positionScale = Double(MundaneTimespine.positionUnitsPerDegree)
        let speedScale = Double(MundaneTimespine.speedUnitsPerDegreePerDay)
        let circleUnits = Int64(360 * MundaneTimespine.positionUnitsPerDegree)

        var position = Int64((state.longitude.degrees * positionScale).rounded()) % circleUnits
        if position < 0 { position += circleUnits }
        let speed = (state.longitudinalSpeedDegreesPerDay * speedScale).rounded()

        guard position >= 0,
              position <= Int64(UInt32.max),
              speed >= Double(Int32.min),
              speed <= Double(Int32.max) else {
            return nil
        }
        self.positionUnits = UInt32(position)
        self.speedUnitsPerDay = Int32(speed)
    }

    func state() -> MundaneCelestialState {
        let longitude = CelestialLongitude(
            Double(positionUnits) / Double(MundaneTimespine.positionUnitsPerDegree)
        )!
        let speed = Double(speedUnitsPerDay) / Double(MundaneTimespine.speedUnitsPerDegreePerDay)
        return MundaneCelestialState(
            longitude: longitude,
            longitudinalSpeedDegreesPerDay: speed
        )!
    }
}

internal struct MundaneTimespineRegion: Sendable {
    let startJulianDay: Double
    let endJulianDay: Double
    let sampleDays: Double
    let samples: [MundaneTimespineSample]

    var intervalCount: Int { samples.count - 1 }

    func state(at julianDay: Double) throws -> MundaneCelestialState {
        guard startJulianDay <= julianDay,
              julianDay <= endJulianDay,
              sampleDays > 0,
              samples.count >= 2 else {
            throw MundaneTimespineError.malformedMetadata
        }

        let rawIndex = Int(floor((julianDay - startJulianDay) / sampleDays))
        let index = min(max(0, rawIndex), intervalCount - 1)
        let t0 = startJulianDay + Double(index) * sampleDays
        let t1 = min(t0 + sampleDays, endJulianDay)
        let h = t1 - t0
        guard h > 0 else { throw MundaneTimespineError.malformedMetadata }

        let left = samples[index].state()
        let right = samples[index + 1].state()
        let u = max(0, min(1, (julianDay - t0) / h))

        let p0 = left.longitude.degrees
        let delta = Self.wrap180(right.longitude.degrees - p0)
        let p1 = p0 + delta
        let v0 = left.longitudinalSpeedDegreesPerDay
        let v1 = right.longitudinalSpeedDegreesPerDay

        let u2 = u * u
        let u3 = u2 * u
        let h00 = 2 * u3 - 3 * u2 + 1
        let h10 = u3 - 2 * u2 + u
        let h01 = -2 * u3 + 3 * u2
        let h11 = u3 - u2
        let unwrappedLongitude = h00 * p0 + h10 * h * v0 + h01 * p1 + h11 * h * v1

        let dh00 = 6 * u2 - 6 * u
        let dh10 = 3 * u2 - 4 * u + 1
        let dh01 = -6 * u2 + 6 * u
        let dh11 = 3 * u2 - 2 * u
        let derivativeU = dh00 * p0 + dh10 * h * v0 + dh01 * p1 + dh11 * h * v1
        let speed = derivativeU / h

        guard let longitude = CelestialLongitude(unwrappedLongitude),
              let state = MundaneCelestialState(
                longitude: longitude,
                longitudinalSpeedDegreesPerDay: speed
              ) else {
            throw MundaneTimespineError.malformedMetadata
        }
        return state
    }

    private static func wrap180(_ value: Double) -> Double {
        var result = (value + 180).truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result - 180
    }
}

internal struct MundaneTimespineSeries: Sendable {
    let profile: MundaneTimespineProfile
    let regions: [MundaneTimespineRegion]

    func state(at julianDay: Double) throws -> MundaneCelestialState {
        guard let region = regions.first(where: {
            julianDay >= $0.startJulianDay && julianDay < $0.endJulianDay
        }) else {
            throw MundaneTimespineError.malformedSeries(profile.body)
        }
        return try region.state(at: julianDay)
    }
}

public struct MundaneTimespineArtifactSet: Sendable {
    public let manifest: Data
    public let bodyArtifacts: [MundaneBody: Data]
    public let manifestChecksum: String

    public var totalBytes: Int {
        manifest.count + bodyArtifacts.values.reduce(0) { $0 + $1.count }
    }

    public func data(for body: MundaneBody) -> Data? {
        bodyArtifacts[body]
    }
}

public struct MundaneTimespine: Sendable {
    public static let codec = 2
    public static let positionUnitsPerDegree = 3_600_000
    public static let speedUnitsPerDegreePerDay = 3_600_000
    public static let representation = "separate stamped body knots + cubic Hermite reads"

    public let metadata: MundaneTimespineMetadata
    internal let seriesByBody: [MundaneBody: MundaneTimespineSeries]

    internal init(
        metadata: MundaneTimespineMetadata,
        seriesByBody: [MundaneBody: MundaneTimespineSeries]
    ) throws {
        guard metadata.codec == Self.codec,
              metadata.astroDNACodec == AstroDNA.codec,
              metadata.positionUnitsPerDegree == Self.positionUnitsPerDegree,
              metadata.speedUnitsPerDegreePerDay == Self.speedUnitsPerDegreePerDay,
              metadata.supportedStart.value < metadata.denseStart.value,
              metadata.denseStart.value < metadata.denseEnd.value,
              metadata.denseEnd.value < metadata.supportedEnd.value,
              metadata.profiles.map(\.body) == MundaneBody.canonicalOrder,
              Set(seriesByBody.keys) == Set(MundaneBody.canonicalOrder) else {
            throw MundaneTimespineError.malformedMetadata
        }

        for body in MundaneBody.canonicalOrder {
            guard let series = seriesByBody[body],
                  series.profile.body == body,
                  series.regions.count == 3 else {
                throw MundaneTimespineError.malformedSeries(body)
            }
        }

        self.metadata = metadata
        self.seriesByBody = seriesByBody
    }

    public var bodies: [MundaneBody] { MundaneBody.canonicalOrder }

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
        return try series.state(at: julianDay.value)
    }

    public func encodedArtifacts() -> MundaneTimespineArtifactSet {
        MundaneTimespineCodec.encode(self)
    }

    public var checksum: String {
        encodedArtifacts().manifestChecksum
    }

    public static func decodeArtifacts(
        manifest: Data,
        bodyArtifacts: [MundaneBody: Data]
    ) throws -> MundaneTimespine {
        try MundaneTimespineCodec.decode(manifest: manifest, bodyArtifacts: bodyArtifacts)
    }
}
