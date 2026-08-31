import XCTest
@testable import OrboCore

final class OceanusWaterTableTests: XCTestCase {
    func testRecoveredArtifactProvenanceIsFrozen() {
        XCTAssertEqual(
            OceanusWaterTable.sourceSHA256,
            "7cb3c03a4ed79b8c1b0a2d01b237e1431dc6fb2dbcc09d00a6bb53be24e151e7"
        )
        XCTAssertEqual(OceanusWaterTable.width, 360)
        XCTAssertEqual(OceanusWaterTable.cellCount, 129_600)
    }

    func testEveryCellMatchesApprovedWholeDegreeGeometry() {
        for ascendant in 0..<360 {
            for sun in 0..<360 {
                XCTAssertEqual(
                    Oceanus.waterRelation(
                        ascendantDegree: ascendant,
                        sunDegree: sun
                    ),
                    expectedRelation(ascendant: ascendant, sun: sun),
                    "ASC \(ascendant), Sun \(sun)"
                )
            }
        }
    }

    func testEveryAscendantRowHasFrozenDistribution() {
        for ascendant in 0..<360 {
            var above = 0
            var below = 0
            var tie = 0

            for sun in 0..<360 {
                guard let relation = Oceanus.waterRelation(
                    ascendantDegree: ascendant,
                    sunDegree: sun
                ) else {
                    XCTFail("Missing relation for ASC \(ascendant), Sun \(sun)")
                    return
                }

                switch relation {
                case .above:
                    above += 1
                case .below:
                    below += 1
                case .tie:
                    tie += 1
                }
            }

            XCTAssertEqual(above, 179, "ASC \(ascendant)")
            XCTAssertEqual(below, 179, "ASC \(ascendant)")
            XCTAssertEqual(tie, 2, "ASC \(ascendant)")
        }
    }

    func testGlobalDistributionIsFrozen() {
        var above = 0
        var below = 0
        var tie = 0

        for ascendant in 0..<360 {
            for sun in 0..<360 {
                guard let relation = Oceanus.waterRelation(
                    ascendantDegree: ascendant,
                    sunDegree: sun
                ) else {
                    XCTFail("Missing relation for ASC \(ascendant), Sun \(sun)")
                    return
                }

                switch relation {
                case .above:
                    above += 1
                case .below:
                    below += 1
                case .tie:
                    tie += 1
                }
            }
        }

        XCTAssertEqual(above, 64_440)
        XCTAssertEqual(below, 64_440)
        XCTAssertEqual(tie, 720)
        XCTAssertEqual(above + below + tie, 129_600)
    }

    func testRotationalInvarianceAcrossAllWholeDegrees() {
        for delta in 0..<360 {
            guard let canonical = Oceanus.waterRelation(
                ascendantDegree: 0,
                sunDegree: delta
            ) else {
                XCTFail("Missing canonical relation for delta \(delta)")
                return
            }

            for ascendant in 0..<360 {
                let sun = (ascendant + delta) % 360
                XCTAssertEqual(
                    Oceanus.waterRelation(
                        ascendantDegree: ascendant,
                        sunDegree: sun
                    ),
                    canonical,
                    "Delta \(delta), ASC \(ascendant), Sun \(sun)"
                )
            }
        }
    }

    func testLookupFailsClosedOutsideWholeDegreeBounds() {
        XCTAssertNil(Oceanus.waterRelation(ascendantDegree: -1, sunDegree: 0))
        XCTAssertNil(Oceanus.waterRelation(ascendantDegree: 360, sunDegree: 0))
        XCTAssertNil(Oceanus.waterRelation(ascendantDegree: 0, sunDegree: -1))
        XCTAssertNil(Oceanus.waterRelation(ascendantDegree: 0, sunDegree: 360))
    }

    private func expectedRelation(
        ascendant: Int,
        sun: Int
    ) -> OceanusWaterRelation {
        let delta = (sun - ascendant + 360) % 360

        switch delta {
        case 0, 180:
            return .tie
        case 1...179:
            return .above
        default:
            return .below
        }
    }
}
