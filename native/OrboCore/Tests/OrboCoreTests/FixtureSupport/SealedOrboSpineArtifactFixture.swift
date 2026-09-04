import Foundation
@testable import OrboCore

/// One real Hephaestus manufacture and mount per test process.
/// The construction directory is source testimony; all mounted answers come from this file.
enum SealedOrboSpineArtifactFixture {
    struct Artifact {
        let source: OrboSpineRuntime
        let mounted: OrboSpineRuntime
        let url: URL
        let receipt: OrboSpineArtifactReceipt
    }

    private static let result: Result<Artifact, Error> = Result {
        let source = try SealedOrboSpineFixture.runtime()
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("orbo-spine-artifact-tests-\(ProcessInfo.processInfo.globallyUniqueString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("orbo-v1.orbospine")
        let receipt = try HephaestusOrboSpineArtifactForge.forge(
            schematic: OrboSpineSchematic.current,
            candidate: source,
            to: url
        )
        let mounted = try OrboSpineRuntime.mount(from: url, expectedSHA256: receipt.sha256)
        return Artifact(source: source, mounted: mounted, url: url, receipt: receipt)
    }

    static func artifact() throws -> Artifact { try result.get() }
}
