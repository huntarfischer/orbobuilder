/// Presentation-only choices for an Iris Chart3D view.
///
/// These values may change how a lawful Iris scene is viewed, but they do not
/// alter, replace, or reinterpret any scene coordinate.
public enum IrisCameraProjection: Hashable, Sendable {
    case orthographic
    case perspective
}

public enum IrisCameraMode: Hashable, Sendable {
    /// Existing freely rotatable 3D Timespine view.
    case free3D

    /// Look straight down the Timespine Z axis onto the active Horae plane.
    case celestialFace
}

public struct IrisChart3DPresentation: Hashable, Sendable {
    public let azimuthDegrees: Double
    public let inclinationDegrees: Double
    public let cameraProjection: IrisCameraProjection
    public let cameraMode: IrisCameraMode
    public let orientationMode: IrisOrientationMode
    public let bodySizeMode: IrisBodySizeMode
    public let trackOrder: IrisTrackOrder
    public let trackExpansion: Double
    public let timeExpansion: Double

    public init(
        azimuthDegrees: Double = 20,
        inclinationDegrees: Double = 7,
        cameraProjection: IrisCameraProjection = .orthographic,
        cameraMode: IrisCameraMode = .free3D,
        orientationMode: IrisOrientationMode = .scene,
        bodySizeMode: IrisBodySizeMode = .planetSized,
        trackOrder: IrisTrackOrder = .astroDNA,
        trackExpansion: Double = 1.0,
        timeExpansion: Double = 1.0
    ) {
        self.azimuthDegrees = azimuthDegrees
        self.inclinationDegrees = inclinationDegrees
        self.cameraProjection = cameraProjection
        self.cameraMode = cameraMode
        self.orientationMode = orientationMode
        self.bodySizeMode = bodySizeMode
        self.trackOrder = trackOrder
        self.trackExpansion = min(max(trackExpansion, 0.0), 1.0)
        self.timeExpansion = min(max(timeExpansion, 0.0), 1.0)
    }

    /// Named IX9 state: one flat, orthographic, zodiac-oriented Horae face.
    public var isCelestialAstrolabeFace: Bool {
        cameraMode == .celestialFace
            && cameraProjection == .orthographic
            && orientationMode == .zodiacal
            && timeExpansion == 0.0
    }
}
