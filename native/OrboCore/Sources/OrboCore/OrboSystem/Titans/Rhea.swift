/// Immutable testimony returned by Rhea.
public struct RheaPass: Sendable {
    public let field: Mater.QualifiedField

    internal init(field: Mater.QualifiedField) {
        self.field = field
    }
}

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

    public static func testify(
        _ longitudes: [Planet: CelestialLongitude],
        sect: Sect?
    ) -> RheaPass {
        RheaPass(field: bear(longitudes, sect: sect))
    }
}
