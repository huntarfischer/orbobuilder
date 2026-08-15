import SwiftUI
import OrboCore

@main
struct OrboApp: App {
    // Phase 0 only: prove the production shell is linked to OrboCore without
    // exposing construction information in the production interface.
    private let coreLinkage = OrboCoreBuild.linkageSentinel

    var body: some Scene {
        WindowGroup {
            Color.black
                .ignoresSafeArea()
                .accessibilityIdentifier("orbo.phase0.black-shell")
                .onAppear {
                    _ = coreLinkage
                }
        }
    }
}
