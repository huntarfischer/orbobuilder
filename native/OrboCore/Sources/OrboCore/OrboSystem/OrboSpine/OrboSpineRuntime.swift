import Foundation

/// Minimal provenance binding carried by one assembled runtime OrboSpine.
/// D4 binds identity only; D5 proves the canonical candidate bytes behind it.
public struct OrboSpineRuntimeProvenance: Hashable, Sendable {
    public let candidateManifestSHA256: String
    public let astronomicalAuthority: String
    public let astronomicalSourceVersion: String

    public init?(
        candidateManifestSHA256: String,
        astronomicalAuthority: String,
        astronomicalSourceVersion: String
    ) {
        let digest = candidateManifestSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let authority = astronomicalAuthority.trimmingCharacters(in: .whitespacesAndNewlines)
        let version = astronomicalSourceVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard digest.count == 64,
              digest.allSatisfy({ $0.isHexDigit }),
              !authority.isEmpty,
              !version.isEmpty else {
            return nil
        }
        self.candidateManifestSHA256 = digest
        self.astronomicalAuthority = authority
        self.astronomicalSourceVersion = version
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

    public let stations: [OrboSpineStation]
    public let retrogradePassages: [OrboSpineRetrogradePassage]
    public let ringOccurrences: [OrboSpineRingOccurrence]
    public let eclipses: [OrboSpineEclipseOccurrence]
    public let shellIntervals: [OrboSpineShellInterval]

    public let smeldSeams: SpineSmeldSeams
    public let provenance: OrboSpineRuntimeProvenance
    public let inventory: OrboSpineRuntimeInventory

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
        self.library = OrboSpineLibraryCatalog()
        self.ports = SpinePorts()
        self.linkPort = SpineLinkSet.port
        self.stations = stations.sorted { $0.julianDay.value < $1.julianDay.value }
        self.retrogradePassages = retrogradePassages.sorted { $0.start.value < $1.start.value }
        self.ringOccurrences = ringOccurrences.sorted { $0.julianDay.value < $1.julianDay.value }
        self.eclipses = eclipses.sorted { $0.julianDay.value < $1.julianDay.value }
        self.shellIntervals = shellIntervals.sorted {
            if $0.id.family.rawValue != $1.id.family.rawValue {
                return $0.id.family.rawValue < $1.id.family.rawValue
            }
            return $0.start.value < $1.start.value
        }
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
