import Foundation

public enum MundaneTimespineP22ForgeRecipeError: Error, Equatable, CustomStringConvertible {
    case boundaryMismatch

    public var description: String {
        switch self {
        case .boundaryMismatch:
            return "Stored P22/P23 bounds do not validate as direct Pluto 0 Aries crossings."
        }
    }
}

/// P22-specific manufacture recipe.
///
/// Generic Forge manufactures the plan it receives. This recipe alone owns why P22 begins
/// and ends where it does: the two half-open boundaries are direct Pluto 0 Aries crossings.
/// The recipe also owns P22's proven discovery cadences and construction-count checks.
public enum MundaneTimespineP22ForgeRecipe: HephaestusTimespineRecipe {
    public static let astronomicalSource =
        "Swiss Ephemeris; geocentric tropical apparent ecliptic longitude; UT"

    public static var recipeIdentifier: String { "p22-pluto-zeitgeist" }
    public static var recipeVersion: UInt16 { 1 }

    public static var artifactContract: HephaestusTimespineArtifactContract {
        let eclipseCount = MundaneTimespineP22
            .universalEventTable(for: .eclipse)
            .constructionRecordCount
        return HephaestusTimespineArtifactContract(
            bodyCount: MundaneTimespineP22.profiles.count,
            bodyOccurrenceCount: MundaneTimespineP22.totalConstructionRecords,
            relationshipCount: MundaneTimespineP22.totalUniversalEventRecords - eclipseCount,
            eclipseCount: eclipseCount
        )!
    }

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

    public static func plan(astronomicalSourceVersion: String) -> MundaneTimespineForgePlan {
        let bodyPlans = MundaneTimespineP22.profiles.map { contract in
            MundaneTimespineForgeBodyPlan(
                contract: contract,
                scanStepDays: scanStepDays[contract.body]!
            )!
        }
        return MundaneTimespineForgePlan(
            spanName: MundaneTimespineP22.spanName,
            astronomicalSource: astronomicalSource,
            astronomicalSourceVersion: astronomicalSourceVersion,
            supportedStart: MundaneTimespineP22.startJulianDay,
            supportedEnd: MundaneTimespineP22.endJulianDay,
            bodyPlans: bodyPlans,
            verifiesConstructionRecordCounts: true,
            verifiesMarkerUniqueness: true
        )!
    }

    public static func forgePlan(
        astronomicalSourceVersion: String
    ) -> MundaneTimespineForgePlan {
        plan(astronomicalSourceVersion: astronomicalSourceVersion)
    }

    public static func preflight(
        reference: any ForgeEphemerisReference
    ) throws {
        try validateBoundaries(reference: reference)
    }

    public static func validateBoundaries(
        reference: any ForgeEphemerisReference
    ) throws {
        let start = try reference.state(of: .pluto, at: MundaneTimespineP22.startJulianDay)
        let end = try reference.state(of: .pluto, at: MundaneTimespineP22.endJulianDay)

        guard distanceFromZeroAries(start.longitudeDegrees) < 0.0001,
              start.longitudinalSpeedDegreesPerDay > 0,
              distanceFromZeroAries(end.longitudeDegrees) < 0.0001,
              end.longitudinalSpeedDegreesPerDay > 0 else {
            throw MundaneTimespineP22ForgeRecipeError.boundaryMismatch
        }
    }

    public static func manufacture(
        astronomicalSourceVersion: String,
        reference: any ForgeEphemerisReference
    ) throws -> MundaneTimespineForgeProduct {
        try validateBoundaries(reference: reference)
        return try MundaneTimespineForge.manufacture(
            plan: plan(astronomicalSourceVersion: astronomicalSourceVersion),
            reference: reference
        )
    }

    private static func distanceFromZeroAries(_ longitude: Double) -> Double {
        min(longitude, 360 - longitude)
    }
}
