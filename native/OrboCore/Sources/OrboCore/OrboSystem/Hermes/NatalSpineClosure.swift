public struct NatalSpineAvailability: Hashable, Sendable {
    public let ticketID: HermesTicketID
    public let packageID: HermesPackageID
    public let subjectID: HermesSubjectID
    public let bounds: NatalSpineBounds

    fileprivate init(
        ticketID: HermesTicketID,
        packageID: HermesPackageID,
        subjectID: HermesSubjectID,
        bounds: NatalSpineBounds
    ) {
        self.ticketID = ticketID
        self.packageID = packageID
        self.subjectID = subjectID
        self.bounds = bounds
    }
}

public extension HermesCourier {
    /// ACT III Beat 5. Hecate's blessing authorizes Hermes to record the final
    /// receipt on the original commission. The courier's existing journey law
    /// proves package identity and final destination, then resolves that same
    /// ticket exactly once. The returned announcement contains no Spine matter.
    mutating func closeNatalSpineCommission(
        ticketID: HermesTicketID,
        blessing: NatalSpineHecateBlessing,
        receivedAt: AbsoluteInstant
    ) throws -> NatalSpineAvailability {
        try recordReceipt(
            ticketID: ticketID,
            packageID: blessing.packageID,
            recipient: NatalSpineCommission.hecateAddress,
            receivedAt: receivedAt
        )

        return NatalSpineAvailability(
            ticketID: ticketID,
            packageID: blessing.packageID,
            subjectID: blessing.subjectID,
            bounds: blessing.bounds
        )
    }
}
