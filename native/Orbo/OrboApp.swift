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
    @State private var manifestation: IrisManifestation
    @State private var cameraMode: IrisCameraMode = .topDown

    init() {
        _manifestation = State(
            initialValue: CommandLine.arguments.contains("--iris-text-proof")
                ? .text
                : .chart3D
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("IRIS / HORAE")
                .font(.caption.monospaced())

            Text("11 bodies · one Horae moment · one frame")
                .font(.caption2.monospaced())

            Picker("Manifestation", selection: $manifestation) {
                Text("3D").tag(IrisManifestation.chart3D)
                Text("Text").tag(IrisManifestation.text)
            }
            .pickerStyle(.segmented)

            switch manifestation {
            case .chart3D:
                Picker("Perspective", selection: $cameraMode) {
                    Text("Top").tag(IrisCameraMode.topDown)
                    Text("Vertical").tag(IrisCameraMode.vertical)
                    Text("Horizontal").tag(IrisCameraMode.horizontal)
                }
                .pickerStyle(.segmented)

                IrisChart3DView(
                    scene: IrisLockedPerspectiveHarness.frame.scene,
                    presentation: IrisChart3DPresentation(
                        cameraProjection: .orthographic,
                        cameraMode: cameraMode,
                        orientationMode: .zodiacal
                    )
                )

            case .text:
                IrisHoraeTextView(frame: IrisLockedPerspectiveHarness.frame)
            }
        }
        .padding()
    }
}

private enum IrisManifestation: Hashable {
    case chart3D
    case text
}

/// Host-side proof of the three canonical Iris viewpoints using exactly one
/// Horae-resolved celestial state. Nothing moves through time in this proof.
/// The same 11-body frame can now be manifested either spatially or textually.
///
/// Vertical and Horizontal are intentionally established now as stable spatial
/// frames so later temporal manifestations can use them to reveal movement
/// through time. Top remains the one-moment reading.
private enum IrisLockedPerspectiveHarness {
    private static let baseJulianDay = 2_461_000.5
    private static let selectedJulianDay = JulianDay(baseJulianDay + 4.5)!

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

    private static let bone = OrboSpineBoneSpan(
        start: JulianDay(baseJulianDay)!,
        end: JulianDay(baseJulianDay + 9.0)!
    )!

    private static let supports: [OrboSpineCelestialCoordinate] = bodyPlans.flatMap { plan in
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

    private static let terra = [
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

    private static let locate = OrboSpineLocate(
        bone: bone,
        celestialSupports: supports,
        terraSamples: terra
    )!

    private static let horae = Horae(locate: locate)

    static let frame = IrisHoraeFrame(
        output: try! horae.seek(to: selectedJulianDay)
    )

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
