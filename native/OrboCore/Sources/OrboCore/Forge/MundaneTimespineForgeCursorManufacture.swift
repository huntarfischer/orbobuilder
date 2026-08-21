import Foundation

extension MundaneTimespineForge.Cursor {
    @discardableResult
    public mutating func step(
        reference: any ForgeEphemerisReference,
        segmentBudget: Int = 256
    ) throws -> MundaneTimespineForgeProgress {
        guard segmentBudget > 0 else { return progress }
        var remaining = segmentBudget

        while remaining > 0, !isComplete {
            let bodyPlan = plan.bodyPlans[bodyIndex]
            let body = bodyPlan.contract.body

            if currentJulianDay == nil {
                let startState = try reference.state(of: body, at: plan.supportedStart)
                try beginBody(bodyPlan: bodyPlan, startState: startState)
            }

            guard let loJD = currentJulianDay, let loState = currentState else {
                throw MundaneTimespineForgeError.malformedPlan
            }

            if loJD.value >= plan.supportedEnd.value - 1e-12 {
                try finishCurrentBody(finalState: loState)
                continue
            }

            let hiValue = min(loJD.value + bodyPlan.scanStepDays, plan.supportedEnd.value)
            guard let hiJD = JulianDay(hiValue) else { throw MundaneTimespineForgeError.malformedPlan }
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

            if hiJD.value >= plan.supportedEnd.value - 1e-12 {
                try finishCurrentBody(finalState: hiState)
            }
        }

        return progress
    }

    public func product() throws -> MundaneTimespineForgeProduct {
        guard isComplete else { throw MundaneTimespineForgeError.incompleteManufacture }

        let wholeDegreeRows = try makeWholeDegreeRows()
        var forgedBodies: [MundaneTimespineForgedBody] = []
        forgedBodies.reserveCapacity(plan.bodyPlans.count)

        for bodyPlan in plan.bodyPlans {
            let contract = bodyPlan.contract
            guard let raw = rawByBody[contract.body],
                  let initialState = raw.initialState,
                  let finalState = raw.finalState else {
                throw MundaneTimespineForgeError.malformedPlan
            }

            if plan.verifiesConstructionRecordCounts,
               raw.selected.count != contract.constructionRecordCount {
                throw MundaneTimespineForgeError.recordCountMismatch(
                    body: contract.body,
                    expected: contract.constructionRecordCount,
                    actual: raw.selected.count
                )
            }

            let markerArrays = contract.markerBodies.map { markerBody in
                Self.simultaneousWholeDegreeCells(
                    focalRows: raw.selected,
                    markerRows: wholeDegreeRows[markerBody] ?? []
                )
            }

            var occurrenceByTick: [Int: Int] = [:]
            var occurrences: [MundaneForgedOccurrence] = []
            occurrences.reserveCapacity(raw.selected.count)
            var uniqueness = Set<OccurrenceKey>()
            uniqueness.reserveCapacity(raw.selected.count)

            for index in raw.selected.indices {
                let row = raw.selected[index]
                occurrenceByTick[row.tick, default: 0] += 1
                let markers = contract.markerBodies.enumerated().map { markerIndex, markerBody in
                    MundaneForgeMarker(body: markerBody, wholeDegree: markerArrays[markerIndex][index])
                }
                let key = OccurrenceKey(
                    focalTick: row.tick,
                    markerDegrees: markers.map(\.wholeDegree)
                )
                if plan.verifiesMarkerUniqueness, !uniqueness.insert(key).inserted {
                    throw MundaneTimespineForgeError.markerCollision(body: contract.body)
                }
                let offset = Int64(((row.julianDay.value - plan.supportedStart.value) * 86_400).rounded())
                occurrences.append(
                    MundaneForgedOccurrence(
                        focalCelestialTick: row.tick,
                        focalCelestialDegrees: Double(row.tick) * contract.celestialResolutionDegrees,
                        occurrence: occurrenceByTick[row.tick]!,
                        civicOffsetSeconds: offset,
                        julianDay: row.julianDay,
                        sequenceDirection: row.direction,
                        markers: markers
                    )
                )
            }

            forgedBodies.append(
                MundaneTimespineForgedBody(
                    body: contract.body,
                    celestialResolutionDegrees: contract.celestialResolutionDegrees,
                    markerBodies: contract.markerBodies,
                    occurrences: occurrences,
                    stations: raw.stations.sorted { $0.julianDay.value < $1.julianDay.value },
                    retrogradePassages: Self.makeRetrogradePassages(
                        body: contract.body,
                        start: plan.supportedStart,
                        end: plan.supportedEnd,
                        initialState: initialState,
                        finalState: finalState,
                        stations: raw.stations
                    )
                )
            )
        }

        return MundaneTimespineForgeProduct(
            spanName: plan.spanName,
            astronomicalSource: plan.astronomicalSource,
            astronomicalSourceVersion: plan.astronomicalSourceVersion,
            supportedStart: plan.supportedStart,
            supportedEnd: plan.supportedEnd,
            bodies: forgedBodies
        )
    }

    mutating func beginBody(
        bodyPlan: MundaneTimespineForgeBodyPlan,
        startState: MundaneForgeState
    ) throws {
        let body = bodyPlan.contract.body
        var raw = rawByBody[body] ?? RawBody()
        raw.initialState = startState

        let resolution = bodyPlan.contract.celestialResolutionDegrees
        let ticksPerCircle = try Self.ticksPerCircle(body: body, resolution: resolution)
        let scaled = startState.longitudeDegrees / resolution
        let nearest = Int(scaled.rounded())
        if abs(scaled - Double(nearest)) < 1e-7 {
            raw.selected.append(
                RawCrossing(
                    julianDay: plan.supportedStart,
                    tick: Self.mod(nearest, ticksPerCircle),
                    direction: .from(speed: startState.longitudinalSpeedDegreesPerDay)
                )
            )
        }

        rawByBody[body] = raw
        currentJulianDay = plan.supportedStart
        currentState = startState
    }

    mutating func finishCurrentBody(finalState: MundaneForgeState) throws {
        guard bodyIndex < plan.bodyPlans.count else { return }
        let body = plan.bodyPlans[bodyIndex].contract.body
        var raw = rawByBody[body] ?? RawBody()
        raw.finalState = finalState
        raw.selected.sort { $0.julianDay.value < $1.julianDay.value }
        raw.stations.sort { $0.julianDay.value < $1.julianDay.value }
        rawByBody[body] = raw
        bodyIndex += 1
        currentJulianDay = nil
        currentState = nil
    }
}
