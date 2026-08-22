import Foundation

/// Final Pass 5 type contract for the universal Mundane Timespine shipped with every Orbo.
/// Historical P22 substrate types remain audit evidence; this is the authoritative OrboSpine law.
public enum OrboSpineContract {
    public static let identity = "OrboSpine"
    public static let canonicalBodies = MundaneBody.canonicalOrder
    public static let terraSupportIntervalSeconds = 6 * 60 * 60

    public static let celestialSupportDegrees: [MundaneBody: Double] = [
        .sun: 10,
        .moon: 10,
        .mercury: 1,
        .venus: 1,
        .mars: 1,
        .jupiter: 0.5,
        .saturn: 0.5,
        .uranus: 0.2,
        .neptune: 0.1,
        .pluto: 0.1,
        .trueNorthNode: 0.1,
    ]

    public static func supportDegrees(for body: MundaneBody) -> Double {
        celestialSupportDegrees[body]!
    }
}

/// Continuous directional zodiac coordinate used by OrboSpine celestial tracts.
/// [0,360) is direct/increasing; [360,720) is retrograde/decreasing.
public struct OrboSpineDirectionalDegree: Hashable, Codable, Sendable {
    public let degrees: Double

    public init?(_ degrees: Double) {
        guard degrees.isFinite, degrees >= 0, degrees < 720 else { return nil }
        self.degrees = degrees
    }

    public init?(physicalDegrees: Double, motion: Motion) {
        guard physicalDegrees.isFinite, physicalDegrees >= 0, physicalDegrees < 360 else { return nil }
        self.degrees = physicalDegrees + (motion == .retrograde ? 360 : 0)
    }

    public var physicalDegrees: Double {
        degrees >= 360 ? degrees - 360 : degrees
    }

    public var motion: Motion {
        degrees >= 360 ? .retrograde : .direct
    }

    public var navigationCell: Int {
        Int(degrees.rounded(.down))
    }
}

/// One exact point on one canonical celestial tract at one UT.
public struct OrboSpineCelestialCoordinate: Hashable, Sendable {
    public let body: MundaneBody
    public let directionalDegree: OrboSpineDirectionalDegree
    public let julianDay: JulianDay

    public init(body: MundaneBody, directionalDegree: OrboSpineDirectionalDegree, julianDay: JulianDay) {
        self.body = body
        self.directionalDegree = directionalDegree
        self.julianDay = julianDay
    }
}

public typealias OrboSpineOccurrence = OrboSpineCelestialCoordinate

/// Half-open span on the monotonic UT Bone.
public struct OrboSpineBoneSpan: Hashable, Sendable {
    public let start: JulianDay
    public let end: JulianDay

    public init?(start: JulianDay, end: JulianDay) {
        guard start.value < end.value else { return nil }
        self.start = start
        self.end = end
    }

    public func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= start.value && julianDay.value < end.value
    }
}

/// A station is an exact zero-speed topology boundary. Its directional coordinate belongs
/// to the lane entered after the station.
public struct OrboSpineStation: Hashable, Sendable {
    public let body: MundaneBody
    public let physicalDegrees: Double
    public let julianDay: JulianDay
    public let laneBefore: Motion
    public let laneAfter: Motion

    public init?(
        body: MundaneBody,
        physicalDegrees: Double,
        julianDay: JulianDay,
        laneBefore: Motion,
        laneAfter: Motion
    ) {
        guard physicalDegrees.isFinite,
              physicalDegrees >= 0,
              physicalDegrees < 360,
              laneBefore != laneAfter else { return nil }
        self.body = body
        self.physicalDegrees = physicalDegrees
        self.julianDay = julianDay
        self.laneBefore = laneBefore
        self.laneAfter = laneAfter
    }

    public var directionalDegreeAfter: OrboSpineDirectionalDegree {
        OrboSpineDirectionalDegree(physicalDegrees: physicalDegrees, motion: laneAfter)!
    }

    public var navigationCellAfter: Int {
        directionalDegreeAfter.navigationCell
    }
}

/// A station-bounded navigation reach. It is a view of tract topology, not an independent
/// astronomical truth owner.
public struct OrboSpineReach: Hashable, Sendable {
    public let body: MundaneBody
    public let startDirectionalDegree: OrboSpineDirectionalDegree
    public let endDirectionalDegree: OrboSpineDirectionalDegree
    public let start: JulianDay
    public let end: JulianDay

    public init?(
        body: MundaneBody,
        startDirectionalDegree: OrboSpineDirectionalDegree,
        endDirectionalDegree: OrboSpineDirectionalDegree,
        start: JulianDay,
        end: JulianDay
    ) {
        guard start.value < end.value,
              startDirectionalDegree.motion == endDirectionalDegree.motion else { return nil }
        self.body = body
        self.startDirectionalDegree = startDirectionalDegree
        self.endDirectionalDegree = endDirectionalDegree
        self.start = start
        self.end = end
    }

    public var motion: Motion { startDirectionalDegree.motion }

    public func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= start.value && julianDay.value < end.value
    }
}

public enum TerraMarrowRefinementLaw: String, Codable, Hashable, Sendable {
    case linear
}

/// One forged support point of Earth's universal orientation carried inside the Bone.
public struct TerraMarrowSample: Hashable, Sendable {
    public let turnDegrees: Double
    public let tiltDegrees: Double
    public let julianDay: JulianDay

    public init?(turnDegrees: Double, tiltDegrees: Double, julianDay: JulianDay) {
        guard turnDegrees.isFinite,
              turnDegrees >= 0,
              turnDegrees < 360,
              tiltDegrees.isFinite,
              tiltDegrees > 0,
              tiltDegrees < 90 else { return nil }
        self.turnDegrees = turnDegrees
        self.tiltDegrees = tiltDegrees
        self.julianDay = julianDay
    }
}

public enum TerraMarrowContract {
    public static let supportIntervalSeconds = OrboSpineContract.terraSupportIntervalSeconds
    public static let refinementLaw = TerraMarrowRefinementLaw.linear
    public static let sourceModelSeamYears = [1850, 2050]
}

/// Exact lateral Ring occurrence. Ring owns angular geometry; OrboSpine owns only the
/// occurrence seam needed to store and navigate the event.
public struct OrboSpineRingOccurrence: Hashable, Sendable {
    public let bodyA: MundaneBody
    public let bodyB: MundaneBody
    public let mark: RingMark
    public let bodyADirectionalDegree: OrboSpineDirectionalDegree
    public let bodyBDirectionalDegree: OrboSpineDirectionalDegree
    public let julianDay: JulianDay

    public init?(
        bodyA: MundaneBody,
        bodyB: MundaneBody,
        mark: RingMark,
        bodyADirectionalDegree: OrboSpineDirectionalDegree,
        bodyBDirectionalDegree: OrboSpineDirectionalDegree,
        julianDay: JulianDay
    ) {
        guard bodyA != bodyB else { return nil }
        self.bodyA = bodyA
        self.bodyB = bodyB
        self.mark = mark
        self.bodyADirectionalDegree = bodyADirectionalDegree
        self.bodyBDirectionalDegree = bodyBDirectionalDegree
        self.julianDay = julianDay
    }
}

public enum OrboSpineShellFamily: String, CaseIterable, Codable, Hashable, Sendable {
    case frame = "F"
    case revolt = "R"
    case wave = "W"
    case zeitgeist = "Z"
}

public struct OrboSpineShellID: Hashable, Codable, Sendable, CustomStringConvertible {
    public let family: OrboSpineShellFamily
    public let ordinal: Int

    public init?(family: OrboSpineShellFamily, ordinal: Int) {
        guard ordinal >= 0 else { return nil }
        self.family = family
        self.ordinal = ordinal
    }

    public var description: String { "\(family.rawValue)\(ordinal)" }
}

/// One half-open canonical shell interval. Shell families own their own boundaries.
public struct OrboSpineShellInterval: Hashable, Sendable {
    public let id: OrboSpineShellID
    public let start: JulianDay
    public let end: JulianDay

    public init?(id: OrboSpineShellID, start: JulianDay, end: JulianDay) {
        guard start.value < end.value else { return nil }
        self.id = id
        self.start = start
        self.end = end
    }

    public func contains(_ julianDay: JulianDay) -> Bool {
        julianDay.value >= start.value && julianDay.value < end.value
    }
}

public struct OrboSpineShellAddress: Hashable, Sendable, CustomStringConvertible {
    public let frame: OrboSpineShellID
    public let revolt: OrboSpineShellID
    public let wave: OrboSpineShellID
    public let zeitgeist: OrboSpineShellID

    public init?(
        frame: OrboSpineShellID,
        revolt: OrboSpineShellID,
        wave: OrboSpineShellID,
        zeitgeist: OrboSpineShellID
    ) {
        guard frame.family == .frame,
              revolt.family == .revolt,
              wave.family == .wave,
              zeitgeist.family == .zeitgeist else { return nil }
        self.frame = frame
        self.revolt = revolt
        self.wave = wave
        self.zeitgeist = zeitgeist
    }

    public var description: String {
        "\(frame).\(revolt).\(wave).\(zeitgeist)"
    }
}

/// Separate identity namespace for later celestial additions. These identities do not
/// broaden MundaneBody and do not imply Ring membership.
public struct OrboSpineAuxiliaryFactorID: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }

    public static let trueBlackMoonLilith = OrboSpineAuxiliaryFactorID(rawValue: "true-black-moon-lilith")!
    public static let chiron = OrboSpineAuxiliaryFactorID(rawValue: "chiron")!
}

/// Intended first contents of the Celestial Seam. D0 defines intent only; it does not forge the Smeld.
public enum OrboSpineCelestialSmeldIntent {
    public static let firstSmeld: [OrboSpineAuxiliaryFactorID] = [
        .trueBlackMoonLilith,
        .chiron,
    ]
}

/// Universal reasons to tap any Spine. These are access identities only; behavior belongs downstream.
public enum SpineAccessPort: String, CaseIterable, Codable, Hashable, Sendable {
    case locate
    case library
    case link
}

/// The same three stable doors are exposed by every Spine.
public struct SpinePorts: Hashable, Sendable {
    public let locate: SpineAccessPort
    public let library: SpineAccessPort
    public let link: SpineAccessPort

    public init() {
        self.locate = .locate
        self.library = .library
        self.link = .link
    }
}

public typealias OrboSpinePorts = SpinePorts

/// The two controlled extension seams of a sealed Spine.
public enum SpineSmeldSeam: String, CaseIterable, Codable, Hashable, Sendable {
    case celestial
    case stack
}

/// Identity of one sealed Spine Smeld eligible to mount at a Spine seam.
/// D0 does not implement forging, certification, sealing, or mounting behavior.
public struct SpineSmeld: Hashable, Codable, Sendable {
    public let identity: String

    public init?(identity: String) {
        let trimmed = identity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.identity = trimmed
    }
}

/// Shape alone enforces zero-or-one mounted Smeld per seam. Growth requires replacement,
/// never accumulation of multiple Smelds at the same seam.
public struct SpineSmeldSeams: Hashable, Sendable {
    public let celestial: SpineSmeld?
    public let stack: SpineSmeld?

    public init(celestial: SpineSmeld? = nil, stack: SpineSmeld? = nil) {
        self.celestial = celestial
        self.stack = stack
    }
}

/// Admission law for any Spine Smeld. The actual lifecycle remains owned by Hephaestus
/// and the Dioscuri; this contract only freezes the seam requirements.
public enum SpineSmeldContract {
    public static let maximumMountedPerSeam = 1
    public static let forgeAuthority = "Hephaestus"
    public static let certificationAuthority = "Dioscuri"
    public static let sealAuthority = "Hephaestus"
    public static let requiresSealBeforeMount = true
    public static let replacementLaw = "reforge-and-replace"
}

/// Type-level forge/certification boundaries. Actual manufacture and adjudication remain
/// with Hephaestus and the Dioscuri in later Pass 5 stages.
public enum OrboSpineLifecycleBoundary: String, CaseIterable, Codable, Hashable, Sendable {
    case candidate
    case dioscuriCertified = "dioscuri-certified"
    case hephaestusSealed = "hephaestus-sealed"
    case maintenanceResonance = "maintenance-resonance"
}

public enum OrboSpineResonanceDisposition: String, CaseIterable, Codable, Hashable, Sendable {
    case resonance
    case safeNonResonance = "safe-non-resonance"
    case falseResonance = "false-resonance"
}
