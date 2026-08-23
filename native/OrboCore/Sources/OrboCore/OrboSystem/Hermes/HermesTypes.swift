import Foundation

public struct HermesTicketID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(_ rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }
}

public struct HermesParcelID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(_ rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }
}

public struct HermesPackageID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(_ rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }
}

public struct HermesSubjectID: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

public struct HermesAddress: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

public struct HermesParcelKind: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

public struct HermesPackageKind: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

public struct HermesTicket: Hashable, Codable, Sendable {
    public let ticketID: HermesTicketID
    public let subjectID: HermesSubjectID
    public let serviceDestination: HermesAddress
    public let finalAddressee: HermesAddress
    public let expectedReturnKind: HermesParcelKind

    public init?(
        ticketID: HermesTicketID,
        subjectID: HermesSubjectID,
        serviceDestination: HermesAddress,
        finalAddressee: HermesAddress,
        expectedReturnKind: HermesParcelKind
    ) {
        guard serviceDestination != finalAddressee else { return nil }

        self.ticketID = ticketID
        self.subjectID = subjectID
        self.serviceDestination = serviceDestination
        self.finalAddressee = finalAddressee
        self.expectedReturnKind = expectedReturnKind
    }
}

public struct HermesExpectation: Hashable, Codable, Sendable {
    public let ticketID: HermesTicketID
    public let subjectID: HermesSubjectID
    public let expectedFrom: HermesAddress
    public let expectedReturnKind: HermesParcelKind
    public let finalAddressee: HermesAddress

    public init(ticket: HermesTicket) {
        self.ticketID = ticket.ticketID
        self.subjectID = ticket.subjectID
        self.expectedFrom = ticket.serviceDestination
        self.expectedReturnKind = ticket.expectedReturnKind
        self.finalAddressee = ticket.finalAddressee
    }
}

public struct HermesParcel<Payload: Hashable & Sendable>: Hashable, Sendable {
    public let parcelID: HermesParcelID
    public let ticketID: HermesTicketID
    public let subjectID: HermesSubjectID
    public let sender: HermesAddress
    public let kind: HermesParcelKind
    public let finalAddressee: HermesAddress
    public let payload: Payload

    public init(
        parcelID: HermesParcelID,
        ticketID: HermesTicketID,
        subjectID: HermesSubjectID,
        sender: HermesAddress,
        kind: HermesParcelKind,
        finalAddressee: HermesAddress,
        payload: Payload
    ) {
        self.parcelID = parcelID
        self.ticketID = ticketID
        self.subjectID = subjectID
        self.sender = sender
        self.kind = kind
        self.finalAddressee = finalAddressee
        self.payload = payload
    }
}

extension HermesParcel: Codable where Payload: Codable {}

public struct HermesPackage<Contents: Hashable & Sendable>: Hashable, Sendable {
    public let packageID: HermesPackageID
    public let subjectID: HermesSubjectID
    public let sender: HermesAddress
    public let kind: HermesPackageKind
    public let addresses: [HermesAddress]
    public let contents: Contents

    public init?(
        packageID: HermesPackageID,
        subjectID: HermesSubjectID,
        sender: HermesAddress,
        kind: HermesPackageKind,
        addresses: [HermesAddress],
        contents: Contents
    ) {
        guard !addresses.isEmpty else { return nil }

        self.packageID = packageID
        self.subjectID = subjectID
        self.sender = sender
        self.kind = kind
        self.addresses = addresses
        self.contents = contents
    }
}

extension HermesPackage: Codable where Contents: Codable {}

public struct HermesReceipt: Hashable, Codable, Sendable {
    public let ticketID: HermesTicketID
    public let parcelID: HermesParcelID
    public let recipient: HermesAddress
    public let receivedAt: AbsoluteInstant

    public init(
        ticketID: HermesTicketID,
        parcelID: HermesParcelID,
        recipient: HermesAddress,
        receivedAt: AbsoluteInstant
    ) {
        self.ticketID = ticketID
        self.parcelID = parcelID
        self.recipient = recipient
        self.receivedAt = receivedAt
    }
}

public enum HermesManifestEventKind: String, Hashable, Codable, Sendable {
    case ticketOpened
    case deliveredToService
    case serviceReturnAccepted
    case deliveredToStop
    case recoveredFromStop
    case deliveredToAddressee
    case receiptRecorded
    case resolved
}

public struct HermesManifestEvent: Hashable, Codable, Sendable {
    public let ticketID: HermesTicketID
    public let sequence: Int
    public let kind: HermesManifestEventKind
    public let occurredAt: AbsoluteInstant
    public let parcelID: HermesParcelID?
    public let packageID: HermesPackageID?
    public let address: HermesAddress?

    public init?(
        ticketID: HermesTicketID,
        sequence: Int,
        kind: HermesManifestEventKind,
        occurredAt: AbsoluteInstant,
        parcelID: HermesParcelID? = nil,
        packageID: HermesPackageID? = nil,
        address: HermesAddress? = nil
    ) {
        guard sequence > 0 else { return nil }

        self.ticketID = ticketID
        self.sequence = sequence
        self.kind = kind
        self.occurredAt = occurredAt
        self.parcelID = parcelID
        self.packageID = packageID
        self.address = address
    }
}
