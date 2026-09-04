import Foundation

/// Minimal provenance binding carried by one assembled runtime OrboSpine.
/// The construction manifest remains auditable provenance; when present, artifactSHA256 identifies
/// the exact finished Spine representation mounted by the runtime.
public struct OrboSpineRuntimeProvenance: Hashable, Sendable {
    public let candidateManifestSHA256: String
    public let artifactSHA256: String?
    public let astronomicalAuthority: String
    public let astronomicalSourceVersion: String

    public var spineIdentity: String { artifactSHA256 ?? candidateManifestSHA256 }

    public init?(
        candidateManifestSHA256: String,
        artifactSHA256: String? = nil,
        astronomicalAuthority: String,
        astronomicalSourceVersion: String
    ) {
        let candidateDigest = candidateManifestSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let artifactDigest = artifactSHA256?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let authority = astronomicalAuthority.trimmingCharacters(in: .whitespacesAndNewlines)
        let version = astronomicalSourceVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isSHA256(candidateDigest),
              artifactDigest.map(Self.isSHA256) != false,
              !authority.isEmpty,
              !version.isEmpty else {
            return nil
        }
        self.candidateManifestSHA256 = candidateDigest
        self.artifactSHA256 = artifactDigest
        self.astronomicalAuthority = authority
        self.astronomicalSourceVersion = version
    }

    private static func isSHA256(_ digest: String) -> Bool {
        digest.count == 64 && digest.allSatisfy({ $0.isHexDigit })
    }
}

/// Compact assembly inventory. Counts describe the matter admitted to this runtime body;
/// they are not a second owner of any chronology.
public struct OrboSpineRuntimeInventory: Hashable, Sendable {
    public let celestialSupportCount: Int
    public let stationCount: Int
    public let retrogradePassageCount: Int
    public let ringOccurrenceCount: Int
    public let eclipseCount: Int
    public let shellIntervalCount: Int
    public let terraSampleCount: Int
}

/// D4's single coherent in-memory OrboSpine.
///
/// Large celestial-support and Terra input tables are consumed by Locate during assembly rather
/// than retained here as duplicate peers. Prepared temporal structures remain available for the
/// Library surface, while Link remains an addressability contract and computes nothing.
public struct OrboSpineRuntime: Sendable {
    public let identity: String
    public let bone: OrboSpineBoneSpan

    public let locate: OrboSpineLocate
    public let library: OrboSpineLibraryCatalog
    public let ports: SpinePorts
    public let linkPort: SpineAccessPort
    public let link: SpineLink

    /// Compatibility views of Library-owned prepared matter.
    public var stations: [OrboSpineStation] { library.allStations }
    public var retrogradePassages: [OrboSpineRetrogradePassage] { library.allRetrogradePassages }
    public var ringOccurrences: [OrboSpineRingOccurrence] { library.ringOccurrences }
    public var eclipses: [OrboSpineEclipseOccurrence] { library.eclipses }
    public var shellIntervals: [OrboSpineShellInterval] { library.allShellIntervals }

    public let smeldSeams: SpineSmeldSeams
    public let provenance: OrboSpineRuntimeProvenance
    public let inventory: OrboSpineRuntimeInventory

    /// Mounts one already-forged artifact and binds all three existing Doors to those same bytes.
    /// The expected digest is supplied by the seal/receipt; an artifact never certifies itself.
    public static func mount(from url: URL, expectedSHA256: String) throws -> OrboSpineRuntime {
        let mountedArtifact = try OrboSpineMountedArtifact(url: url)
        let expected = expectedSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard mountedArtifact.sha256 == expected else {
            throw OrboSpineArtifactError.artifactIdentityMismatch(
                expected: expected,
                actual: mountedArtifact.sha256
            )
        }
        return try OrboSpineRuntime(mountedArtifact: mountedArtifact)
    }

    public init?(
        bone: OrboSpineBoneSpan,
        celestialSupports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation],
        boundaryAnchors: [OrboSpineBoundaryAnchor] = [],
        retrogradePassages: [OrboSpineRetrogradePassage],
        ringOccurrences: [OrboSpineRingOccurrence],
        eclipses: [OrboSpineEclipseOccurrence],
        shellIntervals: [OrboSpineShellInterval],
        terraSamples: [TerraMarrowSample],
        provenance: OrboSpineRuntimeProvenance
    ) {
        let canonicalBodies = Set(MundaneBody.canonicalOrder)
        guard Set(celestialSupports.map(\.body)) == canonicalBodies,
              !celestialSupports.isEmpty,
              !terraSamples.isEmpty,
              stations.allSatisfy({ canonicalBodies.contains($0.body) && bone.contains($0.julianDay) }),
              boundaryAnchors.allSatisfy({ canonicalBodies.contains($0.body) }),
              retrogradePassages.allSatisfy({
                  canonicalBodies.contains($0.body)
                      && $0.start.value >= bone.start.value
                      && $0.end.value <= bone.end.value
              }),
              ringOccurrences.allSatisfy({
                  canonicalBodies.contains($0.bodyA)
                      && canonicalBodies.contains($0.bodyB)
                      && bone.contains($0.julianDay)
              }),
              eclipses.allSatisfy({ eclipse in
                  bone.contains(eclipse.julianDay)
                      && (eclipse.greatestEclipseJulianDay == nil
                          || bone.contains(eclipse.greatestEclipseJulianDay!))
              }),
              Self.validShells(shellIntervals, on: bone),
              let locate = OrboSpineLocate(
                  bone: bone,
                  celestialSupports: celestialSupports,
                  stations: stations,
                  boundaryAnchors: boundaryAnchors,
                  terraSamples: terraSamples
              ) else {
            return nil
        }

        self.identity = OrboSpineContract.identity
        self.bone = bone
        self.locate = locate
        self.library = OrboSpineLibraryCatalog(
            retrogradePassages: retrogradePassages,
            stations: stations,
            shellIntervals: shellIntervals,
            ringOccurrences: ringOccurrences,
            eclipses: eclipses
        )
        self.ports = SpinePorts()
        self.linkPort = SpineLinkSet.port
        self.link = SpineLink(provenance: provenance, locate: locate)
        self.smeldSeams = SpineSmeldSeams()
        self.provenance = provenance
        self.inventory = OrboSpineRuntimeInventory(
            celestialSupportCount: celestialSupports.count,
            stationCount: stations.count,
            retrogradePassageCount: retrogradePassages.count,
            ringOccurrenceCount: ringOccurrences.count,
            eclipseCount: eclipses.count,
            shellIntervalCount: shellIntervals.count,
            terraSampleCount: terraSamples.count
        )
    }

    private init(mountedArtifact: OrboSpineMountedArtifact) throws {
        let metadata = mountedArtifact.metadata
        guard metadata.schematicIdentity == OrboSpineContract.identity,
              metadata.schematicVersion == OrboSpineSchematic.version,
              let provenance = OrboSpineRuntimeProvenance(
            candidateManifestSHA256: metadata.candidateManifestSHA256,
            artifactSHA256: mountedArtifact.sha256,
            astronomicalAuthority: metadata.astronomicalAuthority,
            astronomicalSourceVersion: metadata.astronomicalSourceVersion
        ) else {
            throw OrboSpineArtifactError.invalidMetadata
        }
        let locate = OrboSpineLocate(mountedArtifact: mountedArtifact)
        self.identity = metadata.schematicIdentity
        self.bone = metadata.bone
        self.locate = locate
        self.library = OrboSpineLibraryCatalog(mountedArtifact: mountedArtifact)
        self.ports = SpinePorts()
        self.linkPort = SpineLinkSet.port
        self.link = SpineLink(provenance: provenance, locate: locate)
        self.smeldSeams = SpineSmeldSeams()
        self.provenance = provenance
        self.inventory = metadata.inventory
    }

    private static func validShells(
        _ intervals: [OrboSpineShellInterval],
        on bone: OrboSpineBoneSpan
    ) -> Bool {
        guard !intervals.isEmpty,
              Set(intervals.map { $0.id.family }) == Set(OrboSpineShellFamily.allCases) else {
            return false
        }
        return intervals.allSatisfy {
            $0.start.value < bone.end.value && $0.end.value > bone.start.value
        }
    }
}
