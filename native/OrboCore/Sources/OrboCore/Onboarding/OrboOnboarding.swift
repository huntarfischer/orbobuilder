public struct Engraving: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let name: String
    public let birthDate: CivilDate
    public let birthTime: CivilClockTime
    public let birthLocation: String

    public let topos: Topos?
    public let astroDNA: AstroDNA?
    public let tapestry: AtroposPackage?
    public let engraved: Bool

    /// Orbo creates an unfinished Engraving. Its four resolutions are completed
    /// in order by Atlas, the Moirai, and finally Hestia at the Hearth.
    public init(
        subjectID: HermesSubjectID,
        name: String,
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        birthLocation: String
    ) {
        self.subjectID = subjectID
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
        self.topos = nil
        self.astroDNA = nil
        self.tapestry = nil
        self.engraved = false
    }

    private init(
        subjectID: HermesSubjectID,
        name: String,
        birthDate: CivilDate,
        birthTime: CivilClockTime,
        birthLocation: String,
        topos: Topos?,
        astroDNA: AstroDNA?,
        tapestry: AtroposPackage?,
        engraved: Bool
    ) {
        self.subjectID = subjectID
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
        self.topos = topos
        self.astroDNA = astroDNA
        self.tapestry = tapestry
        self.engraved = engraved
    }

    /// Atlas resolves only Topos. Every other Engraving resolution is preserved.
    internal func resolving(topos: Topos) -> Engraving {
        Engraving(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation,
            topos: topos,
            astroDNA: astroDNA,
            tapestry: tapestry,
            engraved: engraved
        )
    }
}

/// Orbo owns onboarding. Completing onboarding creates the unfinished Engraving
/// package that Orbo entrusts to Hermes.
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
    ) -> HermesPackage<Engraving> {
        let engraving = Engraving(
            subjectID: subjectID,
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
            contents: engraving
        )!
    }
}
