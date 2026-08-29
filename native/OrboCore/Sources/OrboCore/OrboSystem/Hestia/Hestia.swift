public struct HearthLitNotice: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let hearthLit: Bool

    public init(subjectID: HermesSubjectID) {
        self.subjectID = subjectID
        self.hearthLit = true
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

    /// Persistence restores the already-kept house directly. Admission is not
    /// replayed and no astrological correspondence is rechecked.
    internal init(
        restoringHoldings holdings: Holdings,
        hearth: Hearth,
        hall: Hall
    ) {
        self.holdings = holdings
        self.hearth = hearth
        self.hall = hall
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
        guard hearth.engraving == nil else {
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
    /// interested system actor.
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

    /// Admits one already-sealed non-native Tapestry to the Hall. Hestia trusts
    /// Atropos's seal and enforces only house placement and identity boundaries.
    mutating func admit(
        subjectID: HermesSubjectID,
        astroDNA: AstroDNA,
        tapestry: AtroposTapestryPackage
    ) throws {
        guard subjectID != nativeSubjectID else {
            throw Failure.nativeAlreadyEstablished
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

    public func holding(_ subjectID: HermesSubjectID) -> Holding? {
        holdings.holding(for: subjectID)
    }

    public func saved(_ subjectID: HermesSubjectID) -> HallResident? {
        hall.resident(for: subjectID)
    }
}
