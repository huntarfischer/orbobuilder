import Foundation

public enum MoiraiNatalSpineFailure: Error, Hashable, Sendable {
    case unexpectedPackage
}

public extension Moirai {
    /// Fulfills the Moirai stop of the one Natal Spine commission.
    /// Clotho alone touches the parent Timespine, then Lachesis allots the bounded Threads.
    static func processNatalSpineSchematics<Source: NatalSpineTimespineSource>(
        _ package: HermesPackage<NatalSpineSchematicsRequest>,
        hearth hestia: Hestia,
        through source: Source
    ) throws -> HermesPackage<AtroposNatalSpineSchematicsPackage> {
        guard package.kind == NatalSpineCommission.packageKind,
              package.addresses == NatalSpineCommission.itinerary,
              package.subjectID == package.contents.subjectID else {
            throw MoiraiNatalSpineFailure.unexpectedPackage
        }

        let truth = try hestia.natalSpineNativeTruth(for: package.subjectID)
        let bounds = try Clotho.boundNatalSpine(truth)
        let threads = try Clotho.gatherNatalSpineThreads(
            native: truth,
            bounds: bounds,
            from: source
        )
        let tables = try Lachesis.petitionNatalSpine(
            native: truth,
            threads: threads
        )

        let atroposStart = ProcessInfo.processInfo.systemUptime
        FileHandle.standardOutput.write(Data("ORBO_NATAL_STAGE START moirai-atropos\n".utf8))
        let certified = try Atropos.inspectNatalSpineSchematics(
            threads: threads,
            themis: tables.themis,
            oceanus: tables.oceanus,
            rhea: tables.rhea
        ).get()
        let atroposElapsed = String(
            format: "%.3f",
            ProcessInfo.processInfo.systemUptime - atroposStart
        )
        FileHandle.standardOutput.write(Data(
            "ORBO_NATAL_STAGE END moirai-atropos elapsed=\(atroposElapsed)s\n".utf8
        ))

        return HermesPackage(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            kind: package.kind,
            addresses: package.addresses,
            contents: certified
        )!
    }
}
