import XCTest
@testable import OrboCore

final class OrboSpineRuntimeTests: XCTestCase {
    func testD4AssemblesOneRuntimeBodyWithThreePortsAndEmptySmeldSeams() throws {
        let runtime = try XCTUnwrap(makeRuntime())

        XCTAssertEqual(runtime.identity, OrboSpineContract.identity)
        XCTAssertEqual(runtime.ports.locate, .locate)
        XCTAssertEqual(runtime.ports.library, .library)
        XCTAssertEqual(runtime.ports.link, .link)
        XCTAssertEqual(runtime.linkPort, .link)
        XCTAssertEqual(runtime.library.coreShelves, OrboSpineLibraryShelf.allCases)
        XCTAssertNil(runtime.smeldSeams.celestial)
        XCTAssertNil(runtime.smeldSeams.stack)

        XCTAssertEqual(runtime.inventory.celestialSupportCount, 22)
        XCTAssertEqual(runtime.inventory.stationCount, 1)
        XCTAssertEqual(runtime.inventory.retrogradePassageCount, 1)
        XCTAssertEqual(runtime.inventory.ringOccurrenceCount, 1)
        XCTAssertEqual(runtime.inventory.eclipseCount, 1)
        XCTAssertEqual(runtime.inventory.shellIntervalCount, 4)
        XCTAssertEqual(runtime.inventory.terraSampleCount, 2)

        let mercuryAtStation = try runtime.locate.coordinate(
            of: .mercury,
            at: JulianDay(1_000.5)!
        )
        XCTAssertEqual(mercuryAtStation.directionalDegree.motion, .retrograde)
        XCTAssertEqual(mercuryAtStation.directionalDegree.physicalDegrees, 10.5, accuracy: 1e-10)
    }

    func testD4RequiresAllCanonicalElevenBeforeAssembly() throws {
        let matter = try makeMatter()
        let withoutNode = matter.supports.filter { $0.body != .trueNorthNode }

        XCTAssertNil(OrboSpineRuntime(
            bone: matter.bone,
            celestialSupports: withoutNode,
            stations: matter.stations,
            retrogradePassages: matter.passages,
            ringOccurrences: matter.ring,
            eclipses: matter.eclipses,
            shellIntervals: matter.shells,
            terraSamples: matter.terra,
            provenance: matter.provenance
        ))
    }

    func testD4RejectsMatterOutsideBoneAndIncompleteShellFamilies() throws {
        let matter = try makeMatter()
        let outsideRing = try XCTUnwrap(OrboSpineRingOccurrence(
            bodyA: .sun,
            bodyB: .mercury,
            mark: .conjunction,
            bodyADirectionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(12)),
            bodyBDirectionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(12)),
            julianDay: JulianDay(1_002)!
        ))

        XCTAssertNil(OrboSpineRuntime(
            bone: matter.bone,
            celestialSupports: matter.supports,
            stations: matter.stations,
            retrogradePassages: matter.passages,
            ringOccurrences: [outsideRing],
            eclipses: matter.eclipses,
            shellIntervals: matter.shells,
            terraSamples: matter.terra,
            provenance: matter.provenance
        ))

        XCTAssertNil(OrboSpineRuntime(
            bone: matter.bone,
            celestialSupports: matter.supports,
            stations: matter.stations,
            retrogradePassages: matter.passages,
            ringOccurrences: matter.ring,
            eclipses: matter.eclipses,
            shellIntervals: matter.shells.filter { $0.id.family != .zeitgeist },
            terraSamples: matter.terra,
            provenance: matter.provenance
        ))
    }

    private struct Matter {
        let bone: OrboSpineBoneSpan
        let supports: [OrboSpineCelestialCoordinate]
        let stations: [OrboSpineStation]
        let passages: [OrboSpineRetrogradePassage]
        let ring: [OrboSpineRingOccurrence]
        let eclipses: [MundaneTimespineEclipseEvent]
        let shells: [OrboSpineShellInterval]
        let terra: [TerraMarrowSample]
        let provenance: OrboSpineRuntimeProvenance
    }

    private func makeRuntime() throws -> OrboSpineRuntime? {
        let matter = try makeMatter()
        return OrboSpineRuntime(
            bone: matter.bone,
            celestialSupports: matter.supports,
            stations: matter.stations,
            retrogradePassages: matter.passages,
            ringOccurrences: matter.ring,
            eclipses: matter.eclipses,
            shellIntervals: matter.shells,
            terraSamples: matter.terra,
            provenance: matter.provenance
        )
    }

    private func makeMatter() throws -> Matter {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))

        var supports: [OrboSpineCelestialCoordinate] = []
        for body in MundaneBody.canonicalOrder {
            if body == .mercury {
                supports.append(coordinate(body, 10, .direct, 1_000))
                supports.append(coordinate(body, 10, .retrograde, 1_001))
            } else {
                let step = OrboSpineContract.supportDegrees(for: body)
                supports.append(coordinate(body, 10, .direct, 1_000))
                supports.append(coordinate(body, 10 + step, .direct, 1_001))
            }
        }

        let station = try XCTUnwrap(OrboSpineStation(
            body: .mercury,
            physicalDegrees: 10.5,
            julianDay: JulianDay(1_000.5)!,
            laneBefore: .direct,
            laneAfter: .retrograde
        ))
        let passage = try XCTUnwrap(OrboSpineRetrogradePassage(
            body: .mercury,
            start: JulianDay(1_000.5)!,
            end: JulianDay(1_002)!,
            startStationPhysicalDegrees: 10.5,
            endStationPhysicalDegrees: nil,
            startBoundary: .station,
            endBoundary: .spineEnd
        ))
        let ring = try XCTUnwrap(OrboSpineRingOccurrence(
            bodyA: .sun,
            bodyB: .mercury,
            mark: .conjunction,
            bodyADirectionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(10.25)),
            bodyBDirectionalDegree: try XCTUnwrap(OrboSpineDirectionalDegree(10.25)),
            julianDay: JulianDay(1_000.25)!
        ))
        let eclipse = try XCTUnwrap(MundaneTimespineEclipseEvent(
            kind: .solar,
            type: .total,
            eclipseDegree: 12,
            julianDay: JulianDay(1_000.75)!
        ))

        let shells = try OrboSpineShellFamily.allCases.map { family in
            let id = try XCTUnwrap(OrboSpineShellID(family: family, ordinal: 1))
            return try XCTUnwrap(OrboSpineShellInterval(
                id: id,
                start: JulianDay(999)!,
                end: JulianDay(1_003)!
            ))
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: JulianDay(1_000)!
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110,
                tiltDegrees: 23.5,
                julianDay: JulianDay(1_002)!
            )),
        ]
        let provenance = try XCTUnwrap(OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "a", count: 64),
            astronomicalAuthority: "Swiss Ephemeris / DE441",
            astronomicalSourceVersion: "2.10.03"
        ))

        return Matter(
            bone: bone,
            supports: supports,
            stations: [station],
            passages: [passage],
            ring: [ring],
            eclipses: [eclipse],
            shells: shells,
            terra: terra,
            provenance: provenance
        )
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
