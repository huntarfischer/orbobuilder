public enum House: Int, CaseIterable, Codable, Hashable, Sendable {
    case first = 1
    case second
    case third
    case fourth
    case fifth
    case sixth
    case seventh
    case eighth
    case ninth
    case tenth
    case eleventh
    case twelfth

    public static let canonicalOrder: [House] = [
        .first, .second, .third, .fourth, .fifth, .sixth,
        .seventh, .eighth, .ninth, .tenth, .eleventh, .twelfth,
    ]

    public var opposite: House {
        let ordinal = ((rawValue - 1 + 6) % 12) + 1
        return House(rawValue: ordinal)!
    }
}
