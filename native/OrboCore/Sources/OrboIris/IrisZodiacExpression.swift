import Foundation
import OrboCore

/// Iris-owned visual family for one canonical zodiac sign.
public enum IrisZodiacFamily: String, CaseIterable, Hashable, Sendable {
    case fire
    case earth
    case air
    case water
}

/// Three related visual weights within each element family.
public enum IrisZodiacShade: Int, CaseIterable, Hashable, Sendable {
    case light
    case middle
    case deep
}

/// Presentation-only description of one canonical Orbo sign.
public struct IrisZodiacAppearance: Hashable, Sendable {
    public let sign: Sign
    public let family: IrisZodiacFamily
    public let shade: IrisZodiacShade

    public init(sign: Sign) {
        self.sign = sign
        switch sign {
        case .aries:
            self.family = .fire
            self.shade = .light
        case .leo:
            self.family = .fire
            self.shade = .middle
        case .sagittarius:
            self.family = .fire
            self.shade = .deep
        case .taurus:
            self.family = .earth
            self.shade = .light
        case .virgo:
            self.family = .earth
            self.shade = .middle
        case .capricorn:
            self.family = .earth
            self.shade = .deep
        case .gemini:
            self.family = .air
            self.shade = .light
        case .libra:
            self.family = .air
            self.shade = .middle
        case .aquarius:
            self.family = .air
            self.shade = .deep
        case .cancer:
            self.family = .water
            self.shade = .light
        case .scorpio:
            self.family = .water
            self.shade = .middle
        case .pisces:
            self.family = .water
            self.shade = .deep
        }
    }
}

/// One sign sector of the zodiac rim. Degrees remain canonical Orbo longitude.
public struct IrisZodiacRimSector: Hashable, Sendable {
    public let sign: Sign
    public let startDegrees: Double
    public let endDegrees: Double
    public let appearance: IrisZodiacAppearance

    public init(sign: Sign) {
        self.sign = sign
        self.startDegrees = Double(sign.rawValue) * 30.0
        self.endDegrees = self.startDegrees + 30.0
        self.appearance = IrisZodiacAppearance(sign: sign)
    }

    public static let canonical: [IrisZodiacRimSector] =
        Sign.canonicalOrder.map(IrisZodiacRimSector.init(sign:))
}

/// Zodiac expression of one unchanged OrboSpine coordinate.
public struct IrisZodiacPlacement: Hashable, Sendable {
    public let source: OrboSpineCelestialCoordinate
    public let longitude: CelestialLongitude
    public let sign: Sign
    public let degreeInSign: DegreeInSign
    public let appearance: IrisZodiacAppearance

    public init(source: OrboSpineCelestialCoordinate) {
        self.source = source
        let longitude = CelestialLongitude(source.directionalDegree.physicalDegrees)!
        self.longitude = longitude
        self.sign = longitude.sign
        self.degreeInSign = longitude.degreeInSign
        self.appearance = IrisZodiacAppearance(sign: longitude.sign)
    }

    public var displayText: String {
        let degrees = Int(degreeInSign.value)
        let minutes = Int((degreeInSign.value - Double(degrees)) * 60.0)
        let retrograde = source.directionalDegree.motion == .retrograde ? " ℞" : ""
        return "\(source.body.displayName) \(degrees)°\(String(format: "%02d", minutes))′ \(Self.displayName(for: sign))\(retrograde)"
    }

    private static func displayName(for sign: Sign) -> String {
        switch sign {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }
}
