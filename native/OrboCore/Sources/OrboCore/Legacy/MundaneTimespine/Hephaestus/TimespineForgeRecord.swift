import Foundation

/// Structured provenance for one Timespine candidate manufacture.
/// It records how the candidate was made and which Dioscuri resonance contract
/// must prove that exact candidate before Hephaestus may complete it.
public struct TimespineForgeRecord: Hashable, Codable, Sendable {
    public let recipeIdentifier: String
    public let recipeVersion: UInt16
    public let resonanceContract: HephaestusResonanceContractIdentity
    public let spanName: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let storageFamily: String
    public let storageVersion: UInt16
    public let celestialTimeFirst: Bool
    public let bodyCount: Int
    public let bodyOccurrenceCount: Int
    public let stationCount: Int
    public let retrogradePassageCount: Int
    public let relationshipCount: Int
    public let eclipseCount: Int
    public let artifactByteCount: Int
    public let candidateSHA256: String

    init(
        recipeIdentifier: String,
        recipeVersion: UInt16,
        resonanceContract: HephaestusResonanceContractIdentity,
        spanName: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        storageFamily: String,
        storageVersion: UInt16,
        celestialTimeFirst: Bool,
        bodyCount: Int,
        bodyOccurrenceCount: Int,
        stationCount: Int,
        retrogradePassageCount: Int,
        relationshipCount: Int,
        eclipseCount: Int,
        artifactByteCount: Int,
        candidateSHA256: String
    ) {
        self.recipeIdentifier = recipeIdentifier
        self.recipeVersion = recipeVersion
        self.resonanceContract = resonanceContract
        self.spanName = spanName
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.storageFamily = storageFamily
        self.storageVersion = storageVersion
        self.celestialTimeFirst = celestialTimeFirst
        self.bodyCount = bodyCount
        self.bodyOccurrenceCount = bodyOccurrenceCount
        self.stationCount = stationCount
        self.retrogradePassageCount = retrogradePassageCount
        self.relationshipCount = relationshipCount
        self.eclipseCount = eclipseCount
        self.artifactByteCount = artifactByteCount
        self.candidateSHA256 = candidateSHA256
    }

    /// Compatibility initializer for existing native fixtures. Production candidates are minted
    /// by Hephaestus and receive the recipe's explicit bound contract at manufacture time.
    init(
        recipeIdentifier: String,
        recipeVersion: UInt16,
        spanName: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        storageFamily: String,
        storageVersion: UInt16,
        celestialTimeFirst: Bool,
        bodyCount: Int,
        bodyOccurrenceCount: Int,
        stationCount: Int,
        retrogradePassageCount: Int,
        relationshipCount: Int,
        eclipseCount: Int,
        artifactByteCount: Int,
        candidateSHA256: String
    ) {
        self.init(
            recipeIdentifier: recipeIdentifier,
            recipeVersion: recipeVersion,
            resonanceContract: HephaestusResonanceContracts.timespineV1,
            spanName: spanName,
            astronomicalSource: astronomicalSource,
            astronomicalSourceVersion: astronomicalSourceVersion,
            storageFamily: storageFamily,
            storageVersion: storageVersion,
            celestialTimeFirst: celestialTimeFirst,
            bodyCount: bodyCount,
            bodyOccurrenceCount: bodyOccurrenceCount,
            stationCount: stationCount,
            retrogradePassageCount: retrogradePassageCount,
            relationshipCount: relationshipCount,
            eclipseCount: eclipseCount,
            artifactByteCount: artifactByteCount,
            candidateSHA256: candidateSHA256
        )
    }
}
