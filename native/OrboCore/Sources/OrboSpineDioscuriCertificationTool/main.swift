import CryptoKit
import Foundation
import OrboCore

private enum CertificationError: Error, CustomStringConvertible {
    case usage
    case missing(String)
    case malformed(String)
    case mismatch(String)

    var description: String {
        switch self {
        case .usage:
            return "usage: OrboSpineDioscuriCertificationTool --build-root <tools/pass5/orbospine-build>"
        case let .missing(value):
            return "Missing Dioscuri input: \(value)"
        case let .malformed(value):
            return "Malformed Dioscuri input: \(value)"
        case let .mismatch(value):
            return "Dioscuri mismatch: \(value)"
        }
    }
}

private struct Arguments {
    let buildRoot: URL

    init(_ raw: [String]) throws {
        guard raw.count == 2, raw[0] == "--build-root" else {
            throw CertificationError.usage
        }
        buildRoot = URL(fileURLWithPath: raw[1], isDirectory: true).standardizedFileURL
    }
}

private struct CandidateFile: Decodable {
    let path: String
    let role: String
    let bytes: Int64
    let sha256: String
}

private struct CandidateManifest: Decodable {
    let identity: String
    let lifecycle: String
    let astronomicalAuthority: String
    let astronomicalSourceVersion: String
    let files: [CandidateFile]
}

private struct CelestialBodyReference: Decodable {
    let body: String
    let supportDegrees: Double
    let supportRows: Int
    let stationRows: Int
    let supportFile: String
    let supportSHA256: String
    let stationFile: String
    let stationSHA256: String
}

private struct CelestialManifestReference: Decodable {
    let identity: String
    let astronomicalSource: String
    let astronomicalSourceVersion: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let bodies: [CelestialBodyReference]
    let totalSupportRows: Int
    let totalStationRows: Int
}

private struct TestimonyArtifact: Encodable {
    let authority: String
    let lifecycle: String
    let schematicIdentity: String
    let schematicVersion: UInt16
    let candidateManifestSHA256: String
    let result: String
    let polluxSource: String
    let castorSource: String
}

private struct CSVHeader {
    let names: [String]
    private let indexes: [String: Int]

    init(_ names: [String]) {
        self.names = names
        self.indexes = Dictionary(uniqueKeysWithValues: names.enumerated().map {
            (Self.normalized($0.element), $0.offset)
        })
    }

    func index(for aliases: [String]) -> Int? {
        aliases.lazy.compactMap { indexes[Self.normalized($0)] }.first
    }

    private static func normalized(_ value: String) -> String {
        String(value.lowercased().filter { $0.isLetter || $0.isNumber })
    }
}

private final class LineReader {
    private let handle: FileHandle
    private var buffer = Data()
    private var reachedEOF = false

    init(_ url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CertificationError.missing(url.path)
        }
        handle = try FileHandle(forReadingFrom: url)
    }

    deinit { try? handle.close() }

    func readLine() throws -> String? {
        while true {
            if let newline = buffer.firstIndex(of: 0x0a) {
                let data = buffer.subdata(in: buffer.startIndex..<newline)
                buffer.removeSubrange(buffer.startIndex...newline)
                guard let line = String(data: data, encoding: .utf8) else {
                    throw CertificationError.malformed("non-UTF8 CSV")
                }
                return line
            }
            if reachedEOF {
                guard !buffer.isEmpty else { return nil }
                let data = buffer
                buffer.removeAll(keepingCapacity: false)
                guard let line = String(data: data, encoding: .utf8) else {
                    throw CertificationError.malformed("non-UTF8 CSV")
                }
                return line
            }
            let chunk = try handle.read(upToCount: 65_536) ?? Data()
            if chunk.isEmpty { reachedEOF = true } else { buffer.append(chunk) }
        }
    }
}

private enum Certification {
    private static let candidateManifest = "orbospine-candidate-manifest.json"
    private static let candidateHash = "orbospine-candidate-manifest.sha256"
    private static let celestialManifest = "celestial/orbospine-celestial-manifest.json"
    private static let boundaryAnchors = "celestial/orbospine-boundary-anchors.csv"
    private static let testimonyFile = "orbospine-dioscuri-testimony.json"
    private static let testimonyHashFile = "orbospine-dioscuri-testimony.sha256"

    static func run(_ raw: [String]) throws {
        let arguments = try Arguments(raw)
        let root = arguments.buildRoot
        let schematic = OrboSpineSchematic.current

        print("ORBOSPINE DIOSCURI CERTIFICATION")

        let candidateURL = root.appendingPathComponent(candidateManifest)
        let candidate: CandidateManifest = try decode(candidateURL)
        let candidateSHA = try sha256(candidateURL)
        let declaredCandidateSHA = try declaredHash(root.appendingPathComponent(candidateHash))
        guard candidateSHA == declaredCandidateSHA,
              candidate.identity == schematic.identity,
              candidate.lifecycle == OrboSpineLifecycleBoundary.candidate.rawValue,
              candidate.astronomicalAuthority == schematic.astronomicalAuthority,
              candidate.astronomicalSourceVersion == schematic.astronomicalSourceVersion else {
            throw CertificationError.mismatch("candidate identity/binding drift")
        }
        print("PASS candidate: \(candidateSHA)")

        try verifyBoundFiles(candidate.files, root: root)
        print("PASS bound matter: \(candidate.files.count) / \(candidate.files.count) SHA-256")

        let celestial: CelestialManifestReference = try decode(root.appendingPathComponent(celestialManifest))
        guard celestial.identity == schematic.identity,
              celestial.astronomicalSource == schematic.astronomicalAuthority,
              celestial.astronomicalSourceVersion == schematic.astronomicalSourceVersion,
              same(celestial.supportedStartJulianDayUT, schematic.bone.start.value),
              same(celestial.supportedEndJulianDayUT, schematic.bone.end.value),
              celestial.bodies.count == schematic.bodyPlans.count,
              celestial.totalSupportRows == 1_550_229,
              celestial.totalStationRows == 52_679 else {
            throw CertificationError.mismatch("celestial source contract drift")
        }

        let candidateByPath = Dictionary(uniqueKeysWithValues: candidate.files.map { ($0.path, $0) })
        var supports: [OrboSpineCelestialCoordinate] = []
        var stations: [OrboSpineStation] = []
        supports.reserveCapacity(celestial.totalSupportRows)
        stations.reserveCapacity(celestial.totalStationRows)

        for body in MundaneBody.canonicalOrder {
            guard let reference = celestial.bodies.first(where: { bodyKey($0.body) == bodyKey(body.displayName) }),
                  same(reference.supportDegrees, OrboSpineContract.supportDegrees(for: body)) else {
                throw CertificationError.mismatch("missing celestial reference for \(body.displayName)")
            }
            let supportPath = "celestial/\(reference.supportFile)"
            let stationPath = "celestial/\(reference.stationFile)"
            guard candidateByPath[supportPath]?.sha256 == reference.supportSHA256,
                  candidateByPath[stationPath]?.sha256 == reference.stationSHA256 else {
                throw CertificationError.mismatch("candidate/celestial SHA binding drift for \(body.displayName)")
            }
            supports.append(contentsOf: try loadSupports(
                body: body,
                url: root.appendingPathComponent(supportPath),
                expectedRows: reference.supportRows,
                bone: schematic.bone
            ))
            stations.append(contentsOf: try loadStations(
                body: body,
                url: root.appendingPathComponent(stationPath),
                expectedRows: reference.stationRows,
                bone: schematic.bone
            ))
        }
        guard supports.count == celestial.totalSupportRows,
              stations.count == celestial.totalStationRows else {
            throw CertificationError.mismatch("loaded celestial row counts drift")
        }
        print("PASS Pollux source: \(supports.count) supports / \(stations.count) stations")

        let anchors = try loadBoundaryAnchors(
            root: root,
            files: candidate.files,
            bone: schematic.bone
        )
        print("PASS Castor anchors: \(anchors.count) exact Bone states")

        let terraProbes = try loadTerraRuntimeProbes(root: root, files: candidate.files, bone: schematic.bone)
        let shellIntervals = try loadRuntimeShellIntersections(root: root, files: candidate.files, bone: schematic.bone)

        guard let provenance = OrboSpineRuntimeProvenance(
            candidateManifestSHA256: candidateSHA,
            astronomicalAuthority: candidate.astronomicalAuthority,
            astronomicalSourceVersion: candidate.astronomicalSourceVersion
        ),
        let runtime = OrboSpineRuntime(
            bone: schematic.bone,
            celestialSupports: supports,
            stations: stations,
            boundaryAnchors: anchors,
            retrogradePassages: [],
            ringOccurrences: [],
            eclipses: [],
            shellIntervals: shellIntervals,
            terraSamples: terraProbes,
            provenance: provenance
        ),
        let source = OrboSpineDurableCelestialResonanceSource(
            schematic: schematic,
            supports: supports,
            stations: stations
        ),
        let assignment = SpineResonanceAssignment(schematic: schematic, candidate: runtime) else {
            throw CertificationError.mismatch("production resonance boundary cannot form")
        }

        let testimony = try SpineResonanceRun.run(
            schematic: schematic,
            source: source,
            assignment: assignment
        )
        guard testimony.schematicIdentity == schematic.identity,
              testimony.schematicVersion == schematic.version,
              testimony.candidateIdentity == candidateSHA,
              testimony.result == .confirmed else {
            throw CertificationError.mismatch("Dioscuri testimony is not confirmed")
        }

        let artifact = TestimonyArtifact(
            authority: "Dioscuri",
            lifecycle: OrboSpineLifecycleBoundary.dioscuriCertified.rawValue,
            schematicIdentity: testimony.schematicIdentity,
            schematicVersion: testimony.schematicVersion,
            candidateManifestSHA256: testimony.candidateIdentity,
            result: "confirmed",
            polluxSource: "forged durable celestial matter",
            castorSource: "assembled candidate Locate"
        )
        let testimonyURL = root.appendingPathComponent(testimonyFile)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(artifact).write(to: testimonyURL, options: .atomic)
        let testimonySHA = try sha256(testimonyURL)
        try "\(testimonySHA)  \(testimonyFile)\n".write(
            to: root.appendingPathComponent(testimonyHashFile),
            atomically: true,
            encoding: .utf8
        )

        print("PASS Castor candidate: \(candidateSHA)")
        print("DIOSCURI TESTIMONY: CONFIRMED")
        print("testimony: \(testimonyURL.path)")
        print("testimony SHA-256: \(testimonySHA)")
        print("CERTIFICATION STAGE: COMPLETE / DIOSCURI-CERTIFIED")
    }

    private static func loadSupports(
        body: MundaneBody,
        url: URL,
        expectedRows: Int,
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineCelestialCoordinate] {
        var result: [OrboSpineCelestialCoordinate] = []
        result.reserveCapacity(expectedRows)
        var previous = -Double.infinity
        let count = try streamCSV(url) { header, fields, row in
            let directionalValue = try double(fields, header, ["directional_degree"], url, row)
            let physical = try double(fields, header, ["physical_degree"], url, row)
            let cell = try int(fields, header, ["navigation_cell"], url, row)
            let motionText = try text(fields, header, ["motion"], url, row)
            let jdValue = try double(fields, header, ["jd_ut"], url, row)
            guard let motion = Motion(rawValue: motionText),
                  let directional = OrboSpineDirectionalDegree(directionalValue),
                  let jd = JulianDay(jdValue),
                  bone.contains(jd),
                  directional.motion == motion,
                  directional.navigationCell == cell,
                  circularDistance(directional.physicalDegrees, physical) <= 1e-9,
                  jdValue > previous else {
                throw CertificationError.mismatch("\(url.lastPathComponent) support row \(row)")
            }
            previous = jdValue
            result.append(OrboSpineCelestialCoordinate(body: body, directionalDegree: directional, julianDay: jd))
        }
        guard count == expectedRows else {
            throw CertificationError.mismatch("\(url.lastPathComponent) support rows \(count) != \(expectedRows)")
        }
        return result
    }

    private static func loadStations(
        body: MundaneBody,
        url: URL,
        expectedRows: Int,
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineStation] {
        var result: [OrboSpineStation] = []
        result.reserveCapacity(expectedRows)
        var previous = -Double.infinity
        let count = try streamCSV(url) { header, fields, row in
            let physical = try double(fields, header, ["physical_degree"], url, row)
            let directionalValue = try double(fields, header, ["directional_degree_after"], url, row)
            let cell = try int(fields, header, ["navigation_cell_after"], url, row)
            let beforeText = try text(fields, header, ["lane_before"], url, row)
            let afterText = try text(fields, header, ["lane_after"], url, row)
            let jdValue = try double(fields, header, ["jd_ut"], url, row)
            guard let before = Motion(rawValue: beforeText),
                  let after = Motion(rawValue: afterText),
                  let jd = JulianDay(jdValue),
                  bone.contains(jd),
                  let station = OrboSpineStation(
                    body: body,
                    physicalDegrees: physical,
                    julianDay: jd,
                    laneBefore: before,
                    laneAfter: after
                  ),
                  same(station.directionalDegreeAfter.degrees, directionalValue),
                  station.navigationCellAfter == cell,
                  jdValue > previous else {
                throw CertificationError.mismatch("\(url.lastPathComponent) station row \(row)")
            }
            previous = jdValue
            result.append(station)
        }
        guard count == expectedRows else {
            throw CertificationError.mismatch("\(url.lastPathComponent) station rows \(count) != \(expectedRows)")
        }
        return result
    }

    private static func loadBoundaryAnchors(
        root: URL,
        files: [CandidateFile],
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineBoundaryAnchor] {
        guard let bound = files.first(where: { $0.path == boundaryAnchors }),
              bound.role == "celestial Bone boundary anchors" else {
            throw CertificationError.missing(boundaryAnchors)
        }

        let url = root.appendingPathComponent(bound.path)
        var result: [OrboSpineBoundaryAnchor] = []
        result.reserveCapacity(MundaneBody.canonicalOrder.count * 2)
        var seen = Set<String>()

        let count = try streamCSV(url) { header, fields, row in
            let bodyText = try text(fields, header, ["body"], url, row)
            guard let body = MundaneBody.canonicalOrder.first(where: {
                bodyKey($0.displayName) == bodyKey(bodyText)
            }) else {
                throw CertificationError.mismatch("boundary anchor row \(row) body")
            }

            let boundaryText = try text(fields, header, ["boundary"], url, row)
            let boundary: OrboSpineBoundaryAnchorKind
            let expectedJulianDay: JulianDay
            switch boundaryText {
            case "z21_start":
                boundary = .start
                expectedJulianDay = bone.start
            case "z23_end_exclusive":
                boundary = .endExclusive
                expectedJulianDay = bone.end
            default:
                throw CertificationError.mismatch("boundary anchor row \(row) side")
            }

            let jdValue = try double(fields, header, ["jd_ut"], url, row)
            let physical = try double(fields, header, ["physical_degree"], url, row)
            let speed = try double(
                fields,
                header,
                ["longitudinal_speed_degrees_per_day"],
                url,
                row
            )
            let motionText = try text(fields, header, ["motion"], url, row)
            let directionalValue = try double(fields, header, ["directional_degree"], url, row)
            let cell = try int(fields, header, ["navigation_cell"], url, row)

            guard let motion = Motion(rawValue: motionText),
                  (motion == .direct ? speed > 0 : speed < 0),
                  let jd = JulianDay(jdValue),
                  same(jd.value, expectedJulianDay.value),
                  let anchor = OrboSpineBoundaryAnchor(
                    body: body,
                    boundary: boundary,
                    julianDay: jd,
                    physicalDegrees: physical,
                    motion: motion
                  ),
                  same(anchor.directionalDegree.degrees, directionalValue),
                  anchor.navigationCell == cell else {
                throw CertificationError.mismatch("boundary anchor row \(row) state")
            }

            let key = "\(body.displayName)|\(boundary.rawValue)"
            guard seen.insert(key).inserted else {
                throw CertificationError.mismatch("duplicate boundary anchor \(key)")
            }
            result.append(anchor)
        }

        let expectedCount = MundaneBody.canonicalOrder.count * 2
        guard count == expectedCount, result.count == expectedCount else {
            throw CertificationError.mismatch(
                "boundary anchor rows \(result.count) != \(expectedCount)"
            )
        }
        for body in MundaneBody.canonicalOrder {
            for boundary in [
                OrboSpineBoundaryAnchorKind.start,
                OrboSpineBoundaryAnchorKind.endExclusive,
            ] {
                let key = "\(body.displayName)|\(boundary.rawValue)"
                guard seen.contains(key) else {
                    throw CertificationError.mismatch("missing boundary anchor \(key)")
                }
            }
        }
        return result
    }

    private static func loadTerraRuntimeProbes(
        root: URL,
        files: [CandidateFile],
        bone: OrboSpineBoneSpan
    ) throws -> [TerraMarrowSample] {
        let terra = files.filter { $0.role == "Terra Marrow" }.sorted { $0.path < $1.path }
        guard terra.count == 3 else {
            throw CertificationError.mismatch("candidate must bind three Terra Marrow tables")
        }
        var first: TerraMarrowSample?
        var last: TerraMarrowSample?
        var seams: [TerraMarrowSample] = []

        for bound in terra {
            _ = try streamCSV(root.appendingPathComponent(bound.path)) { header, fields, row in
                let url = root.appendingPathComponent(bound.path)
                let jdValue = try double(fields, header, ["jd_ut"], url, row)
                let turn = try double(fields, header, ["turn_degrees"], url, row)
                let tilt = try double(fields, header, ["tilt_degrees"], url, row)
                guard let jd = JulianDay(jdValue),
                      let sample = TerraMarrowSample(turnDegrees: turn, tiltDegrees: tilt, julianDay: jd) else {
                    throw CertificationError.mismatch("\(bound.path) Terra row \(row)")
                }
                if first == nil || jdValue < first!.julianDay.value { first = sample }
                if last == nil || jdValue > last!.julianDay.value { last = sample }
                if TerraMarrowContract.sourceModelSeamJulianDays.contains(where: { same($0, jdValue) }) {
                    seams.append(sample)
                }
            }
        }
        guard let first, let last,
              first.julianDay.value <= bone.start.value + 1e-12,
              last.julianDay.value >= bone.end.value - 1e-12,
              Set(seams.map { $0.julianDay.value }).count == TerraMarrowContract.sourceModelSeamJulianDays.count else {
            throw CertificationError.mismatch("Terra runtime probes do not cover Bone/seams")
        }
        return [first] + seams + [last]
    }

    private static func loadRuntimeShellIntersections(
        root: URL,
        files: [CandidateFile],
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineShellInterval] {
        let expected: [(String, OrboSpineShellFamily)] = [
            ("shells/saturnian-frame-table.csv", .frame),
            ("shells/uranian-revolt-table.csv", .revolt),
            ("shells/neptunian-wave-table.csv", .wave),
            ("shells/zeitgeist-z0-z30.csv", .zeitgeist),
        ]
        let paths = Set(files.map { $0.path })
        var result: [OrboSpineShellInterval] = []
        for (path, family) in expected {
            guard paths.contains(path) else { throw CertificationError.missing(path) }
            var intersections: [OrboSpineShellInterval] = []
            let url = root.appendingPathComponent(path)
            _ = try streamCSV(url) { header, fields, row in
                let ordinal = try int(fields, header, ["ordinal"], url, row)
                let startValue = try double(
                    fields, header, ["first_aries_ingress_jd_ut", "firstAriesIngressJulianDayUT"], url, row
                )
                let endValue = try double(
                    fields,
                    header,
                    ["next_shell_first_aries_ingress_jd_ut", "next_zeitgeist_first_aries_ingress_jd_ut", "nextZeitgeistFirstAriesIngressJulianDayUT"],
                    url,
                    row
                )
                guard startValue < endValue,
                      let start = JulianDay(startValue),
                      let end = JulianDay(endValue),
                      let id = OrboSpineShellID(family: family, ordinal: ordinal),
                      let interval = OrboSpineShellInterval(id: id, start: start, end: end) else {
                    throw CertificationError.mismatch("\(path) shell row \(row)")
                }
                if startValue < bone.end.value && endValue > bone.start.value {
                    intersections.append(interval)
                }
            }
            guard !intersections.isEmpty,
                  intersections.first!.start.value <= bone.start.value + 1e-12,
                  intersections.last!.end.value >= bone.end.value - 1e-12 else {
                throw CertificationError.mismatch("\(family.rawValue) shell coverage drift")
            }
            result.append(contentsOf: intersections)
        }
        guard Set(result.map { $0.id.family }) == Set(OrboSpineShellFamily.allCases) else {
            throw CertificationError.mismatch("runtime shell family drift")
        }
        return result
    }

    private static func verifyBoundFiles(_ files: [CandidateFile], root: URL) throws {
        guard Set(files.map { $0.path }).count == files.count else {
            throw CertificationError.mismatch("candidate repeats bound file path")
        }
        for file in files {
            let url = root.appendingPathComponent(file.path)
            guard FileManager.default.fileExists(atPath: url.path) else { throw CertificationError.missing(file.path) }
            let size = ((try FileManager.default.attributesOfItem(atPath: url.path))[.size] as? NSNumber)?.int64Value ?? -1
            guard size == file.bytes, try sha256(url) == file.sha256 else {
                throw CertificationError.mismatch("\(file.path) byte/hash drift")
            }
        }
    }

    private static func streamCSV(
        _ url: URL,
        consume: (CSVHeader, [String], Int) throws -> Void
    ) throws -> Int {
        let reader = try LineReader(url)
        guard let first = try reader.readLine() else { throw CertificationError.malformed("empty CSV \(url.path)") }
        let names = csvFields(first)
        let header = CSVHeader(names)
        var count = 0
        while let line = try reader.readLine() {
            if line.isEmpty { continue }
            let fields = csvFields(line)
            guard fields.count == names.count else {
                throw CertificationError.malformed("\(url.lastPathComponent) row \(count + 2) field count drift")
            }
            try consume(header, fields, count + 2)
            count += 1
        }
        return count
    }

    private static func csvFields(_ line: String) -> [String] {
        let characters = Array(line.trimmingCharacters(in: CharacterSet(charactersIn: "\r")))
        var fields: [String] = []
        var field = ""
        var quoted = false
        var index = 0
        while index < characters.count {
            let character = characters[index]
            if character == "\"" {
                if quoted, index + 1 < characters.count, characters[index + 1] == "\"" {
                    field.append("\"")
                    index += 1
                } else {
                    quoted.toggle()
                }
            } else if character == ",", !quoted {
                fields.append(field)
                field = ""
            } else {
                field.append(character)
            }
            index += 1
        }
        fields.append(field)
        return fields
    }

    private static func text(
        _ fields: [String], _ header: CSVHeader, _ aliases: [String], _ url: URL, _ row: Int
    ) throws -> String {
        guard let index = header.index(for: aliases), fields.indices.contains(index), !fields[index].isEmpty else {
            throw CertificationError.malformed("\(url.lastPathComponent) row \(row) missing \(aliases.joined(separator: "/"))")
        }
        return fields[index]
    }

    private static func double(
        _ fields: [String], _ header: CSVHeader, _ aliases: [String], _ url: URL, _ row: Int
    ) throws -> Double {
        let value = try text(fields, header, aliases, url, row)
        guard let parsed = Double(value), parsed.isFinite else {
            throw CertificationError.malformed("\(url.lastPathComponent) row \(row) invalid Double")
        }
        return parsed
    }

    private static func int(
        _ fields: [String], _ header: CSVHeader, _ aliases: [String], _ url: URL, _ row: Int
    ) throws -> Int {
        let value = try text(fields, header, aliases, url, row)
        guard let parsed = Int(value) else {
            throw CertificationError.malformed("\(url.lastPathComponent) row \(row) invalid Int")
        }
        return parsed
    }

    private static func decode<T: Decodable>(_ url: URL) throws -> T {
        guard FileManager.default.fileExists(atPath: url.path) else { throw CertificationError.missing(url.path) }
        do { return try JSONDecoder().decode(T.self, from: Data(contentsOf: url)) }
        catch { throw CertificationError.malformed("\(url.lastPathComponent): \(error)") }
    }

    private static func declaredHash(_ url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else { throw CertificationError.missing(url.path) }
        let text = try String(contentsOf: url, encoding: .utf8)
        guard let first = text.split(whereSeparator: \.isWhitespace).first else {
            throw CertificationError.malformed("empty candidate hash")
        }
        return String(first)
    }

    private static func sha256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 1_048_576) ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private static func bodyKey(_ value: String) -> String {
        let key = String(value.lowercased().filter { $0.isLetter || $0.isNumber })
        if key == "northnode" || key == "truenode" { return "truenorthnode" }
        return key
    }

    private static func normalized(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }

    private static func circularDistance(_ lhs: Double, _ rhs: Double) -> Double {
        let delta = abs(normalized(lhs) - normalized(rhs))
        return min(delta, 360 - delta)
    }

    private static func same(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) <= 1e-10
    }
}

do {
    try Certification.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    FileHandle.standardError.write(Data("OrboSpineDioscuriCertificationTool error: \(error)\n".utf8))
    exit(EXIT_FAILURE)
}
