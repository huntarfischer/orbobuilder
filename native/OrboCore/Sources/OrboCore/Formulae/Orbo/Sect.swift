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
    /// - strictly greater than 0° and strictly less than 180°: night
    /// - otherwise: day
    ///
    /// Exact contact with either Ascendant (0°) or Descendant (180°) defaults to day.
    public static func sect(
        ascendant: CelestialLongitude,
        sun: CelestialLongitude
    ) -> Sect {
        let distance = (sun.degrees - ascendant.degrees + 360)
            .truncatingRemainder(dividingBy: 360)

        return distance > 0 && distance < 180 ? .night : .day
    }
}
