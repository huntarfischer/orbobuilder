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

    private let stationRows: [OrboSpineStation]
    private let shellRows: [OrboSpineShellInterval]

    public init() {
        self.coreShelves = OrboSpineLibraryShelf.allCases
        self.stationRows = []
        self.shellRows = []
    }

    internal init(
        stations: [OrboSpineStation],
        shellIntervals: [OrboSpineShellInterval]
    ) {
        self.coreShelves = OrboSpineLibraryShelf.allCases
        self.stationRows = stations.sorted { $0.julianDay.value < $1.julianDay.value }
        self.shellRows = shellIntervals.sorted {
            if $0.id.family.rawValue != $1.id.family.rawValue {
                return $0.id.family.rawValue < $1.id.family.rawValue
            }
            return $0.start.value < $1.start.value
        }
    }

    public func contains(_ shelf: OrboSpineLibraryShelf) -> Bool {
        coreShelves.contains(shelf)
    }

    /// Prepared station rows for one canonical body, in temporal order.
    public func stations(for body: MundaneBody) -> [OrboSpineStation] {
        stationRows.filter { $0.body == body }
    }

    /// One exact prepared shell interval by canonical shell identity.
    public func shell(_ id: OrboSpineShellID) -> OrboSpineShellInterval? {
        shellRows.first { $0.id == id }
    }

    /// Compatibility views for the assembled runtime. These are the same Library-owned
    /// arrays, not independently retained chronology.
    internal var allStations: [OrboSpineStation] { stationRows }
    internal var allShellIntervals: [OrboSpineShellInterval] { shellRows }
}
