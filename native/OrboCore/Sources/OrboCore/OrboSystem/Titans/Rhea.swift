/// Immutable testimony returned by Rhea.
public struct RheaPass: Sendable {
    public let field: Mater.QualifiedField

    internal init(field: Mater.QualifiedField) {
        self.field = field
    }
}

/// Degree-owned Mater truth that does not require a chart-wide field or Sect.
/// This is the lawful substrate for bodies such as Terra and the Node as well
/// as planets, because zodiacal degree condition exists independently of body
/// identity.
public struct RheaDegreeQualification: Hashable, Sendable {
    public let longitude: CelestialLongitude
    public let sign: Sign
    public let degreeInSign: DegreeInSign
    public let element: Element
    public let modality: Modality
    public let domicileRuler: Planet
    public let exaltation: Exaltation?
    public let detrimentRuler: Planet
    public let fallRuler: Planet?
    public let bound: Bound
    public let face: Face
    public let triplicity: Triplicity

    internal init(longitude: CelestialLongitude) {
        self.longitude = longitude
        self.sign = longitude.sign
        self.degreeInSign = longitude.degreeInSign
        self.element = Mater.element(of: longitude.sign)
        self.modality = Mater.modality(of: longitude.sign)
        self.domicileRuler = Mater.domicileRuler(of: longitude.sign)
        self.exaltation = Mater.exaltation(in: longitude.sign)
        self.detrimentRuler = Mater.detrimentRuler(in: longitude.sign)
        self.fallRuler = Mater.fallRuler(in: longitude.sign)
        self.bound = Mater.bound(at: longitude)
        self.face = Mater.face(at: longitude)
        self.triplicity = Mater.triplicity(of: longitude.sign)
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

    /// Qualifies one exact zodiacal degree through existing Mater tables only.
    /// No Sect judgment is made here; day/night operation remains outside this
    /// degree-owned record until Hecate lawfully supplies Sect downstream.
    public static func bearDegree(_ longitude: CelestialLongitude) -> RheaDegreeQualification {
        RheaDegreeQualification(longitude: longitude)
    }
}
