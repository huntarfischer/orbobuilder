public struct MoiraiPackage: Hashable, Sendable {
    public let astroDNA: AstroDNA
    public let tapestry: AtroposPackage

    public init(
        astroDNA: AstroDNA,
        tapestry: AtroposPackage
    ) {
        self.astroDNA = astroDNA
        self.tapestry = tapestry
    }
}
