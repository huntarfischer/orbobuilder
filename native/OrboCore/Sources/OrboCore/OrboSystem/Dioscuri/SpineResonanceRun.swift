public enum SpineResonanceTestimonyResult: Equatable, Sendable {
    case confirmed
    case divergent(
        body: MundaneBody,
        expected: OrboSpineCelestialCoordinate,
        returned: OrboSpineCelestialCoordinate
    )
}

public struct SpineResonanceTestimony: Equatable, Sendable {
    public let schematicIdentity: String
    public let schematicVersion: UInt16
    public let candidateIdentity: String
    public let result: SpineResonanceTestimonyResult
}

public enum SpineResonanceRunError: Error, Equatable {
    case productMismatch
    case challengeUnavailable(MundaneBody)
}

/// One complete Schematic-driven Spine resonance run using the already-finished twins.
public enum SpineResonanceRun {
    public static func run(
        schematic: SpineSchematic,
        celestialProduct: SpineForgeProduct,
        assignment: SpineResonanceAssignment
    ) throws -> SpineResonanceTestimony {
        try requireMatching(schematic: schematic, celestialProduct: celestialProduct)

        for bodyPlan in schematic.bodyPlans {
            guard let bodyProduct = celestialProduct.body(bodyPlan.body),
                  let challenge = selectedChallenge(for: bodyProduct) else {
                throw SpineResonanceRunError.challengeUnavailable(bodyPlan.body)
            }

            switch try assignment.resonate(challenge, celestialProduct: celestialProduct) {
            case .confirmed:
                continue
            case let .divergent(expected, returned):
                return SpineResonanceTestimony(
                    schematicIdentity: schematic.identity,
                    schematicVersion: schematic.version,
                    candidateIdentity: assignment.candidateIdentity,
                    result: .divergent(
                        body: bodyPlan.body,
                        expected: expected,
                        returned: returned
                    )
                )
            }
        }

        return SpineResonanceTestimony(
            schematicIdentity: schematic.identity,
            schematicVersion: schematic.version,
            candidateIdentity: assignment.candidateIdentity,
            result: .confirmed
        )
    }

    static func selectedChallenge(
        for bodyProduct: SpineForgeBodyProduct
    ) -> SpineCelestialChallenge? {
        let supports = bodyProduct.supports.sorted { $0.julianDay.value < $1.julianDay.value }

        if supports.count >= 2 {
            for index in 0..<(supports.count - 1) {
                let lower = supports[index]
                let upper = supports[index + 1]
                let motion = lower.directionalDegree.motion

                guard upper.directionalDegree.motion == motion,
                      !hasStation(
                        between: lower.julianDay,
                        and: upper.julianDay,
                        stations: bodyProduct.stations
                      ) else {
                    continue
                }

                let distance = directionalDistance(
                    from: lower.directionalDegree.physicalDegrees,
                    to: upper.directionalDegree.physicalDegrees,
                    motion: motion
                )
                guard distance > epsilon else { continue }

                let physicalDegrees = move(
                    from: lower.directionalDegree.physicalDegrees,
                    by: distance * 0.5,
                    motion: motion
                )
                guard let directionalDegree = OrboSpineDirectionalDegree(
                    physicalDegrees: physicalDegrees,
                    motion: motion
                ) else {
                    continue
                }

                return SpineCelestialChallenge(
                    body: bodyProduct.body,
                    directionalDegree: directionalDegree
                )
            }
        }

        guard let first = supports.first else { return nil }
        return SpineCelestialChallenge(
            body: bodyProduct.body,
            directionalDegree: first.directionalDegree
        )
    }

    private static func requireMatching(
        schematic: SpineSchematic,
        celestialProduct: SpineForgeProduct
    ) throws {
        guard celestialProduct.schematicIdentity == schematic.identity,
              celestialProduct.schematicVersion == schematic.version,
              celestialProduct.bone == schematic.bone,
              celestialProduct.astronomicalAuthority == schematic.astronomicalAuthority,
              celestialProduct.astronomicalSourceVersion == schematic.astronomicalSourceVersion,
              celestialProduct.bodies.map(\.body) == schematic.bodyPlans.map(\.body),
              celestialProduct.bodies.count == schematic.bodyPlans.count else {
            throw SpineResonanceRunError.productMismatch
        }

        for (bodyProduct, bodyPlan) in zip(celestialProduct.bodies, schematic.bodyPlans) {
            guard bodyProduct.supportDegrees == bodyPlan.supportDegrees else {
                throw SpineResonanceRunError.productMismatch
            }
        }
    }

    private static let epsilon = 1e-10

    private static func hasStation(
        between lower: JulianDay,
        and upper: JulianDay,
        stations: [OrboSpineStation]
    ) -> Bool {
        stations.contains {
            $0.julianDay.value > lower.value + epsilon
                && $0.julianDay.value < upper.value - epsilon
        }
    }

    private static func directionalDistance(
        from start: Double,
        to end: Double,
        motion: Motion
    ) -> Double {
        switch motion {
        case .direct:
            return normalized(end - start)
        case .retrograde:
            return normalized(start - end)
        }
    }

    private static func move(
        from start: Double,
        by distance: Double,
        motion: Motion
    ) -> Double {
        switch motion {
        case .direct:
            return normalized(start + distance)
        case .retrograde:
            return normalized(start - distance)
        }
    }

    private static func normalized(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }
}
