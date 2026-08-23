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

public enum HestiaDeliveryDisposition: Hashable, Sendable {
    case hearth(HermesReceipt)
    case hall(HermesReceipt)
    case rejected(HermesReceipt, HestiaCorrection)

    public var receipt: HermesReceipt {
        switch self {
        case let .hearth(receipt), let .hall(receipt), let .rejected(receipt, _):
            return receipt
        }
    }
}

public struct Hestia: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case nativeAlreadyEstablished
        case savedSubjectAlreadyAdmitted
    }

    public private(set) var hearth: Hearth
    public private(set) var hall: Hall

    public var nativeSubjectID: HermesSubjectID {
        hearth.nativeSubjectID
    }

    public init(nativeSubjectID: HermesSubjectID) {
        self.hearth = Hearth(nativeSubjectID: nativeSubjectID)
        self.hall = Hall()
    }

    /// Receives a completed Moirai delivery and immediately chooses its disposition.
    /// The receipt records Hermes delivery in every case. Hestia either hangs the
    /// tapestry in Hearth or Hall, or rejects it with corrective provenance.
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
                receipt,
                HestiaCorrection(
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

        return parcel.subjectID == nativeSubjectID
            ? .hearth(receipt)
            : .hall(receipt)
    }

    /// Stage-3 placement seam. Stage 4 enters through `receive`.
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

    public func saved(_ subjectID: HermesSubjectID) -> HallResident? {
        hall.resident(for: subjectID)
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
