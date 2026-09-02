/// One entity Homer is explicitly allowed to enter as a point of view.
/// Pass A exposes only Horae. The list grows deliberately, never by discovery.
public enum HomerPOV: String, Hashable, Sendable {
    case horae = "HORAE"
}

/// One selectable line carried through Homer's Iris port.
///
/// The owner of a menu authors the selection. Homer only carries it to Iris.
public struct HomerSelection: Hashable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }

    public static let pov = HomerSelection(id: "homer.pov", label: "POV")
    public static let leave = HomerSelection(id: "homer.leave", label: "LEAVE")
    public static let horae = HomerSelection(id: "homer.pov.horae", label: "HORAE")
    public static let homer = HomerSelection(id: "homer.return", label: "HOMER")
}

/// Homer's complete outward vocabulary for Pass A: text and selection.
/// Iris may manifest this port, but presentation state does not come back upstream.
public struct HomerIrisPort: Hashable, Sendable {
    public let text: String
    public let selections: [HomerSelection]

    public init(text: String, selections: [HomerSelection]) {
        self.text = text
        self.selections = selections
    }
}

/// Textual point-of-view entity for entering the real Orbo world.
///
/// Homer owns no deity state and invents no deity actions. `POV` asks the selected
/// entity for its own Homer-facing page, then carries that page unchanged to Iris.
public struct Homer: Hashable, Sendable {
    public static let availablePOVs: [HomerPOV] = [.horae]

    public private(set) var irisPort: HomerIrisPort

    public init() {
        self.irisPort = Self.homePort
    }

    /// Opens Homer's explicit point-of-view menu.
    @discardableResult
    public mutating func POV() -> HomerIrisPort {
        irisPort = HomerIrisPort(
            text: "CHOOSE A POINT OF VIEW",
            selections: Self.availablePOVs.map { pov in
                switch pov {
                case .horae: return .horae
                }
            } + [.homer]
        )
        return irisPort
    }

    /// Enters one real entity through Homer's POV function.
    /// Horae authors the resulting text and selections; Homer only carries them.
    @discardableResult
    public mutating func POV(
        _ pointOfView: HomerPOV,
        through horae: Horae,
        at julianDay: JulianDay
    ) throws -> HomerIrisPort {
        switch pointOfView {
        case .horae:
            let page = try horae.homerPOV(at: julianDay)
            irisPort = page.irisPort
        }
        return irisPort
    }

    /// Returns from any attached POV to Homer itself.
    @discardableResult
    public mutating func home() -> HomerIrisPort {
        irisPort = Self.homePort
        return irisPort
    }

    private static let homePort = HomerIrisPort(
        text: "HOMER",
        selections: [.pov, .leave]
    )
}
