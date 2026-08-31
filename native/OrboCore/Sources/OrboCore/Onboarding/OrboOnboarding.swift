public struct Engraving: Hashable, Sendable {
    public let subjectID: HermesSubjectID
    public let name: String
    public let birthDate: CivilDate
    public let birthTime: CivilClockTime
    public let birthLocation: String

    public let topos: Topos?
    public let tempus: Tempus?
    public let astroDNA: AstroDNA?
    public let sect: Sect?
    public let tapestry: AtroposTapestryPackage?
    public let engraved: Bool

    /// Orbo creates an unfinished Engraving. Its resolutions are completed
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
        self.tempus = nil
        self.astroDNA = nil
        self.sect = nil
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
        tempus: Tempus?,
        astroDNA: AstroDNA?,
        sect: Sect?,
        tapestry: AtroposTapestryPackage?,
        engraved: Bool
    ) {
        self.subjectID = subjectID
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
        self.topos = topos
        self.tempus = tempus
        self.astroDNA = astroDNA
        self.sect = sect
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
            tempus: tempus,
            astroDNA: astroDNA,
            sect: sect,
            tapestry: tapestry,
            engraved: engraved
        )
    }

    /// Resolves only Tempus. Every other Engraving resolution is preserved.
    internal func resolving(tempus: Tempus) -> Engraving {
        Engraving(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation,
            topos: topos,
            tempus: tempus,
            astroDNA: astroDNA,
            sect: sect,
            tapestry: tapestry,
            engraved: engraved
        )
    }

    /// Clotho resolves AstroDNA while preserving every other established truth.
    internal func resolving(astroDNA: AstroDNA) -> Engraving {
        Engraving(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation,
            topos: topos,
            tempus: tempus,
            astroDNA: astroDNA,
            sect: sect,
            tapestry: tapestry,
            engraved: engraved
        )
    }

    /// Preserves the Sect already cast during Clotho's lawful onboarding work.
    internal func resolving(sect: Sect) -> Engraving {
        Engraving(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation,
            topos: topos,
            tempus: tempus,
            astroDNA: astroDNA,
            sect: sect,
            tapestry: tapestry,
            engraved: engraved
        )
    }

    /// The Moirai attach Atropos's canonical seal without completing the Engraving.
    internal func resolving(tapestry: AtroposTapestryPackage) -> Engraving {
        Engraving(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation,
            topos: topos,
            tempus: tempus,
            astroDNA: astroDNA,
            sect: sect,
            tapestry: tapestry,
            engraved: engraved
        )
    }

    /// Hestia completes the Engraving only when she hangs it on the native Hearth.
    internal func hungOnHearth() -> Engraving {
        Engraving(
            subjectID: subjectID,
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: birthLocation,
            topos: topos,
            tempus: tempus,
            astroDNA: astroDNA,
            sect: sect,
            tapestry: tapestry,
            engraved: true
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
