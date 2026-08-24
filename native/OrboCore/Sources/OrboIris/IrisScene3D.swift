import Foundation
import OrboCore

/// One visualization-native 3D point derived from one canonical OrboSpine
/// celestial coordinate.
///
/// The source remains attached unchanged. X/Y are the Cartesian projection of
/// the source's physical zodiac longitude on a unit circle. Z is the source's
/// Julian Day without normalization or temporal reinterpretation.
public struct IrisScenePoint3D: Hashable, Sendable {
    public let source: OrboSpineCelestialCoordinate
    public let x: Double
    public let y: Double
    public let z: Double

    public init(source: OrboSpineCelestialCoordinate) {
        let radians = source.directionalDegree.physicalDegrees * .pi / 180

        self.source = source
        self.x = cos(radians)
        self.y = sin(radians)
        self.z = source.julianDay.value
    }
}

/// Presentation-neutral Iris scene truth.
///
/// Iris accepts existing canonical OrboSpine coordinates and preserves them
/// exactly. Visual projection and presentation state are separate concerns.
public struct IrisScene3D: Hashable, Sendable {
    public let coordinates: [OrboSpineCelestialCoordinate]

    public init(coordinates: [OrboSpineCelestialCoordinate]) {
        self.coordinates = coordinates
    }

    public var points: [IrisScenePoint3D] {
        coordinates.map(IrisScenePoint3D.init(source:))
    }
}
