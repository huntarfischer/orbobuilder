import Foundation

extension MundaneTimespineForge.Cursor {
    mutating func processSegment(
        reference: any ForgeEphemerisReference,
        bodyPlan: MundaneTimespineForgeBodyPlan,
        loJD: JulianDay,
        hiJD: JulianDay,
        loState: MundaneForgeState,
        hiState: MundaneForgeState
    ) throws {
        let body = bodyPlan.contract.body
        let loSpeed = loState.longitudinalSpeedDegreesPerDay
        let hiSpeed = hiState.longitudinalSpeedDegreesPerDay
        let touchesStation = abs(loSpeed) < 1e-12 || abs(hiSpeed) < 1e-12 || loSpeed * hiSpeed < 0

        if touchesStation {
            let stationJD = try refineStation(
                reference: reference,
                body: body,
                lo: loJD,
                hi: hiJD,
                loState: loState,
                hiState: hiState
            )
            let stationState = try reference.state(of: body, at: stationJD)
            let before = MundaneCelestialSequenceDirection.from(speed: abs(loSpeed) < 1e-12 ? -hiSpeed : loSpeed)
            let after = MundaneCelestialSequenceDirection.from(speed: abs(hiSpeed) < 1e-12 ? -loSpeed : hiSpeed)

            var raw = rawByBody[body] ?? RawBody()
            let duplicate = raw.stations.last.map {
                abs($0.julianDay.value - stationJD.value) * 86_400 < 1
            } ?? false
            if !duplicate, before != after {
                raw.stations.append(
                    MundaneForgedStation(
                        body: body,
                        celestialTimeDegrees: stationState.longitudeDegrees,
                        julianDay: stationJD,
                        sequenceBefore: before,
                        sequenceAfter: after
                    )
                )
                rawByBody[body] = raw
            }

            if stationJD.value - loJD.value > 1e-10 {
                try emitMonotonicCrossings(
                    reference: reference,
                    bodyPlan: bodyPlan,
                    loJD: loJD,
                    hiJD: stationJD,
                    loState: loState,
                    hiState: stationState
                )
            }
            if hiJD.value - stationJD.value > 1e-10 {
                try emitMonotonicCrossings(
                    reference: reference,
                    bodyPlan: bodyPlan,
                    loJD: stationJD,
                    hiJD: hiJD,
                    loState: stationState,
                    hiState: hiState
                )
            }
        } else {
            try emitMonotonicCrossings(
                reference: reference,
                bodyPlan: bodyPlan,
                loJD: loJD,
                hiJD: hiJD,
                loState: loState,
                hiState: hiState
            )
        }
    }

    mutating func emitMonotonicCrossings(
        reference: any ForgeEphemerisReference,
        bodyPlan: MundaneTimespineForgeBodyPlan,
        loJD: JulianDay,
        hiJD: JulianDay,
        loState: MundaneForgeState,
        hiState: MundaneForgeState
    ) throws {
        let body = bodyPlan.contract.body
        let resolution = bodyPlan.contract.celestialResolutionDegrees
        let loUnwrapped = loState.longitudeDegrees
        let hiUnwrapped = loUnwrapped + Self.signedShortestDelta(
            from: loState.longitudeDegrees,
            to: hiState.longitudeDegrees
        )
        let delta = hiUnwrapped - loUnwrapped
        if abs(delta) < 1e-14 { return }

        let direction: MundaneCelestialSequenceDirection = delta > 0 ? .increasing : .decreasing
        let scale = Int((1 / resolution).rounded())
        guard scale > 0, abs(Double(scale) * resolution - 1) < 1e-9 else {
            throw MundaneTimespineForgeError.unsupportedResolution(body: body, resolution: resolution)
        }

        if direction == .increasing {
            let first = Int(floor(loUnwrapped / resolution)) + 1
            let last = Int(floor(hiUnwrapped / resolution))
            if first <= last {
                for k in first...last {
                    try appendCrossing(
                        reference: reference,
                        body: body,
                        targetUnwrapped: Double(k) * resolution,
                        tick: Self.mod(k, 360 * scale),
                        direction: direction,
                        loJD: loJD,
                        hiJD: hiJD,
                        anchorLongitude: loState.longitudeDegrees,
                        anchorUnwrapped: loUnwrapped
                    )
                }
            }
        } else {
            let first = Int(ceil(loUnwrapped / resolution)) - 1
            let last = Int(ceil(hiUnwrapped / resolution))
            if first >= last {
                for k in stride(from: first, through: last, by: -1) {
                    try appendCrossing(
                        reference: reference,
                        body: body,
                        targetUnwrapped: Double(k) * resolution,
                        tick: Self.mod(k, 360 * scale),
                        direction: direction,
                        loJD: loJD,
                        hiJD: hiJD,
                        anchorLongitude: loState.longitudeDegrees,
                        anchorUnwrapped: loUnwrapped
                    )
                }
            }
        }
    }

    mutating func appendCrossing(
        reference: any ForgeEphemerisReference,
        body: MundaneBody,
        targetUnwrapped: Double,
        tick: Int,
        direction: MundaneCelestialSequenceDirection,
        loJD: JulianDay,
        hiJD: JulianDay,
        anchorLongitude: Double,
        anchorUnwrapped: Double
    ) throws {
        let jd = try refineCrossing(
            reference: reference,
            body: body,
            targetUnwrapped: targetUnwrapped,
            loJD: loJD,
            hiJD: hiJD,
            anchorLongitude: anchorLongitude,
            anchorUnwrapped: anchorUnwrapped
        )
        guard jd.value >= plan.supportedStart.value - 1e-9,
              jd.value < plan.supportedEnd.value - 1e-9 else { return }

        var raw = rawByBody[body] ?? RawBody()
        let duplicate = raw.selected.last.map {
            $0.tick == tick && abs($0.julianDay.value - jd.value) * 86_400 < 0.25
        } ?? false
        if !duplicate {
            raw.selected.append(RawCrossing(julianDay: jd, tick: tick, direction: direction))
            rawByBody[body] = raw
        }
    }

    func refineStation(
        reference: any ForgeEphemerisReference,
        body: MundaneBody,
        lo: JulianDay,
        hi: JulianDay,
        loState: MundaneForgeState,
        hiState: MundaneForgeState
    ) throws -> JulianDay {
        if abs(loState.longitudinalSpeedDegreesPerDay) < 1e-12 { return lo }
        if abs(hiState.longitudinalSpeedDegreesPerDay) < 1e-12 { return hi }

        var a = lo.value
        var b = hi.value
        var fa = loState.longitudinalSpeedDegreesPerDay
        guard fa * hiState.longitudinalSpeedDegreesPerDay <= 0 else {
            return JulianDay((a + b) * 0.5)!
        }

        for _ in 0..<52 {
            let midpoint = (a + b) * 0.5
            let state = try reference.state(of: body, at: JulianDay(midpoint)!)
            let fm = state.longitudinalSpeedDegreesPerDay
            if abs(fm) < 1e-14 { return JulianDay(midpoint)! }
            if fa * fm <= 0 {
                b = midpoint
            } else {
                a = midpoint
                fa = fm
            }
        }
        return JulianDay((a + b) * 0.5)!
    }

    func refineCrossing(
        reference: any ForgeEphemerisReference,
        body: MundaneBody,
        targetUnwrapped: Double,
        loJD: JulianDay,
        hiJD: JulianDay,
        anchorLongitude: Double,
        anchorUnwrapped: Double
    ) throws -> JulianDay {
        var a = loJD.value
        var b = hiJD.value

        func value(_ jdValue: Double) throws -> (difference: Double, speed: Double) {
            let state = try reference.state(of: body, at: JulianDay(jdValue)!)
            let unwrapped = anchorUnwrapped + Self.signedShortestDelta(
                from: anchorLongitude,
                to: state.longitudeDegrees
            )
            return (unwrapped - targetUnwrapped, state.longitudinalSpeedDegreesPerDay)
        }

        var va = try value(a)
        let vb = try value(b)
        if abs(va.difference) < 1e-12 { return JulianDay(a)! }
        if abs(vb.difference) < 1e-12 { return JulianDay(b)! }
        guard va.difference * vb.difference <= 0 else { return JulianDay((a + b) * 0.5)! }

        var x = a + (b - a) * abs(va.difference) / max(1e-18, abs(va.difference) + abs(vb.difference))
        for _ in 0..<8 {
            let vx = try value(x)
            if abs(vx.difference) < 1e-10 { return JulianDay(x)! }
            if va.difference * vx.difference <= 0 {
                b = x
            } else {
                a = x
                va = vx
            }
            if abs(vx.speed) > 1e-8 {
                let newton = x - vx.difference / vx.speed
                if newton > a && newton < b {
                    x = newton
                    continue
                }
            }
            x = (a + b) * 0.5
        }

        for _ in 0..<24 {
            let midpoint = (a + b) * 0.5
            let vm = try value(midpoint)
            if abs(vm.difference) < 1e-10 { return JulianDay(midpoint)! }
            if va.difference * vm.difference <= 0 {
                b = midpoint
            } else {
                a = midpoint
                va = vm
            }
        }
        return JulianDay((a + b) * 0.5)!
    }
}
