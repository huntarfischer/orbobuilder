import XCTest
@testable import OrboCore

final class GeoplacementTests: XCTestCase {
    func testTerrestrialCoordinateTypesRejectCategoryInvalidValues() {
        XCTAssertNotNil(Latitude(-90))
        XCTAssertNotNil(Latitude(90))
        XCTAssertNil(Latitude(-90.0001))
        XCTAssertNil(Latitude(90.0001))
        XCTAssertNil(Latitude(.infinity))

        XCTAssertNotNil(GeographicLongitude(-180))
        XCTAssertNotNil(GeographicLongitude(180))
        XCTAssertNil(GeographicLongitude(-180.0001))
        XCTAssertNil(GeographicLongitude(180.0001))
        XCTAssertNil(GeographicLongitude(.nan))

        XCTAssertEqual(GeographicLongitude(-89.4)?.degrees, -89.4)
        XCTAssertEqual(CelestialLongitude(-89.4)!.degrees, 270.6, accuracy: 0.000_000_1)
    }

    func testAtlasLoadsTheVersioned7356RecordCorpus() {
        XCTAssertEqual(GeoplacementAtlas.version, "1")
        XCTAssertEqual(GeoplacementAtlas.count, 7_356)
        XCTAssertEqual(GeoplacementAtlas.count, GeoplacementAtlas.expectedRecordCount)
    }

    func testKnownUniquePrototypePlaceResolvesExactly() throws {
        let place = try found(GeoplacementAtlas.resolve("Madison, WI, USA"))

        XCTAssertEqual(place.canonicalName, "Madison, WI, USA")
        XCTAssertEqual(place.latitude.degrees, 43.07, accuracy: 0.000_000_1)
        XCTAssertEqual(place.longitude.degrees, -89.40, accuracy: 0.000_000_1)
        XCTAssertEqual(place.timezone.rawValue, "America/Chicago")
    }

    func testResolutionIsCaseInsensitiveAndTrimsWhitespace() throws {
        let place = try found(GeoplacementAtlas.resolve("  madison, wi, usa  "))
        XCTAssertEqual(place.canonicalName, "Madison, WI, USA")
    }

    func testUniquePrototypePrefixStillResolvesConveniently() throws {
        let place = try found(GeoplacementAtlas.resolve("Richland Center"))
        XCTAssertEqual(place.canonicalName, "Richland Center, WI, USA")
        XCTAssertEqual(place.timezone.rawValue, "America/Chicago")
    }

    func testRealDuplicateExactNameIsSurfacedAsAmbiguousRatherThanSilentlyChosen() throws {
        let matches = try ambiguous(GeoplacementAtlas.resolve("Tokyo, Japan"))

        XCTAssertGreaterThanOrEqual(matches.count, 2)
        XCTAssertTrue(matches.allSatisfy { $0.canonicalName == "Tokyo, Japan" })
        XCTAssertTrue(matches.contains { abs($0.latitude.degrees - 35.68) < 0.000_000_1 })
        XCTAssertTrue(matches.contains { abs($0.latitude.degrees - 35.69) < 0.000_000_1 })
    }

    func testPrefixAmbiguityIsSurfacedRatherThanGuessed() throws {
        let index = GeoplacementIndex(records: [
            try place("Springfield, IL, USA", 39.80, -89.64, "America/Chicago"),
            try place("Springfield, MO, USA", 37.21, -93.29, "America/Chicago")
        ])

        let matches = try ambiguous(index.resolve("Springfield"))
        XCTAssertEqual(matches.count, 2)
    }

    func testUnknownAndEmptyPlacesReturnNotFound() {
        XCTAssertEqual(GeoplacementAtlas.resolve("Not A Real Orbo Place"), .notFound)
        XCTAssertEqual(GeoplacementAtlas.resolve("   "), .notFound)
    }

    func testSearchPreservesStableAtlasOrderAndHonorsLimit() {
        let full = GeoplacementAtlas.search("Madison", limit: 50)
        XCTAssertTrue(full.contains { $0.canonicalName == "Madison, WI, USA" })

        let limited = GeoplacementAtlas.search("a", limit: 3)
        XCTAssertEqual(limited.count, 3)
        XCTAssertEqual(GeoplacementAtlas.search("a", limit: 0), [])
        XCTAssertEqual(GeoplacementAtlas.search("   ", limit: 50), [])
    }

    func testJavaScriptStringEscapesAreDecodedIntoCanonicalPlaceNames() throws {
        let apostrophe = try found(GeoplacementAtlas.resolve("M'sila, Algeria"))
        XCTAssertEqual(apostrophe.canonicalName, "M'sila, Algeria")

        let unicode = try found(GeoplacementAtlas.resolve("St. John’s, Canada"))
        XCTAssertEqual(unicode.canonicalName, "St. John’s, Canada")
    }

    func testAtlasOwnsTimezoneIdentityButNotCivilOffset() throws {
        let place = try found(GeoplacementAtlas.resolve("Madison, WI, USA"))
        XCTAssertEqual(place.timezone, TimezoneIdentifier("America/Chicago"))
    }

    private func found(
        _ resolution: GeoplacementResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Place {
        guard case let .found(place) = resolution else {
            XCTFail("Expected found resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return place
    }

    private func ambiguous(
        _ resolution: GeoplacementResolution,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [Place] {
        guard case let .ambiguous(places) = resolution else {
            XCTFail("Expected ambiguous resolution, got \(resolution)", file: file, line: line)
            throw TestError.unexpectedResolution
        }
        return places
    }

    private func place(
        _ name: String,
        _ latitude: Double,
        _ longitude: Double,
        _ timezone: String
    ) throws -> Place {
        guard
            let latitude = Latitude(latitude),
            let longitude = GeographicLongitude(longitude),
            let timezone = TimezoneIdentifier(timezone),
            let place = Place(
                canonicalName: name,
                latitude: latitude,
                longitude: longitude,
                timezone: timezone
            )
        else {
            throw TestError.invalidFixture
        }
        return place
    }

    private enum TestError: Error {
        case unexpectedResolution
        case invalidFixture
    }
}
