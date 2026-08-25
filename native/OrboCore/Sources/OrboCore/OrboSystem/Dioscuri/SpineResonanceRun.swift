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
    enum CampaignChallenge: Equatable, Sendable {
        case celestial(SpineCelestialChallenge)
        case station(SpineStationChallenge)

        var body: MundaneBody {
            switch self {
            case let .celestial(challenge):
                return challenge.body
            case let .station(challenge):
                return challenge.body
            }
        }
    }

    public static func run(
        schematic: SpineSchematic,
        celestialProduct: SpineForgeProduct,
        assignment: SpineResonanceAssignment
    ) throws -> SpineResonanceTestimony {
        let challenges = try campaign(
            schematic: schematic,
            celestialProduct: celestialProduct
        )

        for challenge in challenges {
            let result: SpineResonanceResult
            switch challenge {
            case let .celestial(celestial):
                result = try assignment.resonate(
                    celestial,
                    celestialProduct: celestialProduct
                )
            case let .station(station):
                result = try assignment.resonate(
                    station,
                    celestialProduct: celestialProduct
                )
            }

            switch result {
            case .confirmed:
                continue
            case let .divergent(expected, returned):
                return SpineResonanceTestimony(
                    schematicIdentity: schematic.identity,
                    schematicVersion: schematic.version,
                    candidateIdentity: assignment.candidateIdentity,
                    result: .divergent(
                        body: challenge.body,
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

    static func campaign(
        schematic: SpineSchematic,
        celestialProduct: SpineForgeProduct
    ) throws -> [CampaignChallenge] {
        try requireMatching(schematic: schematic, celestialProduct: celestialProduct)

        var challenges: [CampaignChallenge] = []

        for bodyPlan in schematic.bodyPlans {
            guard let bodyProduct = celestialProduct.body(bodyPlan.body) else {
                throw SpineResonanceRunError.challengeUnavailable(bodyPlan.body)
            }

            let bodyStart = challenges.count

            if let direct = selectedInteriorChallenge(
                for: .direct,
                in: bodyProduct,
                bone: schematic.bone
            ) {
                challenges.append(.celestial(direct))
            }

            if let retrograde = selectedInteriorChallenge(
                for: .retrograde,
                in: bodyProduct,
                bone: schematic.bone
            ) {
                challenges.append(.celestial(retrograde))
            }

            if let directToRetrograde = selectedStationChallenge(
                laneBefore: .direct,
                laneAfter: .retrograde,
                in: bodyProduct,
                bone: schematic.bone
            ) {
                challenges.append(.station(directToRetrograde))
            }

            if let retrogradeToDirect = selectedStationChallenge(
                laneBefore: .retrograde,
                laneAfter: .direct,
                in: bodyProduct,
                bone: schematic.bone
            ) {
                challenges.append(.station(retrogradeToDirect))
            }

            guard challenges.count > bodyStart else {
                throw SpineResonanceRunError.challengeUnavailable(bodyPlan.body)
            }
        }

        if let wrap = selectedRetrogradeWrapChallenge(
            in: celestialProduct,
            bone: schematic.bone
        ) {
            challenges.append(.celestial(wrap))
        }

        return challenges
    }

    static func selectedInteriorChallenge(
        for motion: Motion,
        in bodyProduct: SpineForgeBodyProduct,
        bone: OrboSpineBoneSpan
    ) -> SpineCelestialChallenge? {
        let supports = bodyProduct.supports.sorted { $0.julianDay.value < $1.julianDay.value }
        guard supports.count >= 2 else { return nil }

        let boneMidpoint = (bone.start.value + bone.end.value) * 0.5
        var best: (
            lower: OrboSpineCelestialCoordinate,
            upper: OrboSpineCelestialCoordinate,
            midpoint: Double,
            distance: Double
        )?

        for index in 0..<(supports.count - 1) {
            let lower = supports[index]
            let upper = supports[index + 1]
            guard lower.directionalDegree.motion == motion,
                  upper.directionalDegree.motion == motion,
                  !hasStation(
                    between: lower.julianDay,
                    and: upper.julianDay,
                    stations: bodyProduct.stations
                  ) else {
                continue
            }

            let span = directionalDistance(
                from: lower.directionalDegree.physicalDegrees,
                to: upper.directionalDegree.physicalDegrees,
                motion: motion
            )
            guard span > epsilon else { continue }

            let midpoint = (lower.julianDay.value + upper.julianDay.value) * 0.5
            let distance = abs(midpoint - boneMidpoint)
            if best == nil
                || distance < best!.distance - epsilon
                || (abs(distance - best!.distance) <= epsilon && midpoint < best!.midpoint) {
                best = (lower, upper, midpoint, distance)
            }
        }

        guard let best else { return nil }
        return celestialChallenge(
            between: best.lower,
            and: best.upper,
            in: bodyProduct
        )
    }

    static func selectedStationChallenge(
        laneBefore: Motion,
        laneAfter: Motion,
        in bodyProduct: SpineForgeBodyProduct,
        bone: OrboSpineBoneSpan
    ) -> SpineStationChallenge? {
        let stations = bodyProduct.stations.sorted { $0.julianDay.value < $1.julianDay.value }
        let boneMidpoint = (bone.start.value + bone.end.value) * 0.5
        var best: (index: Int, julianDay: Double, distance: Double)?

        for (index, station) in stations.enumerated() {
            guard station.laneBefore == laneBefore,
                  station.laneAfter == laneAfter else {
                continue
            }
            let distance = abs(station.julianDay.value - boneMidpoint)
            if best == nil
                || distance < best!.distance - epsilon
                || (abs(distance - best!.distance) <= epsilon
                    && station.julianDay.value < best!.julianDay) {
                best = (index, station.julianDay.value, distance)
            }
        }

        guard let best else { return nil }
        return SpineStationChallenge(
            body: bodyProduct.body,
            occurrenceIndex: best.index
        )
    }

    static func selectedRetrogradeWrapChallenge(
        in celestialProduct: SpineForgeProduct,
        bone: OrboSpineBoneSpan
    ) -> SpineCelestialChallenge? {
        let boneMidpoint = (bone.start.value + bone.end.value) * 0.5
        var best: (
            bodyProduct: SpineForgeBodyProduct,
            lower: OrboSpineCelestialCoordinate,
            upper: OrboSpineCelestialCoordinate,
            midpoint: Double,
            distance: Double
        )?

        for bodyProduct in celestialProduct.bodies {
            let supports = bodyProduct.supports.sorted { $0.julianDay.value < $1.julianDay.value }
            guard supports.count >= 2 else { continue }

            for index in 0..<(supports.count - 1) {
                let lower = supports[index]
                let upper = supports[index + 1]
                guard lower.directionalDegree.motion == .retrograde,
                      upper.directionalDegree.motion == .retrograde,
                      lower.directionalDegree.physicalDegrees < upper.directionalDegree.physicalDegrees,
                      !hasStation(
                        between: lower.julianDay,
                        and: upper.julianDay,
                        stations: bodyProduct.stations
                      ) else {
                    continue
                }

                let span = directionalDistance(
                    from: lower.directionalDegree.physicalDegrees,
                    to: upper.directionalDegree.physicalDegrees,
                    motion: .retrograde
                )
                guard span > epsilon else { continue }

                let midpoint = (lower.julianDay.value + upper.julianDay.value) * 0.5
                let distance = abs(midpoint - boneMidpoint)
                if best == nil
                    || distance < best!.distance - epsilon
                    || (abs(distance - best!.distance) <= epsilon && midpoint < best!.midpoint) {
                    best = (bodyProduct, lower, upper, midpoint, distance)
                }
            }
        }

        guard let best else { return nil }
        return celestialChallenge(
            between: best.lower,
            and: best.upper,
            in: best.bodyProduct
        )
    }

    private static func celestialChallenge(
        between lower: OrboSpineCelestialCoordinate,
        and upper: OrboSpineCelestialCoordinate,
        in bodyProduct: SpineForgeBodyProduct
    ) -> SpineCelestialChallenge? {
        let motion = lower.directionalDegree.motion
        guard upper.directionalDegree.motion == motion else { return nil }

        let span = directionalDistance(
            from: lower.directionalDegree.physicalDegrees,
            to: upper.directionalDegree.physicalDegrees,
            motion: motion
        )
        guard span > epsilon else { return nil }

        let physicalDegrees = move(
            from: lower.directionalDegree.physicalDegrees,
            by: span * 0.5,
            motion: motion
        )
        guard let directionalDegree = OrboSpineDirectionalDegree(
            physicalDegrees: physicalDegrees,
            motion: motion
        ),
        let selectedJulianDay = JulianDay(
            (lower.julianDay.value + upper.julianDay.value) * 0.5
        ) else {
            return nil
        }

        let occurrences = PolluxResonator.occurrences(
            of: directionalDegree,
            in: bodyProduct
        )
        guard let occurrenceIndex = occurrences.firstIndex(where: {
            abs($0.julianDay.value - selectedJulianDay.value) <= epsilon
        }) else {
            return nil
        }

        return SpineCelestialChallenge(
            body: bodyProduct.body,
            directionalDegree: directionalDegree,
            occurrenceIndex: occurrenceIndex
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
