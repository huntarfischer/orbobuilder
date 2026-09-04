import Foundation
import XCTest
@testable import OrboCore

final class OrboSpineArtifactTests: XCTestCase {
    func testRealArtifactBindsOneIdentityAcrossAllThreeDoors() throws {
        let artifact = try SealedOrboSpineArtifactFixture.artifact()

        XCTAssertEqual(artifact.mounted.provenance.artifactSHA256, artifact.receipt.sha256)
        XCTAssertEqual(artifact.mounted.provenance.candidateManifestSHA256,
                       artifact.source.provenance.candidateManifestSHA256)
        XCTAssertEqual(artifact.mounted.link.spineIdentity, artifact.receipt.sha256)
        XCTAssertEqual(artifact.mounted.inventory, artifact.source.inventory)
        XCTAssertEqual(artifact.receipt.formatVersion, OrboSpineArtifactFormat.version)
        XCTAssertGreaterThan(artifact.receipt.byteCount, 0)
        print("ORBOSPINE_ARTIFACT_BYTES=\(artifact.receipt.byteCount)")
        print("ORBOSPINE_ARTIFACT_SHA256=\(artifact.receipt.sha256)")
    }

    func testMountedSpineKeepsApolloContactsFreshAcrossTime() throws {
        let artifact = try SealedOrboSpineArtifactFixture.artifact()
        let horae = Horae(locate: artifact.mounted.locate)
        let firstMoment = JulianDay(artifact.source.bone.start.value + 1)!
        let secondMoment = JulianDay(firstMoment.value + 1)!
        XCTAssertLessThan(secondMoment.value, artifact.source.bone.end.value)

        var settings = ApolloAspectSettings()
        settings.orb = 45

        let first = try Apollo.establishAegis(
            at: firstMoment,
            using: horae,
            hestia: nil,
            atPlace: nil
        )
        let second = try Apollo.establishAegis(
            at: secondMoment,
            using: horae,
            hestia: nil,
            atPlace: nil
        )
        let firstContacts = Apollo.contacts(in: first.sky, settings: settings)
        let secondContacts = Apollo.contacts(in: second.sky, settings: settings)

        XCTAssertFalse(firstContacts.isEmpty)
        XCTAssertEqual(firstContacts.count, secondContacts.count)
        XCTAssertNotEqual(first.source.celestial, second.source.celestial)
        XCTAssertNotEqual(
            firstContacts,
            secondContacts,
            "Apollo's aspect relationships must refresh when Horae reads a new moment from the mounted Spine."
        )
    }

    func testMountedLocateMatchesRealCandidateAcrossBoneAndRejectsExclusiveEnd() throws {
        let artifact = try SealedOrboSpineArtifactFixture.artifact()
        let bone = artifact.source.bone
        let moments = [
            bone.start,
            JulianDay((bone.start.value + bone.end.value) / 2)!,
            JulianDay(bone.end.value.nextDown)!,
        ]

        for body in MundaneBody.canonicalOrder {
            for moment in moments {
                XCTAssertEqual(
                    try artifact.mounted.locate.coordinate(of: body, at: moment),
                    try artifact.source.locate.coordinate(of: body, at: moment),
                    "\(body) at \(moment.value)"
                )
            }
            let degree = try artifact.source.locate.coordinate(of: body, at: moments[1]).directionalDegree
            XCTAssertEqual(
                try artifact.mounted.locate.occurrences(of: body, at: degree),
                try artifact.source.locate.occurrences(of: body, at: degree),
                "\(body) inverse Locate"
            )
        }

        XCTAssertThrowsError(try artifact.source.locate.coordinate(of: .sun, at: bone.end)) {
            XCTAssertEqual($0 as? OrboSpineLocateError, .outsideBone)
        }
        XCTAssertThrowsError(try artifact.mounted.locate.coordinate(of: .sun, at: bone.end)) {
            XCTAssertEqual($0 as? OrboSpineLocateError, .outsideBone)
        }
    }

    func testMountedNavigationAndTerraMatchRealCandidate() throws {
        let artifact = try SealedOrboSpineArtifactFixture.artifact()
        let middle = JulianDay((artifact.source.bone.start.value + artifact.source.bone.end.value) / 2)!

        for body in MundaneBody.canonicalOrder {
            let coordinate = try artifact.source.locate.coordinate(of: body, at: middle)
            let cell = coordinate.directionalDegree.navigationCell
            XCTAssertEqual(
                try artifact.mounted.locate.candidateWindows(of: body, inNavigationCell: cell),
                try artifact.source.locate.candidateWindows(of: body, inNavigationCell: cell)
            )
        }
        for moment in [artifact.source.bone.start, middle, JulianDay(artifact.source.bone.end.value.nextDown)!] {
            XCTAssertEqual(
                try artifact.mounted.locate.terra(at: moment),
                try artifact.source.locate.terra(at: moment)
            )
        }
    }

    func testMountedLibraryContainsExactlyTheRealPreparedMatter() throws {
        let artifact = try SealedOrboSpineArtifactFixture.artifact()

        assertSameMatter(artifact.mounted.stations, artifact.source.stations)
        assertSameMatter(artifact.mounted.retrogradePassages, artifact.source.retrogradePassages)
        assertSameMatter(artifact.mounted.ringOccurrences, artifact.source.ringOccurrences)
        assertSameMatter(artifact.mounted.eclipses, artifact.source.eclipses)
        assertSameMatter(artifact.mounted.shellIntervals, artifact.source.shellIntervals)
    }

    func testMountedLinkRoundTripsTheSameLocatedMember() throws {
        let artifact = try SealedOrboSpineArtifactFixture.artifact()
        let moment = JulianDay((artifact.source.bone.start.value + artifact.source.bone.end.value) / 2)!
        let coordinate = try artifact.mounted.locate.coordinate(of: .moon, at: moment)
        let address = try artifact.mounted.link.address(of: coordinate)

        XCTAssertEqual(address.spineIdentity, artifact.receipt.sha256)
        XCTAssertEqual(try artifact.mounted.link.coordinate(at: address), coordinate)
    }

    func testArtifactManufactureIsDeterministicAndMountRequiresReceiptIdentity() throws {
        let artifact = try SealedOrboSpineArtifactFixture.artifact()
        let secondURL = artifact.url.deletingLastPathComponent().appendingPathComponent("orbo-v1-second.orbospine")
        let second = try HephaestusOrboSpineArtifactForge.forge(
            schematic: OrboSpineSchematic.current,
            candidate: artifact.source,
            to: secondURL
        )

        XCTAssertEqual(second, artifact.receipt)
        XCTAssertEqual(try Data(contentsOf: secondURL), try Data(contentsOf: artifact.url))
        XCTAssertThrowsError(try OrboSpineRuntime.mount(
            from: artifact.url,
            expectedSHA256: String(repeating: "0", count: 64)
        )) { error in
            guard case OrboSpineArtifactError.artifactIdentityMismatch = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testV1GrammarHasNoLinkPayload() {
        XCTAssertEqual(OrboSpineArtifactFormat.Section.allCases, [
            .metadata, .bodyDirectory, .segments, .navigationDirectory, .navigationIndices,
            .terra, .stations, .retrogradePassages, .ring, .eclipses, .shells,
        ])
    }

    private func assertSameMatter<T: Hashable>(
        _ mounted: [T],
        _ source: [T],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(mounted.count, source.count, file: file, line: line)
        XCTAssertEqual(Set(mounted), Set(source), file: file, line: line)
    }
}
