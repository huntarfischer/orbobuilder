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

/// Port II catalog over already-forged OrboSpine matter.
/// D2 exposes stable shelf identities only. It owns no astronomy, copies no truth rows,
/// and leaves the Stack Smeld seam empty.
public struct OrboSpineLibraryCatalog: Hashable, Sendable {
    public static let port = SpineAccessPort.library

    public let coreShelves: [OrboSpineLibraryShelf]
    public let stackSmeld: SpineSmeld?

    public init() {
        self.coreShelves = OrboSpineLibraryShelf.allCases
        self.stackSmeld = nil
    }

    public func contains(_ shelf: OrboSpineLibraryShelf) -> Bool {
        coreShelves.contains(shelf)
    }
}
