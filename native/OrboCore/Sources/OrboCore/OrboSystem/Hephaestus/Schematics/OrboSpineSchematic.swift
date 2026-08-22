import Foundation

/// Canonical Pluto Zeitgeist interval carried by the OrboSpine schematic.
public struct OrboSpineZeitgeistSpan: Hashable, Sendable {
    public let shell: OrboSpineShellID
    public let start: JulianDay
    public let end: JulianDay
    public let startUTC: String
    public let endUTC: String

    public init?(
        ordinal: Int,
        start: JulianDay,
        end: JulianDay,
        startUTC: String,
        endUTC: String
    ) {
        guard let shell = OrboSpineShellID(family: .zeitgeist, ordinal: ordinal),
              start.value < end.value,
              !startUTC.isEmpty,
              !endUTC.isEmpty else { return nil }
        self.shell = shell
        self.start = start
        self.end = end
        self.startUTC = startUTC
        self.endUTC = endUTC
    }
}

/// The v1 celestial manufacture schematic for the universal OrboSpine.
public enum OrboSpineSchematic {
    public static let identity = OrboSpineContract.identity
    public static let version: UInt16 = 1
    public static let astronomicalAuthority =
        "Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT"
    public static let astronomicalSourceVersion = "2.10.03"

    public static let z21 = OrboSpineZeitgeistSpan(
        ordinal: 21,
        start: JulianDay(2_297_171.740867775)!,
        end: JulianDay(2_386_637.0793997087)!,
        startUTC: "1577-05-05T05:46:50.976Z",
        endUTC: "1822-04-16T13:54:20.135Z"
    )!

    public static let z22 = OrboSpineZeitgeistSpan(
        ordinal: 22,
        start: JulianDay(2_386_637.0793997087)!,
        end: JulianDay(2_475_819.1417904533)!,
        startUTC: "1822-04-16T13:54:20.135Z",
        endUTC: "2066-06-17T15:24:10.695Z"
    )!

    public static let z23 = OrboSpineZeitgeistSpan(
        ordinal: 23,
        start: JulianDay(2_475_819.1417904533)!,
        end: JulianDay(2_565_295.0945935287)!,
        startUTC: "2066-06-17T15:24:10.695Z",
        endUTC: "2311-06-10T14:16:12.881Z"
    )!

    public static let zeitgeists = [z21, z22, z23]
    public static let supportedStart = z21.start
    public static let supportedEnd = z23.end

    public static let scanStepDays: [MundaneBody: Double] = [
        .sun: 0.20,
        .moon: 0.05,
        .mercury: 0.10,
        .venus: 0.20,
        .mars: 0.25,
        .jupiter: 0.25,
        .saturn: 0.50,
        .uranus: 1.0,
        .neptune: 1.0,
        .pluto: 1.0,
        .trueNorthNode: 0.10,
    ]

    public static let current: SpineSchematic = {
        let bone = OrboSpineBoneSpan(start: supportedStart, end: supportedEnd)!
        let bodyPlans = MundaneBody.canonicalOrder.map { body in
            SpineSchematicBodyPlan(
                body: body,
                supportDegrees: OrboSpineContract.supportDegrees(for: body),
                scanStepDays: scanStepDays[body]!
            )!
        }
        let fences = [z21.start, z22.start, z23.start, z23.end].map { julianDay in
            SpineSchematicBoundaryCheck(
                body: .pluto,
                physicalDegrees: 0,
                motion: .direct,
                julianDay: julianDay,
                toleranceDegrees: 0.0001
            )!
        }
        return SpineSchematic(
            identity: identity,
            version: version,
            bone: bone,
            astronomicalAuthority: astronomicalAuthority,
            astronomicalSourceVersion: astronomicalSourceVersion,
            bodyPlans: bodyPlans,
            boundaryChecks: fences
        )!
    }()
}
