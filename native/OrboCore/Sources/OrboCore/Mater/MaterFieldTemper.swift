public extension Mater {
    enum DispositorTerminalKind: String, Codable, Hashable, Sendable {
        case domicile
        case mutualReception = "mutual-reception"
        case dispositorLoop = "dispositor-loop"
    }

    enum MutualReceptionKind: String, Codable, Hashable, Sendable {
        case domicile
        case exaltation
        case mixed
    }

    struct DispositorKeeper: Hashable, Sendable {
        public let kind: DispositorTerminalKind
        public let id: String

        fileprivate init(kind: DispositorTerminalKind, id: String) {
            self.kind = kind
            self.id = id
        }
    }

    struct DispositorCycle: Hashable, Sendable {
        public let id: String
        public let members: [Planet]
        public let length: Int
        public let kind: DispositorTerminalKind

        fileprivate init(id: String, members: [Planet], kind: DispositorTerminalKind) {
            self.id = id
            self.members = members
            self.length = members.count
            self.kind = kind
        }
    }

    struct MutualReception: Hashable, Sendable {
        public let a: Planet
        public let b: Planet
        public let kind: MutualReceptionKind

        fileprivate init(a: Planet, b: Planet, kind: MutualReceptionKind) {
            self.a = a
            self.b = b
            self.kind = kind
        }
    }

    /// One planet's reusable Temper resolved inside one complete planetary field.
    ///
    /// The reusable sign Temper is referenced directly. Only facts that require
    /// the other placements in the field are added here.
    struct FieldTemper: Hashable, Sendable {
        public let planet: Planet
        public let temper: Temper
        public let dispositorCapable: Bool

        public let bearer: Planet
        public let dispositorPath: [Planet]
        public let keeper: DispositorKeeper
        public let terminalKind: DispositorTerminalKind
        public let cycleMembership: DispositorCycle?

        /// Immediate condition answer. Never inferred downstream from details.
        public let mutualReception: Bool
        public let mutualReceptionWith: [Planet]
        public let mutualReceptionKinds: [MutualReceptionKind]

        public let immediateDependents: [Planet]
        public let transitiveDescendants: [Planet]

        fileprivate init(
            planet: Planet,
            temper: Temper,
            dispositorCapable: Bool,
            bearer: Planet,
            dispositorPath: [Planet],
            keeper: DispositorKeeper,
            terminalKind: DispositorTerminalKind,
            cycleMembership: DispositorCycle?,
            mutualReception: Bool,
            mutualReceptionWith: [Planet],
            mutualReceptionKinds: [MutualReceptionKind],
            immediateDependents: [Planet],
            transitiveDescendants: [Planet]
        ) {
            self.planet = planet
            self.temper = temper
            self.dispositorCapable = dispositorCapable
            self.bearer = bearer
            self.dispositorPath = dispositorPath
            self.keeper = keeper
            self.terminalKind = terminalKind
            self.cycleMembership = cycleMembership
            self.mutualReception = mutualReception
            self.mutualReceptionWith = mutualReceptionWith
            self.mutualReceptionKinds = mutualReceptionKinds
            self.immediateDependents = immediateDependents
            self.transitiveDescendants = transitiveDescendants
        }
    }

    /// Complete one-field Mater resolution for the ten canonical planets.
    ///
    /// Pass 2 is intentionally sign-resolution only. Houses, Tympan placement
    /// routing, and relations between two separate fields remain outside it.
    struct Field: Sendable {
        public let placements: [Planet: Sign]
        public let tempers: [FieldTemper]
        public let cycles: [DispositorCycle]
        public let mutualReceptions: [MutualReception]
        public let byPlanet: [Planet: FieldTemper]

        fileprivate init(
            placements: [Planet: Sign],
            tempers: [FieldTemper],
            cycles: [DispositorCycle],
            mutualReceptions: [MutualReception]
        ) {
            self.placements = placements
            self.tempers = tempers
            self.cycles = cycles
            self.mutualReceptions = mutualReceptions
            self.byPlanet = Dictionary(uniqueKeysWithValues: tempers.map { ($0.planet, $0) })
        }

        public func temper(for planet: Planet) -> FieldTemper {
            byPlanet[planet]!
        }
    }

    /// Resolves the complete traditional dispositor/reception circuitry for one
    /// canonical ten-planet field. Modern planets occupy signs and therefore
    /// receive traditional bearers, but the classical seven remain the only
    /// dispositor-capable backbone in Pass 2.
    static func resolveField(_ placements: [Planet: Sign]) -> Field {
        precondition(
            Set(placements.keys) == Set(Planet.canonicalOrder),
            "Mater.resolveField requires exactly the ten canonical planetary placements."
        )

        let bearerByPlanet = Dictionary(
            uniqueKeysWithValues: Planet.canonicalOrder.map { planet in
                (planet, domicileRuler(of: placements[planet]!))
            }
        )

        var chains: [Planet: MaterFieldChainDraft] = [:]
        var cyclesByID: [String: DispositorCycle] = [:]

        func registerCycle(
            members: [Planet],
            kind: DispositorTerminalKind
        ) -> DispositorKeeper {
            let orderedMembers = members.sorted { $0.rawValue < $1.rawValue }
            let id = orderedMembers.map(\.rawValue).joined(separator: "+")
            if cyclesByID[id] == nil {
                cyclesByID[id] = DispositorCycle(
                    id: id,
                    members: orderedMembers,
                    kind: kind
                )
            }
            return DispositorKeeper(kind: kind, id: id)
        }

        for start in Planet.canonicalOrder {
            var path = [start]
            var seen: Set<Planet> = [start]
            var current = start
            var keeper: DispositorKeeper?
            var terminalKind: DispositorTerminalKind?

            while true {
                if current.isClassical, bearerByPlanet[current] == current {
                    keeper = registerCycle(members: [current], kind: .domicile)
                    terminalKind = .domicile
                    break
                }

                let next = bearerByPlanet[current]!
                if seen.contains(next) {
                    let cycleStart = path.firstIndex(of: next)!
                    let members = Array(path[cycleStart...])
                    let kind: DispositorTerminalKind = members.count == 2
                        ? .mutualReception
                        : .dispositorLoop
                    keeper = registerCycle(members: members, kind: kind)
                    terminalKind = kind
                    break
                }

                path.append(next)
                seen.insert(next)
                current = next
            }

            chains[start] = MaterFieldChainDraft(
                bearer: bearerByPlanet[start]!,
                path: path,
                keeper: keeper!,
                terminalKind: terminalKind!
            )
        }

        let cycles = cyclesByID.values.sorted { $0.id < $1.id }
        var cycleByMember: [Planet: DispositorCycle] = [:]
        for cycle in cycles {
            for member in cycle.members {
                cycleByMember[member] = cycle
            }
        }

        var receptions: [MutualReception] = []
        for i in Planet.classicalSeven.indices {
            for j in Planet.classicalSeven.index(after: i)..<Planet.classicalSeven.endIndex {
                let a = Planet.classicalSeven[i]
                let b = Planet.classicalSeven[j]
                let signA = placements[a]!
                let signB = placements[b]!

                // Preserve the recovered Orbo rule: a planet at home is host,
                // not guest, and does not form a reception through that stay.
                if domicileRuler(of: signA) == a || domicileRuler(of: signB) == b {
                    continue
                }

                let aInDomicileOfB = domicileRuler(of: signA) == b
                let aInExaltationOfB = exaltation(in: signA)?.planet == b
                let bInDomicileOfA = domicileRuler(of: signB) == a
                let bInExaltationOfA = exaltation(in: signB)?.planet == a

                let kind: MutualReceptionKind?
                if aInDomicileOfB && bInDomicileOfA {
                    kind = .domicile
                } else if aInExaltationOfB && bInExaltationOfA {
                    kind = .exaltation
                } else if (aInDomicileOfB && bInExaltationOfA)
                    || (aInExaltationOfB && bInDomicileOfA) {
                    kind = .mixed
                } else {
                    kind = nil
                }

                if let kind {
                    receptions.append(MutualReception(a: a, b: b, kind: kind))
                }
            }
        }

        var receptionDetailsByPlanet: [Planet: [(partner: Planet, kind: MutualReceptionKind)]] = [:]
        for reception in receptions {
            receptionDetailsByPlanet[reception.a, default: []].append(
                (partner: reception.b, kind: reception.kind)
            )
            receptionDetailsByPlanet[reception.b, default: []].append(
                (partner: reception.a, kind: reception.kind)
            )
        }

        let fieldTempers = Planet.canonicalOrder.map { planet -> FieldTemper in
            let chain = chains[planet]!
            let details = receptionDetailsByPlanet[planet, default: []]
            let orderedDetails = Planet.canonicalOrder.compactMap { candidate in
                details.first { $0.partner == candidate }
            }

            let immediateDependents = Planet.canonicalOrder.filter { candidate in
                bearerByPlanet[candidate] == planet
            }

            let transitiveDescendants = Planet.canonicalOrder.filter { candidate in
                guard candidate != planet,
                      let index = chains[candidate]!.path.firstIndex(of: planet)
                else {
                    return false
                }
                return index > 0
            }

            return FieldTemper(
                planet: planet,
                temper: temper(of: planet, in: placements[planet]!),
                dispositorCapable: planet.isClassical,
                bearer: chain.bearer,
                dispositorPath: chain.path,
                keeper: chain.keeper,
                terminalKind: chain.terminalKind,
                cycleMembership: cycleByMember[planet],
                mutualReception: !orderedDetails.isEmpty,
                mutualReceptionWith: orderedDetails.map { $0.partner },
                mutualReceptionKinds: orderedDetails.map { $0.kind },
                immediateDependents: immediateDependents,
                transitiveDescendants: transitiveDescendants
            )
        }

        return Field(
            placements: placements,
            tempers: fieldTempers,
            cycles: cycles,
            mutualReceptions: receptions
        )
    }
}

private struct MaterFieldChainDraft {
    let bearer: Planet
    let path: [Planet]
    let keeper: Mater.DispositorKeeper
    let terminalKind: Mater.DispositorTerminalKind
}
