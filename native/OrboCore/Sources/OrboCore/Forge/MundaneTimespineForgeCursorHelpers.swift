import Foundation

extension MundaneTimespineForge.Cursor {
    func makeWholeDegreeRows() throws -> [MundaneBody: [RawCrossing]] {
        let markerBodiesNeeded = Set(
            plan.bodyPlans.flatMap { $0.contract.markerBodies }
        )
        var result: [MundaneBody: [RawCrossing]] = [:]

        for bodyPlan in plan.bodyPlans {
            let contract = bodyPlan.contract
            guard markerBodiesNeeded.contains(contract.body) else { continue }
            guard let raw = rawByBody[contract.body] else {
                throw MundaneTimespineForgeError.malformedPlan
            }

            let scale = Int((1 / contract.celestialResolutionDegrees).rounded())
            guard scale > 0,
                  abs(Double(scale) * contract.celestialResolutionDegrees - 1) < 1e-9 else {
                throw MundaneTimespineForgeError.unsupportedResolution(
                    body: contract.body,
                    resolution: contract.celestialResolutionDegrees
                )
            }

            if scale == 1 {
                result[contract.body] = raw.selected
            } else {
                result[contract.body] = raw.selected.compactMap { row in
                    guard row.tick.isMultiple(of: scale) else { return nil }
                    return RawCrossing(
                        julianDay: row.julianDay,
                        tick: row.tick / scale,
                        direction: row.direction
                    )
                }
            }
        }
        return result
    }

    static func ticksPerCircle(
        body: MundaneBody,
        resolution: Double
    ) throws -> Int {
        guard resolution.isFinite, resolution > 0, resolution <= 360 else {
            throw MundaneTimespineForgeError.unsupportedResolution(
                body: body,
                resolution: resolution
            )
        }
        let ticks = Int((360 / resolution).rounded())
        guard ticks > 0,
              abs(Double(ticks) * resolution - 360) < 1e-9 else {
            throw MundaneTimespineForgeError.unsupportedResolution(
                body: body,
                resolution: resolution
            )
        }
        return ticks
    }

    static func simultaneousWholeDegreeCells(
        focalRows: [RawCrossing],
        markerRows: [RawCrossing]
    ) -> [UInt16] {
        var values: [UInt16] = []
        values.reserveCapacity(focalRows.count)
        var markerIndex = -1
        let before = cellBeforeFirst(markerRows)

        for row in focalRows {
            while markerIndex + 1 < markerRows.count,
                  markerRows[markerIndex + 1].julianDay.value <= row.julianDay.value + 1e-12 {
                markerIndex += 1
            }
            let cell = markerIndex < 0 ? before : cellAfter(markerRows[markerIndex])
            values.append(UInt16(cell))
        }
        return values
    }

    static func cellBeforeFirst(_ rows: [RawCrossing]) -> Int {
        guard let first = rows.first else { return 0 }
        return first.direction == .increasing ? mod(first.tick - 1, 360) : first.tick
    }

    static func cellAfter(_ crossing: RawCrossing) -> Int {
        crossing.direction == .increasing ? crossing.tick : mod(crossing.tick - 1, 360)
    }

    static func makeRetrogradePassages(
        body: MundaneBody,
        start: JulianDay,
        end: JulianDay,
        initialState: MundaneForgeState,
        finalState: MundaneForgeState,
        stations: [MundaneForgedStation]
    ) -> [MundaneForgedRetrogradePassage] {
        let sortedStations = stations.sorted { $0.julianDay.value < $1.julianDay.value }
        var passages: [MundaneForgedRetrogradePassage] = []
        var segmentStartJD = start
        var segmentStartLongitude = initialState.longitudeDegrees
        var direction = MundaneCelestialSequenceDirection.from(
            speed: initialState.longitudinalSpeedDegreesPerDay
        )

        for station in sortedStations {
            if direction == .decreasing, station.julianDay.value > segmentStartJD.value {
                passages.append(
                    MundaneForgedRetrogradePassage(
                        body: body,
                        startCelestialTimeDegrees: segmentStartLongitude,
                        endCelestialTimeDegrees: station.celestialTimeDegrees,
                        startJulianDay: segmentStartJD,
                        endJulianDay: station.julianDay
                    )
                )
            }
            segmentStartJD = station.julianDay
            segmentStartLongitude = station.celestialTimeDegrees
            direction = station.sequenceAfter
        }

        if direction == .decreasing, end.value > segmentStartJD.value {
            passages.append(
                MundaneForgedRetrogradePassage(
                    body: body,
                    startCelestialTimeDegrees: segmentStartLongitude,
                    endCelestialTimeDegrees: finalState.longitudeDegrees,
                    startJulianDay: segmentStartJD,
                    endJulianDay: end
                )
            )
        }
        return passages
    }

    static func signedShortestDelta(from a: Double, to b: Double) -> Double {
        var delta = normalize(b) - normalize(a)
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return delta
    }

    static func normalize(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }

    static func mod(_ value: Int, _ modulus: Int) -> Int {
        let result = value % modulus
        return result >= 0 ? result : result + modulus
    }

    static func segmentCount(start: Double, end: Double, step: Double) -> Int {
        max(0, Int(ceil((end - start) / step)))
    }
}
