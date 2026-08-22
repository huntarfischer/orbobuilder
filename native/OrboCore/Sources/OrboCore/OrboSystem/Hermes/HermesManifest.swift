public enum HermesTicketState: String, Hashable, Codable, Sendable {
    case unresolved
    case resolved
}

public struct HermesManifest: Sendable {
    private var journal: [HermesManifestEvent] = []

    public init() {}

    @discardableResult
    public mutating func append(_ event: HermesManifestEvent) -> Bool {
        let priorEvents = events(for: event.ticketID)
        let expectedSequence = (priorEvents.last?.sequence ?? 0) + 1
        guard event.sequence == expectedSequence else { return false }

        journal.append(event)
        return true
    }

    public func events(for ticketID: HermesTicketID) -> [HermesManifestEvent] {
        journal.filter { $0.ticketID == ticketID }
    }

    public func currentState(for ticketID: HermesTicketID) -> HermesTicketState? {
        let ticketEvents = events(for: ticketID)
        guard !ticketEvents.isEmpty else { return nil }

        return ticketEvents.contains { $0.kind == .resolved }
            ? .resolved
            : .unresolved
    }

    public func unresolvedTickets() -> [HermesTicketID] {
        var seen: Set<HermesTicketID> = []
        var orderedTicketIDs: [HermesTicketID] = []

        for event in journal where seen.insert(event.ticketID).inserted {
            orderedTicketIDs.append(event.ticketID)
        }

        return orderedTicketIDs.filter { currentState(for: $0) == .unresolved }
    }
}
