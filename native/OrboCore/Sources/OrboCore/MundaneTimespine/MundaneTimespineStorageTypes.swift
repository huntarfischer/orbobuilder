import Foundation

/// Native shipping representation identifier for the Mundane Timespine.
/// This owns its own storage version and does not reuse AstroDNA's identity version.
public enum MundaneTimespineStorageFormat {
    public static let version: UInt16 = 1
    public static let celestialTimeFirst = true
    public static let microdegreesPerDegree: UInt64 = 1_000_000
    public static let circleMicrodegrees: UInt64 = 360 * microdegreesPerDegree
    static let magic = Array("ORBOTS01".utf8)
}

public enum MundaneTimespineStorageError: Error, Equatable, CustomStringConvertible {
    case malformedImage
    case malformedArtifact
    case unsupportedVersion(UInt16)
    case celestialTimeLawMissing
    case sectionMissing(String)
    case duplicateSection
    case invalidBody(UInt8)
    case invalidRingMark(UInt8)
    case invalidOrientation(UInt8)
    case invalidEclipseKind(UInt8)
    case invalidEclipseType(UInt8)
    case invalidCentrality(UInt8)
    case integerOverflow
    case truncated

    public var description: String {
        switch self {
        case .malformedImage: return "Mundane Timespine storage image is malformed."
        case .malformedArtifact: return "Mundane Timespine artifact is malformed."
        case let .unsupportedVersion(version): return "Unsupported Mundane Timespine storage version \(version)."
        case .celestialTimeLawMissing: return "Mundane Timespine artifact does not declare celestial-time-first storage."
        case let .sectionMissing(name): return "Mundane Timespine artifact is missing \(name)."
        case .duplicateSection: return "Mundane Timespine artifact repeats a section identity."
        case let .invalidBody(raw): return "Mundane Timespine artifact contains invalid body id \(raw)."
        case let .invalidRingMark(raw): return "Mundane Timespine artifact contains invalid Ring mark \(raw)."
        case let .invalidOrientation(raw): return "Mundane Timespine artifact contains invalid relationship orientation \(raw)."
        case let .invalidEclipseKind(raw): return "Mundane Timespine artifact contains invalid eclipse kind \(raw)."
        case let .invalidEclipseType(raw): return "Mundane Timespine artifact contains invalid eclipse type \(raw)."
        case let .invalidCentrality(raw): return "Mundane Timespine artifact contains invalid eclipse centrality \(raw)."
        case .integerOverflow: return "Mundane Timespine artifact integer exceeds native storage bounds."
        case .truncated: return "Mundane Timespine artifact ends before a declared field or section."
        }
    }
}

public struct MundaneTimespineStoredOccurrence: Hashable, Sendable {
    public let celestialTick: Int
    public let civicOffsetSeconds: Int64
    public let sequenceDirection: MundaneCelestialSequenceDirection
    public let markerWholeDegrees: [UInt16]
}

public struct MundaneTimespineStoredStation: Hashable, Sendable {
    public let celestialMicrodegrees: UInt32
    public let civicOffsetSeconds: Int64
    public let motionAfter: Motion
}

public struct MundaneTimespineStoredRetrogradePassage: Hashable, Sendable {
    public let startCelestialMicrodegrees: UInt32
    public let endCelestialMicrodegrees: UInt32
    public let startCivicOffsetSeconds: Int64
    public let endCivicOffsetSeconds: Int64
}

public struct MundaneTimespineStoredBody: Sendable {
    public let body: MundaneBody
    public let ticksPerDegree: Int
    public let markerBodies: [MundaneBody]
    public let occurrences: [MundaneTimespineStoredOccurrence]
    public let stations: [MundaneTimespineStoredStation]
    public let retrogradePassages: [MundaneTimespineStoredRetrogradePassage]

    public init?(
        body: MundaneBody,
        ticksPerDegree: Int,
        markerBodies: [MundaneBody],
        occurrences: [MundaneTimespineStoredOccurrence],
        stations: [MundaneTimespineStoredStation],
        retrogradePassages: [MundaneTimespineStoredRetrogradePassage]
    ) {
        guard ticksPerDegree > 0,
              !occurrences.isEmpty,
              !markerBodies.contains(body),
              Set(markerBodies).count == markerBodies.count else { return nil }
        let circleTicks = 360 * ticksPerDegree
        guard occurrences.allSatisfy({
            (0..<circleTicks).contains($0.celestialTick)
                && $0.markerWholeDegrees.count == markerBodies.count
                && $0.markerWholeDegrees.allSatisfy { $0 < 360 }
        }),
        stations.allSatisfy({ $0.celestialMicrodegrees < MundaneTimespineStorageFormat.circleMicrodegrees }),
        retrogradePassages.allSatisfy({
            $0.startCelestialMicrodegrees < MundaneTimespineStorageFormat.circleMicrodegrees
                && $0.endCelestialMicrodegrees < MundaneTimespineStorageFormat.circleMicrodegrees
        }) else { return nil }
        self.body = body
        self.ticksPerDegree = ticksPerDegree
        self.markerBodies = markerBodies
        self.occurrences = occurrences.sorted { $0.civicOffsetSeconds < $1.civicOffsetSeconds }
        self.stations = stations.sorted { $0.civicOffsetSeconds < $1.civicOffsetSeconds }
        self.retrogradePassages = retrogradePassages.sorted { $0.startCivicOffsetSeconds < $1.startCivicOffsetSeconds }
    }

    public var celestialResolutionDegrees: Double { 1 / Double(ticksPerDegree) }
}

/// Rich decoded storage image. This keeps construction-integrity material that the ordinary
/// runtime reader does not need, including companion marker cells and retrograde passages.
public struct MundaneTimespineStorageImage: Sendable {
    public let spanName: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let bodies: [MundaneTimespineStoredBody]
    public let relationships: [MundaneTimespineRelationshipEvent]
    public let eclipses: [MundaneTimespineEclipseEvent]

    public init?(
        spanName: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        bodies: [MundaneTimespineStoredBody],
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) {
        guard !spanName.isEmpty,
              !astronomicalSource.isEmpty,
              !astronomicalSourceVersion.isEmpty,
              supportedStart.value < supportedEnd.value,
              !bodies.isEmpty,
              Set(bodies.map(\.body)).count == bodies.count else { return nil }
        let spanSeconds = Int64(((supportedEnd.value - supportedStart.value) * 86_400).rounded())
        guard bodies.allSatisfy({ body in
            body.occurrences.allSatisfy { (0..<spanSeconds).contains($0.civicOffsetSeconds) }
                && body.stations.allSatisfy { (0..<spanSeconds).contains($0.civicOffsetSeconds) }
                && body.retrogradePassages.allSatisfy {
                    $0.startCivicOffsetSeconds >= 0
                        && $0.startCivicOffsetSeconds < $0.endCivicOffsetSeconds
                        && $0.endCivicOffsetSeconds <= spanSeconds
                }
        }),
        relationships.allSatisfy({
            $0.julianDay.value >= supportedStart.value && $0.julianDay.value < supportedEnd.value
        }),
        eclipses.allSatisfy({
            $0.julianDay.value >= supportedStart.value && $0.julianDay.value < supportedEnd.value
                && ($0.greatestEclipseJulianDay == nil
                    || ($0.greatestEclipseJulianDay!.value >= supportedStart.value
                        && $0.greatestEclipseJulianDay!.value < supportedEnd.value))
        }) else { return nil }
        self.spanName = spanName
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.bodies = bodies.sorted { $0.body.rawValue < $1.body.rawValue }
        self.relationships = relationships.sorted { $0.julianDay.value < $1.julianDay.value }
        self.eclipses = eclipses.sorted { $0.julianDay.value < $1.julianDay.value }
    }
}

extension MundaneTimespineStorageImage {
    /// Native Forge product -> final storage anatomy. Universal relationship/eclipse arrays are
    /// supplied by their own Forge/import mating surface and remain universal, natal-free facts.
    public init?(
        forgeProduct: MundaneTimespineForgeProduct,
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) {
        let bodies = forgeProduct.bodies.compactMap { forged -> MundaneTimespineStoredBody? in
            let ticksPerDegree = Int((1 / forged.celestialResolutionDegrees).rounded())
            guard ticksPerDegree > 0 else { return nil }
            let occurrences = forged.occurrences.map { row in
                MundaneTimespineStoredOccurrence(
                    celestialTick: row.focalCelestialTick,
                    civicOffsetSeconds: row.civicOffsetSeconds,
                    sequenceDirection: row.sequenceDirection,
                    markerWholeDegrees: row.markers.map(\.wholeDegree)
                )
            }
            let stations = forged.stations.map { row in
                MundaneTimespineStoredStation(
                    celestialMicrodegrees: Self.microdegrees(row.celestialTimeDegrees),
                    civicOffsetSeconds: Int64(((row.julianDay.value - forgeProduct.supportedStart.value) * 86_400).rounded()),
                    motionAfter: row.motionAfter
                )
            }
            let passages = forged.retrogradePassages.map { row in
                MundaneTimespineStoredRetrogradePassage(
                    startCelestialMicrodegrees: Self.microdegrees(row.startCelestialTimeDegrees),
                    endCelestialMicrodegrees: Self.microdegrees(row.endCelestialTimeDegrees),
                    startCivicOffsetSeconds: Int64(((row.startJulianDay.value - forgeProduct.supportedStart.value) * 86_400).rounded()),
                    endCivicOffsetSeconds: Int64(((row.endJulianDay.value - forgeProduct.supportedStart.value) * 86_400).rounded())
                )
            }
            return MundaneTimespineStoredBody(
                body: forged.body,
                ticksPerDegree: ticksPerDegree,
                markerBodies: forged.markerBodies,
                occurrences: occurrences,
                stations: stations,
                retrogradePassages: passages
            )
        }
        guard bodies.count == forgeProduct.bodies.count else { return nil }
        self.init(
            spanName: forgeProduct.spanName,
            astronomicalSource: forgeProduct.astronomicalSource,
            astronomicalSourceVersion: forgeProduct.astronomicalSourceVersion,
            supportedStart: forgeProduct.supportedStart,
            supportedEnd: forgeProduct.supportedEnd,
            bodies: bodies,
            relationships: relationships,
            eclipses: eclipses
        )
    }

    public func runtimeImage() -> MundaneTimespineRuntimeImage? {
        let bodySeries = bodies.compactMap { stored -> MundaneTimespineBodySeries? in
            let anchors = stored.occurrences.compactMap { row in
                let jd = JulianDay(supportedStart.value + Double(row.civicOffsetSeconds) / 86_400)!
                return MundaneTimespineCelestialAnchor(
                    celestialTimeDegrees: Double(row.celestialTick) / Double(stored.ticksPerDegree),
                    julianDay: jd,
                    motion: row.sequenceDirection.motion
                )
            }
            let stations = stored.stations.compactMap { row in
                let jd = JulianDay(supportedStart.value + Double(row.civicOffsetSeconds) / 86_400)!
                let before: Motion = row.motionAfter == .direct ? .retrograde : .direct
                return MundaneTimespineStationAnchor(
                    celestialTimeDegrees: Double(row.celestialMicrodegrees) / Double(MundaneTimespineStorageFormat.microdegreesPerDegree),
                    julianDay: jd,
                    motionBefore: before,
                    motionAfter: row.motionAfter
                )
            }
            return MundaneTimespineBodySeries(
                body: stored.body,
                celestialResolutionDegrees: stored.celestialResolutionDegrees,
                anchors: anchors,
                stations: stations
            )
        }
        guard bodySeries.count == bodies.count else { return nil }
        return MundaneTimespineRuntimeImage(
            spanName: spanName,
            supportedStart: supportedStart,
            supportedEnd: supportedEnd,
            bodySeries: bodySeries,
            relationships: relationships,
            eclipses: eclipses
        )
    }

    static func microdegrees(_ degrees: Double) -> UInt32 {
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        let raw = UInt64((normalized * Double(MundaneTimespineStorageFormat.microdegreesPerDegree)).rounded())
            % MundaneTimespineStorageFormat.circleMicrodegrees
        return UInt32(raw)
    }
}
