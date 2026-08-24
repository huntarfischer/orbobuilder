import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                VStack(spacing: 12) {
                    Text("IRIS I3 / FIRST SIGHT")
                        .font(.caption.monospaced())

                    IrisChart3DView(scene: IrisI3Fixture.scene)
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

/// Fixed typed input for the I3 renderer proof only.
/// These coordinates are not an ephemeris claim and Iris does not manufacture them.
private enum IrisI3Fixture {
    static let scene = IrisScene3D(coordinates: [
        coordinate(.sun, degree: 0, motion: .direct, julianDay: 2_461_000.5),
        coordinate(.mercury, degree: 90, motion: .direct, julianDay: 2_461_000.5),
        coordinate(.mars, degree: 180, motion: .direct, julianDay: 2_461_000.5),
        coordinate(.jupiter, degree: 270, motion: .retrograde, julianDay: 2_461_000.5),
        coordinate(.sun, degree: 8, motion: .direct, julianDay: 2_461_001.5),
        coordinate(.mercury, degree: 102, motion: .direct, julianDay: 2_461_001.5),
        coordinate(.mars, degree: 185, motion: .direct, julianDay: 2_461_001.5),
        coordinate(.jupiter, degree: 262, motion: .retrograde, julianDay: 2_461_001.5),
    ])

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
