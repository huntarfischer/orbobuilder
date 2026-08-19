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
            return "Hephaestus artifact provenance does not match the bound recipe."
        }
    }
}

/// Native fabrication authority for canonical Orbo artifacts.
///
/// Fresh Forge manufacture, canonical persisted assembly, and preserved-candidate rehydration
/// all converge on the same recipe/provenance/anatomy checks. Rehydration never manufactures
/// astronomical matter and never creates a new candidate identity: it restores Hephaestus custody
/// of the exact preserved ORBOTS bytes so Dioscuri may continue examining that immutable work.
public enum Hephaestus {
    public static let celestialTimeFirst = true
    public static let candidateIdentityAlgorithm = "SHA-256"
    public static let candidateRehydrationLaw = "exact ORBOTS bytes + bound recipe -> same candidate identity"
    public static let runtimeRole = "none"
    public static let queryRole = "none"
    public static let interpretationRole = "none"

    /// Manufacture fresh Timespine chronology through Forge, then mint the immutable candidate.
    public static func manufactureCandidate<R: HephaestusTimespineRecipe>(
        recipe: R.Type,
        astronomicalSourceVersion: String,
        reference: any ForgeEphemerisReference,
        relationships: [MundaneTimespineRelationshipEvent] = [],
        eclipses: [MundaneTimespineEclipseEvent] = []
    ) throws -> TimespineCandidate {
        try validateRecipe(R.self, astronomicalSourceVersion: astronomicalSourceVersion)
        guard Self.celestialTimeFirst, MundaneTimespineStorageFormat.celestialTimeFirst else {
            throw MundaneTimespineStorageError.celestialTimeLawMissing
        }

        try R.preflight(reference: reference)
        let plan = R.forgePlan(astronomicalSourceVersion: astronomicalSourceVersion)
        let product = try MundaneTimespineForge.manufacture(plan: plan, reference: reference)

        guard let image = MundaneTimespineStorageImage(
            forgeProduct: product,
            relationships: relationships,
            eclipses: eclipses
        ) else {
            throw HephaestusError.storageAssemblyFailed
        }

        return try mintCandidate(recipe: R.self, image: image)
    }

    /// Mint a candidate from already-proven canonical construction matter without rerunning
    /// Forge or an ephemeris. The recipe still owns the required span, source, anatomy, and
    /// resonance contract; this is a second input route into the same Hephaestus engine.
    public static func manufactureCandidate<R: HephaestusTimespineRecipe>(
        recipe: R.Type,
        assembledStorageImage image: MundaneTimespineStorageImage
    ) throws -> TimespineCandidate {
        try validateRecipe(R.self, astronomicalSourceVersion: image.astronomicalSourceVersion)
        guard Self.celestialTimeFirst, MundaneTimespineStorageFormat.celestialTimeFirst else {
            throw MundaneTimespineStorageError.celestialTimeLawMissing
        }
        try validateProvenance(R.self, image: image)
        return try mintCandidate(recipe: R.self, image: image)
    }

    /// Restore an already-minted immutable candidate from its exact preserved ORBOTS bytes.
    /// This performs no Forge work and no astronomical assembly. The artifact is decoded,
    /// checked against the bound recipe, re-encoded byte-for-byte, and given the SHA-256 identity
    /// inherent in those bytes. A different byte sequence is therefore a different candidate.
    public static func rehydrateCandidate<R: HephaestusTimespineRecipe>(
        recipe: R.Type,
        artifactData: Data
    ) throws -> TimespineCandidate {
        guard Self.celestialTimeFirst, MundaneTimespineStorageFormat.celestialTimeFirst else {
            throw MundaneTimespineStorageError.celestialTimeLawMissing
        }

        let artifact = try MundaneTimespineArtifact(data: artifactData)
        let decoded = try artifact.storageImage()
        try validateRecipe(R.self, astronomicalSourceVersion: decoded.astronomicalSourceVersion)
        try validateProvenance(R.self, image: decoded)
        try enforce(R.artifactContract, counts: counts(in: decoded))

        let reencoded = try decoded.encodedArtifact()
        guard reencoded == artifactData else {
            throw HephaestusError.artifactRoundTripMismatch
        }

        return makeCandidate(
            recipe: R.self,
            artifactData: artifactData,
            artifact: artifact,
            decoded: decoded
        )
    }

    private static func mintCandidate<R: HephaestusTimespineRecipe>(
        recipe: R.Type,
        image: MundaneTimespineStorageImage
    ) throws -> TimespineCandidate {
        let imageCounts = counts(in: image)
        try enforce(R.artifactContract, counts: imageCounts)

        let artifactData = try image.encodedArtifact()
        let artifact = try MundaneTimespineArtifact(data: artifactData)
        let decoded = try artifact.storageImage()

        guard decoded.spanName == image.spanName,
              decoded.astronomicalSource == image.astronomicalSource,
              decoded.astronomicalSourceVersion == image.astronomicalSourceVersion,
              decoded.supportedStart == image.supportedStart,
              decoded.supportedEnd == image.supportedEnd else {
            throw HephaestusError.provenanceMismatch
        }

        let decodedCounts = counts(in: decoded)
        try enforce(R.artifactContract, counts: decodedCounts)

        let reencoded = try decoded.encodedArtifact()
        guard reencoded == artifactData else {
            throw HephaestusError.artifactRoundTripMismatch
        }

        return makeCandidate(
            recipe: R.self,
            artifactData: artifactData,
            artifact: artifact,
            decoded: decoded
        )
    }

    private static func makeCandidate<R: HephaestusTimespineRecipe>(
        recipe: R.Type,
        artifactData: Data,
        artifact: MundaneTimespineArtifact,
        decoded: MundaneTimespineStorageImage
    ) -> TimespineCandidate {
        let decodedCounts = counts(in: decoded)
        let identity = TimespineCandidateIdentity.hash(artifactData: artifactData)
        let record = TimespineForgeRecord(
            recipeIdentifier: R.recipeIdentifier,
            recipeVersion: R.recipeVersion,
            resonanceContract: R.resonanceContract,
            spanName: decoded.spanName,
            astronomicalSource: decoded.astronomicalSource,
            astronomicalSourceVersion: decoded.astronomicalSourceVersion,
            storageFamily: MundaneTimespineStorageFormat.identifier,
            storageVersion: MundaneTimespineStorageFormat.version,
            celestialTimeFirst: MundaneTimespineStorageFormat.celestialTimeFirst,
            bodyCount: decodedCounts.bodyCount,
            bodyOccurrenceCount: decodedCounts.bodyOccurrenceCount,
            stationCount: decodedCounts.stationCount,
            retrogradePassageCount: decodedCounts.retrogradePassageCount,
            relationshipCount: decodedCounts.relationshipCount,
            eclipseCount: decodedCounts.eclipseCount,
            artifactByteCount: artifactData.count,
            candidateSHA256: identity.sha256
        )

        return TimespineCandidate(
            identity: identity,
            artifact: artifact,
            forgeRecord: record
        )
    }

    private static func validateRecipe<R: HephaestusTimespineRecipe>(
        _ recipe: R.Type,
        astronomicalSourceVersion: String
    ) throws {
        guard !R.recipeIdentifier.isEmpty, R.recipeVersion > 0 else {
            throw HephaestusError.invalidRecipeIdentity
        }
        guard !astronomicalSourceVersion.isEmpty else {
            throw HephaestusError.invalidAstronomicalSourceVersion
        }
    }

    private static func validateProvenance<R: HephaestusTimespineRecipe>(
        _ recipe: R.Type,
        image: MundaneTimespineStorageImage
    ) throws {
        let plan = R.forgePlan(astronomicalSourceVersion: image.astronomicalSourceVersion)
        guard image.spanName == plan.spanName,
              image.astronomicalSource == plan.astronomicalSource,
              image.astronomicalSourceVersion == plan.astronomicalSourceVersion,
              image.supportedStart == plan.supportedStart,
              image.supportedEnd == plan.supportedEnd else {
            throw HephaestusError.provenanceMismatch
        }
    }

    private struct ArtifactCounts {
        let bodyCount: Int
        let bodyOccurrenceCount: Int
        let stationCount: Int
        let retrogradePassageCount: Int
        let relationshipCount: Int
        let eclipseCount: Int
    }

    private static func counts(in image: MundaneTimespineStorageImage) -> ArtifactCounts {
        ArtifactCounts(
            bodyCount: image.bodies.count,
            bodyOccurrenceCount: image.bodies.reduce(0) { $0 + $1.occurrences.count },
            stationCount: image.bodies.reduce(0) { $0 + $1.stations.count },
            retrogradePassageCount: image.bodies.reduce(0) { $0 + $1.retrogradePassages.count },
            relationshipCount: image.relationships.count,
            eclipseCount: image.eclipses.count
        )
    }

    private static func enforce(
        _ contract: HephaestusTimespineArtifactContract,
        counts: ArtifactCounts
    ) throws {
        var checks: [(String, Int, Int)] = [
            ("bodies", contract.bodyCount, counts.bodyCount),
            ("body occurrences", contract.bodyOccurrenceCount, counts.bodyOccurrenceCount),
            ("relationships", contract.relationshipCount, counts.relationshipCount),
            ("eclipses", contract.eclipseCount, counts.eclipseCount),
        ]
        if let expected = contract.stationCount {
            checks.append(("stations", expected, counts.stationCount))
        }
        if let expected = contract.retrogradePassageCount {
            checks.append(("retrograde passages", expected, counts.retrogradePassageCount))
        }

        for (component, expected, actual) in checks where expected != actual {
            throw HephaestusError.artifactContractMismatch(
                component: component,
                expected: expected,
                actual: actual
            )
        }
    }
}
