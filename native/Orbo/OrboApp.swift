import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                VStack(spacing: 12) {
                    Text("IRIS MVP / FROZEN")
                        .font(.caption.monospaced())

                    IrisChart3DView(
                        scene: IrisI4Fixture.scene,
                        presentation: IrisChart3DPresentation(
                            azimuthDegrees: 65,
                            inclinationDegrees: 28,
                            cameraProjection: .perspective
                        )
                    )
                }
                .padding()
            } else {
                Color.black
                    .ignoresSafeArea()
                    .accessibilityIdentifier("orbo.phase0.black-shell")
            }
        }
    }
}

/// Fixed typed input for the Iris MVP temporal-strand renderer proof only.
/// The host supplies every body, degree, motion, and time. Iris chooses none of them.
/// These coordinates are not an ephemeris claim.
private enum IrisI4Fixture {
    private static let baseJulianDay = 2_461_000.5
    private static let stepDays = 0.25

    private static let strands: [(body: MundaneBody, motion: Motion, degrees: [Double])] = [
        (.sun, .direct, [0, 4, 8, 12, 16, 20, 24, 28, 32]),
        (.mercury, .direct, [90, 97, 104, 111, 118, 125, 132, 139, 146]),
        (.mars, .direct, [180, 183, 186, 189, 192, 195, 198, 201, 204]),
        (.jupiter, .retrograde, [270, 266, 262, 258, 254, 250, 246, 242, 238]),
    ]

    static let scene = IrisScene3D(
        coordinates: strands.flatMap { strand in
            strand.degrees.enumerated().map { index, degree in
                coordinate(
                    strand.body,
                    degree: degree,
                    motion: strand.motion,
                    julianDay: baseJulianDay + (Double(index) * stepDays)
                )
            }
        }
    )

    private static func coordinate(
        _ body: MundaneBody,
        degree: Double,
        motion: Motion,
        julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: degree,
                motion: motion
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }
}
