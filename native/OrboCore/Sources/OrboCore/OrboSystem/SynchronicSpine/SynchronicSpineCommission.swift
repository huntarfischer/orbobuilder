public struct SynchronicSpineSchematicsRequest: Hashable, Sendable {
    public let subjectID: HermesSubjectID

    public init(subjectID: HermesSubjectID) {
        self.subjectID = subjectID
    }
}

public struct SynchronicSpineCommissionHandle: Hashable, Sendable {
    public let package: HermesPackage<SynchronicSpineSchematicsRequest>
    public let ticketID: HermesTicketID
}

public enum SynchronicSpineCommission {
    public static let packageKind = HermesPackageKind(rawValue: "orbo.synchronic-spine-schematics.v1")!
    // Clotho receives the request inside the existing Moirai stop.
    public static let moiraiAddress = NatalSpineCommission.moiraiAddress
    public static let hephaestusAddress = NatalSpineCommission.hephaestusAddress
    public static let timeGardenAddress = HermesAddress(rawValue: "orbo.time-garden")!
    public static let itinerary = [moiraiAddress, hephaestusAddress, timeGardenAddress]

    public static func package(
        subjectID: HermesSubjectID,
        packageID: HermesPackageID = HermesPackageID()
    ) -> HermesPackage<SynchronicSpineSchematicsRequest> {
        HermesPackage(
            packageID: packageID,
            subjectID: subjectID,
            sender: OrboOnboarding.orboAddress,
            kind: packageKind,
            addresses: itinerary,
            contents: SynchronicSpineSchematicsRequest(subjectID: subjectID)
        )!
    }
}

public enum SynchronicSpinePassAFailure: Error, Hashable, Sendable {
    case nativeTruthUnavailable
    case wrongSubject
    case alreadyCommissioned
    case unexpectedPackage
    case commissionNotDeliveredToClotho
    case sourceDoesNotCoverBone
    case mismatchedFoundation
}

public extension Orbo {
    /// Authors the request for the native already kept by Hestia. The existing
    /// courier alone opens the ticket and applies its package replay law.
    func commissionSynchronicSpine(
        subjectID: HermesSubjectID,
        hearth: Hestia,
        via courier: inout HermesCourier,
        occurredAt: AbsoluteInstant,
        packageID: HermesPackageID = HermesPackageID()
    ) throws -> SynchronicSpineCommissionHandle {
        guard backOfHouse == .nativeReady,
              let native = hearth.nativeEngraving() else {
            throw SynchronicSpinePassAFailure.nativeTruthUnavailable
        }
        guard hearth.nativeSubjectID == subjectID, native.subjectID == subjectID else {
            throw SynchronicSpinePassAFailure.wrongSubject
        }
        let package = SynchronicSpineCommission.package(subjectID: subjectID, packageID: packageID)
        do {
            let ticketID = try courier.accept(package: package, occurredAt: occurredAt)
            return SynchronicSpineCommissionHandle(package: package, ticketID: ticketID)
        } catch HermesCourier.Failure.packageAlreadyAccepted {
            throw SynchronicSpinePassAFailure.alreadyCommissioned
        }
    }
}
