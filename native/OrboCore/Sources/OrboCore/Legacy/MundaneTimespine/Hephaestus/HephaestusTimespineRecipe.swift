import Foundation

/// The complete structural payload a recipe requires before Hephaestus may mint a candidate.
/// This is a manufacture contract, not a Dioscuri certification result.
public struct HephaestusTimespineArtifactContract: Hashable, Sendable {
    public let bodyCount: Int
    public let bodyOccurrenceCount: Int
    public let stationCount: Int?
    public let retrogradePassageCount: Int?
    public let relationshipCount: Int
    public let eclipseCount: Int

    public init?(
        bodyCount: Int,
        bodyOccurrenceCount: Int,
        stationCount: Int? = nil,
        retrogradePassageCount: Int? = nil,
        relationshipCount: Int,
        eclipseCount: Int
    ) {
        guard bodyCount > 0,
              bodyOccurrenceCount > 0,
              stationCount.map({ $0 >= 0 }) ?? true,
              retrogradePassageCount.map({ $0 >= 0 }) ?? true,
              relationshipCount >= 0,
              eclipseCount >= 0 else { return nil }
        self.bodyCount = bodyCount
        self.bodyOccurrenceCount = bodyOccurrenceCount
        self.stationCount = stationCount
        self.retrogradePassageCount = retrogradePassageCount
        self.relationshipCount = relationshipCount
        self.eclipseCount = eclipseCount
    }
}

/// A Timespine recipe tells Hephaestus what is being made and which Dioscuri
/// resonance contract must prove that work before Hephaestus may complete it.
///
/// Recipes own product-specific law. Hephaestus owns the fabrication lifecycle.
public protocol HephaestusTimespineRecipe: Sendable {
    static var recipeIdentifier: String { get }
    static var recipeVersion: UInt16 { get }
    static var artifactContract: HephaestusTimespineArtifactContract { get }
    static var resonanceContract: HephaestusResonanceContractIdentity { get }

    static func forgePlan(
        astronomicalSourceVersion: String
    ) -> MundaneTimespineForgePlan

    static func preflight(
        reference: any ForgeEphemerisReference
    ) throws
}

public extension HephaestusTimespineRecipe {
    /// The current house-dish contract. Future Timespine recipes may override this
    /// without requiring any change to Hephaestus's manufacture/completion engine.
    static var resonanceContract: HephaestusResonanceContractIdentity {
        HephaestusResonanceContracts.timespineV1
    }

    static func preflight(reference: any ForgeEphemerisReference) throws {}
}
