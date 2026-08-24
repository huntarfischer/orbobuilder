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

    public struct TraditionalGovernanceGroup: Hashable, Sendable {
        public let governor: TraditionalGovernor
        public let houses: [House]

        public init(governor: TraditionalGovernor, houses: [House]) {
            self.governor = governor
            self.houses = houses
        }
    }

    public struct ModernGovernance: Hashable, Sendable {
        public let governor: Planet
        public let sign: Sign
        public let house: House

        fileprivate init(governor: Planet, sign: Sign, house: House) {
            self.governor = governor
            self.sign = sign
            self.house = house
        }
    }

    public struct HouseRecord: Codable, Hashable, Sendable {
        public let house: House
        public let sign: Sign
        public let ruler: Planet
        public let modernGovernor: Planet?

        public init(
            house: House,
            sign: Sign,
            ruler: Planet,
            modernGovernor: Planet?
        ) {
            self.house = house
            self.sign = sign
            self.ruler = ruler
            self.modernGovernor = modernGovernor
        }

        // Legacy V1 vocabulary. Tympan V2 names the chart-specific relation governance.
        public var coRuler: Planet? {
            modernGovernor
        }

        public init(
            house: House,
            sign: Sign,
            ruler: Planet,
            coRuler: Planet?
        ) {
            self.init(
                house: house,
                sign: sign,
                ruler: ruler,
                modernGovernor: coRuler
            )
        }
    }

    public struct Imprint: Sendable {
        public let risingSign: Sign
        public let houses: [HouseRecord]
        public let traditionalGovernanceLattice: [TraditionalGovernanceGroup]
        public let modernGovernance: [ModernGovernance]

        fileprivate let houseBySign: [Sign: House]
        fileprivate let signByHouse: [House: Sign]
        fileprivate let rulesHouses: [TraditionalGovernor: [House]]
        fileprivate let modernGovernedHouses: [Planet: [House]]

        fileprivate init(
            risingSign: Sign,
            houses: [HouseRecord],
            traditionalGovernanceLattice: [TraditionalGovernanceGroup],
            modernGovernance: [ModernGovernance],
            houseBySign: [Sign: House],
            signByHouse: [House: Sign],
            rulesHouses: [TraditionalGovernor: [House]],
            modernGovernedHouses: [Planet: [House]]
        ) {
            self.risingSign = risingSign
            self.houses = houses
            self.traditionalGovernanceLattice = traditionalGovernanceLattice
            self.modernGovernance = modernGovernance
            self.houseBySign = houseBySign
            self.signByHouse = signByHouse
            self.rulesHouses = rulesHouses
            self.modernGovernedHouses = modernGovernedHouses
        }

        public func housesRuled(by governor: TraditionalGovernor) -> [House] {
            rulesHouses[governor] ?? []
        }

        public func housesModernlyGoverned(by planet: Planet) -> [House] {
            modernGovernedHouses[planet] ?? []
        }

        // Legacy V1 vocabulary. Canonical V2 callers should use housesModernlyGoverned(by:).
        public func housesCoRuled(by planet: Planet) -> [House] {
            housesModernlyGoverned(by: planet)
        }
    }

    public static let flipHouses = 6

    private static let modernRulerships: [(sign: Sign, ruler: Planet)] = [
        (.scorpio, .pluto),
        (.aquarius, .uranus),
        (.pisces, .neptune),
    ]

    private static let modernRulersBySign: [Sign: Planet] = Dictionary(
        uniqueKeysWithValues: modernRulerships.map { ($0.sign, $0.ruler) }
    )

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
                    modernGovernor: modernRulersBySign[sign]
                )
            }

            let traditionalGovernanceLattice = TraditionalGovernor.allCases.map { governor in
                TraditionalGovernanceGroup(
                    governor: governor,
                    houses: houses
                        .filter { $0.ruler == governor.planet }
                        .map(\.house)
                )
            }

            let rulesHouses = Dictionary(
                uniqueKeysWithValues: traditionalGovernanceLattice.map { group in
                    (group.governor, group.houses)
                }
            )

            let modernGovernance = modernRulerships.map { rulership -> ModernGovernance in
                guard let house = houseBySign[rulership.sign] else {
                    preconditionFailure("Tympan imprint is missing a modern-governed sign.")
                }
                return ModernGovernance(
                    governor: rulership.ruler,
                    sign: rulership.sign,
                    house: house
                )
            }

            let modernGovernedHouses = Dictionary(
                uniqueKeysWithValues: modernGovernance.map { relationship in
                    (relationship.governor, [relationship.house])
                }
            )

            return Imprint(
                risingSign: risingSign,
                houses: houses,
                traditionalGovernanceLattice: traditionalGovernanceLattice,
                modernGovernance: modernGovernance,
                houseBySign: houseBySign,
                signByHouse: signByHouse,
                rulesHouses: rulesHouses,
                modernGovernedHouses: modernGovernedHouses
            )
        }

        precondition(imprints.count == 12)

        for imprint in imprints {
            precondition(imprint.houses.count == 12)
            precondition(imprint.houseBySign.count == 12)
            precondition(imprint.signByHouse.count == 12)
            precondition(imprint.houseBySign[imprint.risingSign] == .first)
            precondition(imprint.traditionalGovernanceLattice.count == TraditionalGovernor.allCases.count)
            precondition(imprint.traditionalGovernanceLattice.map(\.governor) == TraditionalGovernor.allCases)
            precondition(imprint.modernGovernance.count == modernRulerships.count)
            precondition(imprint.modernGovernance.map(\.governor) == [.pluto, .uranus, .neptune])
            precondition(Set(imprint.modernGovernance.map(\.house)).count == 3)

            let allHouses = Set(imprint.houses.map(\.house))
            precondition(allHouses == Set(House.canonicalOrder))

            let traditionallyGoverned = imprint.traditionalGovernanceLattice.flatMap(\.houses)
            precondition(traditionallyGoverned.count == 12)
            precondition(Set(traditionallyGoverned) == Set(House.canonicalOrder))

            for relationship in imprint.modernGovernance {
                precondition(imprint.houseBySign[relationship.sign] == relationship.house)
                precondition(
                    imprint.houses.first { $0.house == relationship.house }?.modernGovernor
                        == relationship.governor
                )
                precondition(imprint.housesModernlyGoverned(by: relationship.governor) == [relationship.house])
                precondition(TraditionalGovernor(planet: relationship.governor) == nil)
            }

            for traditional in Planet.classicalSeven {
                precondition(imprint.housesModernlyGoverned(by: traditional).isEmpty)
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

    public static func modernRuler(of sign: Sign) -> Planet? {
        modernRulersBySign[sign]
    }

    public static func modernGovernor(of house: House, rising risingSign: Sign) -> Planet? {
        modernRuler(of: sign(of: house, rising: risingSign))
    }

    public static func housesRuled(
        by governor: TraditionalGovernor,
        rising risingSign: Sign
    ) -> [House] {
        imprint(for: risingSign).housesRuled(by: governor)
    }

    public static func housesModernlyGoverned(
        by planet: Planet,
        rising risingSign: Sign
    ) -> [House] {
        imprint(for: risingSign).housesModernlyGoverned(by: planet)
    }

    // Legacy V1 vocabulary retained as compatibility shims during the V2 transition.
    public static func coRuler(of sign: Sign) -> Planet? {
        modernRuler(of: sign)
    }

    public static func coRuler(of house: House, rising risingSign: Sign) -> Planet? {
        modernGovernor(of: house, rising: risingSign)
    }

    public static func housesCoRuled(
        by planet: Planet,
        rising risingSign: Sign
    ) -> [House] {
        housesModernlyGoverned(by: planet, rising: risingSign)
    }

    public static func opposite(of house: House) -> House {
        house.opposite
    }
}
