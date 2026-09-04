import SwiftUI
import Foundation
import OrboCore
import OrboIris

@main
struct ApolloAstrolabeWorkshopApp: App {
    @StateObject private var model = ApolloAstrolabeWorkshopModel()

    var body: some Scene {
        WindowGroup {
            ApolloAstrolabeWorkshopView(model: model)
                .task { await model.mount() }
        }
    }
}

@MainActor
private final class ApolloAstrolabeWorkshopModel: ObservableObject {
    @Published private(set) var instrument: ApolloAstrolabe?
    @Published private(set) var status = "Mounting the Timespine"
    @Published private(set) var failure: String?
    private var started = false

    var angle: Double { instrument?.rotationDegrees ?? initialAngle }

    var frame: IrisPort<ApolloAstrolabeSignalFrame>? {
        instrument.map { Apollo.signalForIris($0) }
    }

    func mount() async {
        guard !started else { return }
        started = true
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }
        guard let root = Bundle.main.url(forResource: "orbospine-build", withExtension: nil) else {
            fail("The mounted OrboSpine is missing from this workshop target.")
            return
        }

        do {
            let artifact = root.appendingPathComponent("orbo-v1.orbospine")
            let mounted = try await Task.detached(priority: .userInitiated) {
                try OrboSpineRuntime.mount(
                    from: artifact,
                    expectedSHA256: "c009ee14231747e6409fb717027a12c74d3236cdd0646f9d8db4f978b0d29191"
                )
            }.value
            let horae = Horae(locate: mounted.locate)
            let moment = JulianDay(2_461_288.75)!
            let output = try horae.seek(to: moment)
            let aegis = try Apollo.establishAegis(from: output, hestia: nil, atPlace: nil)
            instrument = ApolloAstrolabe(aegis: aegis, rotationDegrees: initialAngle)
            status = "Horae connected · Timespine \(String(mounted.identity.prefix(10)))"
            FileHandle.standardOutput.write(Data("APOLLO_WORKSHOP_READY: real Spine mounted\n".utf8))
        } catch {
            fail(String(describing: error))
        }
    }

    func turn(to degrees: Double) {
        guard var instrument else { return }
        instrument.turn(to: degrees)
        self.instrument = instrument
    }

    func settle() {
        guard var instrument else { return }
        _ = instrument.settleToNearestDetent()
        self.instrument = instrument
    }

    private var initialAngle: Double {
        guard let marker = CommandLine.arguments.firstIndex(of: "--workshop-angle"),
              CommandLine.arguments.indices.contains(marker + 1),
              let value = Double(CommandLine.arguments[marker + 1]) else { return 0 }
        return value
    }

    private func fail(_ message: String) {
        failure = message
        status = "Mount failed"
    }
}

private struct ApolloAstrolabeWorkshopView: View {
    @ObservedObject var model: ApolloAstrolabeWorkshopModel

    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.958, blue: 0.94).ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 5) {
                    Text("APOLLO ASTROLABE")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .tracking(3.4)
                    Text("WORKSHOP · ACT I")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 18)

                Spacer(minLength: 12)

                Group {
                    if let frame = model.frame {
                        IrisApolloAstrolabeView(frame: frame)
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    } else if let failure = model.failure {
                        ContentUnavailableView(
                            "Apollo Astrolabe unavailable",
                            systemImage: "exclamationmark.triangle",
                            description: Text(failure)
                        )
                    } else {
                        ProgressView(model.status)
                            .tint(Color(red: 0.27, green: 0.20, blue: 0.42))
                    }
                }
                .frame(maxWidth: 660, maxHeight: 660)
                .padding(.horizontal, 18)

                Spacer(minLength: 14)

                controls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)
                    .disabled(model.instrument == nil)
                    .opacity(model.instrument == nil ? 0.35 : 1)
            }
        }
        .foregroundStyle(Color(red: 0.11, green: 0.09, blue: 0.15))
        .accessibilityIdentifier("apollo.workshop")
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack {
                Text(model.instrument?.dominantFace.rawValue.uppercased() ?? "AEGIS")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(1.6)
                Spacer()
                Text("\(Int(model.angle.rounded()))°")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            }
            Slider(
                value: Binding(get: { model.angle }, set: model.turn),
                in: 0...360,
                step: 1,
                onEditingChanged: { editing in
                    guard !editing else { return }
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) { model.settle() }
                }
            )
            .tint(Color(red: 0.23, green: 0.17, blue: 0.36))
            .accessibilityLabel("Rotate Apollo Astrolabe")
            .accessibilityValue("\(Int(model.angle.rounded())) degrees")
            .accessibilityIdentifier("apollo.workshop.rotation")
            HStack {
                Text("AEGIS · 0°")
                Spacer()
                Text("EDGE · 90°")
                Spacer()
                Text("TABULA · 180°")
            }
            .font(.system(size: 8, weight: .medium, design: .monospaced))
            .foregroundStyle(.secondary)
            Text(model.status)
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .accessibilityIdentifier("apollo.workshop.status")
        }
        .frame(maxWidth: 620)
    }
}
