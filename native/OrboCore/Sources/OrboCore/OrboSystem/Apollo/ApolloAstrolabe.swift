import Foundation

/// The two meaningful faces and the physical edge of Apollo's instrument.
public enum ApolloAstrolabeFace: String, Hashable, Sendable {
    case aegis
    case edge
    case tabula
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
        face: .init(red: 0.055, green: 0.027, blue: 0.135),
        faceHighlight: .init(red: 0.115, green: 0.075, blue: 0.235),
        edge: .init(red: 0.025, green: 0.016, blue: 0.070),
        engraving: .init(red: 0.66, green: 0.62, blue: 0.78),
        accent: .init(red: 0.96, green: 0.66, blue: 0.18)
    )
}

/// Normalized dimensions shared by the Aegis and Tabula. A renderer scales the
/// values to its viewport; it does not independently invent device geometry.
public struct ApolloAstrolabeGeometry: Hashable, Sendable {
    public let rimRadius: Double
    public let destinationInnerRadius: Double
    public let inscriptionInnerRadius: Double
    public let socketRadius: Double
    public let thicknessRatio: Double

    public static let prototype = ApolloAstrolabeGeometry(
        rimRadius: 0.5,
        destinationInnerRadius: 0.385,
        inscriptionInnerRadius: 0.335,
        socketRadius: 0.265,
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
    public let geometry: ApolloAstrolabeGeometry
    public let material: ApolloAstrolabeMaterial
    public private(set) var rotationDegrees: Double

    public init(
        aegis: ApolloAegis,
        rotationDegrees: Double = 0,
        geometry: ApolloAstrolabeGeometry = .prototype,
        material: ApolloAstrolabeMaterial = .prototypeVioletStone
    ) {
        self.aegis = aegis
        self.geometry = geometry
        self.material = material
        self.rotationDegrees = Self.normalized(rotationDegrees)
    }

    public mutating func turn(to degrees: Double) {
        rotationDegrees = Self.normalized(degrees)
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
