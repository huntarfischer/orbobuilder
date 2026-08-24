public enum Tympan {
    public enum TraditionalGovernor: String, CaseIterable, Codable, Hashable, Sendable {
        case sun = "Sun"
        case moon = "Moon"
        case mercury = "Mercury"
        case venus = "Venus"
        case mars = "Mars"
        case jupiter = "Jupiter"
        case saturn = "Saturn"

        public init?(planet: Planet) {
            guard planet.isClassical else { return nil }
            self.init(rawValue: planet.rawValue)
        }

        public var planet: Planet {
            Planet(rawValue: rawValue)!
        }
    }

    public struct HouseRecord: Codable, Hashable, Sendable {
        public let house: House
        public let sign: Sign
        public let ruler: Planet
        public let coRuler: Planet?

        public init(
            house: House,
            sign: Sign,
            ruler: Planet,
            coRuler: Planet?
        ) {
            self.house = house
            self.sign = sign
            self.ruler = ruler
            self.coRuler = coRuler
        }
    }

    public struct Imprint: Sendable {
        public let risingSign: Sign
        public let houses: [HouseRecord]

        fileprivate let houseBySign: [Sign: House]
        fileprivate let signByHouse: [House: Sign]
        fileprivate let rulesHouses: [TraditionalGovernor: [House]]
        fileprivate let coRulesHouses: [Planet: [House]]

        fileprivate init(
            risingSign: Sign,
            houses: [HouseRecord],
            houseBySign: [Sign: House],
            signByHouse: [House: Sign],
            rulesHouses: [TraditionalGovernor: [House]],
            coRulesHouses: [Planet: [House]]
        ) {
            self.risingSign = risingSign
            self.houses = houses
            self.houseBySign = houseBySign
            self.signByHouse = signByHouse
            self.rulesHouses = rulesHouses
            self.coRulesHouses = coRulesHouses
        }

        public func housesRuled(by governor: TraditionalGovernor) -> [House] {
            rulesHouses[governor] ?? []
        }

        public func housesCoRuled(by planet: Planet) -> [House] {
            coRulesHouses[planet] ?? []
        }
    }

    public static let flipHouses = 6

    private static let modernCoRulersBySign: [Sign: Planet] = [
        .scorpio: .pluto,
        .aquarius: .uranus,
        .pisces: .neptune,
    ]

    public static let imprints: [Imprint] = {
        let imprints = Sign.canonicalOrder.map { risingSign -> Imprint in
            let houseBySign = Dictionary(
                uniqueKeysWithValues: Sign.canonicalOrder.map { sign -> (Sign, House) in
                    let ordinal = ((sign.rawValue - risingSign.rawValue + 12) % 12) + 1
                    guard let house = House(rawValue: ordinal) else {
                        preconditionFailure("Tympan generated an invalid house ordinal.")
                    }
                    return (sign, house)
                }
            )

            let signByHouse = Dictionary(
                uniqueKeysWithValues: houseBySign.map { sign, house in
                    (house, sign)
                }
            )

            let houses = House.canonicalOrder.map { house -> HouseRecord in
                guard let sign = signByHouse[house] else {
                    preconditionFailure("Tympan imprint is missing house \(house.rawValue).")
                }
                return HouseRecord(
                    house: house,
                    sign: sign,
                    ruler: Mater.domicileRuler(of: sign),
                    coRuler: modernCoRulersBySign[sign]
                )
            }

            let rulesHouses = Dictionary(
                uniqueKeysWithValues: TraditionalGovernor.allCases.map { governor in
                    let governed = houses
                        .filter { $0.ruler == governor.planet }
                        .map(\.house)
                    return (governor, governed)
                }
            )

            let coRulesHouses = Dictionary(
                uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                    let governed = houses
                        .filter { $0.coRuler == planet }
                        .map(\.house)
                    return (planet, governed)
                }
            )

            return Imprint(
                risingSign: risingSign,
                houses: houses,
                houseBySign: houseBySign,
                signByHouse: signByHouse,
                rulesHouses: rulesHouses,
                coRulesHouses: coRulesHouses
            )
        }

        precondition(imprints.count == 12)

        for imprint in imprints {
            precondition(imprint.houses.count == 12)
            precondition(imprint.houseBySign.count == 12)
            precondition(imprint.signByHouse.count == 12)
            precondition(imprint.houseBySign[imprint.risingSign] == .first)

            let allHouses = Set(imprint.houses.map(\.house))
            precondition(allHouses == Set(House.canonicalOrder))

            let traditionallyGoverned = TraditionalGovernor.allCases
                .flatMap { imprint.housesRuled(by: $0) }
            precondition(traditionallyGoverned.count == 12)
            precondition(Set(traditionallyGoverned) == Set(House.canonicalOrder))

            for modern in [Planet.uranus, .neptune, .pluto] {
                precondition(imprint.housesCoRuled(by: modern).count == 1)
            }
            for traditional in Planet.classicalSeven {
                precondition(imprint.housesCoRuled(by: traditional).isEmpty)
            }
        }

        return imprints
    }()

    public static func imprint(for risingSign: Sign) -> Imprint {
        imprints[risingSign.rawValue]
    }

    public static func house(of sign: Sign, rising risingSign: Sign) -> House {
        imprint(for: risingSign).houseBySign[sign]!
    }

    public static func house(
        of longitude: CelestialLongitude,
        ascendant: CelestialLongitude
    ) -> House {
        house(of: longitude.sign, rising: ascendant.sign)
    }

    public static func sign(of house: House, rising risingSign: Sign) -> Sign {
        imprint(for: risingSign).signByHouse[house]!
    }

    public static func ruler(of house: House, rising risingSign: Sign) -> Planet {
        Mater.domicileRuler(of: sign(of: house, rising: risingSign))
    }

    public static func coRuler(of sign: Sign) -> Planet? {
        modernCoRulersBySign[sign]
    }

    public static func coRuler(of house: House, rising risingSign: Sign) -> Planet? {
        coRuler(of: sign(of: house, rising: risingSign))
    }

    public static func housesRuled(
        by governor: TraditionalGovernor,
        rising risingSign: Sign
    ) -> [House] {
        imprint(for: risingSign).housesRuled(by: governor)
    }

    public static func housesCoRuled(
        by planet: Planet,
        rising risingSign: Sign
    ) -> [House] {
        imprint(for: risingSign).housesCoRuled(by: planet)
    }

    public static func opposite(of house: House) -> House {
        house.opposite
    }
}
