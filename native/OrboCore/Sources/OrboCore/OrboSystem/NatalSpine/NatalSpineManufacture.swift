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
        let certified = try Moirai.processNatalSpineSchematics(
            handle.package,
            hearth: hearth,
            through: parent
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
        let substrate = try Hephaestus.forgeNatalSpineSubstrate(
            for: commission,
            from: parent
        )
        let themis = try Hephaestus.forgeNatalSpineThemis(
            for: commission,
            on: substrate
        )
        let oceanus = try Hephaestus.forgeNatalSpineOceanus(on: themis)
        let rhea = try Hephaestus.forgeNatalSpineRhea(on: oceanus)
        let candidate = try Hephaestus.forgeNatalSpineAddressability(on: rhea)
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: certified.contents,
            parent: parent
        ).get()
        let sealed = Hephaestus.sealNatalSpine(approval)

        let receipt = try Hephaestus.forgeNatalSpineArtifact(
            sealed,
            to: artifactURL
        )
        try receipt.write(to: receiptURL)
        let mounted = try NatalSpineRuntime.mount(
            from: artifactURL,
            expectedSHA256: receipt.sha256,
            expectedParentSpineIdentity: parent.provenance.spineIdentity
        )

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
