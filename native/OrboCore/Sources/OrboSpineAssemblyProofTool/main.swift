import CryptoKit
import Foundation
import OrboCore

private enum AssemblyProofError: Error, CustomStringConvertible {
    case usage(String)
    case missing(String)
    case malformed(String)
    case mismatch(String)
    case gzip(String)

    var description: String {
        switch self {
        case let .usage(message): return message
        case let .missing(message): return "Missing D5 assembly input: \(message)"
        case let .malformed(message): return "Malformed D5 assembly input: \(message)"
        case let .mismatch(message): return "D5 assembly mismatch: \(message)"
        case let .gzip(message): return "D5 gzip read failed: \(message)"
        }
    }
}

private struct Arguments {
    let buildRoot: URL

    init(_ raw: [String]) throws {
        guard raw.count == 2, raw[0] == "--build-root" else {
            throw AssemblyProofError.usage(
                "usage: OrboSpineAssemblyProofTool --build-root <tools/pass5/orbospine-build>"
            )
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

private struct CelestialSummary: Decodable {
    let supportRows: Int
    let stationRows: Int
}

private struct MotionSummary: Decodable {
    let passageRows: Int
    let sourceStationRows: Int
}

private struct CountSummary: Decodable {
    let totalRows: Int
}

private struct ShellSummary: Decodable {
    let address: String
    let families: [String]
}

private struct TerraSummary: Decodable {
    let rows: Int
    let supportIntervalSeconds: Int
    let refinementLaw: String
    let sourceModelSeamYears: [Int]
}

private struct CandidateManifest: Decodable {
    let identity: String
    let lifecycle: String
    let span: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let astronomicalAuthority: String
    let astronomicalSourceVersion: String
    let celestial: CelestialSummary
    let motion: MotionSummary
    let aspects: CountSummary
    let temporalShells: ShellSummary
    let eclipses: CountSummary
    let terraMarrow: TerraSummary
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

private struct CSVHeader {
    let names: [String]
    let indexes: [String: Int]

    init(_ names: [String]) {
        self.names = names
        var built: [String: Int] = [:]
        for (index, name) in names.enumerated() {
            built[Self.normalized(name)] = index
        }
        indexes = built
    }

    func index(for aliases: [String]) -> Int? {
        for alias in aliases {
            if let index = indexes[Self.normalized(alias)] { return index }
        }
        return nil
    }

    private static func normalized(_ value: String) -> String {
        String(value.lowercased().filter { $0.isLetter || $0.isNumber })
    }
}

private final class CSVLineReader {
    private let process: Process?
    private let errorPipe: Pipe?
    private let handle: FileHandle
    private var buffer = Data()
    private var reachedEOF = false
    private var finished = false

    init(url: URL) throws {
        if url.pathExtension.lowercased() == "gz" {
            let process = Process()
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/gzip")
            process.arguments = ["-dc", url.path]
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            do {
                try process.run()
            } catch {
                throw AssemblyProofError.gzip("\(url.lastPathComponent): \(error)")
            }
            self.process = process
            self.errorPipe = errorPipe
            self.handle = outputPipe.fileHandleForReading
        } else {
            self.process = nil
            self.errorPipe = nil
            do {
                self.handle = try FileHandle(forReadingFrom: url)
            } catch {
                throw AssemblyProofError.missing(url.path)
            }
        }
    }

    deinit {
        if process?.isRunning == true { process?.terminate() }
        try? handle.close()
    }

    func readLine() throws -> String? {
        while true {
            if let newline = buffer.firstIndex(of: 0x0a) {
                let lineData = buffer.subdata(in: buffer.startIndex..<newline)
                buffer.removeSubrange(buffer.startIndex...newline)
                guard let line = String(data: lineData, encoding: .utf8) else {
                    throw AssemblyProofError.malformed("non-UTF8 CSV")
                }
                return line
            }

            if reachedEOF {
                guard !buffer.isEmpty else { return nil }
                let lineData = buffer
                buffer.removeAll(keepingCapacity: false)
                guard let line = String(data: lineData, encoding: .utf8) else {
                    throw AssemblyProofError.malformed("non-UTF8 CSV")
                }
                return line
            }

            let chunk = try handle.read(upToCount: 65_536) ?? Data()
            if chunk.isEmpty {
                reachedEOF = true
            } else {
                buffer.append(chunk)
            }
        }
    }

    func finish() throws {
        guard !finished else { return }
        finished = true
        guard let process else { return }
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            let errorData = errorPipe?.fileHandleForReading.readDataToEndOfFile() ?? Data()
            let message = String(data: errorData, encoding: .utf8)
                ?? "gzip exit \(process.terminationStatus)"
            throw AssemblyProofError.gzip(message.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}

private struct MotionResolver {
    private let stationsByBody: [MundaneBody: [OrboSpineStation]]
    private let initialMotionByBody: [MundaneBody: Motion]

    init(
        supports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation]
    ) throws {
        var firstSupport: [MundaneBody: OrboSpineCelestialCoordinate] = [:]
        for support in supports {
            if let current = firstSupport[support.body] {
                if support.julianDay.value < current.julianDay.value {
                    firstSupport[support.body] = support
                }
            } else {
                firstSupport[support.body] = support
            }
        }

        var grouped: [MundaneBody: [OrboSpineStation]] = [:]
        for station in stations {
            grouped[station.body, default: []].append(station)
        }
        for body in grouped.keys {
            grouped[body]!.sort { $0.julianDay.value < $1.julianDay.value }
        }

        var initial: [MundaneBody: Motion] = [:]
        for body in MundaneBody.canonicalOrder {
            if let firstStation = grouped[body]?.first {
                initial[body] = firstStation.laneBefore
            } else if let support = firstSupport[body] {
                initial[body] = support.directionalDegree.motion
            } else {
                throw AssemblyProofError.mismatch("no initial motion for \(body.displayName)")
            }
        }

        stationsByBody = grouped
        initialMotionByBody = initial
    }

    func motion(of body: MundaneBody, at julianDay: JulianDay) throws -> Motion {
        guard let initial = initialMotionByBody[body] else {
            throw AssemblyProofError.mismatch("motion resolver missing \(body.displayName)")
        }
        let stations = stationsByBody[body] ?? []
        var low = 0
        var high = stations.count
        while low < high {
            let middle = (low + high) / 2
            if stations[middle].julianDay.value <= julianDay.value + 1e-12 {
                low = middle + 1
            } else {
                high = middle
            }
        }
        return low == 0 ? initial : stations[low - 1].laneAfter
    }

    func isStation(_ body: MundaneBody, at julianDay: JulianDay) -> Bool {
        guard let stations = stationsByBody[body], !stations.isEmpty else { return false }
        var low = 0
        var high = stations.count
        while low < high {
            let middle = (low + high) / 2
            if stations[middle].julianDay.value < julianDay.value {
                low = middle + 1
            } else {
                high = middle
            }
        }
        if low < stations.count,
           abs(stations[low].julianDay.value - julianDay.value) <= 1e-10 {
            return true
        }
        if low > 0,
           abs(stations[low - 1].julianDay.value - julianDay.value) <= 1e-10 {
            return true
        }
        return false
    }
}

private enum AssemblyProof {
    private static let candidateManifestPath = "orbospine-candidate-manifest.json"
    private static let candidateHashPath = "orbospine-candidate-manifest.sha256"
    private static let celestialManifestPath = "celestial/orbospine-celestial-manifest.json"

    private static let expectedSupportRows = 1_550_229
    private static let expectedStationRows = 52_679
    private static let expectedPassageRows = 26_343
    private static let expectedRingRows = 2_315_930
    private static let expectedEclipseRows = 3_539
    private static let expectedTerraRows = 1_072_502

    static func run(_ raw: [String]) throws {
        let arguments = try Arguments(raw)
        let root = arguments.buildRoot
        guard FileManager.default.fileExists(atPath: root.path) else {
            throw AssemblyProofError.missing(root.path)
        }

        print("ORBOSPINE D5 / ASSEMBLY PROOF")

        let candidateURL = root.appendingPathComponent(candidateManifestPath)
        let candidateHashURL = root.appendingPathComponent(candidateHashPath)
        let candidate: CandidateManifest = try decode(candidateURL)
        let candidateSHA = try sha256(candidateURL)
        let declaredCandidateSHA = try declaredHash(candidateHashURL)
        guard candidateSHA == declaredCandidateSHA else {
            throw AssemblyProofError.mismatch("candidate manifest SHA-256 drift")
        }
        try validateCandidate(candidate)
        print("PASS candidate manifest: \(candidateSHA)")

        try verifyBoundFiles(candidate.files, root: root)
        print("PASS bound files: \(candidate.files.count) / \(candidate.files.count) SHA-256")

        guard let bone = OrboSpineBoneSpan(
            start: OrboSpineManufactureContract.supportedStart,
            end: OrboSpineManufactureContract.supportedEnd
        ) else {
            throw AssemblyProofError.mismatch("canonical Bone cannot be formed")
        }

        let celestialURL = root.appendingPathComponent(celestialManifestPath)
        let celestial: CelestialManifestReference = try decode(celestialURL)
        let (supports, stations) = try loadCelestial(
            root: root,
            candidateFiles: candidate.files,
            manifest: celestial,
            bone: bone
        )
        guard supports.count == expectedSupportRows,
              stations.count == expectedStationRows else {
            throw AssemblyProofError.mismatch(
                "celestial load \(supports.count) supports / \(stations.count) stations"
            )
        }
        print("PASS celestial: \(supports.count) supports / \(stations.count) stations")

        let terra = try loadTerra(root: root, files: candidate.files, bone: bone)
        guard terra.count == expectedTerraRows else {
            throw AssemblyProofError.mismatch("Terra rows \(terra.count) != \(expectedTerraRows)")
        }
        print("PASS Terra Marrow: \(terra.count) rows / source seams exact")

        let resolver = try MotionResolver(supports: supports, stations: stations)
        let passages = try loadAndProveMotion(
            root: root,
            files: candidate.files,
            stations: stations,
            bone: bone
        )
        guard passages.count == expectedPassageRows else {
            throw AssemblyProofError.mismatch("motion rows \(passages.count) != \(expectedPassageRows)")
        }
        print("PASS motion: \(passages.count) passages / rederived from stations")

        let ring = try loadRingOccurrences(
            root: root,
            files: candidate.files,
            resolver: resolver,
            bone: bone
        )
        guard ring.count == expectedRingRows else {
            throw AssemblyProofError.mismatch("Ring rows \(ring.count) != \(expectedRingRows)")
        }
        print("PASS Ring: \(ring.count) exact occurrences")

        let eclipses = try loadEclipses(root: root, files: candidate.files, bone: bone)
        guard eclipses.count == expectedEclipseRows else {
            throw AssemblyProofError.mismatch("eclipse rows \(eclipses.count) != \(expectedEclipseRows)")
        }
        print("PASS eclipses: \(eclipses.count)")

        let shells = try loadShells(root: root, files: candidate.files, bone: bone)
        print("PASS temporal shells: F.R.W.Z / \(shells.count) Bone intersections")

        guard let provenance = OrboSpineRuntimeProvenance(
            candidateManifestSHA256: candidateSHA,
            astronomicalAuthority: candidate.astronomicalAuthority,
            astronomicalSourceVersion: candidate.astronomicalSourceVersion
        ) else {
            throw AssemblyProofError.mismatch("candidate provenance cannot form runtime provenance")
        }

        guard let runtime = OrboSpineRuntime(
            bone: bone,
            celestialSupports: supports,
            stations: stations,
            retrogradePassages: passages,
            ringOccurrences: ring,
            eclipses: eclipses,
            shellIntervals: shells,
            terraSamples: terra,
            provenance: provenance
        ) else {
            throw AssemblyProofError.mismatch("canonical candidate cannot assemble as OrboSpineRuntime")
        }

        try proveRuntime(
            runtime,
            candidateSHA: candidateSHA,
            supports: supports,
            resolver: resolver,
            terra: terra
        )

        print("PASS runtime: Locate / Library / Link")
        print("PASS Smeld seams: Celestial empty / Stack empty")
        print("D5 ASSEMBLY PROOF: COMPLETE / PRESERVED")
    }

    private static func validateCandidate(_ candidate: CandidateManifest) throws {
        let expectedShellFamilies = Set([
            "Frame / Saturn",
            "Revolt / Uranus",
            "Wave / Neptune",
            "Zeitgeist / Pluto",
        ])

        guard candidate.identity == OrboSpineContract.identity,
              candidate.lifecycle == OrboSpineLifecycleBoundary.candidate.rawValue,
              candidate.span == "Z21-Z23",
              same(candidate.supportedStartJulianDayUT, OrboSpineManufactureContract.supportedStart.value),
              same(candidate.supportedEndJulianDayUT, OrboSpineManufactureContract.supportedEnd.value),
              candidate.astronomicalAuthority == OrboSpineManufactureContract.astronomicalSource,
              candidate.astronomicalSourceVersion == OrboSpineManufactureContract.canonicalAstronomicalSourceVersion,
              candidate.celestial.supportRows == expectedSupportRows,
              candidate.celestial.stationRows == expectedStationRows,
              candidate.motion.passageRows == expectedPassageRows,
              candidate.motion.sourceStationRows == expectedStationRows,
              candidate.aspects.totalRows == expectedRingRows,
              candidate.eclipses.totalRows == expectedEclipseRows,
              candidate.terraMarrow.rows == expectedTerraRows,
              candidate.terraMarrow.supportIntervalSeconds == TerraMarrowContract.supportIntervalSeconds,
              candidate.terraMarrow.refinementLaw == TerraMarrowContract.refinementLaw.rawValue,
              candidate.terraMarrow.sourceModelSeamYears == TerraMarrowContract.sourceModelSeamYears,
              candidate.temporalShells.address == "F.R.W.Z",
              Set(candidate.temporalShells.families) == expectedShellFamilies else {
            throw AssemblyProofError.mismatch("candidate manifest contract drift")
        }

        let paths = candidate.files.map(\.path)
        guard Set(paths).count == paths.count else {
            throw AssemblyProofError.mismatch("candidate manifest repeats a bound file path")
        }
    }

    private static func verifyBoundFiles(_ files: [CandidateFile], root: URL) throws {
        for file in files {
            let url = root.appendingPathComponent(file.path)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw AssemblyProofError.missing(file.path)
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let bytes = (attributes[.size] as? NSNumber)?.int64Value ?? -1
            guard bytes == file.bytes else {
                throw AssemblyProofError.mismatch("\(file.path) bytes \(bytes) != \(file.bytes)")
            }
            let digest = try sha256(url)
            guard digest == file.sha256 else {
                throw AssemblyProofError.mismatch("\(file.path) SHA-256 drift")
            }
        }
    }

    private static func loadCelestial(
        root: URL,
        candidateFiles: [CandidateFile],
        manifest: CelestialManifestReference,
        bone: OrboSpineBoneSpan
    ) throws -> ([OrboSpineCelestialCoordinate], [OrboSpineStation]) {
        guard manifest.identity == OrboSpineContract.identity,
              manifest.astronomicalSource == OrboSpineManufactureContract.astronomicalSource,
              manifest.astronomicalSourceVersion == OrboSpineManufactureContract.canonicalAstronomicalSourceVersion,
              same(manifest.supportedStartJulianDayUT, bone.start.value),
              same(manifest.supportedEndJulianDayUT, bone.end.value),
              manifest.totalSupportRows == expectedSupportRows,
              manifest.totalStationRows == expectedStationRows,
              manifest.bodies.count == MundaneBody.canonicalOrder.count else {
            throw AssemblyProofError.mismatch("celestial manifest contract drift")
        }

        var references: [MundaneBody: CelestialBodyReference] = [:]
        for reference in manifest.bodies {
            let body = try body(named: reference.body)
            guard references[body] == nil else {
                throw AssemblyProofError.mismatch("duplicate celestial body \(reference.body)")
            }
            references[body] = reference
        }
        guard Set(references.keys) == Set(MundaneBody.canonicalOrder) else {
            throw AssemblyProofError.mismatch("celestial manifest is not exactly the Eleven")
        }

        let candidateByPath = Dictionary(uniqueKeysWithValues: candidateFiles.map { ($0.path, $0) })
        var supports: [OrboSpineCelestialCoordinate] = []
        var stations: [OrboSpineStation] = []
        supports.reserveCapacity(expectedSupportRows)
        stations.reserveCapacity(expectedStationRows)

        for body in MundaneBody.canonicalOrder {
            guard let reference = references[body],
                  same(reference.supportDegrees, OrboSpineContract.supportDegrees(for: body)) else {
                throw AssemblyProofError.mismatch("\(body.displayName) support law drift")
            }

            let supportPath = "celestial/\(reference.supportFile)"
            let stationPath = "celestial/\(reference.stationFile)"
            guard let supportBound = candidateByPath[supportPath],
                  supportBound.role == "celestial support",
                  supportBound.sha256 == reference.supportSHA256,
                  let stationBound = candidateByPath[stationPath],
                  stationBound.role == "station topology",
                  stationBound.sha256 == reference.stationSHA256 else {
                throw AssemblyProofError.mismatch("\(body.displayName) candidate binding drift")
            }

            let bodySupports = try loadSupports(
                body: body,
                url: root.appendingPathComponent(supportPath),
                expectedRows: reference.supportRows,
                bone: bone
            )
            let bodyStations = try loadStations(
                body: body,
                url: root.appendingPathComponent(stationPath),
                expectedRows: reference.stationRows,
                bone: bone
            )
            supports.append(contentsOf: bodySupports)
            stations.append(contentsOf: bodyStations)
        }

        return (supports, stations)
    }

    private static func loadSupports(
        body: MundaneBody,
        url: URL,
        expectedRows: Int,
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineCelestialCoordinate] {
        let expectedHeader = [
            "directional_degree",
            "physical_degree",
            "navigation_cell",
            "motion",
            "jd_ut",
            "civic_offset_seconds",
        ]
        var rows: [OrboSpineCelestialCoordinate] = []
        rows.reserveCapacity(expectedRows)
        var previousJD = -Double.infinity

        let count = try streamCSV(url) { header, fields, rowNumber in
            guard header.names == expectedHeader else {
                throw AssemblyProofError.malformed("\(url.lastPathComponent) support header drift")
            }
            let directionalValue = try requiredDouble(fields, header, ["directional_degree"], url, rowNumber)
            let physical = try requiredDouble(fields, header, ["physical_degree"], url, rowNumber)
            let cell = try requiredInt(fields, header, ["navigation_cell"], url, rowNumber)
            let motionText = try requiredText(fields, header, ["motion"], url, rowNumber)
            let jdValue = try requiredDouble(fields, header, ["jd_ut"], url, rowNumber)
            _ = try requiredInt64(fields, header, ["civic_offset_seconds"], url, rowNumber)

            guard let motion = Motion(rawValue: motionText),
                  let directional = OrboSpineDirectionalDegree(directionalValue),
                  let jd = JulianDay(jdValue),
                  bone.contains(jd),
                  directional.motion == motion,
                  directional.navigationCell == cell,
                  circularDistance(directional.physicalDegrees, physical) <= 1e-9,
                  jdValue > previousJD else {
                throw AssemblyProofError.mismatch("\(url.lastPathComponent) support row \(rowNumber)")
            }
            previousJD = jdValue
            rows.append(OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: directional,
                julianDay: jd
            ))
        }

        guard count == expectedRows else {
            throw AssemblyProofError.mismatch("\(url.lastPathComponent) rows \(count) != \(expectedRows)")
        }
        return rows
    }

    private static func loadStations(
        body: MundaneBody,
        url: URL,
        expectedRows: Int,
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineStation] {
        let expectedHeader = [
            "physical_degree",
            "directional_degree_after",
            "navigation_cell_after",
            "lane_before",
            "lane_after",
            "jd_ut",
        ]
        var rows: [OrboSpineStation] = []
        rows.reserveCapacity(expectedRows)
        var previousJD = -Double.infinity

        let count = try streamCSV(url) { header, fields, rowNumber in
            guard header.names == expectedHeader else {
                throw AssemblyProofError.malformed("\(url.lastPathComponent) station header drift")
            }
            let physical = try requiredDouble(fields, header, ["physical_degree"], url, rowNumber)
            let directional = try requiredDouble(fields, header, ["directional_degree_after"], url, rowNumber)
            let cell = try requiredInt(fields, header, ["navigation_cell_after"], url, rowNumber)
            let beforeText = try requiredText(fields, header, ["lane_before"], url, rowNumber)
            let afterText = try requiredText(fields, header, ["lane_after"], url, rowNumber)
            let jdValue = try requiredDouble(fields, header, ["jd_ut"], url, rowNumber)

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
                  same(station.directionalDegreeAfter.degrees, directional),
                  station.navigationCellAfter == cell,
                  jdValue > previousJD else {
                throw AssemblyProofError.mismatch("\(url.lastPathComponent) station row \(rowNumber)")
            }
            previousJD = jdValue
            rows.append(station)
        }

        guard count == expectedRows else {
            throw AssemblyProofError.mismatch("\(url.lastPathComponent) rows \(count) != \(expectedRows)")
        }
        return rows
    }

    private static func loadTerra(
        root: URL,
        files: [CandidateFile],
        bone: OrboSpineBoneSpan
    ) throws -> [TerraMarrowSample] {
        let terraFiles = files.filter { $0.role == "Terra Marrow" }.sorted { $0.path < $1.path }
        guard terraFiles.count == 3 else {
            throw AssemblyProofError.mismatch("candidate must bind exactly three Terra Marrow files")
        }

        let expectedHeader = ["jd_ut", "turn_degrees", "tilt_degrees", "sample_kind"]
        var samples: [TerraMarrowSample] = []
        samples.reserveCapacity(expectedTerraRows)
        var exactSeams = Set<Int>()

        for bound in terraFiles {
            let url = root.appendingPathComponent(bound.path)
            var previousJD = -Double.infinity
            _ = try streamCSV(url) { header, fields, rowNumber in
                guard header.names == expectedHeader else {
                    throw AssemblyProofError.malformed("\(bound.path) Terra header drift")
                }
                let jdValue = try requiredDouble(fields, header, ["jd_ut"], url, rowNumber)
                let turn = try requiredDouble(fields, header, ["turn_degrees"], url, rowNumber)
                let tilt = try requiredDouble(fields, header, ["tilt_degrees"], url, rowNumber)
                let kind = try requiredText(fields, header, ["sample_kind"], url, rowNumber)
                guard let jd = JulianDay(jdValue),
                      jdValue >= bone.start.value - 1e-12,
                      jdValue <= bone.end.value + 1e-12,
                      jdValue > previousJD,
                      let sample = TerraMarrowSample(
                        turnDegrees: turn,
                        tiltDegrees: tilt,
                        julianDay: jd
                      ) else {
                    throw AssemblyProofError.mismatch("\(bound.path) Terra row \(rowNumber)")
                }
                previousJD = jdValue
                samples.append(sample)

                for (index, seam) in TerraMarrowContract.sourceModelSeamJulianDays.enumerated()
                where abs(jdValue - seam) <= 1e-12 {
                    guard kind == "seam_exact_long_term" else {
                        throw AssemblyProofError.mismatch("Terra seam \(index) is not exact long-term ownership")
                    }
                    exactSeams.insert(index)
                }
            }
        }

        guard samples.count == expectedTerraRows,
              exactSeams.count == TerraMarrowContract.sourceModelSeamJulianDays.count else {
            throw AssemblyProofError.mismatch("Terra count or source seam coverage drift")
        }
        return samples
    }

    private static func loadAndProveMotion(
        root: URL,
        files: [CandidateFile],
        stations: [OrboSpineStation],
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineRetrogradePassage] {
        let motionFiles = files.filter { $0.role == "continuous Z21-Z23 retrograde passages" }
        guard motionFiles.count == 1, let bound = motionFiles.first else {
            throw AssemblyProofError.mismatch("candidate must bind one continuous motion table")
        }

        let expectedHeader = [
            "body",
            "start_jd_ut",
            "end_jd_ut",
            "start_station_physical_degree",
            "end_station_physical_degree",
            "start_boundary",
            "end_boundary",
        ]
        let url = root.appendingPathComponent(bound.path)
        var loaded: [OrboSpineRetrogradePassage] = []
        loaded.reserveCapacity(expectedPassageRows)

        let count = try streamCSV(url) { header, fields, rowNumber in
            guard header.names == expectedHeader else {
                throw AssemblyProofError.malformed("motion header drift")
            }
            let body = try body(named: requiredText(fields, header, ["body"], url, rowNumber))
            let startValue = try requiredDouble(fields, header, ["start_jd_ut"], url, rowNumber)
            let endValue = try requiredDouble(fields, header, ["end_jd_ut"], url, rowNumber)
            let startDegree = try optionalDouble(fields, header, ["start_station_physical_degree"], url, rowNumber)
            let endDegree = try optionalDouble(fields, header, ["end_station_physical_degree"], url, rowNumber)
            let startBoundaryText = try requiredText(fields, header, ["start_boundary"], url, rowNumber)
            let endBoundaryText = try requiredText(fields, header, ["end_boundary"], url, rowNumber)

            guard let start = JulianDay(startValue),
                  let end = JulianDay(endValue),
                  let startBoundary = OrboSpineRetrogradeBoundary(rawValue: startBoundaryText),
                  let endBoundary = OrboSpineRetrogradeBoundary(rawValue: endBoundaryText),
                  let passage = OrboSpineRetrogradePassage(
                    body: body,
                    start: start,
                    end: end,
                    startStationPhysicalDegrees: startDegree,
                    endStationPhysicalDegrees: endDegree,
                    startBoundary: startBoundary,
                    endBoundary: endBoundary
                  ),
                  startValue >= bone.start.value - 1e-12,
                  endValue <= bone.end.value + 1e-12 else {
                throw AssemblyProofError.mismatch("motion row \(rowNumber)")
            }
            loaded.append(passage)
        }
        guard count == expectedPassageRows else {
            throw AssemblyProofError.mismatch("motion rows \(count) != \(expectedPassageRows)")
        }

        let stationsByBody = Dictionary(grouping: stations, by: \.body)
        let loadedByBody = Dictionary(grouping: loaded, by: \.body)
        for body in MundaneBody.canonicalOrder {
            let bodyStations = (stationsByBody[body] ?? []).sorted { $0.julianDay.value < $1.julianDay.value }
            guard let derived = OrboSpineMotionBody.retrogradePassages(
                body: body,
                stations: bodyStations,
                span: bone
            ) else {
                throw AssemblyProofError.mismatch("\(body.displayName) motion cannot rederive from stations")
            }
            let actual = (loadedByBody[body] ?? []).sorted { $0.start.value < $1.start.value }
            guard passagesEqual(derived, actual) else {
                throw AssemblyProofError.mismatch("\(body.displayName) forged motion differs from station derivation")
            }
        }

        return loaded
    }

    private static func loadRingOccurrences(
        root: URL,
        files: [CandidateFile],
        resolver: MotionResolver,
        bone: OrboSpineBoneSpan
    ) throws -> [OrboSpineRingOccurrence] {
        let ringFiles = files.filter {
            $0.role == "exact major aspects" || $0.role == "exact minor aspects"
        }.sorted { $0.path < $1.path }
        guard ringFiles.count == 6 else {
            throw AssemblyProofError.mismatch("candidate must bind six Ring occurrence tables")
        }

        var events: [OrboSpineRingOccurrence] = []
        events.reserveCapacity(expectedRingRows)

        for bound in ringFiles {
            let url = root.appendingPathComponent(bound.path)
            _ = try streamCSV(url) { header, fields, rowNumber in
                let bodyA = try body(named: requiredText(
                    fields, header, ["bodyA", "body_a"], url, rowNumber
                ))
                let bodyB = try body(named: requiredText(
                    fields, header, ["bodyB", "body_b"], url, rowNumber
                ))
                let ringDegrees = try requiredInt(
                    fields, header, ["ringDegrees", "ring_degrees", "mark_degrees"], url, rowNumber
                )
                guard let mark = RingMark(rawValue: ringDegrees) else {
                    throw AssemblyProofError.mismatch("\(bound.path) row \(rowNumber) Ring mark")
                }
                let jdValue = try requiredDouble(
                    fields,
                    header,
                    ["civicTimeJulianDayUT", "civic_time_julian_day_ut", "jd_ut", "julian_day_ut"],
                    url,
                    rowNumber
                )
                guard let jd = JulianDay(jdValue), bone.contains(jd) else {
                    throw AssemblyProofError.mismatch("\(bound.path) row \(rowNumber) Ring UT")
                }

                let directionalA = try relationshipDirectionalDegree(
                    fields: fields,
                    header: header,
                    body: bodyA,
                    julianDay: jd,
                    bodyLabel: "A",
                    resolver: resolver,
                    url: url,
                    rowNumber: rowNumber
                )
                let directionalB = try relationshipDirectionalDegree(
                    fields: fields,
                    header: header,
                    body: bodyB,
                    julianDay: jd,
                    bodyLabel: "B",
                    resolver: resolver,
                    url: url,
                    rowNumber: rowNumber
                )

                guard let event = OrboSpineRingOccurrence(
                    bodyA: bodyA,
                    bodyB: bodyB,
                    mark: mark,
                    bodyADirectionalDegree: directionalA,
                    bodyBDirectionalDegree: directionalB,
                    julianDay: jd
                ) else {
                    throw AssemblyProofError.mismatch("\(bound.path) row \(rowNumber) Ring occurrence")
                }
                events.append(event)
            }
        }

        guard events.count == expectedRingRows else {
            throw AssemblyProofError.mismatch("Ring rows \(events.count) != \(expectedRingRows)")
        }
        return events
    }

    private static func relationshipDirectionalDegree(
        fields: [String],
        header: CSVHeader,
        body: MundaneBody,
        julianDay: JulianDay,
        bodyLabel: String,
        resolver: MotionResolver,
        url: URL,
        rowNumber: Int
    ) throws -> OrboSpineDirectionalDegree {
        let directionalAliases = bodyLabel == "A"
            ? ["bodyADirectionalDegree", "body_a_directional_degree", "bodyADirectionalDegrees"]
            : ["bodyBDirectionalDegree", "body_b_directional_degree", "bodyBDirectionalDegrees"]

        if let text = optionalText(fields, header, directionalAliases), !text.isEmpty {
            guard let value = Double(text),
                  value.isFinite,
                  let directional = OrboSpineDirectionalDegree(value),
                  directional.motion == (try resolver.motion(of: body, at: julianDay)) else {
                throw AssemblyProofError.mismatch("\(url.lastPathComponent) row \(rowNumber) directional body \(bodyLabel)")
            }
            return directional
        }

        let physicalAliases = bodyLabel == "A"
            ? [
                "bodyACelestialTimeDegrees",
                "body_a_celestial_time_degrees",
                "bodyAPhysicalDegrees",
                "body_a_physical_degree",
              ]
            : [
                "bodyBCelestialTimeDegrees",
                "body_b_celestial_time_degrees",
                "bodyBPhysicalDegrees",
                "body_b_physical_degree",
              ]
        let physical = try requiredDouble(fields, header, physicalAliases, url, rowNumber)
        let motion = try resolver.motion(of: body, at: julianDay)
        guard let directional = OrboSpineDirectionalDegree(
            physicalDegrees: normalizedDegrees(physical),
            motion: motion
        ) else {
            throw AssemblyProofError.mismatch("\(url.lastPathComponent) row \(rowNumber) physical body \(bodyLabel)")
        }
        return directional
    }

    private static func loadEclipses(
        root: URL,
        files: [CandidateFile],
        bone: OrboSpineBoneSpan
    ) throws -> [MundaneTimespineEclipseEvent] {
        let eclipseFiles = files.filter { $0.role == "eclipse table" }.sorted { $0.path < $1.path }
        guard eclipseFiles.count == 3 else {
            throw AssemblyProofError.mismatch("candidate must bind three eclipse tables")
        }

        var events: [MundaneTimespineEclipseEvent] = []
        events.reserveCapacity(expectedEclipseRows)

        for bound in eclipseFiles {
            let url = root.appendingPathComponent(bound.path)
            _ = try streamCSV(url) { header, fields, rowNumber in
                let degree = try requiredDouble(fields, header, ["eclipse_degree"], url, rowNumber)
                let kindText = try requiredText(fields, header, ["eclipse_kind"], url, rowNumber).lowercased()
                let typeText = try requiredText(fields, header, ["eclipse_type"], url, rowNumber).lowercased()
                let phaseValue = try requiredDouble(fields, header, ["phase_jd_ut", "jd_ut"], url, rowNumber)
                let greatestValue = try optionalDouble(
                    fields,
                    header,
                    ["greatest_eclipse_jd_ut"],
                    url,
                    rowNumber
                )
                let magnitude = try optionalDouble(fields, header, ["magnitude"], url, rowNumber)
                let secondary = try optionalDouble(
                    fields,
                    header,
                    ["secondary_magnitude"],
                    url,
                    rowNumber
                )
                let centrality = optionalText(fields, header, ["centrality"]).flatMap {
                    $0.isEmpty ? nil : $0
                }

                guard let kind = MundaneTimespineEclipseKind(rawValue: kindText),
                      let type = MundaneTimespineEclipseType(rawValue: typeText),
                      let phase = JulianDay(phaseValue),
                      bone.contains(phase) else {
                    throw AssemblyProofError.mismatch("\(bound.path) eclipse row \(rowNumber) identity")
                }

                let greatest: JulianDay?
                if let greatestValue {
                    guard let value = JulianDay(greatestValue), bone.contains(value) else {
                        throw AssemblyProofError.mismatch("\(bound.path) eclipse row \(rowNumber) greatest UT")
                    }
                    greatest = value
                } else {
                    greatest = nil
                }

                guard let event = MundaneTimespineEclipseEvent(
                    kind: kind,
                    type: type,
                    eclipseDegree: degree,
                    julianDay: phase,
                    greatestEclipseJulianDay: greatest,
                    magnitude: magnitude,
                    secondaryMagnitude: secondary,
                    centrality: centrality
                ) else {
                    throw AssemblyProofError.mismatch("\(bound.path) eclipse row \(rowNumber)")
                }
                events.append(event)
            }
        }

        return events
    }

    private static func loadShells(
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
        let fileByPath = Dictionary(uniqueKeysWithValues: files.map { ($0.path, $0) })
        var result: [OrboSpineShellInterval] = []

        for (path, family) in expected {
            guard let bound = fileByPath[path], bound.role.hasPrefix("temporal shell ") else {
                throw AssemblyProofError.mismatch("candidate does not bind \(path) as temporal shell")
            }
            let url = root.appendingPathComponent(path)
            var all: [OrboSpineShellInterval] = []
            var previousStart = -Double.infinity
            var previousEnd: Double?

            _ = try streamCSV(url) { header, fields, rowNumber in
                let idText = try requiredText(
                    fields,
                    header,
                    ["shell_id", "zeitgeist_id", "id"],
                    url,
                    rowNumber
                )
                let ordinal = try requiredInt(fields, header, ["ordinal"], url, rowNumber)
                let startValue = try requiredDouble(
                    fields,
                    header,
                    ["first_aries_ingress_jd_ut", "firstAriesIngressJulianDayUT"],
                    url,
                    rowNumber
                )
                let endValue = try requiredDouble(
                    fields,
                    header,
                    [
                        "next_shell_first_aries_ingress_jd_ut",
                        "next_zeitgeist_first_aries_ingress_jd_ut",
                        "nextZeitgeistFirstAriesIngressJulianDayUT",
                    ],
                    url,
                    rowNumber
                )
                guard idText == "\(family.rawValue)\(ordinal)",
                      startValue > previousStart,
                      previousEnd == nil || same(previousEnd!, startValue),
                      let start = JulianDay(startValue),
                      let end = JulianDay(endValue),
                      let id = OrboSpineShellID(family: family, ordinal: ordinal),
                      let interval = OrboSpineShellInterval(id: id, start: start, end: end) else {
                    throw AssemblyProofError.mismatch("\(path) shell row \(rowNumber)")
                }
                previousStart = startValue
                previousEnd = endValue
                all.append(interval)
            }

            let intersections = all.filter {
                $0.start.value < bone.end.value && $0.end.value > bone.start.value
            }
            guard !intersections.isEmpty,
                  intersections.first!.start.value <= bone.start.value + 1e-12,
                  intersections.last!.end.value >= bone.end.value - 1e-12 else {
                throw AssemblyProofError.mismatch("\(family.rawValue) does not cover the Bone")
            }
            for index in 1..<intersections.count {
                guard same(intersections[index - 1].end.value, intersections[index].start.value) else {
                    throw AssemblyProofError.mismatch("\(family.rawValue) has shell gap or overlap")
                }
            }
            result.append(contentsOf: intersections)
        }

        guard Set(result.map { $0.id.family }) == Set(OrboSpineShellFamily.allCases) else {
            throw AssemblyProofError.mismatch("F.R.W.Z family coverage drift")
        }
        return result
    }

    private static func proveRuntime(
        _ runtime: OrboSpineRuntime,
        candidateSHA: String,
        supports: [OrboSpineCelestialCoordinate],
        resolver: MotionResolver,
        terra: [TerraMarrowSample]
    ) throws {
        guard runtime.identity == OrboSpineContract.identity,
              runtime.inventory.celestialSupportCount == expectedSupportRows,
              runtime.inventory.stationCount == expectedStationRows,
              runtime.inventory.retrogradePassageCount == expectedPassageRows,
              runtime.inventory.ringOccurrenceCount == expectedRingRows,
              runtime.inventory.eclipseCount == expectedEclipseRows,
              runtime.inventory.terraSampleCount == expectedTerraRows,
              runtime.provenance.candidateManifestSHA256 == candidateSHA,
              runtime.library.coreShelves == OrboSpineLibraryShelf.allCases,
              runtime.ports.locate == .locate,
              runtime.ports.library == .library,
              runtime.ports.link == .link,
              runtime.linkPort == .link,
              runtime.smeldSeams.celestial == nil,
              runtime.smeldSeams.stack == nil,
              nondecreasing(runtime.stations.map { $0.julianDay.value }),
              nondecreasing(runtime.retrogradePassages.map { $0.start.value }),
              nondecreasing(runtime.ringOccurrences.map { $0.julianDay.value }),
              nondecreasing(runtime.eclipses.map { $0.julianDay.value }) else {
            throw AssemblyProofError.mismatch("assembled runtime structure drift")
        }

        var probed = Set<MundaneBody>()
        for support in supports where !probed.contains(support.body) {
            if resolver.isStation(support.body, at: support.julianDay) { continue }
            let located = try runtime.locate.coordinate(of: support.body, at: support.julianDay)
            guard same(located.directionalDegree.degrees, support.directionalDegree.degrees) else {
                throw AssemblyProofError.mismatch("Locate probe drift for \(support.body.displayName)")
            }
            probed.insert(support.body)
            if probed.count == MundaneBody.canonicalOrder.count { break }
        }
        guard probed == Set(MundaneBody.canonicalOrder) else {
            throw AssemblyProofError.mismatch("Locate could not probe all Eleven")
        }

        for seam in TerraMarrowContract.sourceModelSeamJulianDays {
            guard let source = terra.first(where: { abs($0.julianDay.value - seam) <= 1e-12 }),
                  let jd = JulianDay(seam) else {
                throw AssemblyProofError.mismatch("missing Terra seam probe")
            }
            let located = try runtime.locate.terra(at: jd)
            guard abs(located.turnDegrees - source.turnDegrees) <= 1e-9,
                  abs(located.tiltDegrees - source.tiltDegrees) <= 1e-9 else {
                throw AssemblyProofError.mismatch("Terra seam Locate drift")
            }
        }

        let specificIdentity = "\(runtime.identity):\(candidateSHA)"
        guard let first = SpineLinkAddress(spineIdentity: specificIdentity, memberIdentity: "bone"),
              let second = SpineLinkAddress(
                spineIdentity: specificIdentity,
                memberIdentity: "library:ring-chronology"
              ),
              let link = SpineLinkSet(members: [first, second]),
              link.members.count == 2,
              SpineLinkSet.port == .link else {
            throw AssemblyProofError.mismatch("Link addressability drift")
        }
    }

    private static func passagesEqual(
        _ lhs: [OrboSpineRetrogradePassage],
        _ rhs: [OrboSpineRetrogradePassage]
    ) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (a, b) in zip(lhs, rhs) {
            guard a.body == b.body,
                  same(a.start.value, b.start.value),
                  same(a.end.value, b.end.value),
                  optionalSame(a.startStationPhysicalDegrees, b.startStationPhysicalDegrees),
                  optionalSame(a.endStationPhysicalDegrees, b.endStationPhysicalDegrees),
                  a.startBoundary == b.startBoundary,
                  a.endBoundary == b.endBoundary else {
                return false
            }
        }
        return true
    }

    private static func optionalSame(_ lhs: Double?, _ rhs: Double?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return true
        case let (a?, b?): return abs(a - b) <= 1e-9
        default: return false
        }
    }

    private static func streamCSV(
        _ url: URL,
        consume: (CSVHeader, [String], Int) throws -> Void
    ) throws -> Int {
        let reader = try CSVLineReader(url: url)
        guard let firstLine = try reader.readLine() else {
            throw AssemblyProofError.malformed("empty CSV \(url.path)")
        }
        let names = csvFields(firstLine)
        guard !names.isEmpty else {
            throw AssemblyProofError.malformed("missing CSV header \(url.path)")
        }
        let header = CSVHeader(names)
        var count = 0

        while let line = try reader.readLine() {
            if line.isEmpty { continue }
            let fields = csvFields(line)
            guard fields.count == names.count else {
                throw AssemblyProofError.malformed(
                    "\(url.lastPathComponent) row \(count + 2) has \(fields.count) fields, expected \(names.count)"
                )
            }
            try consume(header, fields, count + 2)
            count += 1
        }
        try reader.finish()
        return count
    }

    private static func csvFields(_ line: String) -> [String] {
        let line = line.trimmingCharacters(in: CharacterSet(charactersIn: "\r"))
        var fields: [String] = []
        var current = ""
        var quoted = false
        var index = line.startIndex

        while index < line.endIndex {
            let character = line[index]
            if character == "\"" {
                let next = line.index(after: index)
                if quoted, next < line.endIndex, line[next] == "\"" {
                    current.append("\"")
                    index = line.index(after: next)
                    continue
                }
                quoted.toggle()
            } else if character == ",", !quoted {
                fields.append(current)
                current.removeAll(keepingCapacity: true)
            } else {
                current.append(character)
            }
            index = line.index(after: index)
        }
        fields.append(current)
        return fields
    }

    private static func optionalText(
        _ fields: [String],
        _ header: CSVHeader,
        _ aliases: [String]
    ) -> String? {
        guard let index = header.index(for: aliases), fields.indices.contains(index) else { return nil }
        return fields[index]
    }

    private static func requiredText(
        _ fields: [String],
        _ header: CSVHeader,
        _ aliases: [String],
        _ url: URL,
        _ rowNumber: Int
    ) throws -> String {
        guard let value = optionalText(fields, header, aliases), !value.isEmpty else {
            throw AssemblyProofError.malformed(
                "\(url.lastPathComponent) row \(rowNumber) missing \(aliases.joined(separator: "/"))"
            )
        }
        return value
    }

    private static func requiredDouble(
        _ fields: [String],
        _ header: CSVHeader,
        _ aliases: [String],
        _ url: URL,
        _ rowNumber: Int
    ) throws -> Double {
        let text = try requiredText(fields, header, aliases, url, rowNumber)
        guard let value = Double(text), value.isFinite else {
            throw AssemblyProofError.malformed("\(url.lastPathComponent) row \(rowNumber) invalid Double")
        }
        return value
    }

    private static func optionalDouble(
        _ fields: [String],
        _ header: CSVHeader,
        _ aliases: [String],
        _ url: URL,
        _ rowNumber: Int
    ) throws -> Double? {
        guard let text = optionalText(fields, header, aliases), !text.isEmpty else { return nil }
        guard let value = Double(text), value.isFinite else {
            throw AssemblyProofError.malformed("\(url.lastPathComponent) row \(rowNumber) invalid optional Double")
        }
        return value
    }

    private static func requiredInt(
        _ fields: [String],
        _ header: CSVHeader,
        _ aliases: [String],
        _ url: URL,
        _ rowNumber: Int
    ) throws -> Int {
        let text = try requiredText(fields, header, aliases, url, rowNumber)
        guard let value = Int(text) else {
            throw AssemblyProofError.malformed("\(url.lastPathComponent) row \(rowNumber) invalid Int")
        }
        return value
    }

    private static func requiredInt64(
        _ fields: [String],
        _ header: CSVHeader,
        _ aliases: [String],
        _ url: URL,
        _ rowNumber: Int
    ) throws -> Int64 {
        let text = try requiredText(fields, header, aliases, url, rowNumber)
        guard let value = Int64(text) else {
            throw AssemblyProofError.malformed("\(url.lastPathComponent) row \(rowNumber) invalid Int64")
        }
        return value
    }

    private static func body(named name: String) throws -> MundaneBody {
        let key = String(name.lowercased().filter { $0.isLetter || $0.isNumber })
        if key == "northnode" || key == "truenorthnode" || key == "truenode" {
            return .trueNorthNode
        }
        if let body = MundaneBody.canonicalOrder.first(where: {
            let display = String($0.displayName.lowercased().filter { $0.isLetter || $0.isNumber })
            let construction = String($0.constructionDataName.lowercased().filter { $0.isLetter || $0.isNumber })
            return key == display || key == construction
        }) {
            return body
        }
        throw AssemblyProofError.malformed("unknown body \(name)")
    }

    private static func decode<T: Decodable>(_ url: URL) throws -> T {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AssemblyProofError.missing(url.path)
        }
        do {
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        } catch {
            throw AssemblyProofError.malformed("cannot decode \(url.lastPathComponent): \(error)")
        }
    }

    private static func declaredHash(_ url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AssemblyProofError.missing(url.path)
        }
        let text = try String(contentsOf: url, encoding: .utf8)
        guard let hash = text.split(whereSeparator: \.isWhitespace).first else {
            throw AssemblyProofError.malformed("empty candidate SHA-256 file")
        }
        return String(hash)
    }

    private static func sha256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let chunk = try handle.read(upToCount: 1_048_576) ?? Data()
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private static func normalizedDegrees(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result == 360 ? 0 : result
    }

    private static func circularDistance(_ lhs: Double, _ rhs: Double) -> Double {
        let delta = abs(normalizedDegrees(lhs) - normalizedDegrees(rhs))
        return min(delta, 360 - delta)
    }

    private static func nondecreasing(_ values: [Double]) -> Bool {
        guard values.count > 1 else { return true }
        for index in 1..<values.count where values[index] + 1e-12 < values[index - 1] {
            return false
        }
        return true
    }

    private static func same(_ lhs: Double, _ rhs: Double) -> Bool {
        abs(lhs - rhs) <= 1e-12
    }
}

do {
    try AssemblyProof.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    let message = "OrboSpineAssemblyProofTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
