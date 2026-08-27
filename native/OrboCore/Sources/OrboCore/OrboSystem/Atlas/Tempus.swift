public struct TempusProvenance: Hashable, Codable, Sendable {
    public let source: CivilTimeSource
    public let timeZoneDataVersion: String?

    internal init(
        source: CivilTimeSource,
        timeZoneDataVersion: String? = nil
    ) {
        self.source = source
        self.timeZoneDataVersion = timeZoneDataVersion
    }
}

public struct Tempus: Hashable, Codable, Sendable {
    public let absoluteInstant: AbsoluteInstant
    public let provenance: TempusProvenance

    internal init(
        absoluteInstant: AbsoluteInstant,
        provenance: TempusProvenance
    ) {
        self.absoluteInstant = absoluteInstant
        self.provenance = provenance
    }
}
