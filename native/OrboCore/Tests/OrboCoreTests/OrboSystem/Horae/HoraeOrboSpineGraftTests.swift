import XCTest
@testable import OrboCore

final class HoraeOrboSpineGraftTests: XCTestCase {
    func testHoraeAtDoorOneMatchesRuntimeLocateAtInteriorUT() throws {
        let runtime = try makeRuntime()
        let horae = Horae(locate: runtime.locate)
        let julianDay = JulianDay(1_000.75)!

        let output = try horae.seek(to: julianDay)
        let expected = try expectedOutput(from: runtime, at: julianDay)

        XCTAssertEqual(output, expected)
    }

    func testHoraeCarriesRuntimeBoundaryAnchorTruthWithoutKnowingAnchor() throws {
        let runtime = try makeRuntime()
        let horae = Horae(locate: runtime.locate)
        let boneStart = runtime.bone.start

        let output = try horae.seek(to: boneStart)
        let expected = try expectedOutput(from: runtime, at: boneStart)
        let mercury = try XCTUnwrap(output.celestial.first { $0.body == .mercury })
        let directMercury = try runtime.locate.coordinate(of: .mercury, at: boneStart)

        XCTAssertEqual(output, expected)
        XCTAssertEqual(mercury, directMercury)
        XCTAssertEqual(mercury.directionalDegree.physicalDegrees, 10.0, accuracy: 1e-10)
        XCTAssertEqual(mercury.directionalDegree.motion, .direct)
    }

    private func expectedOutput(
        from runtime: OrboSpineRuntime,
        at julianDay: JulianDay
    ) throws -> HoraeOutput {
        let celestial = try OrboSpineContract.canonicalBodies.map { body in
            try runtime.locate.coordinate(of: body, at: julianDay)
        }
        let terra = try runtime.locate.terra(at: julianDay)
        return HoraeOutput(
            julianDay: julianDay,
            celestial: celestial,
            terra: terra
        )
    }

    private func makeRuntime() throws -> OrboSpineRuntime {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(1_000)!,
            end: JulianDay(1_002)!
        ))

        var supports: [OrboSpineCelestialCoordinate] = []
        for body in OrboSpineContract.canonicalBodies {
            if body == .mercury {
                supports.append(coordinate(body, 10.4, .direct, 1_000.5))
                supports.append(coordinate(body, 10.6, .direct, 1_001.0))
            } else {
                let step = OrboSpineContract.supportDegrees(for: body)
                supports.append(coordinate(body, 20.0, .direct, 1_000.0))
                supports.append(coordinate(body, 20.0 + step, .direct, 1_001.0))
            }
        }

        let boundaryAnchors = [
            try XCTUnwrap(OrboSpineBoundaryAnchor(
                body: .mercury,
                boundary: .start,
                julianDay: bone.start,
                physicalDegrees: 10.0,
                motion: .direct
            )),
            try XCTUnwrap(OrboSpineBoundaryAnchor(
                body: .mercury,
                boundary: .endExclusive,
                julianDay: bone.end,
                physicalDegrees: 11.0,
                motion: .direct
            )),
        ]

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
                julianDay: bone.start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 110,
                tiltDegrees: 23.5,
                julianDay: bone.end
            )),
        ]

        let provenance = try XCTUnwrap(OrboSpineRuntimeProvenance(
            candidateManifestSHA256: String(repeating: "a", count: 64),
            astronomicalAuthority: "Swiss Ephemeris / DE441",
            astronomicalSourceVersion: "2.10.03"
        ))

        return try XCTUnwrap(OrboSpineRuntime(
            bone: bone,
            celestialSupports: supports,
            stations: [],
            boundaryAnchors: boundaryAnchors,
            retrogradePassages: [],
            ringOccurrences: [],
            eclipses: [],
            shellIntervals: shells,
            terraSamples: terra,
            provenance: provenance
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
