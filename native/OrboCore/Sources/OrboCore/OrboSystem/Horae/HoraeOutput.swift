/// One presentation-neutral cross-section exposed by Horae at one UT.
///
/// Horae do not reinterpret or duplicate OrboSpine truth. The celestial and
/// Terra values remain the existing canonical OrboSpine types returned at this
/// temporal level.
public struct HoraeOutput: Hashable, Sendable {
    public let julianDay: JulianDay
    public let celestial: [OrboSpineCelestialCoordinate]
    public let terra: TerraMarrowSample

    public init(
        julianDay: JulianDay,
        celestial: [OrboSpineCelestialCoordinate],
        terra: TerraMarrowSample
    ) {
        self.julianDay = julianDay
        self.celestial = celestial
        self.terra = terra
    }
}
