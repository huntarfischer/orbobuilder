public extension Mater {
    enum HouseRoutingTerminalKind: String, Codable, Hashable, Sendable {
        case ownHouse = "own-house"
        case houseExchange = "house-exchange"
        case routingLoop = "routing-loop"
    }

    struct HouseRoutingKeeper: Hashable, Sendable {
        public let kind: HouseRoutingTerminalKind
        public let id: String

        fileprivate init(kind: HouseRoutingTerminalKind, id: String) {
            self.kind = kind
            self.id = id
        }
    }

    struct HouseRoutingCycle: Hashable, Sendable {
        public let id: String
        public let members: [House]
        public let length: Int
        public let kind: HouseRoutingTerminalKind

        fileprivate init(
            id: String,
            members: [House],
            kind: HouseRoutingTerminalKind
        ) {
            self.id = id
            self.members = members
            self.length = members.count
            self.kind = kind
        }
    }

    /// One frozen Tympan house form joined to the actual planetary placements.
    ///
    /// Tympan remains the authority for governorship. Mater only records where
    /// those already-known governors are actually placed in this supplied field.
    struct HousePlacement: Hashable, Sendable {
        public let house: House
        public let sign: Sign

        public let traditionalGovernor: Planet
        public let traditionalGovernorHouse: House

        /// Modern governorship is a separate Tympan augmentation, not a branch
        /// in the traditional house-routing graph.
        public let modernGovernor: Planet?
        public let modernGovernorHouse: House?

        public let routingPath: [House]
        public let keeper: HouseRoutingKeeper
        public let terminalKind: HouseRoutingTerminalKind
        public let cycleMembership: HouseRoutingCycle?

        fileprivate init(
            house: House,
            sign: Sign,
            traditionalGovernor: Planet,
            traditionalGovernorHouse: House,
            modernGovernor: Planet?,
            modernGovernorHouse: House?,
            routingPath: [House],
            keeper: HouseRoutingKeeper,
            terminalKind: HouseRoutingTerminalKind,
            cycleMembership: HouseRoutingCycle?
        ) {
            self.house = house
            self.sign = sign
            self.traditionalGovernor = traditionalGovernor
            self.traditionalGovernorHouse = traditionalGovernorHouse
            self.modernGovernor = modernGovernor
            self.modernGovernorHouse = modernGovernorHouse
            self.routingPath = routingPath
            self.keeper = keeper
            self.terminalKind = terminalKind
            self.cycleMembership = cycleMembership
        }
    }

    struct PlacementField: Sendable {
        public let field: Field
        public let risingSign: Sign
        public let houses: [HousePlacement]
        public let cycles: [HouseRoutingCycle]
        public let byHouse: [House: HousePlacement]

        fileprivate init(
            field: Field,
            risingSign: Sign,
            houses: [HousePlacement],
            cycles: [HouseRoutingCycle]
        ) {
            self.field = field
            self.risingSign = risingSign
            self.houses = houses
            self.cycles = cycles
            self.byHouse = Dictionary(uniqueKeysWithValues: houses.map { ($0.house, $0) })
        }

        public func placement(for house: House) -> HousePlacement {
            byHouse[house]!
        }
    }

    /// Joins one already-resolved Mater field to one frozen Tympan Imprint.
    ///
    /// No governorship is recalculated here. The Imprint supplies the governor;
    /// the field supplies the governor's actual sign; Tympan maps that sign to
    /// the occupied house.
    static func resolvePlacement(
        field: Field,
        in imprint: Tympan.Imprint
    ) -> PlacementField {
        let risingSign = imprint.risingSign

        let traditionalGovernorByHouse = Dictionary(
            uniqueKeysWithValues: House.canonicalOrder.map { house in
                (
                    house,
                    imprint.governance(of: house).traditionalGovernor.planet
                )
            }
        )

        let destinationByHouse = Dictionary(
            uniqueKeysWithValues: House.canonicalOrder.map { house -> (House, House) in
                let governor = traditionalGovernorByHouse[house]!
                let governorSign = field.placements[governor]!
                return (
                    house,
                    Tympan.house(of: governorSign, rising: risingSign)
                )
            }
        )

        var routeDrafts: [House: MaterHouseRouteDraft] = [:]
        var cyclesByID: [String: HouseRoutingCycle] = [:]

        func registerCycle(
            members: [House],
            kind: HouseRoutingTerminalKind
        ) -> HouseRoutingKeeper {
            let orderedMembers = members.sorted { $0.rawValue < $1.rawValue }
            let id = orderedMembers.map { String($0.rawValue) }.joined(separator: "+")
            if cyclesByID[id] == nil {
                cyclesByID[id] = HouseRoutingCycle(
                    id: id,
                    members: orderedMembers,
                    kind: kind
                )
            }
            return HouseRoutingKeeper(kind: kind, id: id)
        }

        for start in House.canonicalOrder {
            var path = [start]
            var seen: Set<House> = [start]
            var current = start
            var keeper: HouseRoutingKeeper?
            var terminalKind: HouseRoutingTerminalKind?

            while true {
                let next = destinationByHouse[current]!

                if next == current {
                    keeper = registerCycle(members: [current], kind: .ownHouse)
                    terminalKind = .ownHouse
                    break
                }

                if seen.contains(next) {
                    let cycleStart = path.firstIndex(of: next)!
                    let members = Array(path[cycleStart...])
                    let kind: HouseRoutingTerminalKind = members.count == 2
                        ? .houseExchange
                        : .routingLoop
                    keeper = registerCycle(members: members, kind: kind)
                    terminalKind = kind
                    break
                }

                path.append(next)
                seen.insert(next)
                current = next
            }

            routeDrafts[start] = MaterHouseRouteDraft(
                path: path,
                keeper: keeper!,
                terminalKind: terminalKind!
            )
        }

        let cycles = cyclesByID.values.sorted { lhs, rhs in
            let l = lhs.members.map(\.rawValue)
            let r = rhs.members.map(\.rawValue)
            return l.lexicographicallyPrecedes(r)
        }

        var cycleByHouse: [House: HouseRoutingCycle] = [:]
        for cycle in cycles {
            for house in cycle.members {
                cycleByHouse[house] = cycle
            }
        }

        let houses = House.canonicalOrder.map { house -> HousePlacement in
            let governance = imprint.governance(of: house)
            let traditionalGovernor = governance.traditionalGovernor.planet
            let traditionalGovernorHouse = destinationByHouse[house]!
            let modernGovernor = governance.modernGovernor
            let modernGovernorHouse = modernGovernor.map { governor in
                Tympan.house(of: field.placements[governor]!, rising: risingSign)
            }
            let route = routeDrafts[house]!

            return HousePlacement(
                house: house,
                sign: governance.sign,
                traditionalGovernor: traditionalGovernor,
                traditionalGovernorHouse: traditionalGovernorHouse,
                modernGovernor: modernGovernor,
                modernGovernorHouse: modernGovernorHouse,
                routingPath: route.path,
                keeper: route.keeper,
                terminalKind: route.terminalKind,
                cycleMembership: cycleByHouse[house]
            )
        }

        return PlacementField(
            field: field,
            risingSign: risingSign,
            houses: houses,
            cycles: cycles
        )
    }

    enum CrossFieldSide: String, Codable, Hashable, Sendable {
        case a
        case b
    }

    enum CrossReceptionDirection: String, Codable, Hashable, Sendable {
        case mutual
        case aInB = "a-in-b"
        case bInA = "b-in-a"
    }

    struct CrossHandoff: Hashable, Sendable {
        public let from: CrossFieldSide
        public let planet: Planet
        public let bearer: Planet
        public let landsInOtherField: Sign

        fileprivate init(
            from: CrossFieldSide,
            planet: Planet,
            bearer: Planet,
            landsInOtherField: Sign
        ) {
            self.from = from
            self.planet = planet
            self.bearer = bearer
            self.landsInOtherField = landsInOtherField
        }
    }

    struct CrossReception: Hashable, Sendable {
        /// Planet in field A.
        public let a: Planet

        /// Planet in field B.
        public let b: Planet

        public let direction: CrossReceptionDirection
        public let kind: MutualReceptionKind

        fileprivate init(
            a: Planet,
            b: Planet,
            direction: CrossReceptionDirection,
            kind: MutualReceptionKind
        ) {
            self.a = a
            self.b = b
            self.direction = direction
            self.kind = kind
        }
    }

    struct CrossField: Sendable {
        public let handoffs: [CrossHandoff]
        public let receptions: [CrossReception]

        fileprivate init(
            handoffs: [CrossHandoff],
            receptions: [CrossReception]
        ) {
            self.handoffs = handoffs
            self.receptions = receptions
        }
    }

    /// Resolves only the deterministic Mater relations between two already-
    /// resolved fields. A cross handoff is one step into the other field. It
    /// never becomes an alternating walk.
    static func resolveCrossField(_ a: Field, _ b: Field) -> CrossField {
        let handoffsA = Planet.canonicalOrder.map { planet -> CrossHandoff in
            let bearer = domicileRuler(of: a.placements[planet]!)
            return CrossHandoff(
                from: .a,
                planet: planet,
                bearer: bearer,
                landsInOtherField: b.placements[bearer]!
            )
        }

        let handoffsB = Planet.canonicalOrder.map { planet -> CrossHandoff in
            let bearer = domicileRuler(of: b.placements[planet]!)
            return CrossHandoff(
                from: .b,
                planet: planet,
                bearer: bearer,
                landsInOtherField: a.placements[bearer]!
            )
        }

        var receptions: [CrossReception] = []

        for aPlanet in Planet.classicalSeven {
            let signA = a.placements[aPlanet]!
            let aHome = domicileRuler(of: signA) == aPlanet

            for bPlanet in Planet.classicalSeven where bPlanet != aPlanet {
                let signB = b.placements[bPlanet]!
                let bHome = domicileRuler(of: signB) == bPlanet

                let aInDomicileOfB = !aHome && domicileRuler(of: signA) == bPlanet
                let aInExaltationOfB = !aHome && exaltation(in: signA)?.planet == bPlanet
                let bInDomicileOfA = !bHome && domicileRuler(of: signB) == aPlanet
                let bInExaltationOfA = !bHome && exaltation(in: signB)?.planet == aPlanet

                let aReceived = aInDomicileOfB || aInExaltationOfB
                let bReceived = bInDomicileOfA || bInExaltationOfA
                guard aReceived || bReceived else { continue }

                let direction: CrossReceptionDirection
                if aReceived && bReceived {
                    direction = .mutual
                } else if aReceived {
                    direction = .aInB
                } else {
                    direction = .bInA
                }

                let kind: MutualReceptionKind
                if aInDomicileOfB && bInDomicileOfA {
                    kind = .domicile
                } else if aInExaltationOfB && bInExaltationOfA {
                    kind = .exaltation
                } else if aReceived && bReceived {
                    kind = .mixed
                } else if aInDomicileOfB || bInDomicileOfA {
                    kind = .domicile
                } else {
                    kind = .exaltation
                }

                receptions.append(
                    CrossReception(
                        a: aPlanet,
                        b: bPlanet,
                        direction: direction,
                        kind: kind
                    )
                )
            }
        }

        return CrossField(
            handoffs: handoffsA + handoffsB,
            receptions: receptions
        )
    }
}

private struct MaterHouseRouteDraft {
    let path: [House]
    let keeper: Mater.HouseRoutingKeeper
    let terminalKind: Mater.HouseRoutingTerminalKind
}
