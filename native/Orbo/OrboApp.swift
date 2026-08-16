import SwiftUI

@main
struct OrboApp: App {
    var body: some Scene {
        WindowGroup {
            Color.black
                .ignoresSafeArea()
                .accessibilityIdentifier("orbo.phase0.black-shell")
        }
    }
}
