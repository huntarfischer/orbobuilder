/// Hermes's read-only point of view over one recorded courier journey.
///
/// Hermes owns the manifest history. Homer receives only that existing typed
/// history and its current ticket state; this seam performs no endpoint-domain
/// work and does not infer what delivery meant to sender or recipient.
public struct HermesJourneyPOV: Hashable, Sendable {
    public let ticketID: HermesTicketID
    public let currentState: HermesTicketState
    public let events: [HermesManifestEvent]

    public init(
        ticketID: HermesTicketID,
        currentState: HermesTicketState,
        events: [HermesManifestEvent]
    ) {
        self.ticketID = ticketID
        self.currentState = currentState
        self.events = events
    }
}

public extension HermesCourier {
    func signalForHomer(
        ticketID: HermesTicketID
    ) -> HomerPort<HermesJourneyPOV>? {
        guard let currentState = manifest.currentState(for: ticketID) else {
            return nil
        }

        return HomerPort(
            pointOfView: HermesJourneyPOV(
                ticketID: ticketID,
                currentState: currentState,
                events: manifest.events(for: ticketID)
            )
        )
    }
}
