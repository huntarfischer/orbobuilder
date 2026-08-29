/// Pass B direct seam from Apollo to Horae.
///
/// The requested Julian Day is supplied to Apollo. This seam does not establish
/// Astrolabe temporal ownership, retain a clock, inspect Locate, or calculate
/// celestial truth. Apollo asks Horae and returns Horae's answer unchanged.
public extension Apollo {
    static func askHorae(
        at julianDay: JulianDay,
        using horae: Horae
    ) throws -> HoraeOutput {
        try horae.seek(to: julianDay)
    }
}
