/// The smallest universal-Timespine seam needed by the temporal Titan passes.
/// It reads already-forged OrboSpine matter and owns no astronomy.
public protocol NatalSpineTimespinePort: Sendable {
    func coordinate(
        of body: MundaneBody,
        at julianDay: JulianDay
    ) throws -> OrboSpineCelestialCoordinate

    func occurrences(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [OrboSpineCelestialCoordinate]
}

extension OrboSpineLocate: NatalSpineTimespinePort {}
