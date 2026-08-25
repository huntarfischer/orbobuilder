/// Keeper of Mater.
///
/// Rhea does not reimplement planetary condition. She is the authoritative
/// entrance to the frozen Mater law.
public enum Rhea {
    public static func bear(
        _ longitudes: [Planet: CelestialLongitude],
        sect: Sect?
    ) -> Mater.QualifiedField {
        Mater.qualifyField(longitudes, sect: sect)
    }
}
