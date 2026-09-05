import Foundation

/// The two meaningful faces and the physical edge of Apollo's instrument.
public enum ApolloAstrolabeFace: String, Hashable, Sendable {
    case aegis
    case edge
    case tabula
}

/// Commands a control surface may return to Apollo. The surface identifies a
/// touched piece of Apollo's own instrument; it does not mutate the Iris frame.
public enum ApolloAstrolabeCommand: Hashable, Sendable {
    case turn(Double)
    case settle
    case flip
    case selectDestination(ApolloTabulaDestination?)
    case selectBodyMode(ApolloTabulaBodyMode)
}

/// A destination engraved around the Tabula. These are parts of Apollo's
/// device, not destinations owned or interpreted by Iris.
public enum ApolloTabulaDestination: Int, CaseIterable, Hashable, Sendable {
    case natal
    case hereNow
    case planets
    case moon
    case image
    case aspects
    case ledger
    case timing
    case almanac
    case gears
    case archive
    case composite

    public var title: String {
        switch self {
        case .natal: return "Natal"
        case .hereNow: return "Here · Now"
        case .planets: return "Planets"
        case .moon: return "Moon"
        case .image: return "Image"
        case .aspects: return "Aspects"
        case .ledger: return "Ledger"
        case .timing: return "Timing"
        case .almanac: return "Almanac"
        case .gears: return "Gears"
        case .archive: return "Archive"
        case .composite: return "Composite"
        }
    }

    /// Zodiac glyphs are fixed engravings in the prototype's destination order.
    public var glyph: String {
        ["♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎", "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎"][rawValue]
    }
}

/// The four prototype modes seated in Gemini's Tabula socket ring.
public enum ApolloTabulaBodyMode: String, CaseIterable, Hashable, Sendable {
    case planets
    case objects
    case points
    case lots

    public var socketTitle: String { rawValue.capitalized }
    public var fieldTitle: String { "THE \(rawValue.uppercased())" }
}

/// One engraved control seated on the prototype's circular chip rail. Apollo
/// owns the name, glyph, angle, and state; Iris only places the supplied mark.
public struct ApolloTabulaChip: Hashable, Sendable {
    public let name: String
    public let glyph: String
    public let angleDegrees: Double
    public let enabled: Bool

    public init(name: String, glyph: String, angleDegrees: Double, enabled: Bool) {
        self.name = name
        self.glyph = glyph
        self.angleDegrees = angleDegrees
        self.enabled = enabled
    }
}

/// Mutable state of the reverse face. It remains inside Apollo's complete
/// instrument value rather than becoming view state owned by Iris.
public struct ApolloTabula: Hashable, Sendable {
    public private(set) var destination: ApolloTabulaDestination?
    public private(set) var bodyMode: ApolloTabulaBodyMode

    public init(
        destination: ApolloTabulaDestination? = nil,
        bodyMode: ApolloTabulaBodyMode = .planets
    ) {
        self.destination = destination
        self.bodyMode = bodyMode
    }

    public mutating func select(_ destination: ApolloTabulaDestination?) {
        self.destination = destination
    }

    public mutating func select(_ mode: ApolloTabulaBodyMode) {
        bodyMode = mode
    }

    /// Direct transcription of the prototype's `_chipPos` source order and
    /// angular laws. Planet and Lot seats follow domicile spokes; objects and
    /// points divide the complete rail evenly.
    public var bodyChips: [ApolloTabulaChip] {
        switch bodyMode {
        case .planets:
            return [
                ("Sun", "☉", 4), ("Moon", "☽", 3), ("Mercury", "☿", 2),
                ("Venus", "♀", 1), ("Mars", "♂", 0), ("Jupiter", "♃", 8),
                ("Saturn", "♄", 9), ("Uranus", "♅", 10),
                ("Neptune", "♆", 11), ("Pluto", "♇", 7),
            ].map { ApolloTabulaChip(name: $0.0, glyph: $0.1,
                angleDegrees: 180 + Double($0.2 * 30 + 15), enabled: true) }
        case .objects:
            return [
                ("Chiron", "⚷"), ("Ceres", "⚳"), ("Pallas", "⚴"),
                ("Juno", "⚵"), ("Vesta", "⚶"),
            ].enumerated().map { index, item in
                ApolloTabulaChip(name: item.0, glyph: item.1,
                    angleDegrees: 180 + Double(index) * 72, enabled: false)
            }
        case .points:
            return [("Nodes", "☊"), ("Lilith", "⚸"), ("Vertex", "Vx")]
                .enumerated().map { index, item in
                    ApolloTabulaChip(name: item.0, glyph: item.1,
                        angleDegrees: 180 + Double(index) * 120, enabled: index == 0)
                }
        case .lots:
            return [
                ("Fortune", "⊗", 3), ("Spirit", "Sp", 4), ("Eros", "Er", 1),
                ("Necessity", "Nc", 2), ("Courage", "Cg", 0),
                ("Victory", "Vc", 8), ("Nemesis", "Nm", 9), ("Death", "Dt", 7),
            ].map { ApolloTabulaChip(name: $0.0, glyph: $0.1,
                angleDegrees: 180 + Double($0.2 * 30 + 15), enabled: false) }
        }
    }
}

/// Platform-neutral color values so Apollo can own a material recipe without
/// importing a presentation framework.
public struct ApolloAstrolabeColor: Hashable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

/// One concrete material recipe for Act I. The value boundary is deliberately
/// ready for later skins without introducing a speculative renderer protocol.
public struct ApolloAstrolabeMaterial: Hashable, Sendable {
    public let name: String
    public let face: ApolloAstrolabeColor
    public let faceHighlight: ApolloAstrolabeColor
    public let edge: ApolloAstrolabeColor
    public let engraving: ApolloAstrolabeColor
    public let accent: ApolloAstrolabeColor

    public static let prototypeVioletStone = ApolloAstrolabeMaterial(
        name: "Prototype violet stone",
        face: .init(red: 0.094, green: 0.067, blue: 0.263),
        faceHighlight: .init(red: 0.102, green: 0.075, blue: 0.282),
        edge: .init(red: 0.063, green: 0.043, blue: 0.188),
        engraving: .init(red: 0.804, green: 0.847, blue: 0.949),
        accent: .init(red: 0.910, green: 0.671, blue: 0.255)
    )
}

/// Normalized dimensions shared by the Aegis and Tabula. A renderer scales the
/// values to its viewport; it does not independently invent device geometry.
public struct ApolloAstrolabeGeometry: Hashable, Sendable {
    public let rimRadius: Double
    public let destinationInnerRadius: Double
    public let inscriptionInnerRadius: Double
    public let socketInnerRadius: Double
    public let socketOuterRadius: Double
    public let zodiacGlyphRadius: Double
    public let thicknessRatio: Double

    /// Compatibility name retained for the accepted Act I contract.
    public var socketRadius: Double { socketInnerRadius }

    public static let prototype = ApolloAstrolabeGeometry(
        rimRadius: 0.493,
        destinationInnerRadius: 0.385,
        inscriptionInnerRadius: 0.332,
        socketInnerRadius: 0.264,
        socketOuterRadius: 0.329,
        zodiacGlyphRadius: 0.4375,
        thicknessRatio: 0.048
    )
}

/// Relative visibility of each physical surface at one rotation.
public struct ApolloAstrolabeExposure: Hashable, Sendable {
    public let aegis: Double
    public let edge: Double
    public let tabula: Double
}

/// Apollo's complete two-faced instrument. It owns device pose and detents; its
/// Aegis owns the mounted Horae cross-section already accepted by the app.
public struct ApolloAstrolabe: Hashable, Sendable {
    public static let detents: [Double] = [0, 90, 180, 270, 360]

    public let aegis: ApolloAegis
    public let skyContacts: [ApolloContact]
    public let geometry: ApolloAstrolabeGeometry
    public let material: ApolloAstrolabeMaterial
    public private(set) var tabula: ApolloTabula
    public private(set) var rotationDegrees: Double

    public init(
        aegis: ApolloAegis,
        rotationDegrees: Double = 0,
        geometry: ApolloAstrolabeGeometry = .prototype,
        material: ApolloAstrolabeMaterial = .prototypeVioletStone,
        tabula: ApolloTabula = ApolloTabula()
    ) {
        self.aegis = aegis
        self.skyContacts = Apollo.contacts(in: aegis.sky, settings: ApolloAspectSettings())
        self.geometry = geometry
        self.material = material
        self.tabula = tabula
        self.rotationDegrees = Self.normalized(rotationDegrees)
    }

    public mutating func turn(to degrees: Double) {
        rotationDegrees = Self.normalized(degrees)
    }

    public mutating func flip() {
        turn(to: rotationDegrees + 180)
    }

    public mutating func selectTabulaDestination(_ destination: ApolloTabulaDestination?) {
        tabula.select(destination)
    }

    public mutating func selectTabulaBodyMode(_ mode: ApolloTabulaBodyMode) {
        tabula.select(mode)
    }

    @discardableResult
    public mutating func settleToNearestDetent() -> Double {
        let settled = Self.nearestDetent(to: rotationDegrees)
        rotationDegrees = settled == 360 ? 0 : settled
        return settled
    }

    public var exposure: ApolloAstrolabeExposure {
        Self.exposure(at: rotationDegrees)
    }

    public static func exposure(at degrees: Double) -> ApolloAstrolabeExposure {
        let cosine = cos(normalized(degrees) * .pi / 180)
        return ApolloAstrolabeExposure(
            aegis: max(0, cosine),
            edge: 1 - abs(cosine),
            tabula: max(0, -cosine)
        )
    }

    public var dominantFace: ApolloAstrolabeFace {
        let exposure = exposure
        if exposure.edge >= exposure.aegis, exposure.edge >= exposure.tabula { return .edge }
        return exposure.aegis > exposure.tabula ? .aegis : .tabula
    }

    public static func nearestDetent(to degrees: Double) -> Double {
        let angle = normalized(degrees)
        return detents.min { abs($0 - angle) < abs($1 - angle) } ?? 0
    }

    private static func normalized(_ degrees: Double) -> Double {
        guard degrees.isFinite else { return 0 }
        let remainder = degrees.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }
}
