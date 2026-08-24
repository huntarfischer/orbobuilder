import XCTest
@testable import OrboCore

final class ArcGridTests: XCTestCase {
    func testProjectBuildsExactly360CanonicalDegreeWindows() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 277, minute: 34, second: 17))
        let field = Arc.cast(anchor)
        let grid = Arc.project(field)

        XCTAssertEqual(grid.field, field)
        XCTAssertEqual(grid.cells.count, 360)
        XCTAssertEqual(grid.cells.map(\.degree), Array(0..<360))
        XCTAssertEqual(Arc.outputTicksPerDegree, 7_200)
        XCTAssertNil(grid[-1])
        XCTAssertNil(grid[360])
        XCTAssertEqual(grid[0]?.degree, 0)
        XCTAssertEqual(grid[359]?.degree, 359)
    }

    func testNonWholeDegreeAnchorCreatesExactPartialBoundaryCells() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 277, minute: 34, second: 17))
        let field = Arc.cast(anchor)
        let grid = Arc.project(field)

        XCTAssertEqual(field.minusPole.degree, 187)
        XCTAssertEqual(field.plusPole.degree, 7)

        let minusCell = try XCTUnwrap(grid[187])
        guard case let .partial(minusRange) = minusCell.coverage else {
            return XCTFail("The minus-pole degree must be partially possible.")
        }
        XCTAssertEqual(minusRange.lower, field.minusPole)
        XCTAssertEqual(minusRange.lower.minute, 34)
        XCTAssertEqual(minusRange.lower.second, 17)
        XCTAssertEqual(minusRange.lower.halfSecond, 0)
        XCTAssertEqual(minusRange.upper.degree, 187)
        XCTAssertEqual(minusRange.upper.minute, 59)
        XCTAssertEqual(minusRange.upper.second, 59)
        XCTAssertEqual(minusRange.upper.halfSecond, 1)
        XCTAssertEqual(minusCell.minusPole, field.minusPole)
        XCTAssertNil(minusCell.plusPole)

        let plusCell = try XCTUnwrap(grid[7])
        guard case let .partial(plusRange) = plusCell.coverage else {
            return XCTFail("The plus-pole degree must be partially possible.")
        }
        XCTAssertEqual(plusRange.lower.degree, 7)
        XCTAssertEqual(plusRange.lower.minute, 0)
        XCTAssertEqual(plusRange.lower.second, 0)
        XCTAssertEqual(plusRange.lower.halfSecond, 0)
        XCTAssertEqual(plusRange.upper, field.plusPole)
        XCTAssertEqual(plusCell.plusPole, field.plusPole)
        XCTAssertNil(plusCell.minusPole)

        let centerCell = try XCTUnwrap(grid[277])
        XCTAssertEqual(centerCell.coverage, .possible)
        XCTAssertEqual(centerCell.center, field.center)
        XCTAssertNil(centerCell.minusPole)
        XCTAssertNil(centerCell.plusPole)
    }

    func testProjectionAccountsForEveryExactOutputTick() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 277, minute: 34, second: 17))
        let grid = Arc.project(anchor)

        XCTAssertEqual(grid.possibleTickCount, Arc.quarterCircleTicks * 2 + 1)
        XCTAssertEqual(grid.possibleTickCount + grid.impossibleTickCount, Arc.outputTicks)

        for cell in grid.cells {
            XCTAssertEqual(cell.possibleTickCount + cell.impossibleTickCount, Arc.outputTicksPerDegree)
        }
    }

    func testWholeDegreeBoundariesPreserveTheExactPolePoint() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 0))
        let field = Arc.cast(anchor)
        let grid = Arc.project(field)

        XCTAssertEqual(field.minusPole.degree, 270)
        XCTAssertEqual(field.plusPole.degree, 90)

        XCTAssertEqual(grid[0]?.coverage, .possible)
        XCTAssertEqual(grid[89]?.coverage, .possible)
        XCTAssertEqual(grid[270]?.coverage, .possible)
        XCTAssertEqual(grid[359]?.coverage, .possible)
        XCTAssertEqual(grid[269]?.coverage, .impossible)

        let plusCell = try XCTUnwrap(grid[90])
        guard case let .partial(range) = plusCell.coverage else {
            return XCTFail("The exact +90° pole must survive as a one-tick partial cell.")
        }
        XCTAssertEqual(range.count, 1)
        XCTAssertEqual(range.lower, field.plusPole)
        XCTAssertEqual(range.upper, field.plusPole)
        XCTAssertEqual(plusCell.plusPole, field.plusPole)
    }

    func testGridCoverageMatchesUnderlyingCastAtRepresentativeSubdegreeTicks() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 277, minute: 34, second: 17))
        let field = Arc.cast(anchor)
        let grid = Arc.project(field)
        let offsets = [0, 1, Arc.outputTicksPerDegree / 2, Arc.outputTicksPerDegree - 2, Arc.outputTicksPerDegree - 1]

        for degree in 0..<Arc.degrees {
            let cell = try XCTUnwrap(grid[degree])
            for offset in offsets {
                let position = try XCTUnwrap(ArcPosition(degree * Arc.outputTicksPerDegree + offset))
                XCTAssertEqual(cell.containsPossible(position), field.contains(position))
            }
        }
    }

    func testProjectionConvenienceUsesTheSameExactCast() throws {
        let anchor = try XCTUnwrap(ArcCoordinate(degree: 211, minute: 5, second: 9))
        XCTAssertEqual(Arc.project(anchor), Arc.project(Arc.cast(anchor)))
    }
}
