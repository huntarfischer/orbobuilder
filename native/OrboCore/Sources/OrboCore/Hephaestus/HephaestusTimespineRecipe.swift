import Foundation

/// The complete structural payload a recipe requires before Hephaestus may mint a candidate.
/// This is a manufacture contract, not a Dioscuri certification result.
public struct HephaestusTimespineArtifactContract: Hashable, Sendable {
    public let bodyCount: Int
    public let bodyOccurrenceCount: Int
    public let relationshipCount: Int
    public let eclipseCount: Int

    public init?(
        bodyCount: Int,
        bodyOccurrenceCount: Int,
        relationshipCount: Int,
        eclipseCount: Int
    ) {
        guard bodyCount > 0,
              bodyOccurrenceCount > 0,
              relationshipCount >= 0,
              eclipseCount >= 0 else { return nil }
        self.bodyCount = bodyCount
        self.bodyOccurrenceCount = bodyOccurrenceCount
        self.relationshipCount = relationshipCount
        self.eclipseCount = eclipseCount
    }
}

/// A Timespine recipe tells Hephaestus what is being made while leaving generic
/// celestial manufacture to MundaneTimespineForge.
///
/// Recipes own span-specific preflight law. Hephaestus owns the manufacturing transaction.
public protocol HephaestusTimespineRecipe: Sendable {
    static var recipeIdentifier: String { get }
    static var recipeVersion: UInt16 { get }
    static var artifactContract: HephaestusTimespineArtifactContract { get }

    static func forgePlan(
        astronomicalSourceVersion: String
    ) -> MundaneTimespineForgePlan

    static func preflight(
        reference: any ForgeEphemerisReference
    ) throws
}

public extension HephaestusTimespineRecipe {
    static func preflight(reference: any ForgeEphemerisReference) throws {}
}
