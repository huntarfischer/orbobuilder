public struct HermesMessenger: Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case invalidRoute
        case unknownTicket
        case ticketMismatch
        case subjectMismatch
        case senderMismatch
        case parcelKindMismatch
        case finalAddresseeMismatch
        case invalidState
        case manifestRejectedEvent
    }

    public private(set) var manifest: HermesManifest

    private let registry: HermesMessengerRouteRegistry
    private var tickets: [HermesTicketID: HermesTicket]
    private var acceptedReturnParcels: [HermesTicketID: HermesParcelID]

    public init(
        registry: HermesMessengerRouteRegistry = HermesMessengerRouteRegistry(),
        manifest: HermesManifest = HermesManifest()
    ) {
        self.registry = registry
        self.manifest = manifest
        self.tickets = [:]
        self.acceptedReturnParcels = [:]
    }

    public mutating func accept<Payload: Hashable & Sendable>(
        ticket: HermesTicket,
        parcel: HermesParcel<Payload>,
        occurredAt: AbsoluteInstant
    ) throws {
        guard parcel.ticketID == ticket.ticketID else { throw Failure.ticketMismatch }
        guard parcel.subjectID == ticket.subjectID else { throw Failure.subjectMismatch }
        guard parcel.finalAddressee == ticket.finalAddressee else {
            throw Failure.finalAddresseeMismatch
        }
        guard registry.contract(
            for: ticket.serviceDestination,
            accepting: parcel.kind,
            returning: ticket.expectedReturnKind
        ) != nil else {
            throw Failure.invalidRoute
        }
        guard manifest.currentState(for: ticket.ticketID) == nil else {
            throw Failure.invalidState
        }

        try append(
            ticketID: ticket.ticketID,
            kind: .ticketOpened,
            occurredAt: occurredAt,
            parcelID: parcel.parcelID
        )
        tickets[ticket.ticketID] = ticket
    }

    public mutating func deliverToService(
        ticketID: HermesTicketID,
        occurredAt: AbsoluteInstant
    ) throws {
        guard tickets[ticketID] != nil else { throw Failure.unknownTicket }
        guard manifest.events(for: ticketID).last?.kind == .ticketOpened else {
            throw Failure.invalidState
        }

        try append(
            ticketID: ticketID,
            kind: .deliveredToService,
            occurredAt: occurredAt
        )
    }

    public mutating func acceptReturn<Payload: Hashable & Sendable>(
        parcel: HermesParcel<Payload>,
        occurredAt: AbsoluteInstant
    ) throws {
        guard let ticket = tickets[parcel.ticketID] else { throw Failure.unknownTicket }
        guard manifest.events(for: ticket.ticketID).last?.kind == .deliveredToService else {
            throw Failure.invalidState
        }

        let expectation = HermesExpectation(ticket: ticket)
        guard parcel.ticketID == expectation.ticketID else { throw Failure.ticketMismatch }
        guard parcel.subjectID == expectation.subjectID else { throw Failure.subjectMismatch }
        guard parcel.sender == expectation.expectedFrom else { throw Failure.senderMismatch }
        guard parcel.kind == expectation.expectedReturnKind else {
            throw Failure.parcelKindMismatch
        }
        guard parcel.finalAddressee == expectation.finalAddressee else {
            throw Failure.finalAddresseeMismatch
        }

        try append(
            ticketID: ticket.ticketID,
            kind: .serviceReturnAccepted,
            occurredAt: occurredAt,
            parcelID: parcel.parcelID
        )
        acceptedReturnParcels[ticket.ticketID] = parcel.parcelID
    }

    public mutating func deliverToFinalAddressee<Payload: Hashable & Sendable>(
        parcel: HermesParcel<Payload>,
        occurredAt: AbsoluteInstant
    ) throws {
        guard let ticket = tickets[parcel.ticketID] else { throw Failure.unknownTicket }
        guard acceptedReturnParcels[ticket.ticketID] == parcel.parcelID,
              manifest.events(for: ticket.ticketID).last?.kind == .serviceReturnAccepted else {
            throw Failure.invalidState
        }

        let expectation = HermesExpectation(ticket: ticket)
        guard parcel.subjectID == expectation.subjectID else { throw Failure.subjectMismatch }
        guard parcel.sender == expectation.expectedFrom else { throw Failure.senderMismatch }
        guard parcel.kind == expectation.expectedReturnKind else {
            throw Failure.parcelKindMismatch
        }
        guard parcel.finalAddressee == expectation.finalAddressee else {
            throw Failure.finalAddresseeMismatch
        }
        guard registry.finalAddressee(expectation.finalAddressee, accepts: parcel.kind) else {
            throw Failure.invalidRoute
        }

        try append(
            ticketID: ticket.ticketID,
            kind: .deliveredToAddressee,
            occurredAt: occurredAt,
            parcelID: parcel.parcelID
        )
    }

    public mutating func recordReceipt(_ receipt: HermesReceipt) throws {
        guard let ticket = tickets[receipt.ticketID] else { throw Failure.unknownTicket }
        guard acceptedReturnParcels[ticket.ticketID] == receipt.parcelID,
              manifest.events(for: ticket.ticketID).last?.kind == .deliveredToAddressee else {
            throw Failure.invalidState
        }
        guard receipt.recipient == ticket.finalAddressee else {
            throw Failure.finalAddresseeMismatch
        }

        try append(
            ticketID: ticket.ticketID,
            kind: .receiptRecorded,
            occurredAt: receipt.receivedAt,
            parcelID: receipt.parcelID
        )
        try append(
            ticketID: ticket.ticketID,
            kind: .resolved,
            occurredAt: receipt.receivedAt,
            parcelID: receipt.parcelID
        )
    }

    private mutating func append(
        ticketID: HermesTicketID,
        kind: HermesManifestEventKind,
        occurredAt: AbsoluteInstant,
        parcelID: HermesParcelID? = nil
    ) throws {
        let sequence = manifest.events(for: ticketID).count + 1
        guard let event = HermesManifestEvent(
            ticketID: ticketID,
            sequence: sequence,
            kind: kind,
            occurredAt: occurredAt,
            parcelID: parcelID
        ), manifest.append(event) else {
            throw Failure.manifestRejectedEvent
        }
    }
}
