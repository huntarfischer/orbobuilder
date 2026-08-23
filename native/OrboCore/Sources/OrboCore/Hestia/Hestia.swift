public struct HestiaCorrection: Hashable, Sendable {
    public let originalTicketID: HermesTicketID
    public let originalParcelID: HermesParcelID
    public let subjectID: HermesSubjectID
    public let astroDNA: AstroDNA
    public let rejectedTapestry: AtroposPackage
    public let serviceDestination: HermesAddress
    public let finalAddressee: HermesAddress

    public init(
        originalTicketID: HermesTicketID,
        originalParcelID: HermesParcelID,
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA,
        rejectedTapestry: AtroposPackage,
        serviceDestination: HermesAddress,
        finalAddressee: HermesAddress
    ) {
        self.originalTicketID = originalTicketID
        self.originalParcelID = originalParcelID
        self.subjectID = subjectID
        self.astroDNA = astroDNA
        self.rejectedTapestry = rejectedTapestry
        self.serviceDestination = serviceDestination
        self.finalAddressee = finalAddressee
    }
}

public enum HestiaDestination: Hashable, Sendable {
    case holdings
    case hearth
    case hall
}

public enum HestiaDeliveryDisposition: Hashable, Sendable {
    case accepted(destination: HestiaDestination, receipt: HermesReceipt)
    case rejected(receipt: HermesReceipt, correction: HestiaCorrection)

    public var receipt: HermesReceipt {
        switch self {
        case let .accepted(_, receipt), let .rejected(receipt, _):
            return receipt
        }
    }
}

public struct Hestia: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case nativeAlreadyEstablished
        case savedSubjectAlreadyAdmitted
        case nativeCannotEnterHoldings
        case subjectAlreadyInHoldings
    }

    private(set) var holdings: Holdings
    private(set) var hearth: Hearth
    private(set) var hall: Hall

    public var nativeSubjectID: HermesSubjectID {
        hearth.nativeSubjectID
    }

    public init(nativeSubjectID: HermesSubjectID) {
        self.holdings = Holdings()
        self.hearth = Hearth(nativeSubjectID: nativeSubjectID)
        self.hall = Hall()
    }

    /// Receives a completed Moirai delivery and immediately chooses its disposition.
    /// A finished Tapestry can enter Hearth or Hall. Lighter retained deliveries
    /// enter Holdings through Hestia's holding seam. Rejection is a Handback to Hermes.
    public mutating func receive(
        _ parcel: HermesParcel<AtroposPackage>,
        astroDNA: AstroDNA,
        receivedAt: AbsoluteInstant
    ) throws -> HestiaDeliveryDisposition {
        let receipt = HermesReceipt(
            ticketID: parcel.ticketID,
            parcelID: parcel.parcelID,
            recipient: parcel.finalAddressee,
            receivedAt: receivedAt
        )

        guard Self.tapestry(parcel.payload, matches: astroDNA) else {
            return .rejected(
                receipt: receipt,
                correction: HestiaCorrection(
                    originalTicketID: parcel.ticketID,
                    originalParcelID: parcel.parcelID,
                    subjectID: parcel.subjectID,
                    astroDNA: astroDNA,
                    rejectedTapestry: parcel.payload,
                    serviceDestination: parcel.sender,
                    finalAddressee: parcel.finalAddressee
                )
            )
        }

        try admit(
            subjectID: parcel.subjectID,
            astroDNA: astroDNA,
            tapestry: parcel.payload
        )

        return .accepted(
            destination: parcel.subjectID == nativeSubjectID ? .hearth : .hall,
            receipt: receipt
        )
    }

    /// Keeps a lightweight saved subject in Holdings.
    public mutating func hold(
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA
    ) throws {
        guard subjectID != nativeSubjectID else {
            throw Failure.nativeCannotEnterHoldings
        }
        guard holdings.holding(for: subjectID) == nil else {
            throw Failure.subjectAlreadyInHoldings
        }
        guard hall.resident(for: subjectID) == nil else {
            throw Failure.savedSubjectAlreadyAdmitted
        }

        try holdings.admit(
            Holding(
                subjectID: subjectID,
                astroDNA: astroDNA
            )
        )
    }

    /// Stage-3 placement seam. Finished Tapestries enter Hearth or Hall through Hestia.
    mutating func admit(
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA,
        tapestry: AtroposPackage
    ) throws {
        if subjectID == nativeSubjectID {
            guard hearth.resident == nil else {
                throw Failure.nativeAlreadyEstablished
            }

            try hearth.establish(
                HearthResident(
                    subjectID: subjectID,
                    astroDNA: astroDNA,
                    tapestry: tapestry
                )
            )
            return
        }

        guard holdings.holding(for: subjectID) == nil else {
            throw Failure.subjectAlreadyInHoldings
        }
        guard hall.resident(for: subjectID) == nil else {
            throw Failure.savedSubjectAlreadyAdmitted
        }

        try hall.admit(
            HallResident(
                subjectID: subjectID,
                astroDNA: astroDNA,
                tapestry: tapestry
            )
        )
    }

    public func native() -> HearthResident? {
        hearth.resident
    }

    public func holding(_ subjectID: HermesSubjectID) -> Holding? {
        holdings.holding(for: subjectID)
    }

    public func saved(_ subjectID: HermesSubjectID) -> HallResident? {
        hall.resident(for: subjectID)
    }

    /// Hestia is the query surface for the Tapestries she keeps.
    public func tapestry(for subjectID: HermesSubjectID) -> AtroposPackage? {
        if subjectID == nativeSubjectID {
            return hearth.resident?.tapestry
        }
        return hall.resident(for: subjectID)?.tapestry
    }

    private static func tapestry(
        _ tapestry: AtroposPackage,
        matches astroDNA: AstroDNA
    ) -> Bool {
        let threads = tapestry.grid.cells.flatMap(\.threads)
        guard threads.count == AstroDNA.geneCount else { return false }

        var seen: Set<AstroDNAGene> = []
        for thread in threads {
            guard seen.insert(thread.gene).inserted else { return false }
            guard thread.exactState == astroDNA[thread.gene] else { return false }
        }

        return seen.count == AstroDNA.geneCount
    }
}
