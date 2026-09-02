import Foundation
import OrboCore

/// Presentation-only text readout of one unchanged Horae frame.
///
/// The source frame remains authoritative. Iris derives labels and formatting
/// from the exact celestial coordinates and Terra sample Horae already carried
/// across the port. No clock, ephemeris, interpolation, or Locate access lives here.
public struct IrisHoraeTextReadout: Hashable, Sendable {
    public let frame: IrisHoraeFrame

    public init(frame: IrisHoraeFrame) {
        self.frame = frame
    }

    public var julianDay: JulianDay {
        frame.julianDay
    }

    public var rows: [IrisHoraeTextBodyRow] {
        frame.output.celestial.map(IrisHoraeTextBodyRow.init(source:))
    }

    public var terraReadout: IrisTerraReadout {
        frame.terraReadout
    }

    public var displayText: String {
        let bodyLines = rows.map(\.displayText).joined(separator: "\n")
        return [
            "HORAE",
            String(format: "UT · JD %.5f", julianDay.value),
            bodyLines,
            terraReadout.displayText,
        ].joined(separator: "\n")
    }
}

/// One textual manifestation of one canonical Horae celestial coordinate.
/// The complete source coordinate is retained so the readout can always be
/// traced back to the same truth that feeds Iris Scene3D.
public struct IrisHoraeTextBodyRow: Hashable, Sendable {
    public let source: OrboSpineCelestialCoordinate

    public init(source: OrboSpineCelestialCoordinate) {
        self.source = source
    }

    public var body: MundaneBody {
        source.body
    }

    public var longitude: CelestialLongitude {
        CelestialLongitude(source.directionalDegree.physicalDegrees)!
    }

    public var sign: Sign {
        longitude.sign
    }

    public var degreeInSign: Double {
        longitude.degreeInSign.value
    }

    public var motion: Motion {
        source.directionalDegree.motion
    }

    public var positionText: String {
        let suffix = motion == .retrograde ? " R" : ""
        return String(
            format: "%.2f° %@%@",
            degreeInSign,
            Self.signName(sign),
            suffix
        )
    }

    public var displayText: String {
        "\(body.displayName) · \(positionText)"
    }

    private static func signName(_ sign: Sign) -> String {
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
