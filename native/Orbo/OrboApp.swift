import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                IrisLockedPerspectiveView()
            } else {
                Color.black
                    .ignoresSafeArea()
                    .accessibilityIdentifier("orbo.phase0.black-shell")
            }
        }
    }
}

@available(iOS 26.0, *)
private struct IrisLockedPerspectiveView: View {
    @State private var cameraMode: IrisCameraMode = .vertical

    var body: some View {
        VStack(spacing: 12) {
            Text("IRIS / LOCKED TEMPORAL VIEW")
                .font(.caption.monospaced())

            Text("11 bodies · 35 temporal samples")
                .font(.caption2.monospaced())

            Picker("Perspective", selection: $cameraMode) {
                Text("Top").tag(IrisCameraMode.topDown)
                Text("Vertical").tag(IrisCameraMode.vertical)
                Text("Horizontal").tag(IrisCameraMode.horizontal)
            }
            .pickerStyle(.segmented)

            IrisChart3DView(
                scene: IrisLockedPerspectiveHarness.viewport.scene,
                presentation: IrisChart3DPresentation(
                    cameraProjection: .perspective,
                    cameraMode: cameraMode
                )
            )
        }
        .padding()
    }
}

/// Host-side proof of the first Iris temporal visualization with no free-orbit
/// camera. The 35 resolved moments remain one 3D temporal scene; the selector
/// changes only which canonical locked perspective Iris uses to view it.
///
/// Deterministic support matter enters the real OrboSpine Locate -> Horae -> Iris
/// route. These support values are a visualization harness, not an ephemeris claim.
private enum IrisLockedPerspectiveHarness {
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
