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

private struct HestiaCustody: Hashable, Sendable {
    let parcel: HermesParcel<AtroposPackage>
    let astroDNA: AstroDNA
}

public struct Hestia: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case nativeAlreadyEstablished
        case savedSubjectAlreadyAdmitted
        case parcelAlreadyReceived
        case parcelNotInCustody
        case tapestryDoesNotMatchAstroDNA
    }

    public private(set) var hearth: Hearth
    public private(set) var hall: Hall
    private var custody: [HestiaCustody]

    public var nativeSubjectID: HermesSubjectID {
        hearth.nativeSubjectID
    }

    public init(nativeSubjectID: HermesSubjectID) {
        self.hearth = Hearth(nativeSubjectID: nativeSubjectID)
        self.hall = Hall()
        self.custody = []
    }

    /// Accepts custody of a parcel Hermes has delivered to Hestia.
    /// Receipt means custody only. It does not mean the tapestry has been admitted.
    public mutating func receive(
        _ parcel: HermesParcel<AtroposPackage>,
        astroDNA: AstroDNA,
        receivedAt: AbsoluteInstant
    ) throws -> HermesReceipt {
        guard !custody.contains(where: { $0.parcel.parcelID == parcel.parcelID }) else {
            throw Failure.parcelAlreadyReceived
        }

        custody.append(
            HestiaCustody(
                parcel: parcel,
                astroDNA: astroDNA
            )
        )

        return HermesReceipt(
            ticketID: parcel.ticketID,
            parcelID: parcel.parcelID,
            recipient: parcel.finalAddressee,
            receivedAt: receivedAt
        )
    }

    /// Admits a parcel already held in Hestia's custody.
    /// Hestia compares the finished weave to the canonical AstroDNA she received
    /// with the commission, then places the resident in Hearth or Hall.
    public mutating func admit(parcelID: HermesParcelID) throws {
        guard let index = custody.firstIndex(where: { $0.parcel.parcelID == parcelID }) else {
            throw Failure.parcelNotInCustody
        }

        let held = custody[index]
        guard Self.tapestry(held.parcel.payload, matches: held.astroDNA) else {
            throw Failure.tapestryDoesNotMatchAstroDNA
        }

        try admit(
            subjectID: held.parcel.subjectID,
            astroDNA: held.astroDNA,
            tapestry: held.parcel.payload
        )
        custody.remove(at: index)
    }

    /// Refuses residence while preserving the exact source and rejected work
    /// required to commission a corrective Hermes journey back to the service.
    public mutating func reject(parcelID: HermesParcelID) throws -> HestiaCorrection {
        guard let index = custody.firstIndex(where: { $0.parcel.parcelID == parcelID }) else {
            throw Failure.parcelNotInCustody
        }

        let held = custody.remove(at: index)
        return HestiaCorrection(
            originalTicketID: held.parcel.ticketID,
            originalParcelID: held.parcel.parcelID,
            subjectID: held.parcel.subjectID,
            astroDNA: held.astroDNA,
            rejectedTapestry: held.parcel.payload,
            serviceDestination: held.parcel.sender,
            finalAddressee: held.parcel.finalAddressee
        )
    }

    /// Stage-3 placement seam. External admission should enter through custody.
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
