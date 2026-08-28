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

public struct HearthLitNotice: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let hearthLit: Bool

    public init(subjectID: HermesSubjectID) {
        self.subjectID = subjectID
        self.hearthLit = true
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
        case unexpectedEngravingPackage
        case engravingSubjectMismatch
        case missingTopos
        case missingTempus
        case missingAstroDNA
        case missingAtroposSeal
        case engravingAlreadyComplete
        case hearthUnlit
    }

    public static let address = OrboOnboarding.engravingItinerary[2]
    public static let hearthLitNoticeKind = HermesPackageKind(rawValue: "orbo.hearth-lit.v1")!

    private(set) var holdings: Holdings
    private(set) var hearth: Hearth
    private(set) var hall: Hall

    public var nativeSubjectID: HermesSubjectID {
        hearth.nativeSubjectID
    }

    public var hearthLit: Bool {
        hearth.hearthLit
    }

    public init(nativeSubjectID: HermesSubjectID) {
        self.holdings = Holdings()
        self.hearth = Hearth(nativeSubjectID: nativeSubjectID)
        self.hall = Hall()
    }

    /// Receives the canonical traveling Engraving package at the final stop.
    /// Hestia verifies package completeness and admission law only. Atropos's
    /// sealed Tapestry is trusted and never recalculated or reinspected here.
    @discardableResult
    public mutating func receive(
        _ package: HermesPackage<Engraving>
    ) throws -> Engraving {
        guard package.sender == OrboOnboarding.orboAddress,
              package.kind == OrboOnboarding.engravingPackageKind,
              package.addresses == OrboOnboarding.engravingItinerary,
              package.addresses.last == Self.address else {
            throw Failure.unexpectedEngravingPackage
        }

        let engraving = package.contents
        guard package.subjectID == engraving.subjectID,
              engraving.subjectID == nativeSubjectID else {
            throw Failure.engravingSubjectMismatch
        }
        guard engraving.topos != nil else { throw Failure.missingTopos }
        guard engraving.tempus != nil else { throw Failure.missingTempus }
        guard engraving.astroDNA != nil else { throw Failure.missingAstroDNA }
        guard engraving.tapestry != nil else { throw Failure.missingAtroposSeal }
        guard !engraving.engraved else { throw Failure.engravingAlreadyComplete }
        guard hearth.resident == nil, hearth.engraving == nil else {
            throw Failure.nativeAlreadyEstablished
        }

        return try hearth.hang(engraving)
    }

    /// Native kept truth is unavailable until the Hearth has been lit.
    public func nativeEngraving() -> Engraving? {
        guard hearthLit else { return nil }
        return hearth.engraving
    }

    /// Canonical native Tapestry query. The Hearth gate applies before lookup.
    public func canonicalTapestry(for subjectID: HermesSubjectID) -> AtroposTapestryPackage? {
        guard subjectID == nativeSubjectID else { return nil }
        return nativeEngraving()?.tapestry
    }

    /// Once the Hearth is lit, Hestia may send Hermes with the news to any
    /// interested system actor. Pass 9B uses this path to notify Orbo.
    public func sendHearthLitNotice(
        to recipient: HermesAddress,
        via courier: inout HermesCourier,
        occurredAt: AbsoluteInstant,
        packageID: HermesPackageID = HermesPackageID()
    ) throws -> (package: HermesPackage<HearthLitNotice>, ticketID: HermesTicketID) {
        guard hearthLit, hearth.engraving != nil else {
            throw Failure.hearthUnlit
        }

        let notice = HearthLitNotice(subjectID: nativeSubjectID)
        let package = HermesPackage(
            packageID: packageID,
            subjectID: nativeSubjectID,
            sender: Self.address,
            kind: Self.hearthLitNoticeKind,
            addresses: [recipient],
            contents: notice
        )!
        let ticketID = try courier.accept(package: package, occurredAt: occurredAt)
        return (package, ticketID)
    }

    /// Legacy Messenger receipt path retained through Pass 9B for codec-1 and
    /// historical tests. Canonical onboarding uses receive(HermesPackage<Engraving>).
    public mutating func receive(
        _ parcel: HermesParcel<MoiraiPackage>,
        receivedAt: AbsoluteInstant
    ) throws -> HestiaDeliveryDisposition {
        let receipt = HermesReceipt(
            ticketID: parcel.ticketID,
            parcelID: parcel.parcelID,
            recipient: parcel.finalAddressee,
            receivedAt: receivedAt
        )
        let astroDNA = parcel.payload.astroDNA
        let tapestry = parcel.payload.tapestry

        guard Self.tapestry(tapestry, matches: astroDNA) else {
            return .rejected(
                receipt: receipt,
                correction: HestiaCorrection(
                    originalTicketID: parcel.ticketID,
                    originalParcelID: parcel.parcelID,
                    subjectID: parcel.subjectID,
                    astroDNA: astroDNA,
                    rejectedTapestry: tapestry,
                    serviceDestination: parcel.sender,
                    finalAddressee: parcel.finalAddressee
                )
            )
        }

        try admit(
            subjectID: parcel.subjectID,
            astroDNA: astroDNA,
            tapestry: tapestry
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

    /// Legacy finished Tapestries enter Hearth or Hall through Hestia.
    mutating func admit(
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA,
        tapestry: AtroposPackage
    ) throws {
        if subjectID == nativeSubjectID {
            guard hearth.resident == nil, hearth.engraving == nil else {
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

    /// Legacy query surface retained through Pass 9B for downstream callers.
    public func tapestry(for subjectID: HermesSubjectID) -> AtroposPackage? {
        if subjectID == nativeSubjectID {
            return hearth.resident?.tapestry
        }
        return hall.resident(for: subjectID)?.tapestry
    }

    /// Legacy grid correspondence check retained only for codec-1 and the old
    /// Messenger path. Canonical Hestia receipt never invokes this function.
    static func tapestry(
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
