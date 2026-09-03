import Foundation
@testable import OrboCore

/// One real sealed runtime per test process, shared across the system proofs.
/// Xcode reads the shipped app resource; SwiftPM reads the same repository files.
enum SealedOrboSpineFixture {
    private static let mounted: Result<OrboSpineRuntime, Error> = Result {
        if let root = Bundle.main.url(forResource: "orbospine-build", withExtension: nil) {
            return try OrboSpineRuntime.load(from: root)
        }
        var directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while directory.path != "/" {
            let root = directory.appendingPathComponent("tools/pass5/orbospine-build")
            if FileManager.default.fileExists(atPath: root.path) {
                return try OrboSpineRuntime.load(from: root)
            }
            directory.deleteLastPathComponent()
        }
        throw NSError(domain: "SealedOrboSpineFixture", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Real sealed OrboSpine files are required"])
    }

    static func runtime() throws -> OrboSpineRuntime { try mounted.get() }
}
