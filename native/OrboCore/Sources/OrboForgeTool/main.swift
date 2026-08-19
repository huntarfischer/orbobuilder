import Foundation
import OrboCore
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private typealias SweSetEphePath = @convention(c) (UnsafePointer<CChar>?) -> Void
private typealias SweCalcUT = @convention(c) (Double, Int32, Int32, UnsafeMutablePointer<Double>?, UnsafeMutablePointer<CChar>?) -> Int32
private typealias SweVersion = @convention(c) (UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>?

private enum OrboForgeToolError: Error, CustomStringConvertible {
    case missingArgument(String)
    case invalidSwissBody(MundaneBody)
    case swissLibrary(String)
    case swissSymbol(String)
    case swissCalculation(String)
    case quarantined(String)

    var description: String {
        switch self {
        case let .missingArgument(name): return "Missing required argument: \(name)"
        case let .invalidSwissBody(body): return "No Swiss Ephemeris body id for \(body.displayName)."
        case let .swissLibrary(message): return "Swiss Ephemeris library error: \(message)"
        case let .swissSymbol(name): return "Missing Swiss Ephemeris symbol: \(name)"
        case let .swissCalculation(message): return "Swiss Ephemeris calculation failed: \(message)"
        case let .quarantined(reason): return "Hephaestus quarantined P22: \(reason)"
        }
    }
}

private final class SwissEphemerisForgeReference: @unchecked Sendable, ForgeEphemerisReference {
    private let handle: UnsafeMutableRawPointer
    private let calculateUT: SweCalcUT
    let version: String

    private static let swissEphemerisFlag: Int32 = 2
    private static let moshierFlag: Int32 = 4
    private static let speedFlag: Int32 = 256

    init(libraryPath: String, ephemerisDirectory: String) throws {
        guard let opened = dlopen(libraryPath, RTLD_NOW | RTLD_LOCAL) else {
            let message = dlerror().map { String(cString: $0) } ?? "unknown dlopen failure"
            throw OrboForgeToolError.swissLibrary(message)
        }
        handle = opened

        func symbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let pointer = dlsym(opened, name) else { throw OrboForgeToolError.swissSymbol(name) }
            return unsafeBitCast(pointer, to: T.self)
        }

        let setPath: SweSetEphePath = try symbol("swe_set_ephe_path", as: SweSetEphePath.self)
        let calc: SweCalcUT = try symbol("swe_calc_ut", as: SweCalcUT.self)
        let versionFunction: SweVersion = try symbol("swe_version", as: SweVersion.self)
        ephemerisDirectory.withCString { setPath($0) }
        calculateUT = calc

        var buffer = [CChar](repeating: 0, count: 128)
        _ = buffer.withUnsafeMutableBufferPointer { versionFunction($0.baseAddress) }
        version = String(cString: buffer)
    }

    deinit { dlclose(handle) }

    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState {
        let swissBody: Int32
        switch body {
        case .sun: swissBody = 0
        case .moon: swissBody = 1
        case .mercury: swissBody = 2
        case .venus: swissBody = 3
        case .mars: swissBody = 4
        case .jupiter: swissBody = 5
        case .saturn: swissBody = 6
        case .uranus: swissBody = 7
        case .neptune: swissBody = 8
        case .pluto: swissBody = 9
        case .trueNorthNode: swissBody = 11
        }

        var values = [Double](repeating: 0, count: 6)
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let flags = Self.swissEphemerisFlag | Self.speedFlag
        let returned = values.withUnsafeMutableBufferPointer { output in
            errorBuffer.withUnsafeMutableBufferPointer { error in
                calculateUT(julianDay.value, swissBody, flags, output.baseAddress, error.baseAddress)
            }
        }

        guard returned >= 0,
              (returned & Self.swissEphemerisFlag) != 0,
              (returned & Self.moshierFlag) == 0,
              let state = MundaneForgeState(
                longitudeDegrees: values[0],
                longitudinalSpeedDegreesPerDay: values[3]
              ) else {
            throw OrboForgeToolError.swissCalculation(String(cString: errorBuffer))
        }
        return state
    }
}

private struct LiveForgeArguments {
    let libraryPath: String
    let ephemerisDirectory: String

    init(_ raw: [String]) throws {
        let values = try Self.keyValues(raw)
        guard let library = values["--library"], !library.isEmpty else {
            throw OrboForgeToolError.missingArgument("--library")
        }
        guard let ephemeris = values["--ephe-dir"], !ephemeris.isEmpty else {
            throw OrboForgeToolError.missingArgument("--ephe-dir")
        }
        libraryPath = library
        ephemerisDirectory = ephemeris
    }

    static func keyValues(_ raw: [String]) throws -> [String: String] {
        var values: [String: String] = [:]
        var index = 0
        while index < raw.count {
            let key = raw[index]
            guard key.hasPrefix("--"), index + 1 < raw.count else {
                throw OrboForgeToolError.missingArgument(key)
            }
            values[key] = raw[index + 1]
            index += 2
        }
        return values
    }
}

private struct P22CompletionArguments {
    let dataDirectory: URL
    let outputDirectory: URL

    init(_ raw: [String]) throws {
        let values = try LiveForgeArguments.keyValues(raw)
        guard let data = values["--data-dir"], !data.isEmpty else {
            throw OrboForgeToolError.missingArgument("--data-dir")
        }
        guard let output = values["--output-dir"], !output.isEmpty else {
            throw OrboForgeToolError.missingArgument("--output-dir")
        }
        dataDirectory = URL(fileURLWithPath: data, isDirectory: true)
        outputDirectory = URL(fileURLWithPath: output, isDirectory: true)
    }
}

private struct P22CandidateArguments {
    let candidateURL: URL
    let outputDirectory: URL

    init(_ raw: [String]) throws {
        let values = try LiveForgeArguments.keyValues(raw)
        guard let candidate = values["--candidate"], !candidate.isEmpty else {
            throw OrboForgeToolError.missingArgument("--candidate")
        }
        guard let output = values["--output-dir"], !output.isEmpty else {
            throw OrboForgeToolError.missingArgument("--output-dir")
        }
        candidateURL = URL(fileURLWithPath: candidate)
        outputDirectory = URL(fileURLWithPath: output, isDirectory: true)
    }
}

private struct P22ResumeArguments {
    let candidateURL: URL
    let checkpointURL: URL
    let outputDirectory: URL

    init(_ raw: [String]) throws {
        let values = try LiveForgeArguments.keyValues(raw)
        guard let candidate = values["--candidate"], !candidate.isEmpty else {
            throw OrboForgeToolError.missingArgument("--candidate")
        }
        guard let checkpoint = values["--checkpoint"], !checkpoint.isEmpty else {
            throw OrboForgeToolError.missingArgument("--checkpoint")
        }
        guard let output = values["--output-dir"], !output.isEmpty else {
            throw OrboForgeToolError.missingArgument("--output-dir")
        }
        candidateURL = URL(fileURLWithPath: candidate)
        checkpointURL = URL(fileURLWithPath: checkpoint)
        outputDirectory = URL(fileURLWithPath: output, isDirectory: true)
    }
}

private struct CandidateReport: Codable {
    let candidateSHA256: String
    let artifactBytes: Int
    let recipeIdentifier: String
    let recipeVersion: UInt16
    let resonanceContract: String
    let spanName: String
    let astronomicalSource: String
    let astronomicalSourceVersion: String
    let storageFamily: String
    let storageVersion: UInt16
    let bodyCount: Int
    let bodyOccurrenceCount: Int
    let stationCount: Int
    let retrogradePassageCount: Int
    let relationshipCount: Int
    let eclipseCount: Int

    init(_ candidate: TimespineCandidate) {
        let record = candidate.forgeRecord
        candidateSHA256 = candidate.identity.sha256
        artifactBytes = candidate.artifactData.count
        recipeIdentifier = record.recipeIdentifier
        recipeVersion = record.recipeVersion
        resonanceContract = record.resonanceContract.description
        spanName = record.spanName
        astronomicalSource = record.astronomicalSource
        astronomicalSourceVersion = record.astronomicalSourceVersion
        storageFamily = record.storageFamily
        storageVersion = record.storageVersion
        bodyCount = record.bodyCount
        bodyOccurrenceCount = record.bodyOccurrenceCount
        stationCount = record.stationCount
        retrogradePassageCount = record.retrogradePassageCount
        relationshipCount = record.relationshipCount
        eclipseCount = record.eclipseCount
    }
}

private struct ScopeTallyReport: Codable {
    let scope: String
    let questions: Int
    let resonant: Int
    let quantizedCoincidences: Int
    let divergent: Int

    init(_ value: DioscuriScopeTally) {
        scope = value.scope.rawValue
        questions = value.questions
        resonant = value.resonant
        quantizedCoincidences = value.quantizedCoincidences
        divergent = value.divergent
    }
}

private struct CertificateReport: Codable {
    let candidateSHA256: String
    let evidenceSHA256: String
    let dioscuriContractVersion: UInt16
    let totalQuestions: Int
    let quantizedCoincidences: Int
    let tallies: [ScopeTallyReport]

    init(testimony: DioscuriTestimony, certificate: DioscuriCertificate) {
        candidateSHA256 = testimony.candidateSHA256
        evidenceSHA256 = testimony.evidenceSHA256
        dioscuriContractVersion = testimony.dioscuriContractVersion
        totalQuestions = certificate.totalQuestions
        quantizedCoincidences = certificate.quantizedCoincidences
        tallies = certificate.scopeTallies.map(ScopeTallyReport.init)
    }
}

private struct DivergenceReport: Codable {
    let scope: String
    let kind: String
    let civicOffsetSeconds: Int64
    let subject: String
    let expected: String
    let firstObserved: String
    let secondObserved: String
    let deterministic: Bool

    init(_ value: DioscuriDivergence) {
        scope = value.scope.rawValue
        kind = value.kind.rawValue
        civicOffsetSeconds = value.civicOffsetSeconds
        subject = value.subject
        expected = value.expected
        firstObserved = value.firstObserved
        secondObserved = value.secondObserved
        deterministic = value.deterministic
    }
}

private struct QuarantineReport: Codable {
    let reason: String
    let candidateSHA256: String
    let evidenceSHA256: String
    let confirmedDivergences: Int
    let nondeterministicDivergences: Int
    let tallies: [ScopeTallyReport]
    let divergences: [DivergenceReport]

    init(reason: HephaestusQuarantineReason, testimony: DioscuriTestimony, report: DioscuriRejectionReport) {
        self.reason = reason.rawValue
        candidateSHA256 = testimony.candidateSHA256
        evidenceSHA256 = testimony.evidenceSHA256
        confirmedDivergences = report.confirmedDivergenceCount
        nondeterministicDivergences = report.nondeterministicCount
        tallies = report.scopeTallies.map(ScopeTallyReport.init)
        divergences = report.divergences.map(DivergenceReport.init)
    }
}

private struct OrboForgeTool {
    static func main() throws {
        let raw = Array(CommandLine.arguments.dropFirst())
        switch raw.first {
        case "p22-complete":
            try completeP22(Array(raw.dropFirst()))
        case "p22-certify":
            try certifyPreservedP22(Array(raw.dropFirst()))
        case "p22-resume":
            try resumeP22(Array(raw.dropFirst()))
        default:
            try runLiveP22Forge(raw)
        }
    }

    private static func completeP22(_ raw: [String]) throws {
        let arguments = try P22CompletionArguments(raw)
        try prepare(arguments.outputDirectory)

        print("ORBO FORGE / P22 CANONICAL COMPLETION")
        print("manufacturing authority: Hephaestus")
        print("resonance authority: Dioscuri")
        print("recipe: \(MundaneTimespineP22ForgeRecipe.recipeIdentifier) v\(MundaneTimespineP22ForgeRecipe.recipeVersion)")
        print("source: \(MundaneTimespineP22CanonicalInputs.astronomicalSource)")
        print("source version: \(MundaneTimespineP22CanonicalInputs.astronomicalSourceVersion)")
        print("assembly astronomy: none / canonical persisted matter only")

        let assembler = P22CanonicalAssembler(dataDirectory: arguments.dataDirectory)
        let image = try assembler.assemble { update in
            print("assembly \(update.stage): \(update.detail)")
        }

        print("assembly: rich storage image complete")
        let candidate = try Hephaestus.manufactureCandidate(
            recipe: MundaneTimespineP22ForgeRecipe.self,
            assembledStorageImage: image
        )

        let candidateURL = arguments.outputDirectory.appendingPathComponent("p22-candidate.orbots")
        try candidate.artifactData.write(to: candidateURL, options: .atomic)
        try writeJSON(CandidateReport(candidate), to: arguments.outputDirectory.appendingPathComponent("p22-candidate.json"))
        printCandidate(candidate, url: candidateURL, rehydrated: false)

        let checkpointURL = arguments.outputDirectory.appendingPathComponent("p22-dioscuri-checkpoint.json")
        try certifyAndComplete(
            candidate: candidate,
            candidateURL: candidateURL,
            outputDirectory: arguments.outputDirectory,
            checkpointURL: checkpointURL,
            resumingFrom: nil
        )
    }

    private static func certifyPreservedP22(_ raw: [String]) throws {
        let arguments = try P22CandidateArguments(raw)
        try prepare(arguments.outputDirectory)
        let candidate = try loadP22Candidate(arguments.candidateURL)
        try writeJSON(CandidateReport(candidate), to: arguments.outputDirectory.appendingPathComponent("p22-candidate.json"))

        print("ORBO FORGE / P22 PRESERVED CANDIDATE CERTIFICATION")
        print("assembly: skipped")
        print("manufacture: skipped")
        printCandidate(candidate, url: arguments.candidateURL, rehydrated: true)

        let checkpointURL = arguments.outputDirectory.appendingPathComponent("p22-dioscuri-checkpoint.json")
        try certifyAndComplete(
            candidate: candidate,
            candidateURL: arguments.candidateURL,
            outputDirectory: arguments.outputDirectory,
            checkpointURL: checkpointURL,
            resumingFrom: nil
        )
    }

    private static func resumeP22(_ raw: [String]) throws {
        let arguments = try P22ResumeArguments(raw)
        try prepare(arguments.outputDirectory)
        let candidate = try loadP22Candidate(arguments.candidateURL)
        let checkpoint: DioscuriCertificationCheckpoint = try readJSON(
            DioscuriCertificationCheckpoint.self,
            from: arguments.checkpointURL
        )
        try writeJSON(CandidateReport(candidate), to: arguments.outputDirectory.appendingPathComponent("p22-candidate.json"))

        print("ORBO FORGE / P22 DIOSCURI RESUME")
        print("assembly: skipped")
        print("manufacture: skipped")
        printCandidate(candidate, url: arguments.candidateURL, rehydrated: true)
        print("checkpoint loaded: \(arguments.checkpointURL.path)")
        printCheckpoint(checkpoint, prefix: "checkpoint resume")

        try certifyAndComplete(
            candidate: candidate,
            candidateURL: arguments.candidateURL,
            outputDirectory: arguments.outputDirectory,
            checkpointURL: arguments.checkpointURL,
            resumingFrom: checkpoint
        )
    }

    private static func certifyAndComplete(
        candidate: TimespineCandidate,
        candidateURL: URL,
        outputDirectory: URL,
        checkpointURL: URL,
        resumingFrom checkpoint: DioscuriCertificationCheckpoint?
    ) throws {
        print(checkpoint == nil
            ? "Dioscuri: exhaustive resonance begins"
            : "Dioscuri: exhaustive resonance resumes from durable checkpoint")
        print("checkpoint law: \(Dioscuri.checkpointLaw)")
        print("checkpoint cadence: every \(Dioscuri.checkpointQuestionCadence) questions + phase ends + second strikes")

        let testimony = try Dioscuri.testify(
            candidate: candidate,
            resumingFrom: checkpoint,
            progress: printProgress,
            checkpointHandler: { value in
                try writeJSON(value, to: checkpointURL)
                printCheckpoint(value, prefix: "checkpoint saved")
            }
        )
        print("Dioscuri result: \(testimony.result.rawValue)")
        print("Dioscuri evidence SHA-256: \(testimony.evidenceSHA256)")

        let disposition = Hephaestus.complete(candidate: candidate, testimony: testimony)
        switch disposition {
        case let .sealed(sealed):
            guard case let .certificate(certificate) = testimony.evidence else {
                throw OrboForgeToolError.quarantined("resonant testimony did not contain a certificate")
            }
            try writeJSON(
                CertificateReport(testimony: testimony, certificate: certificate),
                to: outputDirectory.appendingPathComponent("p22-dioscuri-certificate.json")
            )
            try writeJSON(
                sealed.seal,
                to: outputDirectory.appendingPathComponent("p22-seal.json")
            )
            print("Hephaestus disposition: SEALED")
            print("seal SHA-256: \(sealed.seal.sealSHA256)")
            print("artifact unchanged: \(sealed.candidate.identity.sha256 == candidate.identity.sha256 ? "yes" : "NO")")
            print("completed checkpoint retained: \(checkpointURL.path)")

        case let .quarantined(quarantine):
            if case let .rejection(report) = testimony.evidence {
                try writeJSON(
                    QuarantineReport(
                        reason: quarantine.reason,
                        testimony: testimony,
                        report: report
                    ),
                    to: outputDirectory.appendingPathComponent("p22-quarantine.json")
                )
            }
            print("Hephaestus disposition: QUARANTINED")
            print("candidate remains unchanged at: \(candidateURL.path)")
            print("completed checkpoint retained: \(checkpointURL.path)")
            throw OrboForgeToolError.quarantined(quarantine.reason.rawValue)
        }
    }

    private static func loadP22Candidate(_ url: URL) throws -> TimespineCandidate {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        return try Hephaestus.rehydrateCandidate(
            recipe: MundaneTimespineP22ForgeRecipe.self,
            artifactData: data
        )
    }

    private static func printCandidate(
        _ candidate: TimespineCandidate,
        url: URL,
        rehydrated: Bool
    ) {
        print("candidate custody: \(rehydrated ? "rehydrated exact artifact" : "new immutable candidate")")
        print("candidate SHA-256: \(candidate.identity.sha256)")
        print("candidate bytes: \(candidate.artifactData.count)")
        print("candidate preserved: \(url.path)")
    }

    private static func printProgress(_ update: DioscuriCertificationProgress) {
        switch update.activity {
        case .phaseProgress:
            print("resonance \(update.phase.rawValue): \(update.completed)/\(update.total)")
        case .secondStrikeStarted:
            print(
                "resonance SECOND STRIKE START \(update.phase.rawValue) "
                + "question \(update.completed)/\(update.total): \(update.detail ?? "divergence")"
            )
        case .secondStrikeCompleted:
            print(
                "resonance SECOND STRIKE END \(update.phase.rawValue) "
                + "question \(update.completed)/\(update.total): \(update.detail ?? "complete")"
            )
        }
    }

    private static func printCheckpoint(
        _ checkpoint: DioscuriCertificationCheckpoint,
        prefix: String
    ) {
        let value = checkpoint.completed
        print(
            "\(prefix): body \(value.bodyOccurrence) / motion \(value.motionTopology) / "
            + "station \(value.station) / relationships \(value.exactRelationship) / eclipse \(value.eclipse)"
        )
    }

    private static func runLiveP22Forge(_ raw: [String]) throws {
        let arguments = try LiveForgeArguments(raw)
        let reference = try SwissEphemerisForgeReference(
            libraryPath: arguments.libraryPath,
            ephemerisDirectory: arguments.ephemerisDirectory
        )

        let contract = MundaneTimespineP22ForgeRecipe.artifactContract

        print("ORBO FORGE / LIVE P22 REFORGE")
        print("manufacturing authority: Hephaestus")
        print("apparatus: MundaneTimespineForge / native Swift")
        print("span: \(MundaneTimespineP22.spanName)")
        print("recipe: \(MundaneTimespineP22ForgeRecipe.recipeIdentifier) v\(MundaneTimespineP22ForgeRecipe.recipeVersion)")
        print("Swiss Ephemeris: \(reference.version)")
        print("body clocks: \(MundaneBody.canonicalOrder.count)")
        print("manufacturing law: celestial coordinate occurrence <-> civic UT")

        let product = try MundaneTimespineP22ForgeRecipe.manufacture(
            astronomicalSourceVersion: reference.version,
            reference: reference
        )

        print("forged occurrences: \(product.totalOccurrenceCount)")
        print("stations: \(product.totalStationCount)")
        print("retrograde passages: \(product.totalRetrogradePassageCount)")
        print("candidate requires relationships: \(contract.relationshipCount)")
        print("candidate requires eclipses: \(contract.eclipseCount)")
        print("status: live body reforge complete; canonical full assembly uses p22-complete")
    }

    private static func prepare(_ directory: URL) throws {
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private static func readJSON<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
}

do {
    try OrboForgeTool.main()
} catch {
    let message = "OrboForgeTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
