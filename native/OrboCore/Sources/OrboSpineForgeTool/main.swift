import Foundation

do {
    try OrboSpineDurableCelestialForge.run(Array(CommandLine.arguments.dropFirst()))
} catch {
    let message = "OrboSpineForgeTool error: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(EXIT_FAILURE)
}
