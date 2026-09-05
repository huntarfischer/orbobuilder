import Foundation
import XCTest
@testable import OrboCore

final class NatalSpineMountedParentIntegrationTests: XCTestCase {
    func testHephaestusReadsTheRealMountedMundaneParentWithoutReconstruction() throws {
        let artifact = repositoryRoot
            .appendingPathComponent("tools/pass5/orbospine-build/orbo-v1.orbospine")
        let attributes = try FileManager.default.attributesOfItem(atPath: artifact.path)
        let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
        if size < 1_000_000 {
            throw XCTSkip("The checkout contains only the Git LFS pointer; CI supplies the sealed artifact.")
        }

        let mountStart = ProcessInfo.processInfo.systemUptime
        let parent = try OrboSpineRuntime.mount(
            from: artifact,
            expectedSHA256: "c009ee14231747e6409fb717027a12c74d3236cdd0646f9d8db4f978b0d29191"
        )
        let mountElapsed = ProcessInfo.processInfo.systemUptime - mountStart
        XCTAssertLessThan(mountElapsed, 10)

        // Act I proves only the mounted-parent seam here. The end-to-end app
        // gate separately runs the expensive real 101-year Titan manufacture.
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let substrate = try Hephaestus.forgeNatalSpineSubstrate(
            for: commission,
            from: parent
        )

        XCTAssertEqual(substrate.parentProvenance.artifactSHA256, parent.provenance.artifactSHA256)
        XCTAssertEqual(Set(substrate.supports.map(\.body)), Set(MundaneBody.canonicalOrder))
        XCTAssertEqual(substrate.boundaryAnchors.count, MundaneBody.canonicalOrder.count * 2)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // NatalSpine tests
            .deletingLastPathComponent() // OrboSystem
            .deletingLastPathComponent() // OrboCoreTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // OrboCore
            .deletingLastPathComponent() // native
            .deletingLastPathComponent() // repository root
    }
}
