import XCTest
@testable import OrboCore

final class AtlasTests: XCTestCase {
    func testMadisonResolvesDeterministicallyToTopos() throws {
        let topos = try found(Atlas().resolve("Madison, WI"))

        XCTAssertEqual(topos.place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(topos.place.latitude.degrees, 43.07, accuracy: 0.000_000_1)
        XCTAssertEqual(topos.place.longitude.degrees, -89.40, accuracy: 0.000_000_1)
        XCTAssertEqual(topos.place.timezone.rawValue, "America/Chicago")
    }

    func testToposCarriesAtlasV1Provenance() throws {
        let topos = try found(Atlas().resolve("Madison, WI"))

        XCTAssertEqual(topos.provenance.version, GeoplacementAtlas.version)
        XCTAssertEqual(topos.provenance.sourceDescription, GeoplacementAtlas.sourceDescription)
    }

    func testAmbiguousPlaceRemainsAmbiguous() throws {
        let topoi = try ambiguous(Atlas().resolve("Tokyo, Japan"))

        XCTAssertGreaterThanOrEqual(topoi.count, 2)
        XCTAssertTrue(topoi.allSatisfy { $0.place.canonicalName == "Tokyo, Japan" })
    }

    func testUnknownAndEmptyQueriesReturnNotFound() {
        XCTAssertEqual(Atlas().resolve("Not A Real Orbo Place"), .notFound)
        XCTAssertEqual(Atlas().resolve("   "), .notFound)
    }

    private func found(
        _ resolution: AtlasResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Topos {
        guard case let .found(topos) = resolution else {
            XCTFail("Expected found resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return topos
    }

    private func ambiguous(
        _ resolution: AtlasResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [Topos] {
        guard case let .ambiguous(topoi) = resolution else {
            XCTFail("Expected ambiguous resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return topoi
    }

    private enum TestError: Error {
        case unexpectedResolution
    }
}
