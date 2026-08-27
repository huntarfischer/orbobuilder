import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                VStack(spacing: 12) {
                    Text("IRIS IX9 / CELESTIAL ASTROLABE")
                        .font(.caption.monospaced())

                    Text("flat Horae face · orthographic · zodiacal")
                        .font(.caption2.monospaced())

                    Text(IrisIX9Harness.activePlane.terraReadout.displayText)
                        .font(.caption2.monospaced())

                    Text("0° Aries at 9 o'clock · local Horizon deferred")
                        .font(.caption2.monospaced())

                    IrisChart3DView(
                        scene: IrisIX9Harness.viewport.scene,
                        plane: IrisIX9Harness.activePlane,
                        presentation: IrisChart3DPresentation(
                            cameraProjection: .orthographic,
                            cameraMode: .celestialFace,
                            orientationMode: .zodiacal,
                            timeExpansion: 0.0
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

/// IX9 host-side integration harness.
///
/// The active celestial Astrolabe is not a regenerated chart. It is the same
/// IX6 Horae plane viewed straight down the Timespine Z axis after IX8 collapses
/// visible temporal depth to zero. Zodiacal orientation is Iris presentation
/// only: canonical longitudes, UT, body identity, and Terra remain unchanged.
/// Deterministic support matter still enters the real OrboSpine Locate -> Horae
/// route; it is a visualization harness, not an ephemeris claim.
private enum IrisIX9Harness {
    private static let baseJulianDay = 2_461_000.5

    private static let bodyPlans: [(
        body: MundaneBody,
        startDegrees: Double,
        dailyDegrees: Double
    )] = [
        (.sun, 29.2, 0.95),
        (.moon, 62.0, 5.0),
        (.mercury, 1.0, -0.8),
        (.venus, 96.0, 0.7),
        (.mars, 128.0, 0.5),
        (.jupiter, 158.0, 0.15),
        (.saturn, 188.0, 0.08),
        (.uranus, 218.0, 0.03),
        (.neptune, 248.0, 0.02),
        (.pluto, 278.0, 0.01),
        (.trueNorthNode, 308.0, -0.04),
    ]

    static let viewport: IrisTimespineViewport = {
        let bone = OrboSpineBoneSpan(
            start: JulianDay(baseJulianDay)!,
            end: JulianDay(baseJulianDay + 9.0)!
        )!

        let supports = bodyPlans.flatMap { plan in
            (0...8).map { index in
                coordinate(
                    body: plan.body,
                    physicalDegrees: normalize(
                        plan.startDegrees + (Double(index) * plan.dailyDegrees)
                    ),
                    motion: plan.dailyDegrees < 0 ? .retrograde : .direct,
                    julianDay: baseJulianDay + Double(index)
                )
            }
        }

        let terra = [
            TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: bone.start
            )!,
            TerraMarrowSample(
                turnDegrees: 109,
                tiltDegrees: 23.5,
                julianDay: bone.end
            )!,
        ]

        let locate = OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        )!
        let horae = Horae(locate: locate)

        return try! IrisTimespineViewport(
            horae: horae,
            start: JulianDay(baseJulianDay + 0.25)!,
            end: JulianDay(baseJulianDay + 8.75)!,
            sampleCount: 35
        )
    }()

    /// Exact current face: the middle Horae frame of the visible window.
    static let activePlane = IrisHoraePlane(frame: viewport.frames[17])

    private static func coordinate(
        body: MundaneBody,
        physicalDegrees: Double,
        motion: Motion,
        julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }

    private static func normalize(_ degrees: Double) -> Double {
        let value = degrees.truncatingRemainder(dividingBy: 360)
        return value < 0 ? value + 360 : value
    }
}
