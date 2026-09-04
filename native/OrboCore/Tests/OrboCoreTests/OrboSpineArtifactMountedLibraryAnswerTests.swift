import XCTest
@testable import OrboCore

final class OrboSpineArtifactMountedLibraryAnswerTests: XCTestCase {
    func testMountedSpineExposesFinishedLibraryMatter() throws {
        let source = try SealedOrboSpineFixture.runtime()
        let forged = try OrboSpineArtifactForge.forge(runtime: source)
        let mounted = try OrboSpineArtifact(data: forged.data)

        XCTAssertFalse(mounted.stations().isEmpty)
        XCTAssertFalse(mounted.ringOccurrences().isEmpty)
        XCTAssertFalse(mounted.eclipses().isEmpty)
        XCTAssertFalse(mounted.shellIntervals().isEmpty)
    }
}
