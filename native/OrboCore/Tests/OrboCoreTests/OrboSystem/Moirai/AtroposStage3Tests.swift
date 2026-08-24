import XCTest
@testable import OrboCore

final class AtroposStage3Tests: XCTestCase {
    private struct NatalPosition {
        let degree: Int
        let minute: Int
        let second: Int
        let retrograde: Bool

        var rawValue: Int {
            var value = degree * Ring.arcsecondsPerDegree + minute * 60 + second
            if retrograde {
                value += Ring.arcseconds
            }
            return value
        }
    }

    private let natalPositions: [AstroDNAGene: NatalPosition] = [
        .ascendant: NatalPosition(degree: 221, minute: 29, second: 37, retrograde: false),
        .moon: NatalPosition(degree: 277, minute: 34, second: 12, retrograde: false),
        .sun: NatalPosition(degree: 21, minute: 8, second: 19, retrograde: false),
        .mercury: NatalPosition(degree: 8, minute: 20, second: 41, retrograde: true),
        .venus: NatalPosition(degree: 9, minute: 49, second: 22, retrograde: true),
        .mars: NatalPosition(degree: 49, minute: 16, second: 5, retrograde: false),
        .jupiter: NatalPosition(degree: 312, minute: 33, second: 44, retrograde: false),
        .saturn: NatalPosition(degree: 237, minute: 9, second: 17, retrograde: true),
        .uranus: NatalPosition(degree: 257, minute: 49, second: 31, retrograde: true),
        .neptune: NatalPosition(degree: 273, minute: 36, second: 26, retrograde: true),
        .pluto: NatalPosition(degree: 213, minute: 42, second: 14, retrograde: true),
        .northNode: NatalPosition(degree: 49, minute: 50, second: 53, retrograde: true),
    ]

    private func natalDNA(
        overrides: [AstroDNAGene: NatalPosition] = [:]
    ) throws -> AstroDNA {
        let sequence = try AstroDNAGene.canonicalOrder.map { gene -> RingFineState in
            let position = try XCTUnwrap(overrides[gene] ?? natalPositions[gene])
            return try XCTUnwrap(RingFineState(position.rawValue))
        }
        return try XCTUnwrap(AstroDNA(sequence: sequence))
    }

    private func completedWork() throws -> (LegacyMoiraiOutput, DegreeGrid) {
        let output = LegacyMoiraiBridge.gather(from: try natalDNA())
        let grid = Lachesis.allot(output.packet, into: DegreeGrid())
        return (output, grid)
    }

    func testValidRecipeAndLachesisGridAreSealed() throws {
        let (output, grid) = try completedWork()

        switch Atropos.inspect(recipe: output.recipe, grid: grid) {
        case .success(let package):
            XCTAssertEqual(package.grid, grid)
        case .failure(let failure):
            XCTFail("Expected Atropos to seal valid work, got \(failure)")
        }
    }

    func testSealedPackagePreservesAllTwelveThreadsUnchanged() throws {
        let (output, grid) = try completedWork()
        let result = Atropos.inspect(recipe: output.recipe, grid: grid)
        let package = try XCTUnwrap(try? result.get())

        XCTAssertEqual(package.grid.cells.count, 360)
        XCTAssertEqual(package.grid.cells.flatMap(\.threads), grid.cells.flatMap(\.threads))
        XCTAssertEqual(package.grid, grid)
    }

    func testSharedDegreeRemainsValid() throws {
        let (output, grid) = try completedWork()
        let package = try Atropos.inspect(recipe: output.recipe, grid: grid).get()
        let degree49 = try XCTUnwrap(
            package.grid.cells.first { $0.address.rawValue == 49 }
        )

        XCTAssertEqual(Set(degree49.threads.map(\.gene)), Set([.mars, .northNode]))
    }

    func testUnrelatedEmptyCellsRemainValid() throws {
        let (output, grid) = try completedWork()
        let package = try Atropos.inspect(recipe: output.recipe, grid: grid).get()
        let degree0 = try XCTUnwrap(
            package.grid.cells.first { $0.address.rawValue == 0 }
        )

        XCTAssertTrue(degree0.threads.isEmpty)
    }

    func testAtroposRejectsExactStateMismatchBetweenRecipeAndAllotment() throws {
        let original = LegacyMoiraiBridge.gather(from: try natalDNA())
        let changedSun = NatalPosition(
            degree: 21,
            minute: 8,
            second: 20,
            retrograde: false
        )
        let changed = LegacyMoiraiBridge.gather(
            from: try natalDNA(overrides: [.sun: changedSun])
        )
        let changedGrid = Lachesis.allot(changed.packet, into: DegreeGrid())

        XCTAssertEqual(
            Atropos.inspect(recipe: original.recipe, grid: changedGrid),
            .failure(.exactStateMismatch(.sun))
        )
    }

    func testAtroposRejectsDifferentProductionAtAnotherDegreeBeforeSealing() throws {
        let original = LegacyMoiraiBridge.gather(from: try natalDNA())
        let changedSun = NatalPosition(
            degree: 22,
            minute: 8,
            second: 19,
            retrograde: false
        )
        let changed = LegacyMoiraiBridge.gather(
            from: try natalDNA(overrides: [.sun: changedSun])
        )
        let changedGrid = Lachesis.allot(changed.packet, into: DegreeGrid())

        XCTAssertEqual(
            Atropos.inspect(recipe: original.recipe, grid: changedGrid),
            .failure(.exactStateMismatch(.sun))
        )
    }

    func testSameRecipeAndGridProduceSameInspectionResult() throws {
        let (output, grid) = try completedWork()

        XCTAssertEqual(
            Atropos.inspect(recipe: output.recipe, grid: grid),
            Atropos.inspect(recipe: output.recipe, grid: grid)
        )
    }
}
