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

public struct MundaneStation: Hashable, Codable, Sendable {
    public let julianDay: JulianDay
    public let motionAfter: Motion

    public init(julianDay: JulianDay, motionAfter: Motion) {
        self.julianDay = julianDay
        self.motionAfter = motionAfter
    }
}

public struct MundaneMotionChronology: Hashable, Codable, Sendable {
    public let initialMotion: Motion
    public let stations: [MundaneStation]

    public init?(initialMotion: Motion, stations: [MundaneStation]) {
        guard zip(stations, stations.dropFirst()).allSatisfy({ $0.julianDay.value < $1.julianDay.value }) else {
            return nil
        }
        self.initialMotion = initialMotion
        self.stations = stations
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

    init(positionUnits: UInt32) {
        self.positionUnits = positionUnits
    }

    init?(longitude: CelestialLongitude) {
        let scale = Double(MundaneTimespine.positionUnitsPerDegree)
        let circleUnits = Int64(360 * MundaneTimespine.positionUnitsPerDegree)
        var position = Int64((longitude.degrees * scale).rounded()) % circleUnits
        if position < 0 { position += circleUnits }
        guard position >= 0, position <= Int64(UInt32.max) else { return nil }
        self.positionUnits = UInt32(position)
    }

    var longitudeDegrees: Double {
        Double(positionUnits) / Double(MundaneTimespine.positionUnitsPerDegree)
    }
}

internal struct MundaneTimespineRegion: Sendable {
    let startJulianDay: Double
    let endJulianDay: Double
    let sampleDays: Double
    let samples: [MundaneTimespineSample]

    func interpolated(at julianDay: Double) throws -> (longitude: Double, speed: Double) {
        guard startJulianDay <= julianDay,
              julianDay <= endJulianDay,
              sampleDays > 0,
              samples.count >= 2 else {
            throw MundaneTimespineError.malformedMetadata
        }

        let x = (julianDay - startJulianDay) / sampleDays
        let interval = Int(floor(x))
        let pointCount = min(4, samples.count)
        let preferredLead = max(0, pointCount / 2 - 1)
        let firstIndex = min(max(0, interval - preferredLead), samples.count - pointCount)
        let indices = Array(firstIndex..<(firstIndex + pointCount))
        let positions = Self.unwrap(indices.map { samples[$0].longitudeDegrees })

        var value = 0.0
        var derivativeInSampleUnits = 0.0

        for i in 0..<pointCount {
            let xi = Double(indices[i])
            var basis = 1.0
            for j in 0..<pointCount where j != i {
                let xj = Double(indices[j])
                basis *= (x - xj) / (xi - xj)
            }

            var derivativeBasis = 0.0
            for m in 0..<pointCount where m != i {
                let xm = Double(indices[m])
                var term = 1.0 / (xi - xm)
                for j in 0..<pointCount where j != i && j != m {
                    let xj = Double(indices[j])
                    term *= (x - xj) / (xi - xj)
                }
                derivativeBasis += term
            }

            value += positions[i] * basis
            derivativeInSampleUnits += positions[i] * derivativeBasis
        }

        return (value, derivativeInSampleUnits / sampleDays)
    }

    private static func unwrap(_ values: [Double]) -> [Double] {
        guard let first = values.first else { return [] }
        var result = [first]
        result.reserveCapacity(values.count)
        for value in values.dropFirst() {
            let previous = result[result.count - 1]
            let previousCanonical = normalize360(previous)
            result.append(previous + wrap180(value - previousCanonical))
        }
        return result
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

internal struct MundaneTimespineSeries: Sendable {
    let profile: MundaneTimespineProfile
    let motionChronology: MundaneMotionChronology
    let regions: [MundaneTimespineRegion]

    func state(at julianDay: Double) throws -> MundaneCelestialState {
        guard let region = regions.first(where: {
            julianDay >= $0.startJulianDay && julianDay < $0.endJulianDay
        }) else {
            throw MundaneTimespineError.malformedSeries(profile.body)
        }
        let interpolation = try region.interpolated(at: julianDay)
        guard let longitude = CelestialLongitude(interpolation.longitude) else {
            throw MundaneTimespineError.malformedSeries(profile.body)
        }

        let expectedMotion = motion(at: julianDay)
        let magnitude = abs(interpolation.speed)
        let signedSpeed = expectedMotion == .retrograde ? -magnitude : magnitude
        return MundaneCelestialState(
            longitude: longitude,
            longitudinalSpeedDegreesPerDay: signedSpeed
        )!
    }

    private func motion(at julianDay: Double) -> Motion {
        var low = 0
        var high = motionChronology.stations.count
        while low < high {
            let mid = (low + high) / 2
            if motionChronology.stations[mid].julianDay.value <= julianDay {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low == 0 ? motionChronology.initialMotion : motionChronology.stations[low - 1].motionAfter
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
    public static let codec = 3
    public static let positionUnitsPerDegree = 3_600_000
    public static let representation = "separate stamped positions + station chronologies + local cubic reads"

    public let metadata: MundaneTimespineMetadata
    internal let seriesByBody: [MundaneBody: MundaneTimespineSeries]

    internal init(
        metadata: MundaneTimespineMetadata,
        seriesByBody: [MundaneBody: MundaneTimespineSeries]
    ) throws {
        guard metadata.codec == Self.codec,
              metadata.astroDNACodec == AstroDNA.codec,
              metadata.positionUnitsPerDegree == Self.positionUnitsPerDegree,
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
                  series.regions.count == 3,
                  series.motionChronology.stations.allSatisfy({
                      $0.julianDay.value >= metadata.supportedStart.value &&
                      $0.julianDay.value < metadata.supportedEnd.value
                  }) else {
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
