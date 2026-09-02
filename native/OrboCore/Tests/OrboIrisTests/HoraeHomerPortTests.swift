import XCTest
@testable import OrboCore
@testable import OrboIris

final class HoraeHomerPortTests: XCTestCase {
    func testRealHoraeOutputTravelsThroughHomerAndIrisUnchanged() throws {
        let runtime = try makeRuntime()
        let horae = Horae(locate: runtime.locate)
        let output = try horae.seek(to: JulianDay(1_000.75)!)

        let homerPort = Horae.signalForHomer(output)
        let irisPort = Homer.POV(homerPort)
        let frame = IrisHomerFrame(port: irisPort)

        XCTAssertEqual(output.celestial.count, 11)
        XCTAssertEqual(output.celestial.map(\.body), OrboSpineContract.canonicalBodies)
        XCTAssertEqual(homerPort.pointOfView, output)
        XCTAssertEqual(irisPort.signal, output)
        XCTAssertEqual(frame.pointOfView, output)
    }

    func testDirectIrisAndHomerPOVCarryTheSameHoraeAuthoredSnapshot() throws {
        let runtime = try makeRuntime()
        let horae = Horae(locate: runtime.locate)
        let output = try horae.seek(to: JulianDay(1_000.5)!)

        let directPort = Horae.signalForIris(output)
        let homerFrame = IrisHomerFrame(port: Homer.POV(Horae.signalForHomer(output)))

        XCTAssertEqual(directPort.signal, output)
        XCTAssertEqual(homerFrame.pointOfView, output)
        XCTAssertEqual(homerFrame.pointOfView, directPort.signal)
    }

    func testSuccessiveRealHoraePOVsRemainIndependentSnapshots() throws {
        let runtime = try makeRuntime()
        let horae = Horae(locate: runtime.locate)
        let first = try horae.seek(to: JulianDay(1_000.25)!)
        let second = try horae.seek(to: JulianDay(1_000.75)!)

        let firstFrame = IrisHomerFrame(port: Homer.POV(Horae.signalForHomer(first)))
        let secondFrame = IrisHomerFrame(port: Homer.POV(Horae.signalForHomer(second)))

        XCTAssertEqual(firstFrame.pointOfView, first)
        XCTAssertEqual(secondFrame.pointOfView, second)
        XCTAssertNotEqual(firstFrame.pointOfView.julianDay, secondFrame.pointOfView.julianDay)
        XCTAssertNotEqual(firstFrame.pointOfView.terra, secondFrame.pointOfView.terra)
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
