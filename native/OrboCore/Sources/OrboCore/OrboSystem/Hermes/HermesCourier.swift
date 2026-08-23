public struct HermesCourier: Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case packageAlreadyAccepted
        case unknownTicket
        case packageMismatch
        case subjectMismatch
        case senderMismatch
        case itineraryMismatch
        case addressMismatch
        case invalidState
        case manifestRejectedEvent
    }

    private enum Phase: Sendable {
        case inCustody
        case awaitingRecovery(Int)
        case awaitingReceipt
        case resolved
    }

    private struct Journey: Sendable {
        let packageID: HermesPackageID
        let subjectID: HermesSubjectID
        let sender: HermesAddress
        let addresses: [HermesAddress]
        var nextAddressIndex: Int
        var phase: Phase
    }

    public private(set) var manifest: HermesManifest

    private var journeys: [HermesTicketID: Journey]
    private var packageTickets: [HermesPackageID: HermesTicketID]

    public init(manifest: HermesManifest = HermesManifest()) {
        self.manifest = manifest
        self.journeys = [:]
        self.packageTickets = [:]
    }

    /// Accepts custody of a package that has already been created and addressed by the caller.
    /// Hermes opens the manifest ticket; he does not author the package or its itinerary.
    @discardableResult
    public mutating func accept<Contents: Hashable & Sendable>(
        package: HermesPackage<Contents>,
        occurredAt: AbsoluteInstant
    ) throws -> HermesTicketID {
        guard packageTickets[package.packageID] == nil else {
            throw Failure.packageAlreadyAccepted
        }

        let ticketID = HermesTicketID()
        try append(
            ticketID: ticketID,
            kind: .ticketOpened,
            occurredAt: occurredAt,
            packageID: package.packageID
        )

        journeys[ticketID] = Journey(
            packageID: package.packageID,
            subjectID: package.subjectID,
            sender: package.sender,
            addresses: package.addresses,
            nextAddressIndex: 0,
            phase: .inCustody
        )
        packageTickets[package.packageID] = ticketID
        return ticketID
    }

    /// Delivers the package to the next printed address. Hermes chooses no destination.
    /// Intermediate addresses require recovery before the journey may continue.
    @discardableResult
    public mutating func deliverNext(
        ticketID: HermesTicketID,
        occurredAt: AbsoluteInstant
    ) throws -> HermesAddress {
        guard var journey = journeys[ticketID] else { throw Failure.unknownTicket }
        guard case .inCustody = journey.phase else { throw Failure.invalidState }
        guard journey.nextAddressIndex < journey.addresses.count else {
            throw Failure.invalidState
        }

        let index = journey.nextAddressIndex
        let address = journey.addresses[index]
        let isFinal = index == journey.addresses.count - 1

        try append(
            ticketID: ticketID,
            kind: isFinal ? .deliveredToAddressee : .deliveredToStop,
            occurredAt: occurredAt,
            packageID: journey.packageID,
            address: address
        )

        journey.phase = isFinal ? .awaitingReceipt : .awaitingRecovery(index)
        journeys[ticketID] = journey
        return address
    }

    /// Recovers the same entrusted package after an intermediate stop.
    /// Contents may have changed; package identity, subject, sender, and itinerary may not.
    public mutating func recover<Contents: Hashable & Sendable>(
        ticketID: HermesTicketID,
        package: HermesPackage<Contents>,
        occurredAt: AbsoluteInstant
    ) throws {
        guard var journey = journeys[ticketID] else { throw Failure.unknownTicket }
        guard case let .awaitingRecovery(deliveredIndex) = journey.phase else {
            throw Failure.invalidState
        }

        guard package.packageID == journey.packageID else { throw Failure.packageMismatch }
        guard package.subjectID == journey.subjectID else { throw Failure.subjectMismatch }
        guard package.sender == journey.sender else { throw Failure.senderMismatch }
        guard package.addresses == journey.addresses else { throw Failure.itineraryMismatch }

        let address = journey.addresses[deliveredIndex]
        try append(
            ticketID: ticketID,
            kind: .recoveredFromStop,
            occurredAt: occurredAt,
            packageID: journey.packageID,
            address: address
        )

        journey.nextAddressIndex = deliveredIndex + 1
        journey.phase = .inCustody
        journeys[ticketID] = journey
    }

    /// Records final acceptance of the package. Only the final printed address can resolve it.
    public mutating func recordReceipt(
        ticketID: HermesTicketID,
        packageID: HermesPackageID,
        recipient: HermesAddress,
        receivedAt: AbsoluteInstant
    ) throws {
        guard var journey = journeys[ticketID] else { throw Failure.unknownTicket }
        guard case .awaitingReceipt = journey.phase else { throw Failure.invalidState }
        guard packageID == journey.packageID else { throw Failure.packageMismatch }
        guard recipient == journey.addresses.last else { throw Failure.addressMismatch }

        try append(
            ticketID: ticketID,
            kind: .receiptRecorded,
            occurredAt: receivedAt,
            packageID: journey.packageID,
            address: recipient
        )
        try append(
            ticketID: ticketID,
            kind: .resolved,
            occurredAt: receivedAt,
            packageID: journey.packageID,
            address: recipient
        )

        journey.phase = .resolved
        journeys[ticketID] = journey
    }

    private mutating func append(
        ticketID: HermesTicketID,
        kind: HermesManifestEventKind,
        occurredAt: AbsoluteInstant,
        packageID: HermesPackageID,
        address: HermesAddress? = nil
    ) throws {
        let sequence = manifest.events(for: ticketID).count + 1
        guard let event = HermesManifestEvent(
            ticketID: ticketID,
            sequence: sequence,
            kind: kind,
            occurredAt: occurredAt,
            packageID: packageID,
            address: address
        ), manifest.append(event) else {
            throw Failure.manifestRejectedEvent
        }
    }
}
