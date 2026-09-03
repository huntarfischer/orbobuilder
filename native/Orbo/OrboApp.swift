import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    @StateObject private var model = OrboApplicationModel()

    var body: some Scene {
        WindowGroup {
            OrboRuntimeView(model: model)
                .task { await model.mount() }
        }
    }
}

@MainActor
private final class OrboApplicationModel: ObservableObject {
    @Published var runtime: OrboSpineRuntime?
    @Published var frame: IrisHoraeFrame?
    @Published var failure: String?
    private(set) var horae: Horae?
    private var started = false

    func mount() async {
        guard !started else { return }
        started = true
        // Xcode's test host lets the acceptance tests load their one shared runtime.
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }
        guard let root = Bundle.main.url(forResource: "orbospine-build", withExtension: nil) else {
            failure = "The OrboSpine files are missing from this app."
            return
        }
        do {
            let mounted = try await Task.detached(priority: .userInitiated) {
                try OrboSpineRuntime.load(from: root)
            }.value
            let horae = Horae(locate: mounted.locate)
            let output = try horae.live()
            self.runtime = mounted
            self.horae = horae
            self.frame = IrisHoraeFrame(port: Horae.signalForIris(output))
        } catch {
            failure = String(describing: error)
        }
    }

    func shift(days: Double) {
        guard let horae, let frame,
              let target = JulianDay(frame.julianDay.value + days) else { return }
        do {
            self.frame = IrisHoraeFrame(port: Horae.signalForIris(try horae.seek(to: target)))
            failure = nil
        } catch { failure = String(describing: error) }
    }
}

private struct OrboRuntimeView: View {
    @ObservedObject var model: OrboApplicationModel
    @State private var show3D = false
    @State private var cameraMode: IrisCameraMode = .topDown

    var body: some View {
        VStack {
            if let failure = model.failure {
                Text(failure).foregroundStyle(.red).padding()
                    .accessibilityIdentifier("orbo.runtime.failure")
            }
            if let frame = model.frame {
                HStack {
                    Button("Previous day") { model.shift(days: -1) }
                    Button("Next day") { model.shift(days: 1) }
                    if #available(iOS 26.0, *) {
                        Toggle("3D", isOn: $show3D)
                    }
                }.padding()
                if #available(iOS 26.0, *), show3D {
                    Picker("Perspective", selection: $cameraMode) {
                        Text("Top").tag(IrisCameraMode.topDown)
                        Text("Vertical").tag(IrisCameraMode.vertical)
                        Text("Horizontal").tag(IrisCameraMode.horizontal)
                    }.pickerStyle(.segmented)
                    IrisChart3DView(scene: frame.scene, presentation: IrisChart3DPresentation(
                        cameraProjection: .orthographic, cameraMode: cameraMode, orientationMode: .zodiacal
                    ))
                } else {
                    IrisHoraeTextView(frame: frame)
                }
            } else if model.failure == nil {
                ProgressView("Opening Orbo…")
            }
        }
    }
}
