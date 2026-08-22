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

private struct AspectSummary: Codable {
    let spans: [CountedSpan]
    let totalRows: Int
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
    let aspects: AspectSummary
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
        let celestialManifestURL = root.appendingPathComponent(celestialManifestRelative)
        let celestialJSON = try loadJSONObject(celestialManifestURL)
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
        files.append(try digest(root: root, relativePath: celestialManifestRelative, role: "celestial manifest"))
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

        let aspectCounts = try gatherAspects(root: root, files: &files)
        guard aspectCounts.map(\.rows).reduce(0, +) == 2_315_930 else {
            throw CandidateManifestError.mismatch("aspect total is not 2315930")
        }

        let eclipseCounts = try gatherEclipses(root: root, files: &files)
        guard eclipseCounts.map(\.rows).reduce(0, +) == 3_539 else {
            throw CandidateManifestError.mismatch("eclipse total is not 3539")
        }

        let shellPaths = [
            ("shells/saturnian-frame-table.csv", "Frame / Saturn"),
            ("shells/uranian-revolt-table.csv", "Revolt / Uranus"),
            ("shells/neptunian-wave-table.csv", "Wave / Neptune"),
            ("shells/zeitgeist-z0-z30.csv", "Zeitgeist / Pluto"),
        ]
        for (path, role) in shellPaths {
            files.append(try digest(root: root, relativePath: path, role: "temporal shell \(role)"))
        }

        let terraManifestRelative = "terra/terra-marrow-manifest.json"
        let terraManifestURL = root.appendingPathComponent(terraManifestRelative)
        let terraJSON = try loadJSONObject(terraManifestURL)
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

        let supportedStart = OrboSpineManufactureContract.supportedStart.value
        let supportedEnd = OrboSpineManufactureContract.supportedEnd.value
        try verifyDouble(celestialJSON, key: "supportedStartJulianDayUT", expected: supportedStart, context: "celestial start")
        try verifyDouble(celestialJSON, key: "supportedEndJulianDayUT", expected: supportedEnd, context: "celestial end")
        try verifyDouble(terraJSON, key: "supportedStartJulianDayUT", expected: supportedStart, context: "Terra start")
        try verifyDouble(terraJSON, key: "supportedEndJulianDayUT", expected: supportedEnd, context: "Terra end")

        files.sort { $0.path < $1.path }

        let manifest = CandidateManifest(
            identity: OrboSpineContract.identity,
            lifecycle: OrboSpineLifecycleBoundary.candidate.rawValue,
            span: "Z21-Z23",
            supportedStartJulianDayUT: supportedStart,
            supportedEndJulianDayUT: supportedEnd,
            astronomicalAuthority: OrboSpineManufactureContract.astronomicalSource,
            astronomicalSourceVersion: OrboSpineManufactureContract.canonicalAstronomicalSourceVersion,
            celestial: CelestialSummary(
                supportRows: supportRows,
                stationRows: stationRows,
                totalRecords: supportRows + stationRows,
                manifest: celestialManifestRelative
            ),
            aspects: AspectSummary(
                spans: aspectCounts,
                totalRows: aspectCounts.map(\.rows).reduce(0, +)
            ),
            temporalShells: ShellSummary(
                address: "F.R.W.Z",
                families: ["Frame / Saturn", "Revolt / Uranus", "Wave / Neptune", "Zeitgeist / Pluto"]
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
                runtimeIndexes: "pending Pass D",
                dioscuriCertification: "pending Pass E",
                adversarialProof: "pending Pass F",
                hephaestusSeal: "pending Pass G"
            )
        )

        let manifestURL = root.appendingPathComponent(candidateFileName)
        try writeJSON(manifest, to: manifestURL)
        let manifestDigest = try digest(root: root, relativePath: candidateFileName, role: "candidate manifest")
        let hashLine = "\(manifestDigest.sha256)  \(candidateFileName)\n"
        try atomicWrite(Data(hashLine.utf8), to: root.appendingPathComponent(candidateHashFileName))

        print("ORBOSPINE MANUFACTURE CLOSEOUT")
        print("PASS celestial: \(supportRows) supports / \(stationRows) stations")
        print("PASS aspects: \(aspectCounts.map(\.rows).reduce(0, +)) exact occurrences")
        print("PASS temporal shells: F.R.W.Z")
        print("PASS eclipses: \(eclipseCounts.map(\.rows).reduce(0, +))")
        print("PASS Terra Marrow: \(terraRows) rows")
        print("candidate manifest: \(manifestURL.path)")
        print("candidate SHA-256: \(manifestDigest.sha256)")
        print("MANUFACTURE STAGE: COMPLETE / ORBOSPINE CANDIDATE")
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
