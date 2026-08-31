public struct NatalSpineSchematicsRequest: Hashable, Sendable {
    public let subjectID: HermesSubjectID

    public init(subjectID: HermesSubjectID) {
        self.subjectID = subjectID
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
