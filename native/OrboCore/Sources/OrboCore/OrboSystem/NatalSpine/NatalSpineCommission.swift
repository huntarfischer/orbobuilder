public struct NatalSpineSchematicsRequest: Hashable, Sendable {
    public let subjectID: HermesSubjectID

    public init(subjectID: HermesSubjectID) {
        self.subjectID = subjectID
    }
}

public struct NatalSpineCommissionHandle: Hashable, Sendable {
    public let package: HermesPackage<NatalSpineSchematicsRequest>
    public let ticketID: HermesTicketID

    public init(
        package: HermesPackage<NatalSpineSchematicsRequest>,
        ticketID: HermesTicketID
    ) {
        self.package = package
        self.ticketID = ticketID
    }
}

public enum NatalSpineCommission {
    public static let packageKind = HermesPackageKind(rawValue: "orbo.natal-spine-schematics.v1")!

    public static let moiraiAddress = HermesAddress(rawValue: "orbo.moirai")!
    public static let hephaestusAddress = HermesAddress(rawValue: "orbo.hephaestus")!
    public static let horaeAddress = HermesAddress(rawValue: "orbo.horae")!
    public static let chronosAddress = HermesAddress(rawValue: "orbo.chronos")!
    public static let hecateAddress = HermesAddress(rawValue: "orbo.hecate")!

    public static let itinerary = [
        moiraiAddress,
        hephaestusAddress,
        horaeAddress,
        chronosAddress,
        hecateAddress,
    ]

    public static func package(
        subjectID: HermesSubjectID,
        packageID: HermesPackageID = HermesPackageID()
    ) -> HermesPackage<NatalSpineSchematicsRequest> {
        HermesPackage(
            packageID: packageID,
            subjectID: subjectID,
            sender: OrboOnboarding.orboAddress,
            kind: packageKind,
            addresses: itinerary,
            contents: NatalSpineSchematicsRequest(subjectID: subjectID)
        )!
    }
}

public enum OrboNatalSpineCommissionFailure: Error, Hashable, Sendable {
    case nativeTruthUnavailable
    case alreadyCommissioned
}

public extension Orbo {
    /// Opens the single Natal Spine commission only after Hestia has made native truth ready.
    /// Orbo authors the request; Hermes owns the manifest and custody truth from acceptance onward.
    func commissionNatalSpine(
        subjectID: HermesSubjectID,
        via courier: inout HermesCourier,
        occurredAt: AbsoluteInstant,
        packageID: HermesPackageID = HermesPackageID()
    ) throws -> NatalSpineCommissionHandle {
        guard backOfHouse == .nativeReady else {
            throw OrboNatalSpineCommissionFailure.nativeTruthUnavailable
        }

        let package = NatalSpineCommission.package(
            subjectID: subjectID,
            packageID: packageID
        )

        let ticketID: HermesTicketID
        do {
            ticketID = try courier.accept(package: package, occurredAt: occurredAt)
        } catch HermesCourier.Failure.packageAlreadyAccepted {
            throw OrboNatalSpineCommissionFailure.alreadyCommissioned
        }

        return NatalSpineCommissionHandle(package: package, ticketID: ticketID)
    }
}
