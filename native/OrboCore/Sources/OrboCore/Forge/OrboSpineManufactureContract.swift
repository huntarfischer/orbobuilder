import Foundation

public enum OrboSpineManufactureError: Error, Equatable, CustomStringConvertible {
    case zeitgeistBoundaryMismatch(Int)

    public var description: String {
        switch self {
        case let .zeitgeistBoundaryMismatch(ordinal):
            return "OrboSpine Z\(ordinal) boundary is not a direct Pluto 0 Aries crossing."
        }
    }
}

/// Canonical Pluto Zeitgeist interval admitted to the shipped OrboSpine forge span.
/// Boundaries come from the finished temporal-shell tables and are half-open.
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

/// Pass C manufacturing law for the universal OrboSpine.
///
/// This contract owns the astronomical authority, the complete three-Z Bone span,
/// the selected Eleven support spacings, and the proven scan cadences used to find
/// crossings and stations. It does not define runtime storage or Dioscuri verdicts.
public enum OrboSpineManufactureContract {
    public static let astronomicalSource =
        "Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT"
    public static let canonicalAstronomicalSourceVersion = "2.10.03"

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

    public static var celestialSupportDegrees: [MundaneBody: Double] {
        OrboSpineContract.celestialSupportDegrees
    }

    /// The four direct Pluto 0 Aries crossings that fence Z21, Z22, and Z23.
    public static var zeitgeistBoundaryJulianDays: [JulianDay] {
        [z21.start, z22.start, z23.start, z23.end]
    }

    /// The final OrboSpine celestial Forge plan. The historical construction-record
    /// count field carried by `MundaneTimespineBodyContract` is deliberately not
    /// authoritative here: Pass C discovers fresh row counts from the frozen support law.
    /// Companion markers are also absent because Ring occurrence truth is manufactured
    /// independently rather than embedded into body rows.
    public static func forgePlan(
        astronomicalSourceVersion: String
    ) -> MundaneTimespineForgePlan {
        MundaneTimespineForgePlan(
            spanName: "OrboSpine Z21-Z23",
            astronomicalSource: astronomicalSource,
            astronomicalSourceVersion: astronomicalSourceVersion,
            supportedStart: supportedStart,
            supportedEnd: supportedEnd,
            bodyPlans: MundaneBody.canonicalOrder.map(bodyPlan(for:)),
            verifiesConstructionRecordCounts: false,
            verifiesMarkerUniqueness: false
        )!
    }

    /// A durable Pass C transaction for one complete celestial tract. Each body keeps the
    /// exact same Z21-Z23 Bone span as the full Forge plan; only the selected tract differs.
    public static func forgePlan(
        for body: MundaneBody,
        astronomicalSourceVersion: String
    ) -> MundaneTimespineForgePlan {
        MundaneTimespineForgePlan(
            spanName: "OrboSpine Z21-Z23 / \(body.displayName)",
            astronomicalSource: astronomicalSource,
            astronomicalSourceVersion: astronomicalSourceVersion,
            supportedStart: supportedStart,
            supportedEnd: supportedEnd,
            bodyPlans: [bodyPlan(for: body)],
            verifiesConstructionRecordCounts: false,
            verifiesMarkerUniqueness: false
        )!
    }

    public static func manufactureCelestialTracts(
        astronomicalSourceVersion: String,
        reference: any ForgeEphemerisReference
    ) throws -> MundaneTimespineForgeProduct {
        try validateZeitgeistBoundaries(reference: reference)
        return try MundaneTimespineForge.manufacture(
            plan: forgePlan(astronomicalSourceVersion: astronomicalSourceVersion),
            reference: reference
        )
    }

    public static func validateZeitgeistBoundaries(
        reference: any ForgeEphemerisReference
    ) throws {
        for (index, julianDay) in zeitgeistBoundaryJulianDays.enumerated() {
            let state = try reference.state(of: .pluto, at: julianDay)
            guard distanceFromZeroAries(state.longitudeDegrees) < 0.0001,
                  state.longitudinalSpeedDegreesPerDay > 0 else {
                let ordinal = 21 + index
                throw OrboSpineManufactureError.zeitgeistBoundaryMismatch(ordinal)
            }
        }
    }

    private static func bodyPlan(for body: MundaneBody) -> MundaneTimespineForgeBodyPlan {
        let contract = MundaneTimespineBodyContract(
            body: body,
            celestialResolutionDegrees: OrboSpineContract.supportDegrees(for: body),
            markerBodies: [],
            constructionRecordCount: 1
        )!
        return MundaneTimespineForgeBodyPlan(
            contract: contract,
            scanStepDays: scanStepDays[body]!
        )!
    }

    private static func distanceFromZeroAries(_ longitude: Double) -> Double {
        min(longitude, 360 - longitude)
    }
}
