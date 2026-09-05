import Foundation

public extension Lachesis {
    /// Conducts the Natal Spine Titan pass against one native and one Clotho life domain.
    /// The three tables remain separate. Rhea receives the temporal facts already
    /// established by Themis and Oceanus rather than performing another time sweep.
    static func petitionNatalSpine<Port: NatalSpineTimespinePort>(
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        through port: Port
    ) throws -> (
        themis: NatalSpineThemisTable,
        oceanus: NatalSpineOceanusTable,
        rhea: NatalSpineRheaTable
    ) {
        let themisStart = ProcessInfo.processInfo.systemUptime
        FileHandle.standardOutput.write(Data("ORBO_NATAL_STAGE START moirai-themis\n".utf8))
        let themis = try Themis.traceNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )
        let themisElapsed = String(
            format: "%.3f",
            ProcessInfo.processInfo.systemUptime - themisStart
        )
        FileHandle.standardOutput.write(Data(
            "ORBO_NATAL_STAGE END moirai-themis elapsed=\(themisElapsed)s output=\(themis.spans.count)\n".utf8
        ))

        let oceanusStart = ProcessInfo.processInfo.systemUptime
        FileHandle.standardOutput.write(Data("ORBO_NATAL_STAGE START moirai-oceanus\n".utf8))
        let oceanus = try Oceanus.traceNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )
        let oceanusElapsed = String(
            format: "%.3f",
            ProcessInfo.processInfo.systemUptime - oceanusStart
        )
        FileHandle.standardOutput.write(Data(
            "ORBO_NATAL_STAGE END moirai-oceanus elapsed=\(oceanusElapsed)s output=\(oceanus.realizations.count)\n".utf8
        ))

        let rheaStart = ProcessInfo.processInfo.systemUptime
        FileHandle.standardOutput.write(Data("ORBO_NATAL_STAGE START moirai-rhea\n".utf8))
        let rhea = try Rhea.qualifyNatalSpine(
            native: truth,
            bounds: bounds,
            themis: themis,
            oceanus: oceanus,
            through: port
        )
        let rheaElapsed = String(
            format: "%.3f",
            ProcessInfo.processInfo.systemUptime - rheaStart
        )
        FileHandle.standardOutput.write(Data(
            "ORBO_NATAL_STAGE END moirai-rhea elapsed=\(rheaElapsed)s output=\(rhea.qualifications.count)\n".utf8
        ))

        return (themis, oceanus, rhea)
    }
}
