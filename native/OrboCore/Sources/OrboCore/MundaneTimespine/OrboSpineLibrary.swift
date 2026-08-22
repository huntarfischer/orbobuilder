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
/// D2 exposes stable core shelf identities only. It owns no astronomy, copies no truth rows,
/// and does not own the Stack Smeld mount; SpineSmeldSeams remains the sole seam owner.
public struct OrboSpineLibraryCatalog: Hashable, Sendable {
    public static let port = SpineAccessPort.library

    public let coreShelves: [OrboSpineLibraryShelf]

    public init() {
        self.coreShelves = OrboSpineLibraryShelf.allCases
    }

    public func contains(_ shelf: OrboSpineLibraryShelf) -> Bool {
        coreShelves.contains(shelf)
    }
}
