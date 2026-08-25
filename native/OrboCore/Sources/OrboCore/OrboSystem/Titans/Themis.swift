/// Immutable testimony returned by Themis.
public struct ThemisPass: Sendable {
    public let imprint: Tympan.Imprint

    internal init(imprint: Tympan.Imprint) {
        self.imprint = imprint
    }
}

/// Keeper of Tympan.
///
/// Themis does not reimplement whole-sign form. She is the authoritative
/// entrance to the frozen Tympan law.
public enum Themis {
    public static func set(_ risingSign: Sign) -> Tympan.Imprint {
        Tympan.imprint(for: risingSign)
    }

    public static func testify(_ risingSign: Sign) -> ThemisPass {
        ThemisPass(imprint: set(risingSign))
    }
}
