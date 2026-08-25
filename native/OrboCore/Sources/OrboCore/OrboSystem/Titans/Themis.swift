/// Keeper of Tympan.
///
/// Themis does not reimplement whole-sign form. She is the authoritative
/// entrance to the frozen Tympan law.
public enum Themis {
    public static func set(_ risingSign: Sign) -> Tympan.Imprint {
        Tympan.imprint(for: risingSign)
    }
}
