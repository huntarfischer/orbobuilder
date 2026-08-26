import Foundation
import OrboCore

/// One presentation point on the colored zodiac rim carried by a Horae plane.
/// Longitude and sign come from canonical Orbo zodiac law; Iris owns only the
/// radius and visible placement of the rim.
public struct IrisZodiacRimPoint: Hashable, Sendable {
    public let sign: Sign
    public let longitudeDegrees: Double
    public let appearance: IrisZodiacAppearance
    public let x: Double
    public let y: Double
    public let z: Double

    public init(
        longitude: CelestialLongitude,
        julianDay: JulianDay,
        radius: Double
    ) {
        self.sign = longitude.sign
        self.longitudeDegrees = longitude.degrees
        self.appearance = IrisZodiacAppearance(sign: longitude.sign)

        let radians = longitude.degrees * .pi / 180.0
        self.x = cos(radians) * radius
        self.y = sin(radians) * radius
        self.z = julianDay.value
    }
}

/// The explicit selected-UT cross-section carried outward from Horae.
///
/// The plane retains the complete Horae frame, including Terra. Its celestial
/// marks are exactly the frame's canonical coordinates. The zodiac rim is
/// presentation geometry placed at the same raw Julian Day.
public struct IrisHoraePlane: Hashable, Sendable {
    public static let rimSampleCount = 360

    public let frame: IrisHoraeFrame

    public init(frame: IrisHoraeFrame) {
        self.frame = frame
    }

    public var julianDay: JulianDay {
        frame.julianDay
    }

    public var terra: TerraMarrowSample {
        frame.terra
    }

    public var bodyCoordinates: [OrboSpineCelestialCoordinate] {
        frame.output.celestial
    }

    public var bodyPoints: [IrisScenePoint3D] {
        frame.scene.points
    }

    /// A one-degree presentation sampling of the canonical twelve-sign rim.
    /// Samples sit at degree centers so every point belongs unambiguously to one
    /// canonical sign while the 30-degree boundaries remain exact in Orbo law.
    public func rimPoints(radius: Double) -> [IrisZodiacRimPoint] {
        precondition(radius.isFinite && radius > 0)

        return (0..<Self.rimSampleCount).map { degree in
            let longitude = CelestialLongitude(Double(degree) + 0.5)!
            return IrisZodiacRimPoint(
                longitude: longitude,
                julianDay: julianDay,
                radius: radius
            )
        }
    }
}
