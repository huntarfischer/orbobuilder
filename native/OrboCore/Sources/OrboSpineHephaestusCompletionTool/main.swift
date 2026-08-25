import CryptoKit
import Foundation
import OrboCore

private enum CompletionToolError: Error, CustomStringConvertible {
    case usage
    case missing(String)
    case malformed(String)
    case mismatch(String)

    var description: String {
        switch self {
        case .usage:
            return "usage: OrboSpineHephaestusCompletionTool --build-root <tools/pass5/orbospine-build>"
        case let .missing(value):
            return "Missing Hephaestus input: \(value)"
        case let .malformed(value):
            return "Malformed Hephaestus input: \(value)"
        case let .mismatch(value):
            return "Hephaestus mismatch: \(value)"
        }
    }
}

private struct Arguments {
    let buildRoot: URL

    init(_ raw: [String]) throws {
        guard raw.count == 2, raw[0] == "--build-root" else {
            throw CompletionToolError.usage
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

private struct DioscuriTestimonyArtifact: Decodable {
    let authority: String
    let lifecycle: String
    let schematicIdentity: String
    let schematicVersion: UInt16
    let candidateManifestSHA256: String
    let result: String
}

private struct HephaestusSealArtifact: Encodable {
    let authority: String
    let lifecycle: String
    let schematicIdentity: String
    let schematicVersion: UInt16
    let candidateManifestSHA256: String
    let dioscuriTestimonySHA256: String
}

private enum Completion {
    private static let candidateManifest = "orbospine-candidate-manifest.json"
    private static let candidateHash = "orbospine-candidate-manifest.sha256"
    private static let testimonyFile = "orbospine-dioscuri-testimony.json"
    private static let testimonyHashFile = "orbospine-dioscuri-testimony.sha256"
    private static let sealFile = "orbospine-hephaestus-seal.json"
    private static let sealHashFile = "orbospine-hephaestus-seal.sha256"

    static func run(_ raw: [String]) throws {
        let arguments = try Arguments(raw)
        let root = arguments.buildRoot
        let schematic = OrboSpineSchematic.current

        print("ORBOSPINE HEPHAESTUS COMPLETION")

        let candidateURL = root.appendingPathComponent(candidateManifest)
        let candidate: CandidateManifest = try decode(candidateURL)
        let candidateSHA = try sha256(candidateURL)
        let declaredCandidateSHA = try declaredHash(root.appendingPathComponent(candidateHash))
        guard candidateSHA == declaredCandidateSHA,
              candidate.identity == schematic.identity,
              candidate.lifecycle == OrboSpineLifecycleBoundary.candidate.rawValue,
              candidate.astronomicalAuthority == schematic.astronomicalAuthority,
              candidate.astronomicalSourceVersion == schematic.astronomicalSourceVersion else {
            throw CompletionToolError.mismatch("candidate identity/binding drift")
        }
        print("PASS candidate: \(candidateSHA)")

        try verifyBoundFiles(candidate.files, root: root)
        print("PASS bound matter: \(candidate.files.count) / \(candidate.files.count) SHA-256")

        let testimonyURL = root.appendingPathComponent(testimonyFile)
        let testimonySHA = try sha256(testimonyURL)
        let declaredTestimonySHA = try declaredHash(root.appendingPathComponent(testimonyHashFile))
        guard testimonySHA == declaredTestimonySHA else {
            throw CompletionToolError.mismatch("Dioscuri testimony SHA-256 drift")
        }

        let testimony: DioscuriTestimonyArtifact = try decode(testimonyURL)
        guard testimony.authority == "Dioscuri",
              testimony.lifecycle == OrboSpineLifecycleBoundary.dioscuriCertified.rawValue,
              testimony.schematicIdentity == schematic.identity,
              testimony.schematicVersion == schematic.version,
              testimony.candidateManifestSHA256 == candidateSHA,
              testimony.result == "confirmed" else {
            throw CompletionToolError.mismatch("Dioscuri testimony is not exact confirmed evidence")
        }
        print("PASS Dioscuri testimony: \(testimonySHA)")

        let disposition = try HephaestusOrboSpineCompletion.complete(
            schematic: schematic,
            candidateIdentity: candidateSHA,
            testimonySchematicIdentity: testimony.schematicIdentity,
            testimonySchematicVersion: testimony.schematicVersion,
            testimonyCandidateIdentity: testimony.candidateManifestSHA256,
            testimonyResult: .confirmed
        )

        guard case let .sealed(seal) = disposition,
              seal.schematicIdentity == schematic.identity,
              seal.schematicVersion == schematic.version,
              seal.candidateIdentity == candidateSHA else {
            throw CompletionToolError.mismatch("Hephaestus did not seal the exact candidate")
        }

        let artifact = HephaestusSealArtifact(
            authority: "Hephaestus",
            lifecycle: OrboSpineLifecycleBoundary.hephaestusSealed.rawValue,
            schematicIdentity: seal.schematicIdentity,
            schematicVersion: seal.schematicVersion,
            candidateManifestSHA256: seal.candidateIdentity,
            dioscuriTestimonySHA256: testimonySHA
        )

        let sealURL = root.appendingPathComponent(sealFile)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(artifact).write(to: sealURL, options: .atomic)

        let sealSHA = try sha256(sealURL)
        try "\(sealSHA)  \(sealFile)\n".write(
            to: root.appendingPathComponent(sealHashFile),
            atomically: true,
            encoding: .utf8
        )

        print("HEPHAESTUS SEAL: COMPLETE")
        print("seal: \(sealURL.path)")
        print("seal SHA-256: \(sealSHA)")
        print("ORBOSPINE LIFECYCLE: HEPHAESTUS-SEALED")
    }

    private static func verifyBoundFiles(_ files: [CandidateFile], root: URL) throws {
        guard Set(files.map(\.path)).count == files.count else {
            throw CompletionToolError.mismatch("candidate repeats bound file path")
        }

        for file in files {
            let url = root.appendingPathComponent(file.path)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw CompletionToolError.missing(file.path)
            }
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let size = (attributes[.size] as? NSNumber)?.int64Value ?? -1
            guard size == file.bytes, try sha256(url) == file.sha256 else {
                throw CompletionToolError.mismatch("\(file.path) byte/hash drift")
            }
        }
    }

    private static func decode<T: Decodable>(_ url: URL) throws -> T {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CompletionToolError.missing(url.path)
        }
        do {
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        } catch {
            throw CompletionToolError.malformed("\(url.lastPathComponent): \(error)")
        }
    }

    private static func declaredHash(_ url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CompletionToolError.missing(url.path)
        }
        let text = try String(contentsOf: url, encoding: .utf8)
        guard let first = text.split(whereSeparator: \.isWhitespace).first else {
            throw CompletionToolError.malformed("empty hash file \(url.lastPathComponent)")
        }
        return String(first)
    }

    private static func sha256(_ url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CompletionToolError.missing(url.path)
        }
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
}

do {
    try Completion.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    FileHandle.standardError.write(Data("OrboSpineHephaestusCompletionTool error: \(error)\n".utf8))
    exit(EXIT_FAILURE)
}
