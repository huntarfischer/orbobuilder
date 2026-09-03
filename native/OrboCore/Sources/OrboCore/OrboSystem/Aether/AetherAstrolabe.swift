public extension Aether {
    /// Authored environmental material transcribed from the prototype's root
    /// field. These decorative stars are not celestial body coordinates.
    static var astrolabeEnvironment: AetherEnvironment {
        func stop(_ position: Double, _ red: Double, _ green: Double, _ blue: Double) -> AetherFieldStop {
            AetherFieldStop(position: position, color: AetherColorValue(red: red, green: green, blue: blue))
        }
        return establishEnvironment(
            celestialField: AetherField(stops: [
                stop(0, 0.047, 0.031, 0.122), stop(0.24, 0.075, 0.102, 0.243),
                stop(0.46, 0.149, 0.286, 0.431)
            ]),
            starField: [
                (0.06, 0.02), (0.18, 0.09), (0.59, 0.03), (0.76, 0.16),
                (0.32, 0.22), (0.92, 0.05), (0.08, 0.28), (0.63, 0.29),
                (0.47, 0.11), (0.86, 0.37), (0.22, 0.41), (0.54, 0.46)
            ].map { AetherStar(horizontalPosition: $0.0, verticalPosition: $0.1, apparentRadius: 0.7, intensity: 0.3) },
            earthwardField: AetherField(stops: [
                stop(0.68, 0.494, 0.373, 0.180), stop(0.82, 0.580, 0.322, 0.169),
                stop(0.94, 0.486, 0.227, 0.184), stop(1, 0.388, 0.165, 0.165)
            ])
        )
    }
}
