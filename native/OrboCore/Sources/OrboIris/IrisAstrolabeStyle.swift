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

    /// The graduated limb belongs to the instrument, independently of its horizon.
    public func graduation(degree: Double, radius: Double) -> CGPoint {
        IrisAegisGeometry(diameter: diameter, horizon: nil).point(longitude: degree, radius: radius)
    }

    /// _drawLitTrack: neighboring bodies alternate depth on the Rete. Longitude
    /// remains untouched. Rank is drawing order, not an orbital calculator.
    static func trackOffsets(_ placements: [AstrolabePlacement]) -> [AstroDNAGene: Double] {
        let rank: [AstroDNAGene] = [.moon, .mercury, .venus, .sun, .mars, .jupiter, .northNode, .saturn, .uranus, .neptune, .pluto, .ascendant]
        let sorted = placements.sorted { $0.longitude.degrees < $1.longitude.degrees }
        var clusters: [[AstrolabePlacement]] = []
        for placement in sorted {
            if let last = clusters.last?.last, placement.longitude.degrees - last.longitude.degrees < 9 {
                clusters[clusters.count - 1].append(placement)
            } else { clusters.append([placement]) }
        }
        // The zodiac has a seam, not a gap between neighboring Pisces/Aries marks.
        if clusters.count > 1, let first = sorted.first, let last = sorted.last,
           first.longitude.degrees + 360 - last.longitude.degrees < 9 {
            let tail = clusters.removeLast()
            clusters[0] = tail + clusters[0]
        }
        var offsets: [AstroDNAGene: Double] = [:]
        for cluster in clusters {
            let ordered = cluster.sorted { rank.firstIndex(of: $0.gene)! < rank.firstIndex(of: $1.gene)! }
            for (index, placement) in ordered.enumerated() { offsets[placement.gene] = Double(index % 2) * 6 }
        }
        return offsets
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
