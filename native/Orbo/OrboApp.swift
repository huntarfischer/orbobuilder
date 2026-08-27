import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                IrisNativeMediumStudyView()
            } else {
                Color.black
                    .ignoresSafeArea()
                    .accessibilityIdentifier("orbo.phase0.black-shell")
            }
        }
    }
}

@available(iOS 26.0, *)
private struct IrisNativeMediumStudyView: View {
    private enum Medium: String, CaseIterable, Hashable {
        case canvas = "Canvas"
        case chart3D = "Chart3D"
    }

    @State private var medium: Medium = .canvas
    @State private var concentricTracks = false
    @State private var planetSizedBodies = true

    private var trackExpansion: Double {
        concentricTracks ? 1.0 : 0.0
    }

    private var bodySizeMode: IrisBodySizeMode {
        planetSizedBodies ? .planetSized : .equal
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("IRIS / NATIVE MEDIUM STUDY")
                .font(.caption.monospaced())

            Text("same Horae moment · same Iris laws · different native surface")
                .font(.caption2.monospaced())
                .multilineTextAlignment(.center)

            Picker("Medium", selection: $medium) {
                ForEach(Medium.allCases, id: \.self) { medium in
                    Text(medium.rawValue).tag(medium)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Toggle("Concentric", isOn: $concentricTracks)
                Toggle("Planet-sized", isOn: $planetSizedBodies)
            }
            .font(.caption)

            Group {
                switch medium {
                case .canvas:
                    IrisCanvasInstrumentView(
                        plane: IrisNativeMediumHarness.plane,
                        orientationMode: .zodiacal,
                        bodySizeMode: bodySizeMode,
                        trackOrder: .astroDNA,
                        trackExpansion: trackExpansion
                    )

                case .chart3D:
                    IrisChart3DView(
                        scene: IrisScene3D(coordinates: []),
                        plane: IrisNativeMediumHarness.plane,
                        presentation: IrisChart3DPresentation(
                            cameraProjection: .orthographic,
                            cameraMode: .topDown,
                            orientationMode: .zodiacal,
                            bodySizeMode: bodySizeMode,
                            trackOrder: .astroDNA,
                            trackExpansion: trackExpansion,
                            timeExpansion: 0.0
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

/// Host-side native-medium comparison using exactly one Horae-resolved state.
///
/// The fixture remains intentionally synthetic. This study is not testing new
/// celestial truth; it is comparing two native rendering surfaces while holding
/// the lawful Iris input and presentation grammar constant.
private enum IrisNativeMediumHarness {
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

    static let plane = IrisHoraePlane(frame: frame)

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
