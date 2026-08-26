/// Presentation-only choices for an Iris Chart3D view.
///
/// These values may change how a lawful Iris scene is viewed, but they do not
/// alter, replace, or reinterpret any scene coordinate.
public enum IrisCameraProjection: Hashable, Sendable {
    case orthographic
    case perspective
}

public struct IrisChart3DPresentation: Hashable, Sendable {
    public let azimuthDegrees: Double
    public let inclinationDegrees: Double
    public let cameraProjection: IrisCameraProjection
    public let bodySizeMode: IrisBodySizeMode

    public init(
        azimuthDegrees: Double = 20,
        inclinationDegrees: Double = 7,
        cameraProjection: IrisCameraProjection = .orthographic,
        bodySizeMode: IrisBodySizeMode = .planetSized
    ) {
        self.azimuthDegrees = azimuthDegrees
        self.inclinationDegrees = inclinationDegrees
        self.cameraProjection = cameraProjection
        self.bodySizeMode = bodySizeMode
    }
}
