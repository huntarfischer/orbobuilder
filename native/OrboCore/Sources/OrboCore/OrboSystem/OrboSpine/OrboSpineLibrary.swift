import Foundation

/// Stable Port II identities for the prepared temporal structures carried by OrboSpine.
/// A shelf names where prepared time-structure can be found; it does not define a query language.
public enum OrboSpineLibraryShelf: String, CaseIterable, Codable, Hashable, Sendable {
    case retrogradePassages = "retrograde-passages"
    case stations
    case ringChronology = "ring-chronology"
    case eclipses
    case frame
    case revolt
    case wave
    case zeitgeist
}

/// Port II over already-forged OrboSpine matter.
///
/// The public empty initializer preserves the stable shelf catalog. Runtime assembly uses
/// the internal matter-bearing initializer so prepared chronology has one owner at Door II.
/// The Library exposes factual reads only; it still defines no consumer query language.
public struct OrboSpineLibraryCatalog: Hashable, Sendable {
    public static let port = SpineAccessPort.library

    public let coreShelves: [OrboSpineLibraryShelf]

    private let retrogradeRows: [OrboSpineRetrogradePassage]
    private let stationRows: [OrboSpineStation]
    private let shellRows: [OrboSpineShellInterval]
    private let ringRows: [OrboSpineRingOccurrence]
    private let eclipseRows: [OrboSpineEclipseOccurrence]
    private let mountedArtifact: OrboSpineMountedArtifact?

    public init() {
        self.coreShelves = OrboSpineLibraryShelf.allCases
        self.retrogradeRows = []
        self.stationRows = []
        self.shellRows = []
        self.ringRows = []
        self.eclipseRows = []
        self.mountedArtifact = nil
    }

    internal init(
        retrogradePassages: [OrboSpineRetrogradePassage] = [],
        stations: [OrboSpineStation],
        shellIntervals: [OrboSpineShellInterval],
        ringOccurrences: [OrboSpineRingOccurrence] = [],
        eclipses: [OrboSpineEclipseOccurrence] = []
    ) {
        self.coreShelves = OrboSpineLibraryShelf.allCases
        self.retrogradeRows = retrogradePassages.sorted { $0.start.value < $1.start.value }
        self.stationRows = stations.sorted { $0.julianDay.value < $1.julianDay.value }
        self.ringRows = ringOccurrences.sorted { $0.julianDay.value < $1.julianDay.value }
        self.eclipseRows = eclipses.sorted { $0.julianDay.value < $1.julianDay.value }
        self.shellRows = shellIntervals.sorted {
            if $0.id.family.rawValue != $1.id.family.rawValue {
                return $0.id.family.rawValue < $1.id.family.rawValue
            }
            return $0.start.value < $1.start.value
        }
        self.mountedArtifact = nil
    }

    internal init(mountedArtifact: OrboSpineMountedArtifact) {
        self.coreShelves = OrboSpineLibraryShelf.allCases
        self.retrogradeRows = []
        self.stationRows = []
        self.shellRows = []
        self.ringRows = []
        self.eclipseRows = []
        self.mountedArtifact = mountedArtifact
    }

    public func contains(_ shelf: OrboSpineLibraryShelf) -> Bool {
        coreShelves.contains(shelf)
    }

    /// Prepared station rows for one canonical body, in temporal order.
    public func stations(for body: MundaneBody) -> [OrboSpineStation] {
        allStations.filter { $0.body == body }
    }

    /// One exact prepared shell interval by canonical shell identity.
    public func shell(_ id: OrboSpineShellID) -> OrboSpineShellInterval? {
        allShellIntervals.first { $0.id == id }
    }

    /// Compatibility views for the assembled runtime. These are the same Library-owned
    /// arrays, not independently retained chronology.
    internal var allRetrogradePassages: [OrboSpineRetrogradePassage] {
        mountedRows { try $0.allRetrogradePassages() } ?? retrogradeRows
    }
    internal var allStations: [OrboSpineStation] {
        mountedRows { try $0.allStations() } ?? stationRows
    }
    internal var allShellIntervals: [OrboSpineShellInterval] {
        mountedRows { try $0.allShells() } ?? shellRows
    }
    /// Existing prepared matter, now available at its declared Port II shelves.
    public var ringOccurrences: [OrboSpineRingOccurrence] {
        mountedRows { try $0.allRingOccurrences() } ?? ringRows
    }
    public var eclipses: [OrboSpineEclipseOccurrence] {
        mountedRows { try $0.allEclipses() } ?? eclipseRows
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.coreShelves == rhs.coreShelves
            && lhs.retrogradeRows == rhs.retrogradeRows
            && lhs.stationRows == rhs.stationRows
            && lhs.shellRows == rhs.shellRows
            && lhs.ringRows == rhs.ringRows
            && lhs.eclipseRows == rhs.eclipseRows
            && lhs.mountedArtifact?.sha256 == rhs.mountedArtifact?.sha256
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coreShelves)
        hasher.combine(retrogradeRows)
        hasher.combine(stationRows)
        hasher.combine(shellRows)
        hasher.combine(ringRows)
        hasher.combine(eclipseRows)
        hasher.combine(mountedArtifact?.sha256)
    }

    private func mountedRows<T>(_ read: (OrboSpineMountedArtifact) throws -> [T]) -> [T]? {
        guard let mountedArtifact else { return nil }
        do { return try read(mountedArtifact) }
        catch { preconditionFailure("Certified OrboSpine Library bytes became unreadable: \(error)") }
    }
}
