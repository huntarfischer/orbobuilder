/// Platform-neutral environmental matter governed by Aether.
///
/// These values describe what exists in the Astrosphere environment. They do
/// not prescribe how Iris or any presentation framework renders that matter.
public struct AetherColorValue: Hashable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public struct AetherFieldStop: Hashable, Sendable {
    public let position: Double
    public let color: AetherColorValue

    public init(position: Double, color: AetherColorValue) {
        self.position = position
        self.color = color
    }
}

public struct AetherField: Hashable, Sendable {
    public let stops: [AetherFieldStop]

    public init(stops: [AetherFieldStop]) {
        self.stops = stops
    }
}

public struct AetherStar: Hashable, Sendable {
    public let horizontalPosition: Double
    public let verticalPosition: Double
    public let apparentRadius: Double
    public let intensity: Double

    public init(
        horizontalPosition: Double,
        verticalPosition: Double,
        apparentRadius: Double,
        intensity: Double
    ) {
        self.horizontalPosition = horizontalPosition
        self.verticalPosition = verticalPosition
        self.apparentRadius = apparentRadius
        self.intensity = intensity
    }
}

public struct AetherEnvironment: Hashable, Sendable {
    public let celestialField: AetherField
    public let starField: [AetherStar]
    public let earthwardField: AetherField

    public init(
        celestialField: AetherField,
        starField: [AetherStar],
        earthwardField: AetherField
    ) {
        self.celestialField = celestialField
        self.starField = starField
        self.earthwardField = earthwardField
    }
}
