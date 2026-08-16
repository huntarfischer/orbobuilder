public enum Mater {
    public static let classicalDispositors: [Planet] = Planet.classicalSeven

    private static let elementCycle: [Element] = [.fire, .earth, .air, .water]
    private static let modalityCycle: [Modality] = [.cardinal, .fixed, .mutable]

    private static let domicileRulersBySign: [Planet] = [
        .mars, .venus, .mercury, .moon, .sun, .mercury,
        .venus, .mars, .jupiter, .saturn, .saturn, .jupiter,
    ]

    private static let exaltationsBySign: [Exaltation?] = {
        var table = Array<Exaltation?>(repeating: nil, count: Sign.canonicalOrder.count)
        let entries: [(Sign, Planet, Double)] = [
            (.aries, .sun, 19),
            (.taurus, .moon, 3),
            (.cancer, .jupiter, 15),
            (.virgo, .mercury, 15),
            (.libra, .saturn, 21),
            (.capricorn, .mars, 28),
            (.pisces, .venus, 27),
        ]

        for (sign, planet, degreeValue) in entries {
            guard let degree = DegreeInSign(degreeValue) else {
                preconditionFailure("Invalid exaltation degree for \(planet).")
            }
            table[sign.rawValue] = Exaltation(planet: planet, sign: sign, degree: degree)
        }

        return table
    }()

    private static let detrimentRulersBySign: [Planet] = Sign.canonicalOrder.map { sign in
        domicileRulersBySign[sign.opposite.rawValue]
    }

    private static let fallRulersBySign: [Planet?] = Sign.canonicalOrder.map { sign in
        exaltationsBySign[sign.opposite.rawValue]?.planet
    }

    private static let ruledSignsByPlanet: [Planet: [Sign]] = Dictionary(
        uniqueKeysWithValues: classicalDispositors.map { planet in
            let signs = Sign.canonicalOrder.filter { domicileRulersBySign[$0.rawValue] == planet }
            return (planet, signs)
        }
    )

    private static let exaltationByPlanet: [Planet: Exaltation] = Dictionary(
        uniqueKeysWithValues: exaltationsBySign.compactMap { exaltation in
            exaltation.map { ($0.planet, $0) }
        }
    )

    public static func element(of sign: Sign) -> Element {
        elementCycle[sign.rawValue % elementCycle.count]
    }

    public static func modality(of sign: Sign) -> Modality {
        modalityCycle[sign.rawValue % modalityCycle.count]
    }

    public static func domicileRuler(of sign: Sign) -> Planet {
        domicileRulersBySign[sign.rawValue]
    }

    public static func signsRuled(by planet: Planet) -> [Sign] {
        ruledSignsByPlanet[planet] ?? []
    }

    public static func exaltation(in sign: Sign) -> Exaltation? {
        exaltationsBySign[sign.rawValue]
    }

    public static func exaltation(of planet: Planet) -> Exaltation? {
        exaltationByPlanet[planet]
    }

    public static func detrimentRuler(in sign: Sign) -> Planet {
        detrimentRulersBySign[sign.rawValue]
    }

    public static func fallRuler(in sign: Sign) -> Planet? {
        fallRulersBySign[sign.rawValue]
    }

    public static func debilities(
        of planet: Planet,
        in sign: Sign
    ) -> Set<EssentialDebility> {
        guard planet.isClassical else { return [] }

        var result = Set<EssentialDebility>()
        if detrimentRuler(in: sign) == planet {
            result.insert(.detriment)
        }
        if fallRuler(in: sign) == planet {
            result.insert(.fall)
        }
        return result
    }

    public static func bound(
        at longitude: CelestialLongitude,
        doctrine: DignityDoctrine = .orboDefault
    ) -> Bound {
        let row = MaterDoctrineTables.bounds(for: doctrine.bounds)[longitude.sign.rawValue]
        let degree = longitude.degreeInSign.value

        guard let bound = row.first(where: { degree < $0.end.value }) else {
            preconditionFailure("Complete bounds table failed to resolve \(longitude.degrees).")
        }
        return bound
    }

    public static func face(
        at longitude: CelestialLongitude,
        doctrine: DignityDoctrine = .orboDefault
    ) -> Face {
        let globalIndex = Int(longitude.degrees / 10)
        let rulers = MaterDoctrineTables.faces(for: doctrine.faces)
        let decan = Int(longitude.degreeInSign.value / 10) + 1

        guard let face = Face(
            ruler: rulers[globalIndex],
            sign: longitude.sign,
            decan: decan,
            scheme: doctrine.faces
        ) else {
            preconditionFailure("Complete face table failed to resolve \(longitude.degrees).")
        }
        return face
    }

    public static func triplicity(
        of sign: Sign,
        doctrine: DignityDoctrine = .orboDefault
    ) -> Triplicity {
        MaterDoctrineTables.triplicity(
            for: element(of: sign),
            scheme: doctrine.triplicity
        )
    }

    public static func essentialCondition(
        of planet: Planet,
        at longitude: CelestialLongitude,
        sect: Sect?,
        doctrine: DignityDoctrine = .orboDefault
    ) -> EssentialCondition? {
        guard planet.isClassical else { return nil }

        let sign = longitude.sign
        let bound = bound(at: longitude, doctrine: doctrine)
        let face = face(at: longitude, doctrine: doctrine)
        let triplicity = triplicity(of: sign, doctrine: doctrine)

        var dignities = Set<DignityRung>()
        if domicileRuler(of: sign) == planet {
            dignities.insert(.domicile)
        }
        if exaltation(in: sign)?.planet == planet {
            dignities.insert(.exaltation)
        }
        if triplicity.operativeRuler(for: sect) == planet || triplicity.participatingRuler == planet {
            dignities.insert(.triplicity)
        }
        if bound.ruler == planet {
            dignities.insert(.bound)
        }
        if face.ruler == planet {
            dignities.insert(.face)
        }

        return EssentialCondition(
            planet: planet,
            longitude: longitude,
            dignities: dignities,
            debilities: debilities(of: planet, in: sign),
            bound: bound,
            face: face,
            triplicity: triplicity
        )
    }
}
