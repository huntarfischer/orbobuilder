import Foundation

public struct NatalSpineManufactureResult: Sendable {
    public let runtime: NatalSpineRuntime
    public let receipt: NatalSpineArtifactReceipt
    public let availability: NatalSpineAvailability

    public init(
        runtime: NatalSpineRuntime,
        receipt: NatalSpineArtifactReceipt,
        availability: NatalSpineAvailability
    ) {
        self.runtime = runtime
        self.receipt = receipt
        self.availability = availability
    }
}

private enum NatalSpineManufactureDiagnostics {
    static func begin(_ stage: String, inputCount: Int? = nil) -> TimeInterval {
        var message = "START \(stage)"
        if let inputCount {
            message += " input=\(inputCount)"
        }
        log(message)
        return ProcessInfo.processInfo.systemUptime
    }

    static func end(
        _ stage: String,
        since start: TimeInterval,
        outputCount: Int? = nil
    ) {
        var message = String(
            format: "END %@ elapsed=%.3fs",
            stage,
            ProcessInfo.processInfo.systemUptime - start
        )
        if let outputCount {
            message += " output=\(outputCount)"
        }
        log(message)
    }

    private static func log(_ message: String) {
        FileHandle.standardOutput.write(Data("ORBO_NATAL_STAGE \(message)\n".utf8))
    }
}

public extension Orbo {
    /// Runs the one lawful commission from the lit Hearth through all owners,
    /// writes the finished binary body, remounts it, and closes the same ticket.
    /// This is a one-time manufacture path, never a launch-time fallback.
    func manufactureNatalSpine(
        for subjectID: HermesSubjectID,
        from hearth: Hestia,
        parent: OrboSpineRuntime,
        via courier: inout HermesCourier,
        artifactURL: URL,
        receiptURL: URL,
        occurredAt: AbsoluteInstant,
        packageID: HermesPackageID = HermesPackageID()
    ) throws -> NatalSpineManufactureResult {
        let handle = try commissionNatalSpine(
            subjectID: subjectID,
            via: &courier,
            occurredAt: occurredAt,
            packageID: packageID
        )

        let moiraiAddress = try courier.deliverNext(
            ticketID: handle.ticketID,
            occurredAt: manufactureInstant(occurredAt, offset: 1)
        )
        guard moiraiAddress == NatalSpineCommission.moiraiAddress else {
            throw NatalSpineManufactureFailure.routeDivergence
        }
        let moiraiStart = NatalSpineManufactureDiagnostics.begin("moirai-certification")
        let certified = try Moirai.processNatalSpineSchematics(
            handle.package,
            hearth: hearth,
            through: parent
        )
        NatalSpineManufactureDiagnostics.end(
            "moirai-certification",
            since: moiraiStart,
            outputCount: certified.contents.themis.spans.count
                + certified.contents.oceanus.realizations.count
                + certified.contents.rhea.qualifications.count
        )
        try courier.recover(
            ticketID: handle.ticketID,
            package: certified,
            occurredAt: manufactureInstant(occurredAt, offset: 2)
        )

        let hephaestusAddress = try courier.deliverNext(
            ticketID: handle.ticketID,
            occurredAt: manufactureInstant(occurredAt, offset: 3)
        )
        guard hephaestusAddress == NatalSpineCommission.hephaestusAddress else {
            throw NatalSpineManufactureFailure.routeDivergence
        }
        let commission = try Hephaestus.receiveNatalSpineSchematics(certified)

        let substrateStart = NatalSpineManufactureDiagnostics.begin("hephaestus-substrate")
        let substrate = try Hephaestus.forgeNatalSpineSubstrate(
            for: commission,
            from: parent
        )
        NatalSpineManufactureDiagnostics.end(
            "hephaestus-substrate",
            since: substrateStart,
            outputCount: substrate.supports.count + substrate.stations.count + substrate.boundaryAnchors.count
        )

        let themisStart = NatalSpineManufactureDiagnostics.begin(
            "hephaestus-themis",
            inputCount: commission.schematics.themis.spans.count
        )
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )
        NatalSpineManufactureDiagnostics.end(
            "hephaestus-themis",
            since: themisStart,
            outputCount: themis.themis.count
        )

        let oceanusStart = NatalSpineManufactureDiagnostics.begin(
            "hephaestus-oceanus",
            inputCount: commission.schematics.oceanus.realizations.count
        )
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        NatalSpineManufactureDiagnostics.end(
            "hephaestus-oceanus",
            since: oceanusStart,
            outputCount: oceanus.oceanus.count
        )

        let rheaStart = NatalSpineManufactureDiagnostics.begin(
            "hephaestus-rhea",
            inputCount: commission.schematics.rhea.qualifications.count
        )
        let rhea = try Hephaestus.forgeNatalSpineRhea(on: oceanus)
        NatalSpineManufactureDiagnostics.end(
            "hephaestus-rhea",
            since: rheaStart,
            outputCount: rhea.rhea.count
        )

        let addressabilityStart = NatalSpineManufactureDiagnostics.begin("hephaestus-addressability")
        let candidate = try Hephaestus.forgeNatalSpineAddressability(on: rhea)
        NatalSpineManufactureDiagnostics.end(
            "hephaestus-addressability",
            since: addressabilityStart
        )

        let verificationStart = NatalSpineManufactureDiagnostics.begin("dioscuri-verification")
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: certified.contents,
            parent: parent
        ).get()
        NatalSpineManufactureDiagnostics.end(
            "dioscuri-verification",
            since: verificationStart
        )

        let sealStart = NatalSpineManufactureDiagnostics.begin("hephaestus-seal")
        let sealed = Hephaestus.sealNatalSpine(approval)
        NatalSpineManufactureDiagnostics.end("hephaestus-seal", since: sealStart)

        let artifactStart = NatalSpineManufactureDiagnostics.begin("artifact-write")
        let receipt = try Hephaestus.forgeNatalSpineArtifact(
            sealed,
            to: artifactURL
        )
        try receipt.write(to: receiptURL)
        NatalSpineManufactureDiagnostics.end("artifact-write", since: artifactStart)

        let mountStart = NatalSpineManufactureDiagnostics.begin("artifact-mount")
        let mounted = try NatalSpineRuntime.mount(
            from: artifactURL,
            expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: parent.provenance.spineIdentity
        )
        NatalSpineManufactureDiagnostics.end("artifact-mount", since: mountStart)

        let finishedPackage = Hephaestus.releaseNatalSpine(sealed)
        try courier.recover(
            ticketID: handle.ticketID,
            package: finishedPackage,
            occurredAt: manufactureInstant(occurredAt, offset: 4)
        )

        let horaeAddress = try courier.deliverNext(
            ticketID: handle.ticketID,
            occurredAt: manufactureInstant(occurredAt, offset: 5)
        )
        let installed = try Horae.receiveNatalSpine(
            finishedPackage,
            deliveredTo: horaeAddress
        )
        _ = try Horae.locateNatalSpine(installed, at: installed.bounds.natal.julianDay)
        _ = try Horae.locateNatalSpine(mounted, at: mounted.bounds.natal.julianDay)
        try courier.recover(
            ticketID: handle.ticketID,
            package: finishedPackage,
            occurredAt: manufactureInstant(occurredAt, offset: 6)
        )

        guard try courier.deliverNext(
            ticketID: handle.ticketID,
            occurredAt: manufactureInstant(occurredAt, offset: 7)
        ) == NatalSpineCommission.chronosAddress else {
            throw NatalSpineManufactureFailure.routeDivergence
        }
        let index = Chronos.indexNatalSpine(installed)
        _ = Chronos.indexNatalSpine(mounted)
        try courier.recover(
            ticketID: handle.ticketID,
            package: finishedPackage,
            occurredAt: manufactureInstant(occurredAt, offset: 8)
        )

        guard try courier.deliverNext(
            ticketID: handle.ticketID,
            occurredAt: manufactureInstant(occurredAt, offset: 9)
        ) == NatalSpineCommission.hecateAddress else {
            throw NatalSpineManufactureFailure.routeDivergence
        }
        let blessing = try Hecate.blessNatalSpine(installed, indexedBy: index)
        let availability = try courier.closeNatalSpineCommission(
            ticketID: handle.ticketID,
            blessing: blessing,
            receivedAt: manufactureInstant(occurredAt, offset: 10)
        )
        return NatalSpineManufactureResult(
            runtime: mounted,
            receipt: receipt,
            availability: availability
        )
    }

    private func manufactureInstant(
        _ start: AbsoluteInstant,
        offset: Int
    ) -> AbsoluteInstant {
        AbsoluteInstant(
            unixSecondsSince1970: start.unixSecondsSince1970 + Double(offset)
        )!
    }
}

public enum NatalSpineManufactureFailure: Error, Hashable, Sendable {
    case routeDivergence
}
