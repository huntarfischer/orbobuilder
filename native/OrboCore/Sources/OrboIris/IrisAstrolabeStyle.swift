import SwiftUI
import OrboCore

/// The prototype's classic instrument finish, independent of the older 3D palette.
enum IrisAstrolabeStyle {
    static let ink = Color(red: 0.07, green: 0.035, blue: 0.17)
    static let text = Color(red: 0.84, green: 0.81, blue: 0.94)
    static let gold = Color(red: 0.91, green: 0.67, blue: 0.25)
    static let signs = ["♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎", "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎"]

    static func color(_ sign: Sign) -> Color {
        switch IrisZodiacAppearance(sign: sign).family {
        case .fire: return Color(red: 0.84, green: 0.27, blue: 0.25)
        case .earth: return Color(red: 0.85, green: 0.44, blue: 0.21)
        case .air: return gold
        case .water: return Color(red: 0.30, green: 0.64, blue: 0.85)
        }
    }

    static func glyph(_ gene: AstroDNAGene) -> String {
        switch gene {
        case .ascendant: return "As"
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        }
    }

    static func position(_ longitude: CelestialLongitude, precise: Bool = true) -> String {
        let seconds = Int((longitude.degreeInSign.value * 3600).rounded(.down))
        return precise ? "\(seconds / 3600)°\((seconds % 3600) / 60)′" : "\(seconds / 3600)°"
    }
}

/// Pure screen geometry. Changing the orientation never changes a source longitude.
public struct IrisAegisGeometry {
    public let diameter: Double
    public let horizon: Double?

    public init(diameter: Double, horizon: Double?) {
        self.diameter = diameter
        self.horizon = horizon
    }

    public func point(longitude: Double, radius: Double) -> CGPoint {
        let angle = (180 + longitude - (horizon ?? 0)) * Double.pi / 180
        return CGPoint(x: diameter / 2 + radius * cos(angle), y: diameter / 2 - radius * sin(angle))
    }
}

/// Transcribes _moonFace's lit half and elliptical shadow using Apollo's Ring
/// separation. The ellipse is display geometry; Iris does not infer lunar events.
struct IrisMoonFace: View {
    let separation: Double
    let color: Color
    /// The wheel supplies the Sun's screen bearing; the header uses waxing/waning.
    var illuminationBearing: Double? = nil
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            let elongation = min(separation, 360 - separation)
            ZStack {
                Circle().fill(IrisAstrolabeStyle.ink)
                Rectangle().fill(color).frame(width: size / 2).offset(x: size / 4)
                Ellipse().fill(elongation < 90 ? IrisAstrolabeStyle.ink : color)
                    .frame(width: abs(cos(elongation * .pi / 180)) * size)
            }
            .clipShape(Circle())
            .rotationEffect(.degrees(illuminationBearing ?? (separation < 180 ? 0 : 180)))
            .overlay(Circle().stroke(color.opacity(0.45), lineWidth: 0.6))
        }
        .accessibilityLabel("Moon phase")
    }
}
