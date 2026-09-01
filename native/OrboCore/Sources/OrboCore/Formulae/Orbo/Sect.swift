/// Orbo's canonical default formulae.
///
/// Alternate traditions may define their own formulae elsewhere under `Formulae`.
public enum OrboFormulae {
    /// Establishes the reusable Sect value from the native Ascendant and Sun.
    ///
    /// Both inputs are canonical longitudes on Orbo's [0, 360) ring.
    /// Directed distance from Ascendant to Sun determines which horizon
    /// semicircle contains the Sun:
    ///
    /// - 0° through 180° inclusive: day
    /// - strictly greater than 180° and strictly less than 360°: night
    ///
    /// Exact contact with either Ascendant (0°) or Descendant (180°) is day.
    public static func sect(
        ascendant: CelestialLongitude,
        sun: CelestialLongitude
    ) -> Sect {
        let distance = (sun.degrees - ascendant.degrees + 360)
            .truncatingRemainder(dividingBy: 360)

        return distance <= 180 ? .day : .night
    }
}
