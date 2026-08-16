import XCTest

private struct SmokeFixture: Decodable, Equatable {
    let id: String
    let input: String
    let expected: String
}

final class FixtureInfrastructureTests: XCTestCase {
    func testGoldenFixtureLoadsAndDecodes() throws {
        let fixture = try FixtureLoader.decode(
            SmokeFixture.self,
            named: "fixture-smoke",
            kind: .golden
        )

        XCTAssertEqual(fixture.id, "phase0-golden-smoke")
        XCTAssertEqual(fixture.input, "fixture-loader")
        XCTAssertEqual(fixture.expected, "golden-readable")
    }

    func testParityFixtureLoadsAndDecodes() throws {
        let fixture = try FixtureLoader.decode(
            SmokeFixture.self,
            named: "fixture-smoke",
            kind: .parity
        )

        XCTAssertEqual(fixture.id, "phase0-parity-smoke")
        XCTAssertEqual(fixture.input, "prototype-reference")
        XCTAssertEqual(fixture.expected, "parity-readable")
    }

    func testMismatchIsDetectable() throws {
        let fixture = try FixtureLoader.decode(
            SmokeFixture.self,
            named: "fixture-smoke",
            kind: .golden
        )

        let intentionallyWrongActual = "not-the-expected-value"
        XCTAssertNotEqual(intentionallyWrongActual, fixture.expected)
    }

    func testMissingFixtureFailsExplicitly() {
        XCTAssertThrowsError(
            try FixtureLoader.data(
                named: "does-not-exist",
                kind: .golden
            )
        ) { error in
            XCTAssertEqual(
                error as? FixtureError,
                .missing(
                    kind: .golden,
                    name: "does-not-exist",
                    fileExtension: "json"
                )
            )
        }
    }
}
