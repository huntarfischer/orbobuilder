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
        source: any SpineResonanceSource,
        assignment: SpineResonanceAssignment
    ) throws -> SpineResonanceTestimony {
        try requireMatching(schematic: schematic, source: source)

        for bodyPlan in schematic.bodyPlans {
            guard let bodyMatter = source.resonanceBody(bodyPlan.body) else {
                throw SpineResonanceRunError.challengeUnavailable(bodyPlan.body)
            }
            let challenges = bodyChallenges(
                for: bodyMatter,
                bone: schematic.bone
            )
            guard !challenges.isEmpty else {
                throw SpineResonanceRunError.challengeUnavailable(bodyPlan.body)
            }

            for challenge in challenges {
                if let testimony = try divergenceTestimony(
                    for: challenge,
                    schematic: schematic,
                    source: source,
                    assignment: assignment
                ) {
                    return testimony
                }
            }
        }

        if let wrap = selectedRetrogradeWrapChallenge(
            in: source,
            bone: schematic.bone
        ),
        let testimony = try divergenceTestimony(
            for: .celestial(wrap),
            schematic: schematic,
            source: source,
            assignment: assignment
        ) {
            return testimony
        }

        return SpineResonanceTestimony(
            schematicIdentity: schematic.identity,
            schematicVersion: schematic.version,
            candidateIdentity: assignment.candidateIdentity,
            result: .confirmed
        )
    }

    /// Compatibility for the already-proven Stage 2 fixture surface. The campaign itself runs
    /// only through SpineResonanceSource.
    public static func run(
        schematic: SpineSchematic,
        celestialProduct: SpineForgeProduct,
        assignment: SpineResonanceAssignment
    ) throws -> SpineResonanceTestimony {
        try run(
            schematic: schematic,
            source: celestialProduct,
            assignment: assignment
        )
    }

    static func campaign(
        schematic: SpineSchematic,
        source: any SpineResonanceSource
    ) throws -> [CampaignChallenge] {
        try requireMatching(schematic: schematic, source: source)

        var challenges: [CampaignChallenge] = []
        for bodyPlan in schematic.bodyPlans {
            guard let bodyMatter = source.resonanceBody(bodyPlan.body) else {
                throw SpineResonanceRunError.challengeUnavailable(bodyPlan.body)
            }
            let selected = bodyChallenges(
                for: bodyMatter,
                bone: schematic.bone
            )
            guard !selected.isEmpty else {
                throw SpineResonanceRunError.challengeUnavailable(bodyPlan.body)
            }
            challenges.append(contentsOf: selected)
        }

        if let wrap = selectedRetrogradeWrapChallenge(
            in: source,
            bone: schematic.bone
        ) {
            challenges.append(.celestial(wrap))
        }
        return challenges
    }

    /// Compatibility for the already-proven Stage 2 fixture surface. Selection remains owned
    /// by the source-matter path above.
    static func campaign(
        schematic: SpineSchematic,
        celestialProduct: SpineForgeProduct
    ) throws -> [CampaignChallenge] {
        try campaign(schematic: schematic, source: celestialProduct)
    }

    static func selectedInteriorChallenge(
        for motion: Motion,
        in bodyMatter: SpineResonanceBodyMatter,
        bone: OrboSpineBoneSpan
    ) -> SpineCelestialChallenge? {
        let supports = bodyMatter.supports.sorted { $0.julianDay.value < $1.julianDay.value }
        guard supports.count >= 2 else { return nil }
        let stationJulianDays = bodyMatter.stations.map(\.julianDay.value).sorted()

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
                    sortedStationJulianDays: stationJulianDays
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
            in: bodyMatter
        )
    }

    static func selectedInteriorChallenge(
        for motion: Motion,
        in bodyProduct: SpineForgeBodyProduct,
        bone: OrboSpineBoneSpan
    ) -> SpineCelestialChallenge? {
        selectedInteriorChallenge(
            for: motion,
            in: SpineResonanceBodyMatter(bodyProduct),
            bone: bone
        )
    }

    static func selectedStationChallenge(
        laneBefore: Motion,
        laneAfter: Motion,
        in bodyMatter: SpineResonanceBodyMatter,
        bone: OrboSpineBoneSpan
    ) -> SpineStationChallenge? {
        let stations = bodyMatter.stations.sorted { $0.julianDay.value < $1.julianDay.value }
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
            body: bodyMatter.body,
            occurrenceIndex: best.index
        )
    }

    static func selectedStationChallenge(
        laneBefore: Motion,
        laneAfter: Motion,
        in bodyProduct: SpineForgeBodyProduct,
        bone: OrboSpineBoneSpan
    ) -> SpineStationChallenge? {
        selectedStationChallenge(
            laneBefore: laneBefore,
            laneAfter: laneAfter,
            in: SpineResonanceBodyMatter(bodyProduct),
            bone: bone
        )
    }

    static func selectedRetrogradeWrapChallenge(
        in source: any SpineResonanceSource,
        bone: OrboSpineBoneSpan
    ) -> SpineCelestialChallenge? {
        let boneMidpoint = (bone.start.value + bone.end.value) * 0.5
        var best: (
            bodyMatter: SpineResonanceBodyMatter,
            lower: OrboSpineCelestialCoordinate,
            upper: OrboSpineCelestialCoordinate,
            midpoint: Double,
            distance: Double
        )?

        for body in source.resonanceBodyOrder {
            guard let bodyMatter = source.resonanceBody(body) else { continue }
            let supports = bodyMatter.supports.sorted { $0.julianDay.value < $1.julianDay.value }
            guard supports.count >= 2 else { continue }
            let stationJulianDays = bodyMatter.stations.map(\.julianDay.value).sorted()

            for index in 0..<(supports.count - 1) {
                let lower = supports[index]
                let upper = supports[index + 1]
                guard lower.directionalDegree.motion == .retrograde,
                      upper.directionalDegree.motion == .retrograde,
                      lower.directionalDegree.physicalDegrees < upper.directionalDegree.physicalDegrees,
                      !hasStation(
                        between: lower.julianDay,
                        and: upper.julianDay,
                        sortedStationJulianDays: stationJulianDays
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
                    best = (bodyMatter, lower, upper, midpoint, distance)
                }
            }
        }

        guard let best else { return nil }
        return celestialChallenge(
            between: best.lower,
            and: best.upper,
            in: best.bodyMatter
        )
    }

    static func selectedRetrogradeWrapChallenge(
        in celestialProduct: SpineForgeProduct,
        bone: OrboSpineBoneSpan
    ) -> SpineCelestialChallenge? {
        selectedRetrogradeWrapChallenge(in: celestialProduct as any SpineResonanceSource, bone: bone)
    }

    private static func bodyChallenges(
        for bodyMatter: SpineResonanceBodyMatter,
        bone: OrboSpineBoneSpan
    ) -> [CampaignChallenge] {
        var challenges: [CampaignChallenge] = []

        if let direct = selectedInteriorChallenge(
            for: .direct,
            in: bodyMatter,
            bone: bone
        ) {
            challenges.append(.celestial(direct))
        }
        if let retrograde = selectedInteriorChallenge(
            for: .retrograde,
            in: bodyMatter,
            bone: bone
        ) {
            challenges.append(.celestial(retrograde))
        }
        if let directToRetrograde = selectedStationChallenge(
            laneBefore: .direct,
            laneAfter: .retrograde,
            in: bodyMatter,
            bone: bone
        ) {
            challenges.append(.station(directToRetrograde))
        }
        if let retrogradeToDirect = selectedStationChallenge(
            laneBefore: .retrograde,
            laneAfter: .direct,
            in: bodyMatter,
            bone: bone
        ) {
            challenges.append(.station(retrogradeToDirect))
        }

        return challenges
    }

    private static func celestialChallenge(
        between lower: OrboSpineCelestialCoordinate,
        and upper: OrboSpineCelestialCoordinate,
        in bodyMatter: SpineResonanceBodyMatter
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
            in: bodyMatter
        )
        guard let occurrenceIndex = occurrences.firstIndex(where: {
            abs($0.julianDay.value - selectedJulianDay.value) <= epsilon
        }) else {
            return nil
        }

        return SpineCelestialChallenge(
            body: bodyMatter.body,
            directionalDegree: directionalDegree,
            occurrenceIndex: occurrenceIndex
        )
    }

    private static func divergenceTestimony(
        for challenge: CampaignChallenge,
        schematic: SpineSchematic,
        source: any SpineResonanceSource,
        assignment: SpineResonanceAssignment
    ) throws -> SpineResonanceTestimony? {
        let result: SpineResonanceResult
        switch challenge {
        case let .celestial(celestial):
            result = try assignment.resonate(
                celestial,
                source: source
            )
        case let .station(station):
            result = try assignment.resonate(
                station,
                source: source
            )
        }

        guard case let .divergent(expected, returned) = result else {
            return nil
        }
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

    private static func requireMatching(
        schematic: SpineSchematic,
        source: any SpineResonanceSource
    ) throws {
        guard source.schematicIdentity == schematic.identity,
              source.schematicVersion == schematic.version,
              source.bone == schematic.bone,
              source.astronomicalAuthority == schematic.astronomicalAuthority,
              source.astronomicalSourceVersion == schematic.astronomicalSourceVersion,
              source.resonanceBodyOrder == schematic.bodyPlans.map(\.body) else {
            throw SpineResonanceRunError.productMismatch
        }

        for bodyPlan in schematic.bodyPlans {
            guard let bodyMatter = source.resonanceBody(bodyPlan.body),
                  bodyMatter.body == bodyPlan.body,
                  bodyMatter.supportDegrees == bodyPlan.supportDegrees else {
                throw SpineResonanceRunError.productMismatch
            }
        }
    }

    private static let epsilon = 1e-10

    private static func hasStation(
        between lower: JulianDay,
        and upper: JulianDay,
        sortedStationJulianDays: [Double]
    ) -> Bool {
        let lowerBound = lower.value + epsilon
        let upperBound = upper.value - epsilon
        guard lowerBound < upperBound, !sortedStationJulianDays.isEmpty else { return false }

        var low = 0
        var high = sortedStationJulianDays.count
        while low < high {
            let mid = low + (high - low) / 2
            if sortedStationJulianDays[mid] <= lowerBound {
                low = mid + 1
            } else {
                high = mid
            }
        }

        return low < sortedStationJulianDays.count
            && sortedStationJulianDays[low] < upperBound
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
