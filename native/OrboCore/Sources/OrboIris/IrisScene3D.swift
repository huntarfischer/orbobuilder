import OrboCore

/// Presentation-neutral Iris scene truth.
///
/// Iris accepts existing canonical OrboSpine coordinates and preserves them
/// exactly. Visual projection and presentation state are separate concerns.
public struct IrisScene3D: Hashable, Sendable {
    public let coordinates: [OrboSpineCelestialCoordinate]

    public init(coordinates: [OrboSpineCelestialCoordinate]) {
        self.coordinates = coordinates
    }
}
