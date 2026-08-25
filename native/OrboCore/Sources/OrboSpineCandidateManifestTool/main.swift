import CryptoKit
import Foundation
import OrboCore

private enum CandidateManifestError: Error, CustomStringConvertible {
    case missing(String)
    case malformed(String)
    case mismatch(String)

    var description: String {
        switch self {
        case let .missing(message): return "Missing OrboSpine matter: \(message)"
        case let .malformed(message): return "Malformed OrboSpine matter: \(message)"
        case let .mismatch(message): return "OrboSpine closeout mismatch: \(message)"
        }
    }
}

private struct Arguments {
    let buildRoot: URL

    init(_ raw: [String]) throws {
        guard raw.count == 2, raw[0] == "--build-root" else {
            throw CandidateManifestError.malformed("usage: --build-root <tools/pass5/orbospine-build>")
        }
        buildRoot = URL(fileURLWithPath: raw[1], isDirectory: true).standardizedFileURL
    }
}

private struct FileDigest: Codable {
    let path: String
    let role: String
    let bytes: Int64
    let sha256: String
}

private struct CountedSpan: Codable {
    let span: String
    let rows: Int
}

private struct CelestialSummary: Codable {
    let supportRows: Int
    let stationRows: Int
    let totalRecords: Int
    let manifest: String
}

private struct MotionSummary: Codable {
    let passageRows: Int
    let sourceStationRows: Int
    let manifest: String
}

private struct AspectSummary: Codable {
    let spans: [CountedSpan]
    let totalRows: Int
}

private struct LunationSummary: Codable {
    let rows: Int
    let newRows: Int
    let fullRows: Int
    let manifest: String
}

private struct EclipseSummary: Codable {
    let spans: [CountedSpan]
    let totalRows: Int
}

private struct ShellSummary: Codable {
    let address: String
    let families: [String]
}

private struct TerraSummary: Codable {
    let rows: Int
    let supportIntervalSeconds: Int
    let refinementLaw: String
    let sourceModelSeamYears: [Int]
    let manifest: String
}

private struct LifecycleSummary: Codable {
    let manufacture: String
    let runtimeIndexes: String
    let dioscuriCertification: String
    let adversarialProof: String
    let hephaestusSeal: String
}

private struct CandidateManifest: Codable {
    let identity: String
    let lifecycle: String
    let span: String
    let supportedStartJulianDayUT: Double
    let supportedEndJulianDayUT: Double
    let astronomicalAuthority: String
    let astronomicalSourceVersion: String
    let celestial: CelestialSummary
    let motion: MotionSummary
    let aspects: AspectSummary
    let lunations: LunationSummary
    let temporalShells: ShellSummary
    let eclipses: EclipseSummary
    let terraMarrow: TerraSummary
    let files: [FileDigest]
    let lifecycleStatus: LifecycleSummary
}

private enum Closeout {
    private static let candidateFileName = "orbospine-candidate-manifest.json"
    private static let candidateHashFileName = "orbospine-candidate-manifest.sha256"

    static func run(_ raw: [String]) throws {
        let arguments = try Arguments(raw)
        let root = arguments.buildRoot
        guard FileManager.default.fileExists(atPath: root.path) else {
            throw CandidateManifestError.missing(root.path)
        }

        var files: [FileDigest] = []

        let celestialManifestRelative = "celestial/orbospine-celestial-manifest.json"
        let celestialJSON = try loadJSONObject(root.appendingPathComponent(celestialManifestRelative))
        let supportRows = try int(celestialJSON, "totalSupportRows")
        let stationRows = try int(celestialJSON, "totalStationRows")
        guard supportRows == 1_550_229 else {
            throw CandidateManifestError.mismatch("celestial support rows \(supportRows) != 1550229")
        }
        guard stationRows == 52_679 else {
            throw CandidateManifestError.mismatch("celestial station rows \(stationRows) != 52679")
        }
        guard let bodies = celestialJSON["bodies"] as? [[String: Any]], bodies.count == 11 else {
            throw CandidateManifestError.malformed("celestial manifest must contain exactly 11 bodies")
        }
        let celestialManifestDigest = try digest(root: root, relativePath: celestialManifestRelative, role: "celestial manifest")
        files.append(celestialManifestDigest)
        for body in bodies {
            let supportFile = try string(body, "supportFile")
            let stationFile = try string(body, "stationFile")
            let supportDigest = try digest(root: root, relativePath: "celestial/\(supportFile)", role: "celestial support")
            let stationDigest = try digest(root: root, relativePath: "celestial/\(stationFile)", role: "station topology")
            try verifyDeclaredDigest(body, key: "supportSHA256", actual: supportDigest.sha256, context: supportFile)
            try verifyDeclaredDigest(body, key: "stationSHA256", actual: stationDigest.sha256, context: stationFile)
            files.append(supportDigest)
            files.append(stationDigest)
        }

        let boundaryAnchorRelative = "celestial/orbospine-boundary-anchors.csv"
        let boundaryAnchorRows = try validateBoundaryAnchors(
            root.appendingPathComponent(boundaryAnchorRelative)
        )
        files.append(try digest(
            root: root,
            relativePath: boundaryAnchorRelative,
            role: "celestial Bone boundary anchors"
        ))

        let motionManifestRelative = "motion/orbospine-motion-manifest.json"
        let motionJSON = try loadJSONObject(root.appendingPathComponent(motionManifestRelative))
        guard try string(motionJSON, "identity") == OrboSpineContract.identity else {
            throw CandidateManifestError.mismatch("motion identity drift")
        }
        let motionStationRows = try int(motionJSON, "sourceStationRows")
        let motionPassageRows = try int(motionJSON, "totalPassageRows")
        guard motionStationRows == stationRows else {
            throw CandidateManifestError.mismatch("motion source stations \(motionStationRows) != celestial \(stationRows)")
        }
        guard motionPassageRows == 26_343 else {
            throw CandidateManifestError.mismatch("motion passages \(motionPassageRows) != 26343")
        }
        guard try string(motionJSON, "sourceCelestialManifest") == celestialManifestRelative else {
            throw CandidateManifestError.mismatch("motion source celestial manifest path drift")
        }
        guard try string(motionJSON, "sourceCelestialManifestSHA256") == celestialManifestDigest.sha256 else {
            throw CandidateManifestError.mismatch("motion source celestial manifest SHA-256 drift")
        }
        guard let motionBodies = motionJSON["bodies"] as? [[String: Any]], motionBodies.count == 11 else {
            throw CandidateManifestError.malformed("motion manifest must contain exactly 11 bodies")
        }
        var motionBodyPassageTotal = 0
        for motionBody in motionBodies {
            let bodyName = try string(motionBody, "body")
            guard let celestialBody = bodies.first(where: { ($0["body"] as? String) == bodyName }) else {
                throw CandidateManifestError.mismatch("motion body \(bodyName) is not canonical celestial matter")
            }
            guard try int(motionBody, "stationRows") == int(celestialBody, "stationRows") else {
                throw CandidateManifestError.mismatch("motion/celestial station count drift for \(bodyName)")
            }
            guard try string(motionBody, "sourceStationFile") == string(celestialBody, "stationFile") else {
                throw CandidateManifestError.mismatch("motion source station file drift for \(bodyName)")
            }
            guard try string(motionBody, "sourceStationSHA256") == string(celestialBody, "stationSHA256") else {
                throw CandidateManifestError.mismatch("motion source station SHA-256 drift for \(bodyName)")
            }
            motionBodyPassageTotal += try int(motionBody, "passageRows")
        }
        guard motionBodyPassageTotal == motionPassageRows else {
            throw CandidateManifestError.mismatch("motion passage body total \(motionBodyPassageTotal) != \(motionPassageRows)")
        }
        files.append(try digest(root: root, relativePath: motionManifestRelative, role: "retrograde motion manifest"))
        let motionPassageFile = try string(motionJSON, "passageFile")
        let motionPassageDigest = try digest(root: root, relativePath: "motion/\(motionPassageFile)", role: "continuous Z21-Z23 retrograde passages")
        try verifyDeclaredDigest(motionJSON, key: "passageSHA256", actual: motionPassageDigest.sha256, context: motionPassageFile)
        files.append(motionPassageDigest)

        let aspectCounts = try gatherAspects(root: root, files: &files)
        guard aspectCounts.map(\.rows).reduce(0, +) == 2_315_930 else {
            throw CandidateManifestError.mismatch("aspect total is not 2315930")
        }

        let lunationManifestRelative = "lunations/manifest.json"
        let lunationJSON = try loadJSONObject(root.appendingPathComponent(lunationManifestRelative))
        let lunationRows = try int(lunationJSON, "rows")
        let newRows = try int(lunationJSON, "newRows")
        let fullRows = try int(lunationJSON, "fullRows")
        guard lunationRows == 18_159, newRows + fullRows == lunationRows else {
            throw CandidateManifestError.mismatch("lunation rows are not canonical 18159")
        }
        files.append(try digest(root: root, relativePath: lunationManifestRelative, role: "lunation manifest"))
        guard let lunationFiles = lunationJSON["files"] as? [[String: Any]], let lunationFile = lunationFiles.first else {
            throw CandidateManifestError.malformed("lunation manifest files")
        }
        let lunationPath = try string(lunationFile, "path")
        let lunationDigest = try digest(root: root, relativePath: "lunations/\(lunationPath)", role: "exact new/full Moon chronology")
        try verifyDeclaredDigest(lunationFile, key: "sha256", actual: lunationDigest.sha256, context: lunationPath)
        files.append(lunationDigest)

        let eclipseCounts = try gatherEclipses(root: root, files: &files)
        guard eclipseCounts.map(\.rows).reduce(0, +) == 3_539 else {
            throw CandidateManifestError.mismatch("eclipse total is not 3539")
        }

        let shellPaths = [
            ("shells/jovian-reign-table.csv", "Reign / Jupiter"),
            ("shells/saturnian-frame-table.csv", "Frame / Saturn"),
            ("shells/uranian-revolt-table.csv", "Revolt / Uranus"),
            ("shells/neptunian-wave-table.csv", "Wave / Neptune"),
            ("shells/zeitgeist-z0-z30.csv", "Zeitgeist / Pluto"),
        ]
        for (path, role) in shellPaths {
            files.append(try digest(root: root, relativePath: path, role: "temporal shell \(role)"))
        }

        let terraManifestRelative = "terra/terra-marrow-manifest.json"
        let terraJSON = try loadJSONObject(root.appendingPathComponent(terraManifestRelative))
        let terraRows = try int(terraJSON, "totalRows")
        let supportIntervalSeconds = try int(terraJSON, "supportIntervalSeconds")
        let refinementLaw = try string(terraJSON, "refinementLaw")
        guard terraRows == 1_072_502 else {
            throw CandidateManifestError.mismatch("Terra rows \(terraRows) != 1072502")
        }
        guard supportIntervalSeconds == TerraMarrowContract.supportIntervalSeconds else {
            throw CandidateManifestError.mismatch("Terra support interval drift")
        }
        guard refinementLaw == TerraMarrowContract.refinementLaw.rawValue else {
            throw CandidateManifestError.mismatch("Terra refinement law drift")
        }
        files.append(try digest(root: root, relativePath: terraManifestRelative, role: "Terra Marrow manifest"))
        guard let terraSpans = terraJSON["spans"] as? [[String: Any]], terraSpans.count == 3 else {
            throw CandidateManifestError.malformed("Terra manifest must contain Z21, Z22, Z23")
        }
        for span in terraSpans {
            let path = try string(span, "file")
            let fileDigest = try digest(root: root, relativePath: "terra/\(path)", role: "Terra Marrow")
            try verifyDeclaredDigest(span, key: "sha256", actual: fileDigest.sha256, context: path)
            files.append(fileDigest)
        }

        let supportedStart = OrboSpineSchematic.supportedStart.value
        let supportedEnd = OrboSpineSchematic.supportedEnd.value
        try verifyDouble(celestialJSON, key: "supportedStartJulianDayUT", expected: supportedStart, context: "celestial start")
        try verifyDouble(celestialJSON, key: "supportedEndJulianDayUT", expected: supportedEnd, context: "celestial end")
        try verifyDouble(motionJSON, key: "supportedStartJulianDayUT", expected: supportedStart, context: "motion start")
        try verifyDouble(motionJSON, key: "supportedEndJulianDayUT", expected: supportedEnd, context: "motion end")
        try verifyDouble(lunationJSON, key: "startJulianDayUT", expected: supportedStart, context: "lunation start")
        try verifyDouble(lunationJSON, key: "endJulianDayUTExclusive", expected: supportedEnd, context: "lunation end")
        try verifyDouble(terraJSON, key: "supportedStartJulianDayUT", expected: supportedStart, context: "Terra start")
        try verifyDouble(terraJSON, key: "supportedEndJulianDayUT", expected: supportedEnd, context: "Terra end")

        files.sort { $0.path < $1.path }

        let manifest = CandidateManifest(
            identity: OrboSpineContract.identity,
            lifecycle: OrboSpineLifecycleBoundary.candidate.rawValue,
            span: "Z21-Z23",
            supportedStartJulianDayUT: supportedStart,
            supportedEndJulianDayUT: supportedEnd,
            astronomicalAuthority: OrboSpineSchematic.astronomicalAuthority,
            astronomicalSourceVersion: OrboSpineSchematic.astronomicalSourceVersion,
            celestial: CelestialSummary(
                supportRows: supportRows,
                stationRows: stationRows,
                totalRecords: supportRows + stationRows,
                manifest: celestialManifestRelative
            ),
            motion: MotionSummary(
                passageRows: motionPassageRows,
                sourceStationRows: motionStationRows,
                manifest: motionManifestRelative
            ),
            aspects: AspectSummary(
                spans: aspectCounts,
                totalRows: aspectCounts.map(\.rows).reduce(0, +)
            ),
            lunations: LunationSummary(
                rows: lunationRows,
                newRows: newRows,
                fullRows: fullRows,
                manifest: lunationManifestRelative
            ),
            temporalShells: ShellSummary(
                address: "J.F.R.W.Z",
                families: ["Reign / Jupiter", "Frame / Saturn", "Revolt / Uranus", "Wave / Neptune", "Zeitgeist / Pluto"]
            ),
            eclipses: EclipseSummary(
                spans: eclipseCounts,
                totalRows: eclipseCounts.map(\.rows).reduce(0, +)
            ),
            terraMarrow: TerraSummary(
                rows: terraRows,
                supportIntervalSeconds: supportIntervalSeconds,
                refinementLaw: refinementLaw,
                sourceModelSeamYears: TerraMarrowContract.sourceModelSeamYears,
                manifest: terraManifestRelative
            ),
            files: files,
            lifecycleStatus: LifecycleSummary(
                manufacture: "complete",
                runtimeIndexes: "pending",
                dioscuriCertification: "pending",
                adversarialProof: "pending",
                hephaestusSeal: "pending"
            )
        )

        let manifestURL = root.appendingPathComponent(candidateFileName)
        try writeJSON(manifest, to: manifestURL)
        let manifestDigest = try digest(root: root, relativePath: candidateFileName, role: "candidate manifest")
        let hashLine = "\(manifestDigest.sha256)  \(candidateFileName)\n"
        try atomicWrite(Data(hashLine.utf8), to: root.appendingPathComponent(candidateHashFileName))

        print("ORBOSPINE WHOLE FORGE")
        print("PASS celestial: \(supportRows) supports / \(stationRows) stations")
        print("PASS boundary anchors: \(boundaryAnchorRows) exact Bone states")
        print("PASS motion: \(motionPassageRows) continuous retrograde passages")
        print("PASS Ring: \(aspectCounts.map(\.rows).reduce(0, +)) exact occurrences")
        print("PASS lunations: \(lunationRows) exact new/full Moons")
        print("PASS eclipses: \(eclipseCounts.map(\.rows).reduce(0, +))")
        print("PASS indexing: J.F.R.W.Z")
        print("PASS Terra Marrow: \(terraRows) rows")
        print("candidate manifest: \(manifestURL.path)")
        print("candidate SHA-256: \(manifestDigest.sha256)")
        print("FORGE STAGE: COMPLETE / UNSEALED ORBOSPINE CANDIDATE")
    }

    private static func validateBoundaryAnchors(_ url: URL) throws -> Int {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CandidateManifestError.missing(url.path)
        }

        let text = try String(contentsOf: url, encoding: .utf8)
        let lines = text.split(whereSeparator: { $0.isNewline })
        guard let headerLine = lines.first else {
            throw CandidateManifestError.malformed("empty boundary-anchor CSV")
        }

        let expectedHeader = [
            "body",
            "boundary",
            "jd_ut",
            "utc",
            "physical_degree",
            "longitudinal_speed_degrees_per_day",
            "motion",
            "directional_degree",
            "navigation_cell",
        ]
        let header = headerLine
            .split(separator: ",", omittingEmptySubsequences: false)
            .map(String.init)
        guard header == expectedHeader else {
            throw CandidateManifestError.malformed("boundary-anchor CSV header")
        }

        let rows = Array(lines.dropFirst())
        let expectedRows = MundaneBody.canonicalOrder.count * 2
        guard rows.count == expectedRows else {
            throw CandidateManifestError.mismatch(
                "boundary-anchor rows \(rows.count) != \(expectedRows)"
            )
        }

        var seen = Set<String>()
        for row in rows {
            let fields = row
                .split(separator: ",", omittingEmptySubsequences: false)
                .map(String.init)
            guard fields.count == expectedHeader.count else {
                throw CandidateManifestError.malformed("boundary-anchor CSV row")
            }

            let bodyName = fields[0]
            guard let body = MundaneBody.canonicalOrder.first(where: { $0.displayName == bodyName }) else {
                throw CandidateManifestError.mismatch("unknown boundary-anchor body \(bodyName)")
            }

            let boundary: OrboSpineBoundaryAnchorKind
            let expectedJulianDay: JulianDay
            switch fields[1] {
            case "z21_start":
                boundary = .start
                expectedJulianDay = OrboSpineSchematic.supportedStart
            case "z23_end_exclusive":
                boundary = .endExclusive
                expectedJulianDay = OrboSpineSchematic.supportedEnd
            default:
                throw CandidateManifestError.mismatch(
                    "unknown boundary-anchor side \(fields[1])"
                )
            }

            guard let julianDayValue = Double(fields[2]),
                  let julianDay = JulianDay(julianDayValue),
                  abs(julianDay.value - expectedJulianDay.value) <= 1e-12 else {
                throw CandidateManifestError.mismatch(
                    "boundary-anchor Julian day drift for \(bodyName) \(fields[1])"
                )
            }
            guard !fields[3].isEmpty else {
                throw CandidateManifestError.malformed(
                    "boundary-anchor UTC missing for \(bodyName) \(fields[1])"
                )
            }

            guard let physicalDegrees = Double(fields[4]),
                  let longitudinalSpeed = Double(fields[5]), longitudinalSpeed.isFinite,
                  let directionalDegrees = Double(fields[7]),
                  let navigationCell = Int(fields[8]) else {
                throw CandidateManifestError.malformed(
                    "boundary-anchor numeric state for \(bodyName) \(fields[1])"
                )
            }

            let motion: Motion
            switch fields[6] {
            case "direct": motion = .direct
            case "retrograde": motion = .retrograde
            default:
                throw CandidateManifestError.mismatch(
                    "unknown boundary-anchor motion \(fields[6])"
                )
            }

            guard (motion == .direct && longitudinalSpeed > 0)
                    || (motion == .retrograde && longitudinalSpeed < 0) else {
                throw CandidateManifestError.mismatch(
                    "boundary-anchor speed/motion drift for \(bodyName) \(fields[1])"
                )
            }

            guard let anchor = OrboSpineBoundaryAnchor(
                body: body,
                boundary: boundary,
                julianDay: julianDay,
                physicalDegrees: physicalDegrees,
                motion: motion
            ),
            abs(anchor.directionalDegree.degrees - directionalDegrees) <= 1e-9,
            anchor.navigationCell == navigationCell else {
                throw CandidateManifestError.mismatch(
                    "boundary-anchor directional state drift for \(bodyName) \(fields[1])"
                )
            }

            let key = "\(body.displayName)|\(boundary.rawValue)"
            guard seen.insert(key).inserted else {
                throw CandidateManifestError.mismatch("duplicate boundary anchor \(key)")
            }
        }

        for body in MundaneBody.canonicalOrder {
            for boundary in [
                OrboSpineBoundaryAnchorKind.start,
                OrboSpineBoundaryAnchorKind.endExclusive,
            ] {
                let key = "\(body.displayName)|\(boundary.rawValue)"
                guard seen.contains(key) else {
                    throw CandidateManifestError.mismatch("missing boundary anchor \(key)")
                }
            }
        }

        return rows.count
    }

    private static func gatherAspects(root: URL, files: inout [FileDigest]) throws -> [CountedSpan] {
        var spans: [CountedSpan] = []
        for ordinal in [21, 23] {
            let manifestPath = "aspects/z\(ordinal)/manifest.json"
            let manifest = try loadJSONObject(root.appendingPathComponent(manifestPath))
            guard let families = manifest["families"] as? [String: Any],
                  let major = families["major"] as? [String: Any],
                  let minor = families["minor"] as? [String: Any] else {
                throw CandidateManifestError.malformed("Z\(ordinal) aspect manifest families")
            }
            let majorRows = try int(major, "rows")
            let minorRows = try int(minor, "rows")
            spans.append(CountedSpan(span: "Z\(ordinal)", rows: majorRows + minorRows))
            files.append(try digest(root: root, relativePath: manifestPath, role: "aspect manifest"))
            files.append(try digestAndVerifyManifestFile(root: root, base: "aspects/z\(ordinal)", manifest: manifest, familyIndex: 0, role: "exact major aspects"))
            files.append(try digestAndVerifyManifestFile(root: root, base: "aspects/z\(ordinal)", manifest: manifest, familyIndex: 1, role: "exact minor aspects"))
        }

        let z22ProvenancePath = "provenance/z22-universal-events-manifest.json"
        let z22 = try loadJSONObject(root.appendingPathComponent(z22ProvenancePath))
        guard let entries = z22["files"] as? [[String: Any]] else {
            throw CandidateManifestError.malformed("Z22 universal event manifest files")
        }
        let major = try z22Entry(entries, family: "exact-major-relationships")
        let minor = try z22Entry(entries, family: "exact-minor-relationships")
        let majorRows = try int(major, "rows")
        let minorRows = try int(minor, "rows")
        spans.insert(CountedSpan(span: "Z22", rows: majorRows + minorRows), at: 1)
        files.append(try digest(root: root, relativePath: z22ProvenancePath, role: "Z22 universal-event provenance"))
        for (entry, role) in [(major, "exact major aspects"), (minor, "exact minor aspects")] {
            let path = try string(entry, "path")
            let item = try digest(root: root, relativePath: "aspects/z22/\(path)", role: role)
            try verifyDeclaredDigest(entry, key: "sha256", actual: item.sha256, context: path)
            files.append(item)
        }
        return spans
    }

    private static func gatherEclipses(root: URL, files: inout [FileDigest]) throws -> [CountedSpan] {
        var spans: [CountedSpan] = []
        for ordinal in [21, 23] {
            let manifestPath = "eclipses/z\(ordinal)/manifest.json"
            let manifest = try loadJSONObject(root.appendingPathComponent(manifestPath))
            let rows = try int(manifest, "rows")
            spans.append(CountedSpan(span: "Z\(ordinal)", rows: rows))
            files.append(try digest(root: root, relativePath: manifestPath, role: "eclipse manifest"))
            guard let declared = manifest["files"] as? [[String: Any]], let first = declared.first else {
                throw CandidateManifestError.malformed("Z\(ordinal) eclipse manifest files")
            }
            let path = try string(first, "path")
            let item = try digest(root: root, relativePath: "eclipses/z\(ordinal)/\(path)", role: "eclipse table")
            try verifyDeclaredDigest(first, key: "sha256", actual: item.sha256, context: path)
            files.append(item)
        }

        let z22 = try loadJSONObject(root.appendingPathComponent("provenance/z22-universal-events-manifest.json"))
        guard let entries = z22["files"] as? [[String: Any]] else {
            throw CandidateManifestError.malformed("Z22 universal event manifest files")
        }
        let eclipse = try z22Entry(entries, family: "eclipse")
        let rows = try int(eclipse, "rows")
        spans.insert(CountedSpan(span: "Z22", rows: rows), at: 1)
        let path = try string(eclipse, "path")
        let item = try digest(root: root, relativePath: "eclipses/z22/\(path)", role: "eclipse table")
        try verifyDeclaredDigest(eclipse, key: "sha256", actual: item.sha256, context: path)
        files.append(item)
        return spans
    }

    private static func digestAndVerifyManifestFile(
        root: URL,
        base: String,
        manifest: [String: Any],
        familyIndex: Int,
        role: String
    ) throws -> FileDigest {
        guard let declared = manifest["files"] as? [[String: Any]], declared.indices.contains(familyIndex) else {
            throw CandidateManifestError.malformed("manifest file inventory")
        }
        let entry = declared[familyIndex]
        let path = try string(entry, "path")
        let item = try digest(root: root, relativePath: "\(base)/\(path)", role: role)
        try verifyDeclaredDigest(entry, key: "sha256", actual: item.sha256, context: path)
        return item
    }

    private static func z22Entry(_ entries: [[String: Any]], family: String) throws -> [String: Any] {
        guard let entry = entries.first(where: { ($0["family"] as? String) == family }) else {
            throw CandidateManifestError.malformed("Z22 missing family \(family)")
        }
        return entry
    }

    private static func loadJSONObject(_ url: URL) throws -> [String: Any] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CandidateManifestError.missing(url.path)
        }
        let data = try Data(contentsOf: url)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CandidateManifestError.malformed(url.path)
        }
        return object
    }

    private static func string(_ object: [String: Any], _ key: String) throws -> String {
        guard let value = object[key] as? String, !value.isEmpty else {
            throw CandidateManifestError.malformed("missing string \(key)")
        }
        return value
    }

    private static func int(_ object: [String: Any], _ key: String) throws -> Int {
        if let value = object[key] as? Int { return value }
        if let value = object[key] as? NSNumber { return value.intValue }
        throw CandidateManifestError.malformed("missing integer \(key)")
    }

    private static func verifyDeclaredDigest(
        _ object: [String: Any],
        key: String,
        actual: String,
        context: String
    ) throws {
        let expected = try string(object, key)
        guard expected == actual else {
            throw CandidateManifestError.mismatch("\(context) SHA-256 \(actual) != declared \(expected)")
        }
    }

    private static func verifyDouble(
        _ object: [String: Any],
        key: String,
        expected: Double,
        context: String
    ) throws {
        guard let number = object[key] as? NSNumber else {
            throw CandidateManifestError.malformed("missing number \(key)")
        }
        guard abs(number.doubleValue - expected) < 1e-12 else {
            throw CandidateManifestError.mismatch("\(context) \(number.doubleValue) != \(expected)")
        }
    }

    private static func digest(root: URL, relativePath: String, role: String) throws -> FileDigest {
        let url = root.appendingPathComponent(relativePath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CandidateManifestError.missing(relativePath)
        }
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let size = attributes[.size] as? NSNumber else {
            throw CandidateManifestError.malformed("size for \(relativePath)")
        }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 1_048_576) ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }
        let hash = hasher.finalize().map { String(format: "%02x", $0) }.joined()
        return FileDigest(path: relativePath, role: role, bytes: size.int64Value, sha256: hash)
    }

    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try atomicWrite(try encoder.encode(value), to: url)
    }

    private static func atomicWrite(_ data: Data, to url: URL) throws {
        let temporary = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).tmp")
        try data.write(to: temporary, options: .atomic)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            _ = try fileManager.replaceItemAt(url, withItemAt: temporary)
        } else {
            try fileManager.moveItem(at: temporary, to: url)
        }
    }
}

do {
    try Closeout.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    let message = "OrboSpineCandidateManifestTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
