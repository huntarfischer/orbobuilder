import Foundation

public enum SynchronicSpinePassAFailure: Error, Hashable, Sendable {
    case duplicateCommission
    case invalidCommissionPackage
    case unexpectedHermesDestination
    case invalidGregorianBone
    case mismatchedFoundation
}

public struct SynchronicSpineCommissionRequest: Hashable, Sendable {
    public let purpose: String

    public init(purpose: String = "synchronic-spine-schematic") {
        self.purpose = purpose
    }
}

public struct SynchronicSpineCommission: Hashable, Sendable {
    public let ticketID: HermesTicketID
    public let packageID: HermesPackageID
    public let subjectID: HermesSubjectID
    public let packageKind: HermesPackageKind
    public let addresses: [HermesAddress]

    public init(
        ticketID: HermesTicketID,
        packageID: HermesPackageID,
        subjectID: HermesSubjectID,
        packageKind: HermesPackageKind,
        addresses: [HermesAddress]
    ) {
        self.ticketID = ticketID
        self.packageID = packageID
        self.subjectID = subjectID
        self.packageKind = packageKind
        self.addresses = addresses
    }
}

public struct SynchronicSpinePattern: Hashable, Sendable {
    public static let requiredBoneCount = 1
    public static let requiredAsteriaPassCount = 12
    public static let requiredThemisImprintCount = 7
    public static let requiredOceanusTideCount = 3
    public static let requiredRheaQualifierCount = 12

    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID

    public init(subjectID: HermesSubjectID, ticketID: HermesTicketID) {
        self.subjectID = subjectID
        self.ticketID = ticketID
    }

    public func matchesInventory(
        boneCount: Int,
        asteriaPassCount: Int,
        themisImprintCount: Int,
        oceanusTideCount: Int,
        rheaQualifierCount: Int
    ) -> Bool {
        boneCount == Self.requiredBoneCount
            && asteriaPassCount == Self.requiredAsteriaPassCount
            && themisImprintCount == Self.requiredThemisImprintCount
            && oceanusTideCount == Self.requiredOceanusTideCount
            && rheaQualifierCount == Self.requiredRheaQualifierCount
    }
}

public struct SynchronicSpineBone: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let ticketID: HermesTicketID
    public let start: AbsoluteInstant
    public let natal: AbsoluteInstant
    public let end: AbsoluteInstant

    public init(
        subjectID: HermesSubjectID,
        ticketID: HermesTicketID,
        start: AbsoluteInstant,
        natal: AbsoluteInstant,
        end: AbsoluteInstant
    ) {
        self.subjectID = subjectID
        self.ticketID = ticketID
        self.start = start
        self.natal = natal
        self.end = end
    }

    public func contains(_ instant: AbsoluteInstant) -> Bool {
        instant.unixSecondsSince1970 >= start.unixSecondsSince1970
            && instant.unixSecondsSince1970 <= end.unixSecondsSince1970
    }
}

public struct SynchronicSpineFoundation: Hashable, Sendable {
    public let commission: SynchronicSpineCommission
    public let pattern: SynchronicSpinePattern
    public let bone: SynchronicSpineBone

    public init(
        commission: SynchronicSpineCommission,
        pattern: SynchronicSpinePattern,
        bone: SynchronicSpineBone
    ) {
        self.commission = commission
        self.pattern = pattern
        self.bone = bone
    }
}

public extension Clotho {
    static func cutSynchronicSpineFoundation(
        commission: SynchronicSpineCommission,
        natal: AbsoluteInstant
    ) throws -> SynchronicSpineFoundation {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        guard
            let startDate = calendar.date(byAdding: .year, value: -1, to: natal.foundationDate),
            let endDate = calendar.date(byAdding: .year, value: 100, to: natal.foundationDate),
            let start = AbsoluteInstant(unixSecondsSince1970: startDate.timeIntervalSince1970),
            let end = AbsoluteInstant(unixSecondsSince1970: endDate.timeIntervalSince1970),
            start.unixSecondsSince1970 < natal.unixSecondsSince1970,
            natal.unixSecondsSince1970 < end.unixSecondsSince1970
        else {
            throw SynchronicSpinePassAFailure.invalidGregorianBone
        }

        let pattern = SynchronicSpinePattern(
            subjectID: commission.subjectID,
            ticketID: commission.ticketID
        )
        let bone = SynchronicSpineBone(
            subjectID: commission.subjectID,
            ticketID: commission.ticketID,
            start: start,
            natal: natal,
            end: end
        )

        return SynchronicSpineFoundation(
            commission: commission,
            pattern: pattern,
            bone: bone
        )
    }
}

public extension Lachesis {
    static func receiveSynchronicSpineFoundation(
        _ foundation: SynchronicSpineFoundation
    ) throws -> SynchronicSpineFoundation {
        guard
            foundation.commission.subjectID == foundation.pattern.subjectID,
            foundation.commission.subjectID == foundation.bone.subjectID,
            foundation.commission.ticketID == foundation.pattern.ticketID,
            foundation.commission.ticketID == foundation.bone.ticketID
        else {
            throw SynchronicSpinePassAFailure.mismatchedFoundation
        }

        return foundation
    }
}

public struct SynchronicSpineActIStarter: Sendable {
    public static let orbo = HermesAddress(rawValue: "Orbo")!
    public static let clotho = HermesAddress(rawValue: "Clotho")!
    public static let hephaestus = HermesAddress(rawValue: "Hephaestus")!
    public static let packageKind = HermesPackageKind(rawValue: "synchronic-spine-schematic")!

    public private(set) var courier: HermesCourier
    private var foundationsBySubject: [HermesSubjectID: SynchronicSpineFoundation]

    public init(courier: HermesCourier = HermesCourier()) {
        self.courier = courier
        self.foundationsBySubject = [:]
    }

    public mutating func start(
        subjectID: HermesSubjectID,
        natal: AbsoluteInstant,
        occurredAt: AbsoluteInstant
    ) throws -> SynchronicSpineFoundation {
        guard foundationsBySubject[subjectID] == nil else {
            throw SynchronicSpinePassAFailure.duplicateCommission
        }

        let request = SynchronicSpineCommissionRequest()
        let packageID = HermesPackageID()
        let addresses = [Self.clotho, Self.hephaestus]
        guard let package = HermesPackage(
            packageID: packageID,
            subjectID: subjectID,
            sender: Self.orbo,
            kind: Self.packageKind,
            addresses: addresses,
            contents: request
        ) else {
            throw SynchronicSpinePassAFailure.invalidCommissionPackage
        }

        let ticketID = try courier.accept(package: package, occurredAt: occurredAt)
        let deliveredTo = try courier.deliverNext(ticketID: ticketID, occurredAt: occurredAt)
        guard deliveredTo == Self.clotho else {
            throw SynchronicSpinePassAFailure.unexpectedHermesDestination
        }

        let commission = SynchronicSpineCommission(
            ticketID: ticketID,
            packageID: packageID,
            subjectID: subjectID,
            packageKind: Self.packageKind,
            addresses: addresses
        )
        let cut = try Clotho.cutSynchronicSpineFoundation(
            commission: commission,
            natal: natal
        )
        let ready = try Lachesis.receiveSynchronicSpineFoundation(cut)

        foundationsBySubject[subjectID] = ready
        return ready
    }

    /// Keeps Hermes's mutable custody state inside the Act I lifecycle owner.
    /// Atropos still performs the call; callers cannot reach through the starter
    /// and mutate the courier directly.
    @discardableResult
    public mutating func receiveAtroposCertifiedSchematic(
        _ schematic: CertifiedSynchronicSpineSchematic,
        occurredAt: AbsoluteInstant
    ) throws -> CertifiedSynchronicSpineSchematicReference {
        try Atropos.callHermesForCertifiedSynchronicSpine(
            schematic,
            courier: &courier,
            occurredAt: occurredAt
        )
    }
}
