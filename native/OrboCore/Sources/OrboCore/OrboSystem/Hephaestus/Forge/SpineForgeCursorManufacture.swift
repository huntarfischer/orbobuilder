import Foundation

extension SpineForge.Cursor {
    @discardableResult
    public mutating func step(
        reference: any SpineForgeEphemerisReference,
        segmentBudget: Int = 256
    ) throws -> SpineForgeProgress {
        guard segmentBudget > 0 else { return progress }
        var remaining = segmentBudget

        while remaining > 0, !isComplete {
            let bodyPlan = schematic.bodyPlans[bodyIndex]
            let body = bodyPlan.body

            if currentJulianDay == nil {
                let startState = try reference.state(of: body, at: schematic.bone.start)
                try beginBody(bodyPlan: bodyPlan, startState: startState)
            }

            guard let loJD = currentJulianDay, let loState = currentState else {
                throw SpineForgeError.malformedSchematic
            }

            if loJD.value >= schematic.bone.end.value - 1e-12 {
                finishCurrentBody()
                continue
            }

            let hiValue = min(loJD.value + bodyPlan.scanStepDays, schematic.bone.end.value)
            guard let hiJD = JulianDay(hiValue) else { throw SpineForgeError.malformedSchematic }
            let hiState = try reference.state(of: body, at: hiJD)

            try processSegment(
                reference: reference,
                bodyPlan: bodyPlan,
                loJD: loJD,
                hiJD: hiJD,
                loState: loState,
                hiState: hiState
            )

            currentJulianDay = hiJD
            currentState = hiState
            completedSegments += 1
            remaining -= 1

            if hiJD.value >= schematic.bone.end.value - 1e-12 {
                finishCurrentBody()
            }
        }

        return progress
    }

    public func product() throws -> SpineForgeProduct {
        guard isComplete else { throw SpineForgeError.incompleteManufacture }

        var forgedBodies: [SpineForgeBodyProduct] = []
        forgedBodies.reserveCapacity(schematic.bodyPlans.count)

        for bodyPlan in schematic.bodyPlans {
            guard let raw = rawByBody[bodyPlan.body] else {
                throw SpineForgeError.malformedSchematic
            }

            let supports = try raw.supports.map { row -> OrboSpineCelestialCoordinate in
                guard let directionalDegree = OrboSpineDirectionalDegree(
                    physicalDegrees: row.physicalDegrees,
                    motion: row.motion
                ) else {
                    throw SpineForgeError.malformedState(bodyPlan.body)
                }
                return OrboSpineCelestialCoordinate(
                    body: bodyPlan.body,
                    directionalDegree: directionalDegree,
                    julianDay: row.julianDay
                )
            }

            forgedBodies.append(
                SpineForgeBodyProduct(
                    body: bodyPlan.body,
                    supportDegrees: bodyPlan.supportDegrees,
                    supports: supports.sorted { $0.julianDay.value < $1.julianDay.value },
                    stations: raw.stations.sorted { $0.julianDay.value < $1.julianDay.value }
                )
            )
        }

        return SpineForgeProduct(
            schematicIdentity: schematic.identity,
            schematicVersion: schematic.version,
            astronomicalAuthority: schematic.astronomicalAuthority,
            astronomicalSourceVersion: schematic.astronomicalSourceVersion,
            bone: schematic.bone,
            bodies: forgedBodies
        )
    }

    mutating func beginBody(
        bodyPlan: SpineSchematicBodyPlan,
        startState: SpineForgeState
    ) throws {
        let body = bodyPlan.body
        var raw = rawByBody[body] ?? RawBody()
        let count = try Self.supportCountPerCircle(body: body, resolution: bodyPlan.supportDegrees)
        let scaled = startState.longitudeDegrees / bodyPlan.supportDegrees
        let nearest = Int(scaled.rounded())
        if abs(scaled - Double(nearest)) < 1e-7 {
            let physicalDegrees = Self.normalize(Double(nearest % count) * bodyPlan.supportDegrees)
            raw.supports.append(
                RawCrossing(
                    julianDay: schematic.bone.start,
                    physicalDegrees: physicalDegrees,
                    motion: Self.motion(forSpeed: startState.longitudinalSpeedDegreesPerDay)
                )
            )
        }

        rawByBody[body] = raw
        currentJulianDay = schematic.bone.start
        currentState = startState
    }

    mutating func finishCurrentBody() {
        guard bodyIndex < schematic.bodyPlans.count else { return }
        let body = schematic.bodyPlans[bodyIndex].body
        var raw = rawByBody[body] ?? RawBody()
        raw.supports.sort { $0.julianDay.value < $1.julianDay.value }
        raw.stations.sort { $0.julianDay.value < $1.julianDay.value }
        rawByBody[body] = raw
        bodyIndex += 1
        currentJulianDay = nil
        currentState = nil
    }
}
