import Foundation

public enum HephaestusError: Error, Equatable, CustomStringConvertible {
    case invalidRecipeIdentity
    case invalidAstronomicalSourceVersion
    case artifactContractMismatch(component: String, expected: Int, actual: Int)
    case storageAssemblyFailed
    case artifactRoundTripMismatch
    case provenanceMismatch

    public var description: String {
        switch self {
        case .invalidRecipeIdentity:
            return "Hephaestus recipe identity/version is invalid."
        case .invalidAstronomicalSourceVersion:
            return "Hephaestus requires a non-empty astronomical source version."
        case let .artifactContractMismatch(component, expected, actual):
            return "Hephaestus artifact contract mismatch for \(component): expected \(expected), got \(actual)."
        case .storageAssemblyFailed:
            return "Hephaestus could not assemble a valid Timespine storage image."
        case .artifactRoundTripMismatch:
            return "Hephaestus ORBOTS encode/decode round trip changed artifact bytes."
        case .provenanceMismatch:
            return "Hephaestus decoded artifact provenance does not match the Forge product."
        }
    }
}

/// Native manufacturing authority for Timespine candidates.
///
/// Hephaestus supervises recipe preflight, generic Forge manufacture, final storage assembly,
/// deterministic ORBOTS packaging, structural round-trip verification, and candidate identity.
/// Hephaestus does not certify celestial/civic agreement; that belongs to the Dioscuri.
public enum Hephaestus {
    public static let celestialTimeFirst = true
    public static let candidateIdentityAlgorithm = "SHA-256"
    public static let runtimeRole = "none"

    public static func manufactureCandidate<R: HephaestusTimespineRecipe>(
        recipe: R.Type,
        astronomicalSourceVersion: String,
        reference: any ForgeEphemerisReference,
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) throws -> TimespineCandidate {
        guard !R.recipeIdentifier.isEmpty, R.recipeVersion > 0 else {
            throw HephaestusError.invalidRecipeIdentity
        }
        guard !astronomicalSourceVersion.isEmpty else {
            throw HephaestusError.invalidAstronomicalSourceVersion
        }
        guard Self.celestialTimeFirst, MundaneTimespineStorageFormat.celestialTimeFirst else {
            throw MundaneTimespineStorageError.celestialTimeLawMissing
        }

        try R.preflight(reference: reference)
        let plan = R.forgePlan(astronomicalSourceVersion: astronomicalSourceVersion)
        let product = try MundaneTimespineForge.manufacture(plan: plan, reference: reference)

        try enforce(
            R.artifactContract,
            bodyCount: product.bodies.count,
            bodyOccurrenceCount: product.totalOccurrenceCount,
            relationshipCount: relationships.count,
            eclipseCount: eclipses.count
        )

        guard let image = MundaneTimespineStorageImage(
            forgeProduct: product,
            relationships: relationships,
            eclipses: eclipses
        ) else {
            throw HephaestusError.storageAssemblyFailed
        }

        let artifactData = try image.encodedArtifact()
        let artifact = try MundaneTimespineArtifact(data: artifactData)
        let decoded = try artifact.storageImage()

        guard decoded.spanName == product.spanName,
              decoded.astronomicalSource == product.astronomicalSource,
              decoded.astronomicalSourceVersion == product.astronomicalSourceVersion,
              decoded.supportedStart == product.supportedStart,
              decoded.supportedEnd == product.supportedEnd else {
            throw HephaestusError.provenanceMismatch
        }

        let decodedOccurrenceCount = decoded.bodies.reduce(0) { $0 + $1.occurrences.count }
        try enforce(
            R.artifactContract,
            bodyCount: decoded.bodies.count,
            bodyOccurrenceCount: decodedOccurrenceCount,
            relationshipCount: decoded.relationships.count,
            eclipseCount: decoded.eclipses.count
        )

        let reencoded = try decoded.encodedArtifact()
        guard reencoded == artifactData else {
            throw HephaestusError.artifactRoundTripMismatch
        }

        let identity = TimespineCandidateIdentity.hash(artifactData: artifactData)
        let record = TimespineForgeRecord(
            recipeIdentifier: R.recipeIdentifier,
            recipeVersion: R.recipeVersion,
            spanName: product.spanName,
            astronomicalSource: product.astronomicalSource,
            astronomicalSourceVersion: product.astronomicalSourceVersion,
            storageFamily: MundaneTimespineStorageFormat.identifier,
            storageVersion: MundaneTimespineStorageFormat.version,
            celestialTimeFirst: MundaneTimespineStorageFormat.celestialTimeFirst,
            bodyCount: decoded.bodies.count,
            bodyOccurrenceCount: decodedOccurrenceCount,
            stationCount: decoded.bodies.reduce(0) { $0 + $1.stations.count },
            retrogradePassageCount: decoded.bodies.reduce(0) { $0 + $1.retrogradePassages.count },
            relationshipCount: decoded.relationships.count,
            eclipseCount: decoded.eclipses.count,
            artifactByteCount: artifactData.count,
            candidateSHA256: identity.sha256
        )

        return TimespineCandidate(
            identity: identity,
            artifact: artifact,
            forgeRecord: record
        )
    }

    private static func enforce(
        _ contract: HephaestusTimespineArtifactContract,
        bodyCount: Int,
        bodyOccurrenceCount: Int,
        relationshipCount: Int,
        eclipseCount: Int
    ) throws {
        let checks: [(String, Int, Int)] = [
            ("bodies", contract.bodyCount, bodyCount),
            ("body occurrences", contract.bodyOccurrenceCount, bodyOccurrenceCount),
            ("relationships", contract.relationshipCount, relationshipCount),
            ("eclipses", contract.eclipseCount, eclipseCount),
        ]
        for (component, expected, actual) in checks where expected != actual {
            throw HephaestusError.artifactContractMismatch(
                component: component,
                expected: expected,
                actual: actual
            )
        }
    }
}
