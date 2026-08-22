import Foundation

public enum OrboSpineLocateError: Error, Equatable, CustomStringConvertible {
    case outsideBone
    case bodyUnavailable(MundaneBody)
    case invalidNavigationCell(Int)
    case terraUnavailable

    public var description: String {
        switch self {
        case .outsideBone:
            return "Requested UT is outside the OrboSpine Bone."
        case let .bodyUnavailable(body):
            return "OrboSpine Locate does not contain \(body.displayName)."
        case let .invalidNavigationCell(cell):
            return "OrboSpine navigation cell \(cell) is outside 0..<720."
        case .terraUnavailable:
            return "OrboSpine Locate does not contain navigable Terra Marrow."
        }
    }
}

/// Port I over already-forged OrboSpine matter.
/// Locate owns no astronomy and performs no ephemeris work.
public struct OrboSpineLocate: Sendable {
    public let bone: OrboSpineBoneSpan

    private let tracts: [MundaneBody: Tract]
    private let terra: TerraSeries?

    public init?(
        bone: OrboSpineBoneSpan,
        celestialSupports: [OrboSpineCelestialCoordinate],
        stations: [OrboSpineStation] = [],
        terraSamples: [TerraMarrowSample] = []
    ) {
        let supportBodies = Set(celestialSupports.map(\.body))
        let stationBodies = Set(stations.map(\.body))
        let bodies = supportBodies.union(stationBodies)
        guard !bodies.isEmpty else { return nil }

        var built: [MundaneBody: Tract] = [:]
        built.reserveCapacity(bodies.count)
        for body in bodies {
            let bodySupports = celestialSupports.filter { $0.body == body }
            let bodyStations = stations.filter { $0.body == body }
            guard let tract = Tract(
                body: body,
                bone: bone,
                supports: bodySupports,
                stations: bodyStations
            ) else {
                return nil
            }
            built[body] = tract
        }

        let terraSeries: TerraSeries?
        if terraSamples.isEmpty {
            terraSeries = nil
        } else {
            guard let value = TerraSeries(bone: bone, samples: terraSamples) else { return nil }
            terraSeries = value
        }

        self.bone = bone
        self.tracts = built
        self.terra = terraSeries
    }

    /// (body, *, UT) -> one directional-degree coordinate.
    /// Station UT belongs to the lane entered after the station.
    public func coordinate(of body: MundaneBody, at julianDay: JulianDay) throws -> OrboSpineCelestialCoordinate {
        guard bone.contains(julianDay) else { throw OrboSpineLocateError.outsideBone }
        guard let tract = tracts[body] else { throw OrboSpineLocateError.bodyUnavailable(body) }
        return tract.coordinate(at: julianDay)
    }

    /// (body, directionalDegree, *) -> every occurrence on the Bone.
    /// The 720-cell projection is used only as the coarse grip; exact fractional degree is retained.
    public func occurrences(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [OrboSpineCelestialCoordinate] {
        guard let tract = tracts[body] else { throw OrboSpineLocateError.bodyUnavailable(body) }
        return tract.occurrences(at: directionalDegree)
    }

    /// Coarse 720-cell candidate windows for later exact Locate refinement.
    /// These are navigation grips, not additional astronomical truth.
    public func candidateWindows(
        of body: MundaneBody,
        inNavigationCell cell: Int
    ) throws -> [OrboSpineBoneSpan] {
        guard (0..<720).contains(cell) else { throw OrboSpineLocateError.invalidNavigationCell(cell) }
        guard let tract = tracts[body] else { throw OrboSpineLocateError.bodyUnavailable(body) }
        return tract.candidateWindows(in: cell)
    }

    /// UT -> Terra Marrow using one-sided source-model refinement at the 1850/2050 seams.
    public func terra(at julianDay: JulianDay) throws -> TerraMarrowSample {
        guard bone.contains(julianDay) else { throw OrboSpineLocateError.outsideBone }
        guard let terra else { throw OrboSpineLocateError.terraUnavailable }
        return terra.sample(at: julianDay)
    }
}

private extension OrboSpineLocate {
    struct Tract: Sendable {
        let body: MundaneBody
        let bone: OrboSpineBoneSpan
        let segments: [Segment]
        let segmentIndexesByCell: [[Int]]

        init?(
            body: MundaneBody,
            bone: OrboSpineBoneSpan,
            supports: [OrboSpineCelestialCoordinate],
            stations: [OrboSpineStation]
        ) {
            guard supports.count >= 2,
                  supports.allSatisfy({ $0.body == body && bone.contains($0.julianDay) }),
                  stations.allSatisfy({ $0.body == body && bone.contains($0.julianDay) }) else {
                return nil
            }

            var raw: [Event] = supports.map {
                Event(
                    julianDay: $0.julianDay,
                    physicalDegrees: $0.directionalDegree.physicalDegrees,
                    motionBefore: $0.directionalDegree.motion,
                    motionAfter: $0.directionalDegree.motion,
                    isStation: false
                )
            }
            raw.append(contentsOf: stations.map {
                Event(
                    julianDay: $0.julianDay,
                    physicalDegrees: $0.physicalDegrees,
                    motionBefore: $0.laneBefore,
                    motionAfter: $0.laneAfter,
                    isStation: true
                )
            })
            raw.sort {
                if abs($0.julianDay.value - $1.julianDay.value) > Self.epsilon {
                    return $0.julianDay.value < $1.julianDay.value
                }
                return $0.isStation && !$1.isStation
            }

            guard var events = Self.collapseCoincidentEvents(raw), events.count >= 2 else { return nil }

            if events[0].julianDay.value > bone.start.value + Self.epsilon {
                guard let boundary = Self.startBoundary(
                    at: bone.start,
                    first: events[0],
                    second: events[1]
                ) else { return nil }
                events.insert(boundary, at: 0)
            } else if abs(events[0].julianDay.value - bone.start.value) > Self.epsilon {
                return nil
            }

            if events[events.count - 1].julianDay.value < bone.end.value - Self.epsilon {
                guard let boundary = Self.endBoundary(
                    at: bone.end,
                    previous: events[events.count - 2],
                    last: events[events.count - 1]
                ) else { return nil }
                events.append(boundary)
            } else if events[events.count - 1].julianDay.value > bone.end.value + Self.epsilon {
                return nil
            }

            var builtSegments: [Segment] = []
            builtSegments.reserveCapacity(events.count - 1)
            let supportStep = OrboSpineContract.supportDegrees(for: body)

            for index in 0..<(events.count - 1) {
                let lower = events[index]
                let upper = events[index + 1]
                guard lower.julianDay.value < upper.julianDay.value,
                      lower.motionAfter == upper.motionBefore else {
                    return nil
                }

                let motion = lower.motionAfter
                let distance = Self.directionalDistance(
                    from: lower.physicalDegrees,
                    to: upper.physicalDegrees,
                    motion: motion
                )
                guard distance > Self.epsilon,
                      distance <= supportStep + 1e-6 else {
                    return nil
                }

                builtSegments.append(
                    Segment(
                        start: lower.julianDay,
                        end: upper.julianDay,
                        startPhysicalDegrees: lower.physicalDegrees,
                        endPhysicalDegrees: upper.physicalDegrees,
                        motion: motion
                    )
                )
            }

            guard !builtSegments.isEmpty,
                  abs(builtSegments[0].start.value - bone.start.value) <= Self.epsilon,
                  abs(builtSegments[builtSegments.count - 1].end.value - bone.end.value) <= Self.epsilon else {
                return nil
            }

            var cellIndex = Array(repeating: [Int](), count: 720)
            for (segmentIndex, segment) in builtSegments.enumerated() {
                for cell in segment.navigationCells {
                    cellIndex[cell].append(segmentIndex)
                }
            }

            self.body = body
            self.bone = bone
            self.segments = builtSegments
            self.segmentIndexesByCell = cellIndex
        }

        func coordinate(at julianDay: JulianDay) -> OrboSpineCelestialCoordinate {
            var low = 0
            var high = segments.count
            while low < high {
                let middle = (low + high) / 2
                if segments[middle].end.value <= julianDay.value {
                    low = middle + 1
                } else {
                    high = middle
                }
            }

            let index = min(low, segments.count - 1)
            let segment = segments[index]
            let fraction = (julianDay.value - segment.start.value) / (segment.end.value - segment.start.value)
            let distance = segment.distanceDegrees * fraction
            let physical = Self.move(
                from: segment.startPhysicalDegrees,
                by: distance,
                motion: segment.motion
            )
            let directional = OrboSpineDirectionalDegree(
                physicalDegrees: physical,
                motion: segment.motion
            )!
            return OrboSpineCelestialCoordinate(
                body: body,
                directionalDegree: directional,
                julianDay: julianDay
            )
        }

        func occurrences(at directionalDegree: OrboSpineDirectionalDegree) -> [OrboSpineCelestialCoordinate] {
            let candidates = segmentIndexesByCell[directionalDegree.navigationCell]
            var result: [OrboSpineCelestialCoordinate] = []
            result.reserveCapacity(candidates.count)

            for index in candidates {
                let segment = segments[index]
                guard segment.motion == directionalDegree.motion else { continue }
                let targetDistance = Self.directionalDistance(
                    from: segment.startPhysicalDegrees,
                    to: directionalDegree.physicalDegrees,
                    motion: segment.motion
                )
                guard targetDistance < segment.distanceDegrees - Self.epsilon || targetDistance <= Self.epsilon else {
                    continue
                }

                let fraction = targetDistance / segment.distanceDegrees
                let value = segment.start.value + (segment.end.value - segment.start.value) * fraction
                guard value >= bone.start.value - Self.epsilon,
                      value < bone.end.value - Self.epsilon,
                      let julianDay = JulianDay(value) else {
                    continue
                }
                result.append(
                    OrboSpineCelestialCoordinate(
                        body: body,
                        directionalDegree: directionalDegree,
                        julianDay: julianDay
                    )
                )
            }

            result.sort { $0.julianDay.value < $1.julianDay.value }
            var deduplicated: [OrboSpineCelestialCoordinate] = []
            deduplicated.reserveCapacity(result.count)
            for occurrence in result {
                if let previous = deduplicated.last,
                   abs(previous.julianDay.value - occurrence.julianDay.value) <= Self.epsilon {
                    continue
                }
                deduplicated.append(occurrence)
            }
            return deduplicated
        }

        func candidateWindows(in cell: Int) -> [OrboSpineBoneSpan] {
            segmentIndexesByCell[cell].compactMap {
                let segment = segments[$0]
                return OrboSpineBoneSpan(start: segment.start, end: segment.end)
            }
        }

        private static let epsilon = 1e-10

        private static func collapseCoincidentEvents(_ raw: [Event]) -> [Event]? {
            var result: [Event] = []
            var index = 0
            while index < raw.count {
                var group: [Event] = [raw[index]]
                var next = index + 1
                while next < raw.count,
                      abs(raw[next].julianDay.value - raw[index].julianDay.value) <= epsilon {
                    group.append(raw[next])
                    next += 1
                }

                let stations = group.filter(\.isStation)
                if let station = stations.first {
                    guard stations.count == 1,
                          group.allSatisfy({
                              abs($0.physicalDegrees - station.physicalDegrees) <= 1e-7 || $0.isStation
                          }) else {
                        return nil
                    }
                    result.append(station)
                } else {
                    guard group.count == 1 else { return nil }
                    result.append(group[0])
                }
                index = next
            }
            return result
        }

        private static func startBoundary(
            at start: JulianDay,
            first: Event,
            second: Event
        ) -> Event? {
            guard !first.isStation,
                  first.motionBefore == first.motionAfter,
                  first.motionAfter == second.motionBefore,
                  first.julianDay.value < second.julianDay.value else {
                return nil
            }
            let distance = directionalDistance(
                from: first.physicalDegrees,
                to: second.physicalDegrees,
                motion: first.motionBefore
            )
            let fraction = (first.julianDay.value - start.value) / (second.julianDay.value - first.julianDay.value)
            let physical = move(
                from: first.physicalDegrees,
                by: -distance * fraction,
                motion: first.motionBefore
            )
            return Event(
                julianDay: start,
                physicalDegrees: physical,
                motionBefore: first.motionBefore,
                motionAfter: first.motionBefore,
                isStation: false
            )
        }

        private static func endBoundary(
            at end: JulianDay,
            previous: Event,
            last: Event
        ) -> Event? {
            guard !last.isStation,
                  last.motionBefore == last.motionAfter,
                  previous.motionAfter == last.motionBefore,
                  previous.julianDay.value < last.julianDay.value else {
                return nil
            }
            let distance = directionalDistance(
                from: previous.physicalDegrees,
                to: last.physicalDegrees,
                motion: last.motionAfter
            )
            let fraction = (end.value - last.julianDay.value) / (last.julianDay.value - previous.julianDay.value)
            let physical = move(
                from: last.physicalDegrees,
                by: distance * fraction,
                motion: last.motionAfter
            )
            return Event(
                julianDay: end,
                physicalDegrees: physical,
                motionBefore: last.motionAfter,
                motionAfter: last.motionAfter,
                isStation: false
            )
        }

        fileprivate static func directionalDistance(
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
            return result == 360 ? 0 : result
        }
    }

    struct Event: Sendable {
        let julianDay: JulianDay
        let physicalDegrees: Double
        let motionBefore: Motion
        let motionAfter: Motion
        let isStation: Bool
    }

    struct Segment: Sendable {
        let start: JulianDay
        let end: JulianDay
        let startPhysicalDegrees: Double
        let endPhysicalDegrees: Double
        let motion: Motion

        var distanceDegrees: Double {
            Tract.directionalDistance(
                from: startPhysicalDegrees,
                to: endPhysicalDegrees,
                motion: motion
            )
        }

        var navigationCells: [Int] {
            let laneOffset = motion == .retrograde ? 360 : 0
            var cells: [Int] = []
            var cell = Int(startPhysicalDegrees.rounded(.down)) % 360
            let endCell = Int(endPhysicalDegrees.rounded(.down)) % 360
            var safety = 0

            while true {
                cells.append(laneOffset + cell)
                if cell == endCell { break }
                cell = motion == .direct ? (cell + 1) % 360 : (cell + 359) % 360
                safety += 1
                if safety > 360 { break }
            }
            return cells
        }
    }

    struct TerraSeries: Sendable {
        let bone: OrboSpineBoneSpan
        let samples: [TerraMarrowSample]

        init?(bone: OrboSpineBoneSpan, samples: [TerraMarrowSample]) {
            let ordered = samples.sorted { $0.julianDay.value < $1.julianDay.value }
            var canonical: [TerraMarrowSample] = []
            canonical.reserveCapacity(ordered.count)

            for sample in ordered {
                if let previous = canonical.last,
                   abs(previous.julianDay.value - sample.julianDay.value) <= 1e-12 {
                    guard abs(previous.turnDegrees - sample.turnDegrees) <= 1e-9,
                          abs(previous.tiltDegrees - sample.tiltDegrees) <= 1e-9 else {
                        return nil
                    }
                    continue
                }
                canonical.append(sample)
            }

            guard canonical.count >= 2,
                  canonical[0].julianDay.value <= bone.start.value + 1e-12,
                  canonical[canonical.count - 1].julianDay.value >= bone.end.value - 1e-12 else {
                return nil
            }

            for seam in TerraMarrowContract.sourceModelSeamJulianDays
            where seam >= bone.start.value && seam < bone.end.value {
                guard canonical.contains(where: { abs($0.julianDay.value - seam) <= 1e-12 }) else {
                    return nil
                }
            }

            self.bone = bone
            self.samples = canonical
        }

        func sample(at julianDay: JulianDay) -> TerraMarrowSample {
            if let exact = exactSample(at: julianDay.value) {
                return exact
            }

            let bounds = sourceRegionBounds(for: julianDay.value)
            let insertion = lowerBound(julianDay.value, low: bounds.lowerBound, high: bounds.upperBound)
            let lowerIndex: Int
            let upperIndex: Int

            if insertion <= bounds.lowerBound {
                lowerIndex = bounds.lowerBound
                upperIndex = min(bounds.lowerBound + 1, bounds.upperBound - 1)
            } else if insertion >= bounds.upperBound {
                upperIndex = bounds.upperBound - 1
                lowerIndex = max(bounds.lowerBound, upperIndex - 1)
            } else {
                lowerIndex = insertion - 1
                upperIndex = insertion
            }

            let lower = samples[lowerIndex]
            let upper = samples[upperIndex]
            let fraction = (julianDay.value - lower.julianDay.value) / (upper.julianDay.value - lower.julianDay.value)
            let turnTravel = normalized(upper.turnDegrees - lower.turnDegrees)
            let turn = normalized(lower.turnDegrees + turnTravel * fraction)
            let tilt = lower.tiltDegrees + (upper.tiltDegrees - lower.tiltDegrees) * fraction
            return TerraMarrowSample(
                turnDegrees: turn,
                tiltDegrees: tilt,
                julianDay: julianDay
            )!
        }

        private func exactSample(at value: Double) -> TerraMarrowSample? {
            let index = lowerBound(value, low: 0, high: samples.count)
            if index < samples.count,
               abs(samples[index].julianDay.value - value) <= 1e-12 {
                return samples[index]
            }
            if index > 0,
               abs(samples[index - 1].julianDay.value - value) <= 1e-12 {
                return samples[index - 1]
            }
            return nil
        }

        private func sourceRegionBounds(for value: Double) -> Range<Int> {
            let seams = TerraMarrowContract.sourceModelSeamJulianDays
            let first = seams[0]
            let second = seams[1]

            if value < first {
                return 0..<upperBound(first)
            }
            if value > first && value < second {
                return upperBound(first)..<lowerBound(second, low: 0, high: samples.count)
            }
            if value > second {
                return lowerBound(second, low: 0, high: samples.count)..<samples.count
            }

            // Exact seams are returned before this method is reached.
            return 0..<samples.count
        }

        private func lowerBound(_ value: Double, low initialLow: Int, high initialHigh: Int) -> Int {
            var low = initialLow
            var high = initialHigh
            while low < high {
                let middle = (low + high) / 2
                if samples[middle].julianDay.value < value {
                    low = middle + 1
                } else {
                    high = middle
                }
            }
            return low
        }

        private func upperBound(_ value: Double) -> Int {
            var low = 0
            var high = samples.count
            while low < high {
                let middle = (low + high) / 2
                if samples[middle].julianDay.value <= value {
                    low = middle + 1
                } else {
                    high = middle
                }
            }
            return low
        }

        private func normalized(_ value: Double) -> Double {
            var result = value.truncatingRemainder(dividingBy: 360)
            if result < 0 { result += 360 }
            return result == 360 ? 0 : result
        }
    }
}
