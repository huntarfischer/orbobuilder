public enum Sign: Int, CaseIterable, Codable, Hashable, Sendable {
    case aries = 0
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces

    public static let canonicalOrder: [Sign] = [
        .aries, .taurus, .gemini, .cancer, .leo, .virgo,
        .libra, .scorpio, .sagittarius, .capricorn, .aquarius, .pisces,
    ]

    public var opposite: Sign {
        Sign(rawValue: (rawValue + 6) % 12)!
    }
}
