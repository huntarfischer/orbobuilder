import SwiftUI
import OrboCore

@main
struct OrboLabApp: App {
    var body: some Scene {
        WindowGroup {
            PhaseZeroLabView()
        }
    }
}

private struct PhaseZeroLabView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("ORBO LAB")
                    .font(.title2.monospaced().weight(.semibold))

                Text("PHASE 0 · THE LAB")
                    .font(.caption.monospaced())

                Divider()

                Text("ORBOCORE")
                    .font(.headline.monospaced())

                Text("linkage sentinel: \(OrboCoreBuild.linkageSentinel)")
                    .font(.body.monospaced())

                Text("Construction-only readout. This does not define a production OrboCore API.")
                    .font(.caption.monospaced())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
    }
}
