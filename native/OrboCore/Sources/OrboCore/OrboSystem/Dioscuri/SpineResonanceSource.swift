/// The celestial matter Pollux is allowed to question. It carries forged supports and exact
/// station topology without exposing how that matter was manufactured or stored.
public struct SpineResonanceBodyMatter: Sendable {
    public let body: MundaneBody
    public let supportDegrees: Double
    public let supports: [OrboSpineCelestialCoordinate]
    public let stations: [OrboSpineStation]

    public init?(
        body: MundaneBody,
        supportDegrees: Double,
        supports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation]
    ) {
        guard supportDegrees.isFinite,
              supportDegrees > 0,
              supports.allSatisfy({ $0.body == body }),
              stations.allSatisfy({ $0.body == body }) else {
            return nil
        }
        self.body = body
        self.supportDegrees = supportDegrees
        self.supports = supports
        self.stations = stations
    }

    init(_ product: SpineForgeBodyProduct) {
        self.body = product.body
        self.supportDegrees = product.supportDegrees
        self.supports = product.supports
        self.stations = product.stations
    }
}

/// Pollux's independent source boundary. A resonance source is the matter from which a
/// candidate Spine was forged, never the candidate runtime itself.
public protocol SpineResonanceSource: Sendable {
    var schematicIdentity: String { get }
    var schematicVersion: UInt16 { get }
    var astronomicalAuthority: String { get }
    var astronomicalSourceVersion: String { get }
    var bone: OrboSpineBoneSpan { get }
    var resonanceBodyOrder: [MundaneBody] { get }

    func resonanceBody(_ body: MundaneBody) -> SpineResonanceBodyMatter?
}

/// The live in-memory Forge product remains a valid Pollux source for manufacture ceremonies
/// and deterministic tests, but Pollux no longer depends on this concrete type.
extension SpineForgeProduct: SpineResonanceSource {
    public var resonanceBodyOrder: [MundaneBody] {
        bodies.map(\.body)
    }

    public func resonanceBody(_ body: MundaneBody) -> SpineResonanceBodyMatter? {
        self.body(body).map(SpineResonanceBodyMatter.init)
    }
}

/// Pollux's production OrboSpine source over already-validated durable celestial matter.
/// Candidate/assembly tooling owns file paths, hashes, and decoding; this value owns only the
/// independent supports/stations traversal presented to the Dioscuri.
public struct OrboSpineDurableCelestialResonanceSource: SpineResonanceSource {
    public let schematicIdentity: String
    public let schematicVersion: UInt16
    public let astronomicalAuthority: String
    public let astronomicalSourceVersion: String
    public let bone: OrboSpineBoneSpan
    public let resonanceBodyOrder: [MundaneBody]

    private let bodiesByIdentity: [MundaneBody: SpineResonanceBodyMatter]

    /// Forms directly from the validated celestial rows the assembly path already loads.
    public init?(
        schematic: SpineSchematic,
        supports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation]
    ) {
        let expectedBodies = Set(schematic.bodyPlans.map(\.body))
        guard supports.allSatisfy({ expectedBodies.contains($0.body) }),
              stations.allSatisfy({ expectedBodies.contains($0.body) }) else {
            return nil
        }

        let bodies = schematic.bodyPlans.compactMap { bodyPlan in
            SpineResonanceBodyMatter(
                body: bodyPlan.body,
                supportDegrees: bodyPlan.supportDegrees,
                supports: supports.filter { $0.body == bodyPlan.body },
                stations: stations.filter { $0.body == bodyPlan.body }
            )
        }
        guard bodies.count == schematic.bodyPlans.count else { return nil }
        self.init(schematic: schematic, bodies: bodies)
    }

    public init?(
        schematic: SpineSchematic,
        bodies: [SpineResonanceBodyMatter]
    ) {
        let bodyOrder = bodies.map(\.body)
        guard bodyOrder == schematic.bodyPlans.map(\.body),
              Set(bodyOrder).count == bodyOrder.count else {
            return nil
        }

        for (bodyMatter, bodyPlan) in zip(bodies, schematic.bodyPlans) {
            guard bodyMatter.supportDegrees == bodyPlan.supportDegrees,
                  bodyMatter.supports.allSatisfy({ schematic.bone.contains($0.julianDay) }),
                  bodyMatter.stations.allSatisfy({ schematic.bone.contains($0.julianDay) }) else {
                return nil
            }
        }

        self.schematicIdentity = schematic.identity
        self.schematicVersion = schematic.version
        self.astronomicalAuthority = schematic.astronomicalAuthority
        self.astronomicalSourceVersion = schematic.astronomicalSourceVersion
        self.bone = schematic.bone
        self.resonanceBodyOrder = bodyOrder
        self.bodiesByIdentity = Dictionary(uniqueKeysWithValues: bodies.map { ($0.body, $0) })
    }

    public func resonanceBody(_ body: MundaneBody) -> SpineResonanceBodyMatter? {
        bodiesByIdentity[body]
    }
}
