import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, *) {
                IrisIX10DemoView()
            } else {
                Color.black
                    .ignoresSafeArea()
                    .accessibilityIdentifier("orbo.phase0.black-shell")
            }
        }
    }
}

@available(iOS 26.0, *)
private struct IrisIX10DemoView: View {
    @State private var session = IrisIX10Harness.initialSession
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 10) {
            Text("IRIS IX10 / HORAE CONTROLS")
                .font(.caption.monospaced())

            Text("absolute UT · relative UT · body focus")
                .font(.caption2.monospaced())

            Text(
                "JD \(session.frame.julianDay.value, format: .number.precision(.fractionLength(5)))"
            )
            .font(.caption2.monospaced())

            Slider(
                value: Binding(
                    get: { session.frame.julianDay.value },
                    set: seekAbsolute(to:)
                ),
                in: session.domain.start.value...session.domain.endExclusive.value.nextDown
            )
            .accessibilityLabel("Absolute UT")

            HStack(spacing: 18) {
                Button("−12h") {
                    shift(hours: -12)
                }
                .disabled(!canShift(hours: -12))

                Text("relative UT")
                    .font(.caption2.monospaced())

                Button("+12h") {
                    shift(hours: 12)
                }
                .disabled(!canShift(hours: 12))
            }

            HStack(spacing: 18) {
                Button("◀︎ body") {
                    cycleFocus(by: -1)
                }

                Text("focus \(session.focusedBody?.displayName ?? "none")")
                    .font(.caption2.monospaced())

                Button("body ▶︎") {
                    cycleFocus(by: 1)
                }
            }

            Text(session.plane.terraReadout.displayText)
                .font(.caption2.monospaced())

            if let errorText {
                Text(errorText)
                    .font(.caption2.monospaced())
            }

            IrisChart3DView(
                scene: IrisIX10Harness.viewport.scene,
                plane: session.plane,
                focusedBody: session.focusedBody,
                presentation: IrisChart3DPresentation(
                    cameraProjection: .orthographic,
                    cameraMode: .celestialFace,
                    orientationMode: .zodiacal,
                    timeExpansion: 0.0
                )
            )
        }
        .padding()
    }

    private func seekAbsolute(to rawJulianDay: Double) {
        guard let julianDay = JulianDay(rawJulianDay) else { return }
        var updated = session
        do {
            try updated.seek(to: julianDay, through: IrisIX10Harness.horae)
            session = updated
            errorText = nil
        } catch {
            errorText = String(describing: error)
        }
    }

    private func shift(hours: Double) {
        guard let offset = HoraeUTOffset(hours: hours) else { return }
        var updated = session
        do {
            try updated.shift(by: offset, through: IrisIX10Harness.horae)
            session = updated
            errorText = nil
        } catch {
            errorText = String(describing: error)
        }
    }

    private func canShift(hours: Double) -> Bool {
        let target = session.frame.julianDay.value + (hours / 24.0)
        return target >= session.domain.start.value
            && target < session.domain.endExclusive.value
    }

    private func cycleFocus(by delta: Int) {
        let bodies = MundaneBody.canonicalOrder
        let currentIndex = session.focusedBody.flatMap { bodies.firstIndex(of: $0) } ?? 0
        let nextIndex = (currentIndex + delta + bodies.count) % bodies.count
        let body = bodies[nextIndex]
        var updated = session

        do {
            try updated.focus(on: body, through: IrisIX10Harness.horae)
            session = updated
            errorText = nil
        } catch {
            errorText = String(describing: error)
        }
    }
}

/// IX10 host-side integration harness.
///
/// Deterministic support matter enters the real OrboSpine Locate -> Horae route.
/// The demo's absolute slider, relative buttons, and body-focus buttons produce
/// only Horae-backed control actions. Iris keeps the returned frame as display
/// state; it owns no clock, celestial interpolation, or direct Locate path.
private enum IrisIX10Harness {
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

    static let horae = Horae(locate: locate)

    static let viewport = try! IrisTimespineViewport(
        horae: horae,
        start: JulianDay(baseJulianDay + 0.25)!,
        end: JulianDay(baseJulianDay + 8.75)!,
        sampleCount: 35
    )

    static let initialSession: IrisHoraeControlSession = {
        var session = try! IrisHoraeControlSession(
            horae: horae,
            initialJulianDay: JulianDay(baseJulianDay + 4.5)!
        )
        try! session.focus(on: .mercury, through: horae)
        return session
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
