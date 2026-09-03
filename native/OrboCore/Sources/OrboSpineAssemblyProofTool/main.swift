import Foundation
import OrboCore

// The proof and the app now mount through the same transplanted reader.
// The original D5 harness is preserved in Obsolete/AssemblyProof.
do {
    let args = Array(CommandLine.arguments.dropFirst())
    guard args.count == 2, args[0] == "--build-root" else {
        throw NSError(domain: "OrboSpineAssemblyProofTool", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "usage: --build-root <orbospine-build>"])
    }
    let runtime = try OrboSpineRuntime.load(from: URL(fileURLWithPath: args[1]))
    let horae = Horae(locate: runtime.locate)
    _ = try horae.seek(to: runtime.bone.start)
    _ = try horae.seek(to: JulianDay((runtime.bone.start.value + runtime.bone.end.value) / 2)!)
    print("PASS sealed runtime: \(runtime.provenance.candidateManifestSHA256)")
    print("PASS inventory: \(runtime.inventory)")
} catch {
    FileHandle.standardError.write(Data("OrboSpineAssemblyProofTool: \(error)\n".utf8))
    exit(EXIT_FAILURE)
}
