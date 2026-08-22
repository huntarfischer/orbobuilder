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

/// Transitional compatibility projection for older Pass 5 callers.
/// The authoritative manufacture instructions now live in `OrboSpineSchematic`.
public enum OrboSpineManufactureContract {
    public static let astronomicalSource = OrboSpineSchematic.astronomicalAuthority
    public static let canonicalAstronomicalSourceVersion = OrboSpineSchematic.astronomicalSourceVersion

    public static let z21 = OrboSpineSchematic.z21
    public static let z22 = OrboSpineSchematic.z22
    public static let z23 = OrboSpineSchematic.z23
    public static let zeitgeists = OrboSpineSchematic.zeitgeists
    public static let supportedStart = OrboSpineSchematic.supportedStart
    public static let supportedEnd = OrboSpineSchematic.supportedEnd
    public static let scanStepDays = OrboSpineSchematic.scanStepDays

    public static var celestialSupportDegrees: [MundaneBody: Double] {
        Dictionary(uniqueKeysWithValues: OrboSpineSchematic.current.bodyPlans.map {
            ($0.body, $0.supportDegrees)
        })
    }

    public static var zeitgeistBoundaryJulianDays: [JulianDay] {
        OrboSpineSchematic.current.boundaryChecks.map(\.julianDay)
    }

    public static func forgePlan(
        astronomicalSourceVersion: String
    ) -> MundaneTimespineForgePlan {
        MundaneTimespineForgePlan(
            spanName: "OrboSpine Z21-Z23",
            astronomicalSource: astronomicalSource,
            astronomicalSourceVersion: astronomicalSourceVersion,
            supportedStart: supportedStart,
            supportedEnd: supportedEnd,
            bodyPlans: MundaneBody.canonicalOrder.map { bodyPlan(for: $0) },
            verifiesConstructionRecordCounts: false,
            verifiesMarkerUniqueness: false
        )!
    }

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
        for (index, check) in OrboSpineSchematic.current.boundaryChecks.enumerated() {
            let state = try reference.state(of: check.body, at: check.julianDay)
            let rawDistance = abs(normalize(state.longitudeDegrees) - check.physicalDegrees)
            let distance = min(rawDistance, 360 - rawDistance)
            let motionMatches: Bool
            switch check.motion {
            case .direct:
                motionMatches = state.longitudinalSpeedDegreesPerDay > 0
            case .retrograde:
                motionMatches = state.longitudinalSpeedDegreesPerDay < 0
            }
            guard distance < check.toleranceDegrees, motionMatches else {
                throw OrboSpineManufactureError.zeitgeistBoundaryMismatch(21 + index)
            }
        }
    }

    private static func bodyPlan(for body: MundaneBody) -> MundaneTimespineForgeBodyPlan {
        let schematicPlan = OrboSpineSchematic.current.bodyPlan(for: body)!
        let contract = MundaneTimespineBodyContract(
            body: body,
            celestialResolutionDegrees: schematicPlan.supportDegrees,
            markerBodies: [],
            constructionRecordCount: 1
        )!
        return MundaneTimespineForgeBodyPlan(
            contract: contract,
            scanStepDays: schematicPlan.scanStepDays
        )!
    }

    private static func normalize(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }
}
