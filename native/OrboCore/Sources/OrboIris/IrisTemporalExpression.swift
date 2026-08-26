import OrboCore

/// Presentation-only temporal placement around one active Horae plane.
///
/// Canonical Julian Day remains on the source point. Iris may compress only the
/// rendered Z distance from the selected Horae plane.
public struct IrisTemporalPlacement: Hashable, Sendable {
    public let source: IrisScenePoint3D
    public let activeJulianDay: JulianDay
    public let expansion: Double
    public let z: Double

    public init(
        source: IrisScenePoint3D,
        activeJulianDay: JulianDay,
        expansion: Double
    ) {
        let t = min(max(expansion, 0.0), 1.0)
        self.source = source
        self.activeJulianDay = activeJulianDay
        self.expansion = t
        self.z = activeJulianDay.value
            + ((source.z - activeJulianDay.value) * t)
    }
}

public enum IrisTemporalExpression {
    public static func placement(
        for point: IrisScenePoint3D,
        activeJulianDay: JulianDay,
        expansion: Double
    ) -> IrisTemporalPlacement {
        IrisTemporalPlacement(
            source: point,
            activeJulianDay: activeJulianDay,
            expansion: expansion
        )
    }

    public static func renderZ(
        for point: IrisScenePoint3D,
        activeJulianDay: JulianDay,
        expansion: Double
    ) -> Double {
        placement(
            for: point,
            activeJulianDay: activeJulianDay,
            expansion: expansion
        ).z
    }
}
