/// Presentation-only planar orientation for Iris celestial views.
///
/// Frozen Iris scene coordinates remain unchanged. Zodiacal orientation rotates
/// the displayed X/Y plane by 180 degrees so Orbo's convention reads:
///
/// 0° Aries       = 9 o'clock
/// 90° Cancer     = 6 o'clock
/// 180° Libra     = 3 o'clock
/// 270° Capricorn = 12 o'clock
public enum IrisOrientationMode: Hashable, Sendable {
    /// Preserve the frozen Iris scene's mathematical X/Y orientation.
    case scene

    /// Orbo zodiacal face orientation. Local/Ascendant orientation comes later.
    case zodiacal
}

public struct IrisPlanarPlacement: Hashable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public enum IrisOrientationExpression {
    public static func placement(
        x: Double,
        y: Double,
        mode: IrisOrientationMode
    ) -> IrisPlanarPlacement {
        switch mode {
        case .scene:
            return IrisPlanarPlacement(x: x, y: y)
        case .zodiacal:
            return IrisPlanarPlacement(x: -x, y: -y)
        }
    }
}
