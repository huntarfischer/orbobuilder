import Foundation
import XCTest
@testable import OrboCore

final class NatalSpineArtifactTests: XCTestCase {
    func testHephaestusWritesDeterministicArtifactAndExternalReceipt() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let first = temporaryURL("first.natalspine")
        let second = temporaryURL("second.natalspine")
        let receiptURL = temporaryURL("first.natalspine.json")

        let firstReceipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: first)
        let secondReceipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: second)
        try firstReceipt.write(to: receiptURL)

        XCTAssertEqual(firstReceipt, secondReceipt)
        XCTAssertEqual(try Data(contentsOf: first), try Data(contentsOf: second))
        XCTAssertEqual(
            try NatalSpineArtifactReceipt.read(from: receiptURL),
            firstReceipt
        )
        XCTAssertEqual(firstReceipt.formatVersion, NatalSpineArtifactFormat.version)
        XCTAssertEqual(firstReceipt.subjectID, sealed.subjectID.rawValue)
        XCTAssertEqual(
            firstReceipt.parentSpineIdentity,
            sealed.seal.parentProvenance.spineIdentity
        )
    }

    func testArtifactPersistsFinishedLocateNavigationExactly() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("finished-navigation.natalspine")

        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let mounted = try NatalSpineMountedArtifact(url: url)

        XCTAssertEqual(try mounted.finishedLocateTracts(), sealed.candidate.artifactTracts)
        XCTAssertEqual(try mounted.finishedLocateTracts().map(\.body), MundaneBody.canonicalOrder)
        XCTAssertTrue(try mounted.finishedLocateTracts().allSatisfy { $0.segmentIndexesByCell.count == 720 })
        XCTAssertEqual(receipt.formatVersion, NatalSpineArtifactFormat.version)
        XCTAssertEqual(receipt.formatVersion, 2)
    }

    func testMountedArtifactPreservesLayersAndBothDirectionsOfAddressability() throws {
        let (sealed, runtime, _) = try mountedFixture()

        XCTAssertEqual(runtime.subjectID, sealed.subjectID)
        XCTAssertEqual(runtime.packageID, sealed.packageID)
        XCTAssertEqual(runtime.bounds, sealed.bounds)
        XCTAssertEqual(runtime.themis.count, sealed.candidate.themis.count)
        XCTAssertEqual(runtime.oceanus.count, sealed.candidate.oceanus.count)
        XCTAssertEqual(runtime.rhea.count, sealed.candidate.rhea.count)

        let moment = runtime.bounds.natal.julianDay
        let mountedAddresses = try Horae.locateNatalSpine(runtime, at: moment)
        let memoryPosition = try Horae.locateNatalSpine(sealed, at: moment)
        XCTAssertEqual(mountedAddresses.count, MundaneBody.canonicalOrder.count)
        XCTAssertEqual(
            mountedAddresses.map(\.coordinate),
            memoryPosition.addresses.map(\.coordinate)
        )

        let sun = try XCTUnwrap(mountedAddresses.first { $0.coordinate.body == .sun })
        let occurrences = try Horae.locateNatalSpine(
            runtime,
            body: .sun,
            at: sun.coordinate.directionalDegree
        )
        XCTAssertFalse(occurrences.isEmpty)
        XCTAssertTrue(occurrences.allSatisfy { runtime.bounds.bone.contains($0.coordinate.julianDay) })
    }

    func testMountFailsClosedOnExternalArtifactOrParentIdentityMismatch() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("identity.natalspine")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)

        XCTAssertThrowsError(
            try NatalSpineRuntime.mount(
                from: url,
                expectedSHA256: String(repeating: "0", count: 64),
                expectedParentSpineIdentity: receipt.parentSpineIdentity
            )
        ) { error in
            guard case NatalSpineArtifactError.artifactIdentityMismatch = error else {
                return XCTFail("Expected artifact identity mismatch, received \(error)")
            }
        }

        XCTAssertThrowsError(
            try NatalSpineRuntime.mount(
                from: url,
                expectedSHA256: receipt.sha256,
                expectedParentSpineIdentity: String(repeating: "1", count: 64)
            )
        ) { error in
            guard case NatalSpineArtifactError.parentIdentityMismatch = error else {
                return XCTFail("Expected parent identity mismatch, received \(error)")
            }
        }
    }


    func testMappedNavigationMatchesForgedCoordinatesAndAll720Cells() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("mapped.natalspine")
        _ = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let mounted = try NatalSpineMountedArtifact(url: url)
        for tract in sealed.candidate.artifactTracts {
            for cell in 0..<720 {
                XCTAssertEqual(try mounted.navigationIndices(of: tract.body, cell: cell),
                               tract.segmentIndexesByCell[cell])
            }
            for segment in tract.segments {
                for day in [segment.start, JulianDay((segment.start.value + segment.end.value) / 2)!] {
                    XCTAssertEqual(try mounted.mappedCoordinate(of: tract.body, at: day),
                                   try sealed.candidate.address(of: tract.body, at: day).coordinate)
                }
            }
        }
        XCTAssertThrowsError(try mounted.mappedCoordinate(of: .sun, at: sealed.bounds.bone.end))
        XCTAssertThrowsError(try mounted.mappedCoordinate(of: .sun,
            at: JulianDay(sealed.bounds.bone.start.value - 1)!))
    }

    func testMappedRetrogradeRecurrencesAndStationLaneOwnership() throws {
        let commission = try NatalSpineActIIFixture.forgeCommission()
        let parent = RetrogradeParent(commission: commission)
        let substrate = try Hephaestus.forgeNatalSpineSubstrate(for: commission, from: parent)
        let themis = try Hephaestus.forgeNatalSpineThemis(for: commission, on: substrate)
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        let rhea = try Hephaestus.forgeNatalSpineRhea(on: oceanus)
        let candidate = try Hephaestus.forgeNatalSpineAddressability(on: rhea)
        let approval = try Dioscuri.inspectNatalSpine(candidate,
            against: commission.schematics, parent: parent).get()
        let sealed = Hephaestus.sealNatalSpine(approval)
        let url = temporaryURL("retrograde.natalspine")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let runtime = try NatalSpineRuntime.mount(from: url, expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: receipt.parentSpineIdentity)
        for motion in [Motion.direct, .retrograde] {
            let degree = OrboSpineDirectionalDegree(physicalDegrees: 90, motion: motion)!
            let expected = try candidate.addresses(of: .mercury, at: degree)
            let actual = try runtime.addresses(of: .mercury, at: degree)
            XCTAssertEqual(actual.map(\.coordinate), expected.map(\.coordinate))
            XCTAssertEqual(actual.count, motion == .direct ? 2 : 1)
        }
        for station in parent.sourceStations {
            XCTAssertEqual(try runtime.address(of: .mercury, at: station.julianDay)
                .coordinate.directionalDegree.motion, station.laneAfter)
        }
    }

    func testMalformedNavigationRangesAndIndicesFailClosed() throws {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("corrupt-navigation.natalspine")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let original = try Data(contentsOf: url)
        let directory = sectionOffset(.locateBodyDirectory, in: original)
        var overlappingBodies = original
        writeUInt64(0, into: &overlappingBodies, at: directory + 32 + 8)
        XCTAssertThrowsError(try NatalSpineMountedArtifact(data: overlappingBodies))

        var invalidIndex = original
        let indices = sectionOffset(.locateNavigationIndices, in: original)
        writeUInt64(UInt64.max, into: &invalidIndex, at: indices)
        let corrupted = try NatalSpineMountedArtifact(data: invalidIndex)
        let firstTract = sealed.candidate.artifactTracts[0]
        let occupiedCell = try XCTUnwrap(firstTract.segmentIndexesByCell.firstIndex { !$0.isEmpty })
        XCTAssertThrowsError(try corrupted.navigationIndices(of: firstTract.body, cell: occupiedCell))
        try invalidIndex.write(to: url)
        XCTAssertThrowsError(try NatalSpineRuntime.mount(from: url, expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: receipt.parentSpineIdentity))

        var overflowingCount = original
        writeUInt64(UInt64.max / 2, into: &overflowingCount,
                    at: NatalSpineArtifactFormat.headerSize + 24 + 32)
        XCTAssertThrowsError(try NatalSpineMountedArtifact(data: overflowingCount))
    }

    private func sectionOffset(_ section: NatalSpineArtifactFormat.Section, in data: Data) -> Int {
        let position = NatalSpineArtifactFormat.headerSize + (Int(section.rawValue) - 1) * 32 + 8
        return Int((0..<8).reduce(UInt64(0)) { $0 | UInt64(data[position + $1]) << ($1 * 8) })
    }

    private func writeUInt64(_ value: UInt64, into data: inout Data, at offset: Int) {
        for byte in 0..<8 { data[offset + byte] = UInt8(truncatingIfNeeded: value >> (byte * 8)) }
    }

    private func mountedFixture() throws -> (
        SealedNatalSpine,
        NatalSpineRuntime,
        NatalSpineArtifactReceipt
    ) {
        let sealed = try NatalSpineActIIIFixture.sealedSpine()
        let url = temporaryURL("fixture.natalspine")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(sealed, to: url)
        let runtime = try NatalSpineRuntime.mount(
            from: url,
            expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: receipt.parentSpineIdentity
        )
        return (sealed, runtime, receipt)
    }

    private func temporaryURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("NatalSpineTests-\(UUID().uuidString)-\(name)")
    }
}


/// Parent first: a deterministic Mercury forward/reverse/forward tract.
/// All other bodies use the existing canonical-parent fixture.
private struct RetrogradeParent: NatalSpineForgeTimespineSource {
    let commission: NatalSpineForgeCommission
    var base: NatalSpineActIIFixture.ParentSource { .init(commission: commission) }
    var sourceBone: OrboSpineBoneSpan { base.sourceBone }
    var sourceProvenance: OrboSpineRuntimeProvenance { base.sourceProvenance }
    var bone: OrboSpineBoneSpan { commission.schematics.bounds.bone }
    var duration: Double { bone.end.value - bone.start.value }
    var sourceStations: [OrboSpineStation] {
        [
            OrboSpineStation(body: .mercury, physicalDegrees: 120,
                julianDay: day(1.0 / 3), laneBefore: .direct, laneAfter: .retrograde)!,
            OrboSpineStation(body: .mercury, physicalDegrees: 60,
                julianDay: day(2.0 / 3), laneBefore: .retrograde, laneAfter: .direct)!
        ]
    }

    func coordinate(of body: MundaneBody, at julianDay: JulianDay) throws -> OrboSpineCelestialCoordinate {
        guard body == .mercury else { return try base.coordinate(of: body, at: julianDay) }
        let fraction = (julianDay.value - bone.start.value) / duration
        let degrees: Double
        let motion: Motion
        if julianDay.value < day(1.0 / 3).value {
            degrees = 360 * fraction; motion = .direct
        } else if julianDay.value < day(2.0 / 3).value {
            degrees = 120 - 180 * (fraction - 1.0 / 3); motion = .retrograde
        } else {
            degrees = 60 + 360 * (fraction - 2.0 / 3); motion = .direct
        }
        return OrboSpineCelestialCoordinate(body: body,
            directionalDegree: OrboSpineDirectionalDegree(physicalDegrees: degrees, motion: motion)!,
            julianDay: julianDay)
    }

    func occurrences(of body: MundaneBody, at degree: OrboSpineDirectionalDegree) throws -> [OrboSpineCelestialCoordinate] {
        guard body == .mercury else { return try base.occurrences(of: body, at: degree) }
        let physical = degree.physicalDegrees
        var fractions: [Double] = []
        if degree.motion == .direct {
            if physical >= 0 && physical < 120 { fractions.append(physical / 360) }
            if physical >= 60 && physical < 180 { fractions.append(2.0 / 3 + (physical - 60) / 360) }
        } else if physical > 60 && physical <= 120 {
            fractions.append(1.0 / 3 + (120 - physical) / 180)
        }
        return fractions.map { OrboSpineCelestialCoordinate(body: body,
            directionalDegree: degree, julianDay: day($0)) }
    }

    private func day(_ fraction: Double) -> JulianDay {
        JulianDay(bone.start.value + duration * fraction)!
    }
}
