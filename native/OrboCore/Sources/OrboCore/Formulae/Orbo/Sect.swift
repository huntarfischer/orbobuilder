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
    /// - strictly between 0° and 180°: night (below the horizon)
    /// - 180° through 360°: day (above the horizon)
    ///
    /// Exact contact with either Ascendant (0°) or Descendant (180°) is day.
    public static func sect(
        ascendant: CelestialLongitude,
        sun: CelestialLongitude
    ) -> Sect {
        let distance = (sun.degrees - ascendant.degrees + 360)
            .truncatingRemainder(dividingBy: 360)

        return distance == 0 || distance >= 180 ? .day : .night
    }
}
