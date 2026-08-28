import Foundation

/// Hecate's Ascendant spell.
///
/// The universal Earth orientation is supplied by Terra Marrow. Topos supplies
/// only the local latitude and longitude needed to turn that universal state
/// into the local eastern horizon.
public enum AscendantKleis {
    public static let id = KleisID(rawValue: "Ascendant")!

    static let terraResource = HecateResourceKey(rawValue: "Terra")!
    static let toposResource = HecateResourceKey(rawValue: "Topos")!

    public static let formula = KleisFormula(
        requiredResources: [terraResource, toposResource],
        formula: "Terra.turn + Topos.longitude, Terra.tilt, Topos.latitude -> Ascendant",
        tradition: "Orbo",
        sectRule: .none,
        isOrboDefault: false,
        sources: ["Orbo Terra/Topos ascendant geometry"],
        status: .complete
    )!

    public static let declaration = Kleis(
        id: id,
        family: .astroDNA,
        context: .natal,
        availability: KleisAvailability(l1: true, l2: true, l3: true)!,
        formulas: [formula]
    )!

    static func cast(
        terra: TerraMarrowSample,
        topos: Topos
    ) -> RingFineState? {
        let thetaDegrees = CelestialLongitude(
            terra.turnDegrees + topos.place.longitude.degrees
        )!.degrees
        let theta = thetaDegrees * Double.pi / 180
        let epsilon = terra.tiltDegrees * Double.pi / 180
        let latitude = topos.place.latitude.degrees * Double.pi / 180

        let ascendantRadians = atan2(
            cos(theta),
            -(sin(theta) * cos(epsilon) + tan(latitude) * sin(epsilon))
        )

        guard let longitude = CelestialLongitude(
            ascendantRadians * 180 / Double.pi
        ) else {
            return nil
        }

        return Ring.fineState(of: longitude, motion: .direct)
    }
}
