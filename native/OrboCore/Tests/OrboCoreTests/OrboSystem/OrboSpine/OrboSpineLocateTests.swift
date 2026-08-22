import XCTest
@testable import OrboCore

final class OrboSpineLocateTests: XCTestCase {
    func testLocateAtUTInterpolatesWithinLaneAndStationsOwnTheLaneEnteredAfter() throws {
        let locate = try XCTUnwrap(makeMercuryLocate())

        let direct = try locate.coordinate(of: .mercury, at: JulianDay(1_001.25)!)
        XCTAssertEqual(direct.directionalDegree.degrees, 21.25, accuracy: 1e-10)
        XCTAssertEqual(direct.directionalDegree.motion, .direct)

        let retrogradeStation = try locate.coordinate(of: .mercury, at: JulianDay(1_001.5)!)
        XCTAssertEqual(retrogradeStation.directionalDegree.degrees, 381.5, accuracy: 1e-10)
        XCTAssertEqual(retrogradeStation.directionalDegree.motion, .retrograde)

        let retrograde = try locate.coordinate(of: .mercury, at: JulianDay(1_001.75)!)
        XCTAssertEqual(retrograde.directionalDegree.degrees, 381.25, accuracy: 1e-10)
        XCTAssertEqual(retrograde.directionalDegree.motion, .retrograde)

        let directStation = try locate.coordinate(of: .mercury, at: JulianDay(1_003.5)!)
        XCTAssertEqual(directStation.directionalDegree.degrees, 19.5, accuracy: 1e-10)
        XCTAssertEqual(directStation.directionalDegree.motion, .direct)
    }

    func testDirectionalDegreeLocateFindsStoredAndInterpolatedOccurrencesThrough720Cells() throws {
        let locate = try XCTUnwrap(makeMercuryLocate())

        let direct205 = try XCTUnwrap(OrboSpineDirectionalDegree(20.5))
        XCTAssertEqual(direct205.navigationCell, 20)
        let directOccurrences = try locate.occurrences(of: .mercury, at: direct205)
        XCTAssertEqual(directOccurrences.count, 2)
        XCTAssertEqual(directOccurrences[0].julianDay.value, 1_000.5, accuracy: 1e-10)
        XCTAssertEqual(directOccurrences[1].julianDay.value, 1_004.5, accuracy: 1e-10)

        let retrograde205 = try XCTUnwrap(OrboSpineDirectionalDegree(380.5))
        XCTAssertEqual(retrograde205.navigationCell, 380)
        let retrogradeOccurrences = try locate.occurrences(of: .mercury, at: retrograde205)
        XCTAssertEqual(retrogradeOccurrences.count, 1)
        XCTAssertEqual(retrogradeOccurrences[0].julianDay.value, 1_002.5, accuracy: 1e-10)

        let directWindows = try locate.candidateWindows(of: .mercury, inNavigationCell: 20)
        let retrogradeWindows = try locate.candidateWindows(of: .mercury, inNavigationCell: 380)
        XCTAssertFalse(directWindows.isEmpty)
        XCTAssertFalse(retrogradeWindows.isEmpty)
        XCTAssertTrue(directWindows.allSatisfy { $0.start.value >= 1_000 && $0.end.value <= 1_008 })
        XCTAssertTrue(retrogradeWindows.allSatisfy { $0.start.value >= 1_000 && $0.end.value <= 1_008 })

        XCTAssertThrowsError(try locate.candidateWindows(of: .mercury, inNavigationCell: 720)) { error in
            XCTAssertEqual(error as? OrboSpineLocateError, .invalidNavigationCell(720))
        }
    }

    func testLocateRejectsMotionChangeWithoutExactStationTopology() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(2_000)!, end: JulianDay(2_003)!))
        let supports = [
            coordinate(.mercury, 20, .direct, 2_000),
            coordinate(.mercury, 21, .direct, 2_001),
            coordinate(.mercury, 21, .retrograde, 2_002),
        ]

        XCTAssertNil(OrboSpineLocate(bone: bone, celestialSupports: supports))
    }

    func testTerraLocateInterpolatesTurnAcrossZero() throws {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(1_100)!, end: JulianDay(1_101)!))
        let supports = [
            coordinate(.sun, 0, .direct, 1_100),
            coordinate(.sun, 10, .direct, 1_100.5),
        ]
        let terra = [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 350, tiltDegrees: 23.4, julianDay: JulianDay(1_100)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 10, tiltDegrees: 23.6, julianDay: JulianDay(1_101)!)),
        ]
        let locate = try XCTUnwrap(OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        ))

        let midpoint = try locate.terra(at: JulianDay(1_100.5)!)
        XCTAssertEqual(midpoint.turnDegrees, 0, accuracy: 1e-10)
        XCTAssertEqual(midpoint.tiltDegrees, 23.5, accuracy: 1e-10)
    }

    func testTerraLocateUsesOneSidedRefinementAt1850SourceSeam() throws {
        XCTAssertEqual(TerraMarrowContract.sourceModelSeamJulianDays, [2_396_758.5, 2_469_807.5])
        let seam = TerraMarrowContract.sourceModelSeamJulianDays[0]
        let start = seam - 0.5
        let end = seam + 0.5
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(start)!, end: JulianDay(end)!))
        let supports = [
            coordinate(.sun, 0, .direct, start),
            coordinate(.sun, 10, .direct, seam),
        ]
        let terra = [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 100, tiltDegrees: 23.4, julianDay: JulianDay(start)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 110, tiltDegrees: 23.4, julianDay: JulianDay(seam)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 200, tiltDegrees: 23.4, julianDay: JulianDay(seam + 0.0001)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 210, tiltDegrees: 23.4, julianDay: JulianDay(end)!)),
        ]
        let locate = try XCTUnwrap(OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        ))

        let exact = try locate.terra(at: JulianDay(seam)!)
        XCTAssertEqual(exact.turnDegrees, 110, accuracy: 1e-10)

        let before = try locate.terra(at: JulianDay(seam - 0.25)!)
        XCTAssertEqual(before.turnDegrees, 105, accuracy: 1e-10)

        let after = try locate.terra(at: JulianDay(seam + 0.25)!)
        XCTAssertGreaterThan(after.turnDegrees, 200)
        XCTAssertLessThan(after.turnDegrees, 210)
    }

    func testTerraLocateRejectsBoneSpanningSourceSeamWithoutExactSample() throws {
        let seam = TerraMarrowContract.sourceModelSeamJulianDays[0]
        let start = seam - 0.5
        let end = seam + 0.5
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(start)!, end: JulianDay(end)!))
        let supports = [
            coordinate(.sun, 0, .direct, start),
            coordinate(.sun, 10, .direct, seam),
        ]
        let terraWithoutExactSeam = [
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 100, tiltDegrees: 23.4, julianDay: JulianDay(start)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 200, tiltDegrees: 23.4, julianDay: JulianDay(seam + 0.0001)!)),
            try XCTUnwrap(TerraMarrowSample(turnDegrees: 210, tiltDegrees: 23.4, julianDay: JulianDay(end)!)),
        ]

        XCTAssertNil(OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terraWithoutExactSeam
        ))
    }

    private func makeMercuryLocate() throws -> OrboSpineLocate {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: JulianDay(1_000)!, end: JulianDay(1_008)!))
        let supports = [
            coordinate(.mercury, 20, .direct, 1_000),
            coordinate(.mercury, 21, .direct, 1_001),
            coordinate(.mercury, 21, .retrograde, 1_002),
            coordinate(.mercury, 20, .retrograde, 1_003),
            coordinate(.mercury, 20, .direct, 1_004),
            coordinate(.mercury, 21, .direct, 1_005),
            coordinate(.mercury, 22, .direct, 1_006),
            coordinate(.mercury, 23, .direct, 1_007),
        ]
        let stations = [
            try XCTUnwrap(OrboSpineStation(
                body: .mercury,
                physicalDegrees: 21.5,
                julianDay: JulianDay(1_001.5)!,
                laneBefore: .direct,
                laneAfter: .retrograde
            )),
            try XCTUnwrap(OrboSpineStation(
                body: .mercury,
                physicalDegrees: 19.5,
                julianDay: JulianDay(1_003.5)!,
                laneBefore: .retrograde,
                laneAfter: .direct
            )),
        ]
        return try XCTUnwrap(OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            stations: stations
        ))
    }

    private func coordinate(
        _ body: MundaneBody,
        _ physicalDegrees: Double,
        _ motion: Motion,
        _ julianDay: Double
    ) -> OrboSpineCelestialCoordinate {
        OrboSpineCelestialCoordinate(
            body: body,
            directionalDegree: OrboSpineDirectionalDegree(
                physicalDegrees: physicalDegrees,
                motion: motion
            )!,
            julianDay: JulianDay(julianDay)!
        )
    }
}
