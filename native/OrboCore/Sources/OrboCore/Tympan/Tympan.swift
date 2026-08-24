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

    public struct HouseGovernance: Hashable, Sendable {
        public let house: House
        public let sign: Sign
        public let traditionalGovernor: TraditionalGovernor
        public let traditionalGovernedHouses: [House]
        public let modernGovernor: Planet?

        fileprivate init(
            house: House,
            sign: Sign,
            traditionalGovernor: TraditionalGovernor,
            traditionalGovernedHouses: [House],
            modernGovernor: Planet?
        ) {
            self.house = house
            self.sign = sign
            self.traditionalGovernor = traditionalGovernor
            self.traditionalGovernedHouses = traditionalGovernedHouses
            self.modernGovernor = modernGovernor
        }
    }

    public struct HouseRecord: Codable, Hashable, Sendable {
        public let house: House
        public let sign: Sign
        public let signRuler: Planet
        public let modernGovernor: Planet?

        public init(
            house: House,
            sign: Sign,
            signRuler: Planet,
            modernGovernor: Planet?
        ) {
            self.house = house
            self.sign = sign
            self.signRuler = signRuler
            self.modernGovernor = modernGovernor
        }

        // Legacy V1 vocabulary retained while callers move to signRuler and governance.
        public var ruler: Planet {
            signRuler
        }

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
                signRuler: ruler,
                modernGovernor: coRuler
            )
        }
    }

    public struct Imprint: Sendable {
        public let risingSign: Sign
        public let houses: [HouseRecord]
        public let traditionalGovernanceLattice: [TraditionalGovernanceGroup]
        public let modernGovernance: [ModernGovernance]
        public let houseGovernance: [HouseGovernance]

        fileprivate let houseBySign: [Sign: House]
        fileprivate let signByHouse: [House: Sign]
        fileprivate let traditionallyGovernedHouses: [TraditionalGovernor: [House]]
        fileprivate let modernGovernedHouses: [Planet: [House]]
        fileprivate let governanceByHouse: [House: HouseGovernance]

        fileprivate init(
            risingSign: Sign,
            houses: [HouseRecord],
            traditionalGovernanceLattice: [TraditionalGovernanceGroup],
            modernGovernance: [ModernGovernance],
            houseGovernance: [HouseGovernance],
            houseBySign: [Sign: House],
            signByHouse: [House: Sign],
            traditionallyGovernedHouses: [TraditionalGovernor: [House]],
            modernGovernedHouses: [Planet: [House]],
            governanceByHouse: [House: HouseGovernance]
        ) {
            self.risingSign = risingSign
            self.houses = houses
            self.traditionalGovernanceLattice = traditionalGovernanceLattice
            self.modernGovernance = modernGovernance
            self.houseGovernance = houseGovernance
            self.houseBySign = houseBySign
            self.signByHouse = signByHouse
            self.traditionallyGovernedHouses = traditionallyGovernedHouses
            self.modernGovernedHouses = modernGovernedHouses
            self.governanceByHouse = governanceByHouse
        }

        public func governance(of house: House) -> HouseGovernance {
            governanceByHouse[house]!
        }

        public func housesGoverned(by governor: TraditionalGovernor) -> [House] {
            traditionallyGovernedHouses[governor] ?? []
        }

        public func housesModernlyGoverned(by planet: Planet) -> [House] {
            modernGovernedHouses[planet] ?? []
        }

        // Legacy V1 vocabulary. Canonical V2 callers should use housesGoverned(by:).
        public func housesRuled(by governor: TraditionalGovernor) -> [House] {
            housesGoverned(by: governor)
        }

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
                    signRuler: Mater.domicileRuler(of: sign),
                    modernGovernor: modernRulersBySign[sign]
                )
            }

            let traditionalGovernanceLattice = TraditionalGovernor.allCases.map { governor in
                TraditionalGovernanceGroup(
                    governor: governor,
                    houses: houses
                        .filter { $0.signRuler == governor.planet }
                        .map(\.house)
                )
            }

            let traditionallyGovernedHouses = Dictionary(
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

            let houseGovernance = House.canonicalOrder.map { house -> HouseGovernance in
                guard let record = houses.first(where: { $0.house == house }) else {
                    preconditionFailure("Tympan imprint is missing a house record.")
                }
                guard let traditionalGovernor = TraditionalGovernor(planet: record.signRuler) else {
                    preconditionFailure("Tympan traditional sign ruler is not a traditional governor.")
                }
                guard let governedHouses = traditionallyGovernedHouses[traditionalGovernor] else {
                    preconditionFailure("Tympan imprint is missing a traditional governance group.")
                }
                return HouseGovernance(
                    house: house,
                    sign: record.sign,
                    traditionalGovernor: traditionalGovernor,
                    traditionalGovernedHouses: governedHouses,
                    modernGovernor: record.modernGovernor
                )
            }

            let governanceByHouse = Dictionary(
                uniqueKeysWithValues: houseGovernance.map { ($0.house, $0) }
            )

            return Imprint(
                risingSign: risingSign,
                houses: houses,
                traditionalGovernanceLattice: traditionalGovernanceLattice,
                modernGovernance: modernGovernance,
                houseGovernance: houseGovernance,
                houseBySign: houseBySign,
                signByHouse: signByHouse,
                traditionallyGovernedHouses: traditionallyGovernedHouses,
                modernGovernedHouses: modernGovernedHouses,
                governanceByHouse: governanceByHouse
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
            precondition(imprint.houseGovernance.count == 12)
            precondition(imprint.houseGovernance.map(\.house) == House.canonicalOrder)
            precondition(imprint.governanceByHouse.count == 12)

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

            for governance in imprint.houseGovernance {
                guard let record = imprint.houses.first(where: { $0.house == governance.house }) else {
                    preconditionFailure("Tympan house governance has no matching house record.")
                }
                precondition(governance.sign == record.sign)
                precondition(governance.traditionalGovernor.planet == record.signRuler)
                precondition(
                    governance.traditionalGovernedHouses
                        == imprint.housesGoverned(by: governance.traditionalGovernor)
                )
                precondition(governance.modernGovernor == record.modernGovernor)
                precondition(imprint.governance(of: governance.house) == governance)
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

    public static func signRuler(of house: House, rising risingSign: Sign) -> Planet {
        Mater.domicileRuler(of: sign(of: house, rising: risingSign))
    }

    public static func traditionalGovernor(
        of house: House,
        rising risingSign: Sign
    ) -> TraditionalGovernor {
        governance(of: house, rising: risingSign).traditionalGovernor
    }

    public static func governance(of house: House, rising risingSign: Sign) -> HouseGovernance {
        imprint(for: risingSign).governance(of: house)
    }

    public static func modernRuler(of sign: Sign) -> Planet? {
        modernRulersBySign[sign]
    }

    public static func modernGovernor(of house: House, rising risingSign: Sign) -> Planet? {
        governance(of: house, rising: risingSign).modernGovernor
    }

    public static func housesGoverned(
        by governor: TraditionalGovernor,
        rising risingSign: Sign
    ) -> [House] {
        imprint(for: risingSign).housesGoverned(by: governor)
    }

    public static func housesModernlyGoverned(
        by planet: Planet,
        rising risingSign: Sign
    ) -> [House] {
        imprint(for: risingSign).housesModernlyGoverned(by: planet)
    }

    // Legacy V1 vocabulary retained as compatibility shims during the V2 transition.
    public static func ruler(of house: House, rising risingSign: Sign) -> Planet {
        signRuler(of: house, rising: risingSign)
    }

    public static func housesRuled(
        by governor: TraditionalGovernor,
        rising risingSign: Sign
    ) -> [House] {
        housesGoverned(by: governor, rising: risingSign)
    }

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
