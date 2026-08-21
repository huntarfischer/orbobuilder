public struct ClothoSourcePacket: Codable, Hashable, Sendable {
    public let risingSign: Sign

    public init(risingSign: Sign) {
        self.risingSign = risingSign
    }
}

public enum Clotho {
    public static func gather(from natalAstroDNA: AstroDNA) -> ClothoSourcePacket {
        ClothoSourcePacket(risingSign: natalAstroDNA.sign(of: .ascendant))
    }
}
