public extension Moirai {
    /// The existing Moirai entrance dispatches the delivered Synchronic
    /// request to Clotho, then hands her Pattern and Bone to Lachesis.
    /// Hermes remains awaiting recovery here until Act I certification.
    static func prepareSynchronicSpine(
        _ commission: SynchronicSpineCommissionHandle,
        hearth: Hestia,
        parent: OrboSpineRuntime,
        courier: HermesCourier
    ) throws -> SynchronicSpineFoundation {
        let events = courier.manifest.events(for: commission.ticketID)
        guard courier.manifest.currentState(for: commission.ticketID) == .unresolved,
              events.count == 2,
              events.first?.kind == .ticketOpened,
              events.last?.kind == .deliveredToStop,
              events.last?.address == SynchronicSpineCommission.moiraiAddress,
              events.allSatisfy({ $0.packageID == commission.package.packageID }) else {
            throw SynchronicSpinePassAFailure.commissionNotDeliveredToClotho
        }
        let foundation = try Clotho.cutSynchronicSpineFoundation(
            commission: commission, hearth: hearth, parent: parent
        )
        return try Lachesis.receiveSynchronicSpineFoundation(foundation)
    }
}
