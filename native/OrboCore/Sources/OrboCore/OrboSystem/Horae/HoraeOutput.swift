/// One presentation-neutral cross-section exposed by Horae at one UT.
///
/// Horae do not reinterpret or duplicate OrboSpine truth. The celestial and
/// Terra values remain the existing canonical OrboSpine types returned at this
/// temporal level. Optional control/readout metadata rides inside this same
/// outward signal; Horae do not create a second control output.
public struct HoraeOutput: Hashable, Sendable {
    public let julianDay: JulianDay
    public let celestial: [OrboSpineCelestialCoordinate]
    public let terra: TerraMarrowSample
    public let controlState: HoraeControlState?

    public init(
        julianDay: JulianDay,
        celestial: [OrboSpineCelestialCoordinate],
        terra: TerraMarrowSample,
        controlState: HoraeControlState? = nil
    ) {
        self.julianDay = julianDay
        self.celestial = celestial
        self.terra = terra
        self.controlState = controlState
    }
}
