public struct EngravingIntake: Hashable, Codable, Sendable {
    public let name: String
    public let birthDate: CivilDate
    public let birthTime: CivilClockTime
    public let birthLocation: String

    public init(
        name: String,
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        birthLocation: String
    ) {
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
    }
}

public struct AtlasEngraving: Hashable, Codable, Sendable {
    public let name: String
    public let birthDate: CivilDate
    public let birthTime: CivilClockTime
    public let birthLocation: String
    public let topos: Topos

    public init(
        intake: EngravingIntake,
        topos: Topos
    ) {
        self.name = intake.name
        self.birthDate = intake.birthDate
        self.birthTime = intake.birthTime
        self.birthLocation = intake.birthLocation
        self.topos = topos
    }
}

/// Orbo owns onboarding. Completing onboarding creates the Engraving package
/// that Orbo entrusts to Hermes.
public enum OrboOnboarding {
    public static let orboAddress = HermesAddress(rawValue: "orbo")!
    public static let engravingPackageKind = HermesPackageKind(rawValue: "orbo.engraving.v1")!
    public static let engravingItinerary = [
        HermesAddress(rawValue: "orbo.atlas")!,
        HermesAddress(rawValue: "orbo.moirai")!,
        HermesAddress(rawValue: "orbo.hestia")!,
    ]

    public static func complete(
        subjectID: HermesSubjectID,
        name: String,
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        birthLocation: String,
        packageID: HermesPackageID = HermesPackageID()
    ) -> HermesPackage<EngravingIntake> {
        let intake = EngravingIntake(
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation
        )

        return HermesPackage(
            packageID: packageID,
            subjectID: subjectID,
            sender: orboAddress,
            kind: engravingPackageKind,
            addresses: engravingItinerary,
            contents: intake
        )!
    }
}
