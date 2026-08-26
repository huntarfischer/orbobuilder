import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                VStack(spacing: 12) {
                    Text("IRIS IX8 / TEMPORAL FLATTEN")
                        .font(.caption.monospaced())

                    Text("timeExpansion 0.20 · source UT unchanged")
                        .font(.caption2.monospaced())

                    Text(IrisIX8Harness.activePlane.terraReadout.displayText)
                        .font(.caption2.monospaced())

                    Text("Horae plane anchors visible Z · Terra preserved")
                        .font(.caption2.monospaced())

                    IrisChart3DView(
                        scene: IrisIX8Harness.viewport.scene,
                        plane: IrisIX8Harness.activePlane,
                        presentation: IrisChart3DPresentation(
                            azimuthDegrees: 65,
                            inclinationDegrees: 28,
                            cameraProjection: .perspective,
                            timeExpansion: 0.20
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

/// IX8 host-side integration harness.
///
/// Deterministic support matter enters the real OrboSpine Locate -> Horae route.
/// Iris owns only the visible interval, sampling density, selected Horae plane,
/// and presentation-only spatial compression around that plane. Every source
/// coordinate retains its canonical Julian Day. Terra remains attached exactly
/// as supplied by Horae. The support values are a visualization harness, not an
/// ephemeris claim; certified production OrboSpine matter is not bundled into
/// the app target yet.
private enum IrisIX8Harness {
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

    /// Explicit current cross-section: the middle Horae frame of the visible window.
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
