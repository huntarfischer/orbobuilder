import CryptoKit
import Foundation
import XCTest
@testable import OrboCore

final class OrboThreeDoorShippedTimespineTests: XCTestCase {
    func testThreeDoorsReadDistinctTruthFromSealedShippedTimespine() throws {
        let root = try shippedTimespineRoot()
        let seal: HephaestusSeal = try decode(root.appendingPathComponent("orbospine-hephaestus-seal.json"))
        let testimonyURL = root.appendingPathComponent("orbospine-dioscuri-testimony.json")
        let testimonyData = try Data(contentsOf: testimonyURL)
        let testimony = try JSONDecoder().decode(DioscuriTestimony.self, from: testimonyData)
        let candidateURL = root.appendingPathComponent("orbospine-candidate-manifest.json")
        let candidateData = try Data(contentsOf: candidateURL)
        let candidate = try JSONDecoder().decode(CandidateManifest.self, from: candidateData)
        let candidateSHA = sha256(candidateData)
        let declaredCandidateSHA = try declaredHash(
            root.appendingPathComponent("orbospine-candidate-manifest.sha256")
        )

        XCTAssertEqual(seal.authority, "Hephaestus")
        XCTAssertEqual(seal.lifecycle, "hephaestus-sealed")
        XCTAssertEqual(seal.schematicIdentity, OrboSpineContract.identity)
        XCTAssertEqual(candidate.identity, OrboSpineContract.identity)
        XCTAssertEqual(candidateSHA, declaredCandidateSHA)
        XCTAssertEqual(candidateSHA, seal.candidateManifestSHA256)
        XCTAssertEqual(sha256(testimonyData), seal.dioscuriTestimonySHA256)
        XCTAssertEqual(testimony.candidateManifestSHA256, candidateSHA)
        XCTAssertEqual(testimony.result, "confirmed")
        XCTAssertEqual(testimony.lifecycle, "dioscuri-certified")

        let celestialPath = "celestial/orbospine-celestial-manifest.json"
        let celestialData = try verifiedData(
            root: root,
            path: celestialPath,
            expectedSHA: try boundSHA(for: celestialPath, in: candidate)
        )
        let celestial = try JSONDecoder().decode(CelestialManifest.self, from: celestialData)
        XCTAssertEqual(celestial.identity, OrboSpineContract.identity)
        XCTAssertEqual(celestial.bodies.count, OrboSpineContract.canonicalBodies.count)

        let targetValue = 2_451_545.0
        let loadedLower = targetValue - 130.0
        let loadedUpper = targetValue + 130.0
        var bodyMatter: [MundaneBody: BodyMatter] = [:]

        for reference in celestial.bodies {
            let body = try body(named: reference.body)
            let supportPath = "celestial/\(reference.supportFile)"
            let stationPath = "celestial/\(reference.stationFile)"

            XCTAssertEqual(
                try boundSHA(for: supportPath, in: candidate),
                reference.supportSHA256
            )
            XCTAssertEqual(
                try boundSHA(for: stationPath, in: candidate),
                reference.stationSHA256
            )

            let supports = try loadSupports(
                body: body,
                data: verifiedData(
                    root: root,
                    path: supportPath,
                    expectedSHA: reference.supportSHA256
                ),
                lower: loadedLower,
                upper: loadedUpper
            )
            let stations = try loadStations(
                body: body,
                data: verifiedData(
                    root: root,
                    path: stationPath,
                    expectedSHA: reference.stationSHA256
                ),
                lower: loadedLower,
                upper: loadedUpper
            )

            XCTAssertGreaterThanOrEqual(supports.count, 2, "\(body.displayName) must expose real support matter around J2000")
            bodyMatter[body] = BodyMatter(supports: supports, stations: stations)
        }

        XCTAssertEqual(Set(bodyMatter.keys), Set(OrboSpineContract.canonicalBodies))

        let startValue = try safeStart(around: targetValue, matter: bodyMatter)
        let endValue = try safeEnd(around: targetValue, matter: bodyMatter)
        let start = try XCTUnwrap(JulianDay(startValue))
        let end = try XCTUnwrap(JulianDay(endValue))
        let target = try XCTUnwrap(JulianDay(targetValue))
        let bone = try XCTUnwrap(OrboSpineBoneSpan(start: start, end: end))

        let supports = bodyMatter.values.flatMap(\.supports).filter { bone.contains($0.julianDay) }
        let stations = bodyMatter.values.flatMap(\.stations).filter { bone.contains($0.julianDay) }

        let terraManifestPath = "terra/terra-marrow-manifest.json"
        let terraManifestData = try verifiedData(
            root: root,
            path: terraManifestPath,
            expectedSHA: try boundSHA(for: terraManifestPath, in: candidate)
        )
        let terraManifest = try JSONDecoder().decode(TerraManifest.self, from: terraManifestData)
        let terraSpan = try XCTUnwrap(
            terraManifest.spans.first {
                $0.startJulianDayUT <= startValue && $0.endJulianDayUT >= endValue
            }
        )
        let terraPath = "terra/\(terraSpan.file)"
        XCTAssertEqual(try boundSHA(for: terraPath, in: candidate), terraSpan.sha256)
        let terra = try loadTerra(
            data: verifiedData(root: root, path: terraPath, expectedSHA: terraSpan.sha256),
            lower: startValue - 1.0,
            upper: endValue + 1.0
        )

        let locate = try XCTUnwrap(
            OrboSpineLocate(
                bone: bone,
                celestialSupports: supports,
                stations: stations,
                terraSamples: terra
            )
        )

        // Door I / STATE: Horae receives the exact cross-section from real Locate matter.
        let horae = Horae(locate: locate)
        let state = try horae.seek(to: target)
        XCTAssertEqual(state.julianDay, target)
        XCTAssertEqual(state.celestial.map(\.body), OrboSpineContract.canonicalBodies)
        XCTAssertEqual(state.terra, try locate.terra(at: target))
        for coordinate in state.celestial {
            XCTAssertEqual(
                coordinate,
                try locate.coordinate(of: coordinate.body, at: target)
            )
        }

        // Door II / CHRONOLOGY: Chronos receives real prepared station rows through Library.
        let mercuryStations = stations.filter { $0.body == .mercury }
        XCTAssertFalse(mercuryStations.isEmpty)
        let library = OrboSpineLibraryCatalog(
            stations: stations,
            shellIntervals: []
        )
        let chronology = Chronos.resolveStations(body: .mercury, using: library)
        guard case let .resolved(answer) = chronology else {
            XCTFail("Chronos must resolve real Mercury chronology from Door II")
            return
        }
        XCTAssertEqual(answer.hits.count, mercuryStations.count)
        XCTAssertEqual(
            answer.hits.map(\.address),
            mercuryStations.map { ChronosAddress.moment($0.julianDay) }
        )

        // Door III / RELATION: Hecate receives one N-way Link built from established
        // coordinates that came from the sealed Timespine's real State and Chronology.
        let firstMercuryStation = try XCTUnwrap(mercuryStations.first)
        let secondMercuryStation = try XCTUnwrap(mercuryStations.dropFirst().first)
        let spineIdentity = "\(OrboSpineContract.identity):\(candidateSHA)"
        let stateAddress = try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: spineIdentity,
                memberIdentity: "locate:jd-ut:\(state.julianDay.value)"
            )
        )
        let firstChronologyAddress = try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: spineIdentity,
                memberIdentity: "library:stations:mercury:\(firstMercuryStation.julianDay.value)"
            )
        )
        let secondChronologyAddress = try XCTUnwrap(
            SpineLinkAddress(
                spineIdentity: spineIdentity,
                memberIdentity: "library:stations:mercury:\(secondMercuryStation.julianDay.value)"
            )
        )
        let link = try XCTUnwrap(
            SpineLinkSet(
                members: [
                    stateAddress,
                    firstChronologyAddress,
                    secondChronologyAddress,
                ]
            )
        )
        let hecate = HecateLink(link: link)

        XCTAssertEqual(SpineLinkSet.port, .link)
        XCTAssertEqual(
            hecate.members,
            [stateAddress, firstChronologyAddress, secondChronologyAddress]
        )
    }

    private struct HephaestusSeal: Decodable {
        let authority: String
        let candidateManifestSHA256: String
        let dioscuriTestimonySHA256: String
        let lifecycle: String
        let schematicIdentity: String
    }

    private struct DioscuriTestimony: Decodable {
        let candidateManifestSHA256: String
        let lifecycle: String
        let result: String
    }

    private struct CandidateManifest: Decodable {
        let identity: String
        let files: [BoundFile]
    }

    private struct BoundFile: Decodable {
        let path: String
        let sha256: String
    }

    private struct CelestialManifest: Decodable {
        let identity: String
        let bodies: [CelestialBodyReference]
    }

    private struct CelestialBodyReference: Decodable {
        let body: String
        let supportFile: String
        let supportSHA256: String
        let stationFile: String
        let stationSHA256: String
    }

    private struct TerraManifest: Decodable {
        let spans: [TerraSpan]
    }

    private struct TerraSpan: Decodable {
        let file: String
        let sha256: String
        let startJulianDayUT: Double
        let endJulianDayUT: Double
    }

    private struct BodyMatter {
        let supports: [OrboSpineCelestialCoordinate]
        let stations: [OrboSpineStation]
    }

    private struct LocalEvent {
        let julianDay: Double
        let isStation: Bool
    }

    private enum ProofError: Error, CustomStringConvertible {
        case shippedRootNotFound
        case malformed(String)
        case unsealed(String)

        var description: String {
            switch self {
            case .shippedRootNotFound:
                return "sealed tools/pass5/orbospine-build root not found"
            case let .malformed(value):
                return "malformed shipped Timespine matter: \(value)"
            case let .unsealed(value):
                return "shipped Timespine file is not bound by the candidate seal: \(value)"
            }
        }
    }

    private func shippedTimespineRoot() throws -> URL {
        if let environment = ProcessInfo.processInfo.environment["ORBO_TIMESPINE_BUILD_ROOT"] {
            let url = URL(fileURLWithPath: environment, isDirectory: true)
            if FileManager.default.fileExists(
                atPath: url.appendingPathComponent("orbospine-hephaestus-seal.json").path
            ) {
                return url
            }
        }

        var cursor = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while cursor.path != "/" {
            let candidate = cursor.appendingPathComponent(
                "tools/pass5/orbospine-build",
                isDirectory: true
            )
            if FileManager.default.fileExists(
                atPath: candidate.appendingPathComponent("orbospine-hephaestus-seal.json").path
            ) {
                return candidate
            }
            cursor.deleteLastPathComponent()
        }
        throw ProofError.shippedRootNotFound
    }

    private func decode<T: Decodable>(_ url: URL) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }

    private func declaredHash(_ url: URL) throws -> String {
        let text = try String(contentsOf: url, encoding: .utf8)
        guard let first = text.split(whereSeparator: \.isWhitespace).first else {
            throw ProofError.malformed(url.lastPathComponent)
        }
        return String(first)
    }

    private func boundSHA(
        for path: String,
        in manifest: CandidateManifest
    ) throws -> String {
        guard let file = manifest.files.first(where: { $0.path == path }) else {
            throw ProofError.unsealed(path)
        }
        return file.sha256
    }

    private func verifiedData(
        root: URL,
        path: String,
        expectedSHA: String
    ) throws -> Data {
        let data = try Data(contentsOf: root.appendingPathComponent(path))
        guard sha256(data) == expectedSHA else {
            throw ProofError.unsealed(path)
        }
        return data
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func loadSupports(
        body: MundaneBody,
        data: Data,
        lower: Double,
        upper: Double
    ) throws -> [OrboSpineCelestialCoordinate] {
        let lines = try csvLines(data)
        guard lines.first == [
            "directional_degree",
            "physical_degree",
            "navigation_cell",
            "motion",
            "jd_ut",
            "civic_offset_seconds",
        ] else {
            throw ProofError.malformed("\(body.displayName) support header")
        }

        var result: [OrboSpineCelestialCoordinate] = []
        for fields in lines.dropFirst() {
            guard fields.count == 6,
                  let directionalValue = Double(fields[0]),
                  let directional = OrboSpineDirectionalDegree(directionalValue),
                  let julianValue = Double(fields[4]),
                  julianValue >= lower,
                  julianValue < upper,
                  let julianDay = JulianDay(julianValue) else {
                if fields.count == 6, let julianValue = Double(fields[4]),
                   (julianValue < lower || julianValue >= upper) {
                    continue
                }
                throw ProofError.malformed("\(body.displayName) support row")
            }
            result.append(
                OrboSpineCelestialCoordinate(
                    body: body,
                    directionalDegree: directional,
                    julianDay: julianDay
                )
            )
        }
        return result
    }

    private func loadStations(
        body: MundaneBody,
        data: Data,
        lower: Double,
        upper: Double
    ) throws -> [OrboSpineStation] {
        let lines = try csvLines(data)
        guard lines.first == [
            "physical_degree",
            "directional_degree_after",
            "navigation_cell_after",
            "lane_before",
            "lane_after",
            "jd_ut",
        ] else {
            throw ProofError.malformed("\(body.displayName) station header")
        }

        var result: [OrboSpineStation] = []
        for fields in lines.dropFirst() {
            guard fields.count == 6,
                  let physical = Double(fields[0]),
                  let before = Motion(rawValue: fields[3]),
                  let after = Motion(rawValue: fields[4]),
                  let julianValue = Double(fields[5]) else {
                throw ProofError.malformed("\(body.displayName) station row")
            }
            if julianValue < lower || julianValue >= upper { continue }
            guard let julianDay = JulianDay(julianValue),
                  let station = OrboSpineStation(
                    body: body,
                    physicalDegrees: physical,
                    julianDay: julianDay,
                    laneBefore: before,
                    laneAfter: after
                  ) else {
                throw ProofError.malformed("\(body.displayName) station topology")
            }
            result.append(station)
        }
        return result
    }

    private func loadTerra(
        data: Data,
        lower: Double,
        upper: Double
    ) throws -> [TerraMarrowSample] {
        let lines = try csvLines(data)
        guard lines.first == ["jd_ut", "turn_degrees", "tilt_degrees", "sample_kind"] else {
            throw ProofError.malformed("Terra header")
        }

        var result: [TerraMarrowSample] = []
        for fields in lines.dropFirst() {
            guard fields.count == 4,
                  let julianValue = Double(fields[0]) else {
                throw ProofError.malformed("Terra row")
            }
            if julianValue < lower || julianValue > upper { continue }
            guard let turn = Double(fields[1]),
                  let tilt = Double(fields[2]),
                  let julianDay = JulianDay(julianValue),
                  let sample = TerraMarrowSample(
                    turnDegrees: turn,
                    tiltDegrees: tilt,
                    julianDay: julianDay
                  ) else {
                throw ProofError.malformed("Terra sample")
            }
            result.append(sample)
        }
        return result
    }

    private func csvLines(_ data: Data) throws -> [[String]] {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ProofError.malformed("non-UTF8 CSV")
        }
        return text
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { line in
                String(line)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\r"))
                    .split(separator: ",", omittingEmptySubsequences: false)
                    .map(String.init)
            }
    }

    private func safeStart(
        around target: Double,
        matter: [MundaneBody: BodyMatter]
    ) throws -> Double {
        var candidate = target - 90.0
        while candidate <= target - 60.0 {
            if matter.values.allSatisfy({ startIsSafe(candidate, in: $0) }) {
                return candidate
            }
            candidate += 0.25
        }
        throw ProofError.malformed("no common non-station Door I start boundary")
    }

    private func safeEnd(
        around target: Double,
        matter: [MundaneBody: BodyMatter]
    ) throws -> Double {
        var candidate = target + 90.0
        while candidate >= target + 60.0 {
            if matter.values.allSatisfy({ endIsSafe(candidate, in: $0) }) {
                return candidate
            }
            candidate -= 0.25
        }
        throw ProofError.malformed("no common non-station Door I end boundary")
    }

    private func startIsSafe(_ candidate: Double, in matter: BodyMatter) -> Bool {
        let events = localEvents(matter)
        guard let first = events.first(where: { $0.julianDay >= candidate }),
              !first.isStation else {
            return false
        }
        return matter.supports.filter { $0.julianDay.value >= candidate }.count >= 2
    }

    private func endIsSafe(_ candidate: Double, in matter: BodyMatter) -> Bool {
        let events = localEvents(matter)
        guard let last = events.last(where: { $0.julianDay < candidate }),
              !last.isStation else {
            return false
        }
        return matter.supports.filter { $0.julianDay.value < candidate }.count >= 2
    }

    private func localEvents(_ matter: BodyMatter) -> [LocalEvent] {
        (
            matter.supports.map {
                LocalEvent(julianDay: $0.julianDay.value, isStation: false)
            }
            + matter.stations.map {
                LocalEvent(julianDay: $0.julianDay.value, isStation: true)
            }
        ).sorted { $0.julianDay < $1.julianDay }
    }

    private func body(named name: String) throws -> MundaneBody {
        let key = normalized(name)
        if key == "northnode" || key == "truenorthnode" || key == "truenode" {
            return .trueNorthNode
        }
        guard let body = OrboSpineContract.canonicalBodies.first(where: {
            normalized($0.displayName) == key || normalized($0.constructionDataName) == key
        }) else {
            throw ProofError.malformed("unknown body \(name)")
        }
        return body
    }

    private func normalized(_ value: String) -> String {
        String(value.lowercased().filter { $0.isLetter || $0.isNumber })
    }
}
