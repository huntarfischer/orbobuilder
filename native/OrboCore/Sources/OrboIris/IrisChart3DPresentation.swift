/// Presentation-only choices for an Iris Chart3D view.
///
/// These values may change how a lawful Iris scene is viewed, but they do not
/// alter, replace, or reinterpret any scene coordinate.
public enum IrisCameraProjection: Hashable, Sendable {
    case orthographic
    case perspective
}

/// The first Iris visualization uses three canonical locked readings of the
/// same 3D temporal scene. There is deliberately no free-orbit camera here.
public enum IrisCameraMode: String, CaseIterable, Hashable, Sendable {
    /// Look straight along Orbo's temporal Z axis.
    case topDown

    /// Show Orbo's temporal Z axis vertically in the screen plane.
    case vertical

    /// Show Orbo's temporal Z axis horizontally in the screen plane.
    case horizontal
}

public struct IrisChart3DPresentation: Hashable, Sendable {
    public let cameraProjection: IrisCameraProjection
    public let cameraMode: IrisCameraMode
    public let orientationMode: IrisOrientationMode
    public let bodySizeMode: IrisBodySizeMode
    public let trackOrder: IrisTrackOrder
    public let trackExpansion: Double
    public let timeExpansion: Double

    public init(
        // Retained as source compatibility for earlier Iris callers. Locked
        // camera modes intentionally ignore arbitrary azimuth/inclination.
        azimuthDegrees: Double = 20,
        inclinationDegrees: Double = 7,
        cameraProjection: IrisCameraProjection = .orthographic,
        cameraMode: IrisCameraMode = .topDown,
        orientationMode: IrisOrientationMode = .scene,
        bodySizeMode: IrisBodySizeMode = .planetSized,
        trackOrder: IrisTrackOrder = .astroDNA,
        trackExpansion: Double = 1.0,
        timeExpansion: Double = 1.0
    ) {
        _ = azimuthDegrees
        _ = inclinationDegrees
        self.cameraProjection = cameraProjection
        self.cameraMode = cameraMode
        self.orientationMode = orientationMode
        self.bodySizeMode = bodySizeMode
        self.trackOrder = trackOrder
        self.trackExpansion = min(max(trackExpansion, 0.0), 1.0)
        self.timeExpansion = min(max(timeExpansion, 0.0), 1.0)
    }
}
