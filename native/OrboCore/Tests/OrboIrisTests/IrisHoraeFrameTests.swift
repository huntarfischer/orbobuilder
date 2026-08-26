import XCTest
@testable import OrboCore
@testable import OrboIris

final class IrisHoraeFrameTests: XCTestCase {
    func testRealHoraeCrossSectionBecomesIrisFrameWithoutChangingTruth() throws {
        let runtime = try makeRuntime()
        let horae = Horae(locate: runtime.locate)
        let requestedJulianDay = JulianDay(1_000.75)!

        let output = try horae.seek(to: requestedJulianDay)
        let frame = IrisHoraeFrame(output: output)

        XCTAssertEqual(output.celestial.count, 11)
        XCTAssertEqual(output.celestial.map(\.body), OrboSpineContract.canonicalBodies)
        XCTAssertTrue(output.celestial.allSatisfy { $0.julianDay == output.julianDay })

        XCTAssertEqual(frame.output, output)
        XCTAssertEqual(frame.julianDay, output.julianDay)
        XCTAssertEqual(frame.terra, output.terra)
        XCTAssertEqual(frame.controlState, output.controlState)
        XCTAssertEqual(frame.scene.coordinates, output.celestial)
        XCTAssertEqual(frame.scene.points.map(\.source), output.celestial)
    }

    func testTimespineViewportRequestsMonotonicFramesThroughHorae() throws {
        let horae = try makeViewportHorae()
        let start = JulianDay(2_000.25)!
        let end = JulianDay(2_001.75)!
        let viewport = try IrisTimespineViewport(
            horae: horae,
            start: start,
            end: end,
            sampleCount: 7
        )

        XCTAssertEqual(viewport.frames.count, 7)
        XCTAssertEqual(viewport.julianDays.first, start)
        XCTAssertEqual(viewport.julianDays.last, end)

        for pair in zip(viewport.julianDays, viewport.julianDays.dropFirst()) {
            XCTAssertLessThan(pair.0.value, pair.1.value)
        }

        for frame in viewport.frames {
            XCTAssertEqual(frame.output.celestial.count, 11)
            XCTAssertEqual(frame.output.celestial.map(\.body), OrboSpineContract.canonicalBodies)
            XCTAssertTrue(frame.output.celestial.allSatisfy { $0.julianDay == frame.julianDay })
        }
    }

    func testTimespineViewportSceneIsExactConcatenationOfHoraeTruth() throws {
        let horae = try makeViewportHorae()
        let viewport = try IrisTimespineViewport(
            horae: horae,
            start: JulianDay(2_000.2)!,
            end: JulianDay(2_001.8)!,
            sampleCount: 9
        )
        let expected = viewport.frames.flatMap { $0.output.celestial }

        XCTAssertEqual(viewport.scene.coordinates, expected)
        XCTAssertEqual(viewport.scene.points.map(\.source), expected)
        XCTAssertEqual(viewport.terraSamples, viewport.frames.map(\.terra))

        for frame in viewport.frames {
            XCTAssertEqual(frame.output, try horae.seek(to: frame.julianDay))
        }
    }

    func testTimespineViewportPreservesRetrogradeTopologyWhileUTMovesForward() throws {
        let horae = try makeViewportHorae()
        let viewport = try IrisTimespineViewport(
            horae: horae,
            start: JulianDay(2_000.1)!,
            end: JulianDay(2_001.9)!,
            sampleCount: 10
        )
        let mercury = viewport.frames.compactMap { frame in
            frame.output.celestial.first(where: { $0.body == .mercury })
        }

        XCTAssertEqual(mercury.count, viewport.frames.count)
        XCTAssertTrue(mercury.allSatisfy { $0.directionalDegree.motion == .retrograde })

        for pair in zip(mercury, mercury.dropFirst()) {
            XCTAssertLessThan(pair.0.julianDay.value, pair.1.julianDay.value)
            XCTAssertGreaterThan(
                pair.0.directionalDegree.physicalDegrees,
                pair.1.directionalDegree.physicalDegrees
            )
        }
    }

    func testTimespineViewportRejectsInvalidSamplingRequest() throws {
        let horae = try makeViewportHorae()
        let start = JulianDay(2_000.25)!
        let end = JulianDay(2_001.75)!

        XCTAssertThrowsError(
            try IrisTimespineViewport(
                horae: horae,
                start: start,
                end: end,
                sampleCount: 1
            )
        ) { error in
            XCTAssertEqual(error as? IrisTimespineViewportError, .sampleCountTooSmall)
        }

        XCTAssertThrowsError(
            try IrisTimespineViewport(
                horae: horae,
                start: end,
                end: start,
                sampleCount: 4
            )
        ) { error in
            XCTAssertEqual(error as? IrisTimespineViewportError, .nonIncreasingInterval)
        }
    }

    private func makeViewportHorae() throws -> Horae {
        let bone = try XCTUnwrap(OrboSpineBoneSpan(
            start: JulianDay(2_000)!,
            end: JulianDay(2_002)!
        ))

        var supports: [OrboSpineCelestialCoordinate] = []
        for (index, body) in OrboSpineContract.canonicalBodies.enumerated() {
            let base = 40.0 + (Double(index) * 20.0)
            let step = OrboSpineContract.supportDegrees(for: body) * 0.4
            let motion: Motion = body == .mercury ? .retrograde : .direct
            let second = motion == .retrograde ? base - step : base + step

            supports.append(coordinate(body, base, motion, 2_000.0))
            supports.append(coordinate(body, second, motion, 2_001.0))
        }

        let terra = [
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 100,
                tiltDegrees: 23.4,
                julianDay: bone.start
            )),
            try XCTUnwrap(TerraMarrowSample(
                turnDegrees: 102,
                tiltDegrees: 23.5,
                julianDay: bone.end
            )),
        ]

        let locate = try XCTUnwrap(OrboSpineLocate(
            bone: bone,
            celestialSupports: supports,
            terraSamples: terra
        ))
        return Horae(locate: locate)
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
