import Foundation

/// The Forge's astronomical read boundary. Production manufacture may bind this to
/// Swiss Ephemeris, while tests may supply a deterministic reference sky.
public protocol ForgeEphemerisReference: Sendable {
    func state(of body: MundaneBody, at julianDay: JulianDay) throws -> MundaneForgeState
}

/// Raw astronomical state used only by Forge while manufacturing a durable chronology.
public struct MundaneForgeState: Hashable, Sendable {
    public let longitudeDegrees: Double
    public let longitudinalSpeedDegreesPerDay: Double

    public init?(longitudeDegrees: Double, longitudinalSpeedDegreesPerDay: Double) {
        guard longitudeDegrees.isFinite, longitudinalSpeedDegreesPerDay.isFinite else { return nil }
        var normalized = longitudeDegrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        self.longitudeDegrees = normalized
        self.longitudinalSpeedDegreesPerDay = longitudinalSpeedDegreesPerDay
    }
}

/// Internal sequence direction of a body's celestial clock. User-facing astrology
/// continues to use Motion.direct / Motion.retrograde.
public enum MundaneCelestialSequenceDirection: String, Codable, Hashable, Sendable {
    case increasing
    case decreasing

    public var motion: Motion {
        switch self {
        case .increasing: return .direct
        case .decreasing: return .retrograde
        }
    }

    fileprivate static func from(speed: Double) -> Self {
        speed < 0 ? .decreasing : .increasing
    }
}

public struct MundaneForgeMarker: Codable, Hashable, Sendable {
    public let body: MundaneBody
    public let wholeDegree: UInt16
}

/// One occurrence of a repeating celestial-time coordinate bound to civic UT.
public struct MundaneForgedOccurrence: Codable, Hashable, Sendable {
    public let focalCelestialTick: Int
    public let focalCelestialDegrees: Double
    public let occurrence: Int
    public let civicOffsetSeconds: Int64
    public let julianDay: JulianDay
    public let sequenceDirection: MundaneCelestialSequenceDirection
    public let markers: [MundaneForgeMarker]
}

/// A station is a turn in the mapping between a body's celestial time and civic UT.
public struct MundaneForgedStation: Codable, Hashable, Sendable {
    public let body: MundaneBody
    public let celestialTimeDegrees: Double
    public let julianDay: JulianDay
    public let sequenceBefore: MundaneCelestialSequenceDirection
    public let sequenceAfter: MundaneCelestialSequenceDirection

    public var motionAfter: Motion { sequenceAfter.motion }
}

public struct MundaneForgedRetrogradePassage: Codable, Hashable, Sendable {
    public let body: MundaneBody
    public let startCelestialTimeDegrees: Double
    public let endCelestialTimeDegrees: Double
    public let startJulianDay: JulianDay
    public let endJulianDay: JulianDay
}

public struct MundaneTimespineForgedBody: Codable, Sendable {
    public let body: MundaneBody
    public let celestialResolutionDegrees: Double
    public let markerBodies: [MundaneBody]
    public let occurrences: [MundaneForgedOccurrence]
    public let stations: [MundaneForgedStation]
    public let retrogradePassages: [MundaneForgedRetrogradePassage]

    public var retrogradeCrossingCount: Int {
        occurrences.reduce(0) { $0 + ($1.sequenceDirection == .decreasing ? 1 : 0) }
    }
}

public struct MundaneTimespineForgeProduct: Sendable {
    public let spanName: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let bodies: [MundaneTimespineForgedBody]

    public var totalOccurrenceCount: Int {
        bodies.reduce(0) { $0 + $1.occurrences.count }
    }

    public var totalStationCount: Int {
        bodies.reduce(0) { $0 + $1.stations.count }
    }

    public var totalRetrogradePassageCount: Int {
        bodies.reduce(0) { $0 + $1.retrogradePassages.count }
    }

    public func body(_ body: MundaneBody) -> MundaneTimespineForgedBody? {
        bodies.first { $0.body == body }
    }
}

public struct MundaneTimespineForgeBodyPlan: Hashable, Sendable {
    public let contract: MundaneTimespineBodyContract
    public let scanStepDays: Double

    public init?(contract: MundaneTimespineBodyContract, scanStepDays: Double) {
        guard scanStepDays.isFinite, scanStepDays > 0 else { return nil }
        self.contract = contract
        self.scanStepDays = scanStepDays
    }
}

public struct MundaneTimespineForgePlan: Sendable {
    public let spanName: String
    public let astronomicalSource: String
    public let astronomicalSourceVersion: String
    public let supportedStart: JulianDay
    public let supportedEnd: JulianDay
    public let bodyPlans: [MundaneTimespineForgeBodyPlan]
    public let validatesP22Boundaries: Bool
    public let verifiesConstructionRecordCounts: Bool
    public let verifiesMarkerUniqueness: Bool

    public init?(
        spanName: String,
        astronomicalSource: String,
        astronomicalSourceVersion: String,
        supportedStart: JulianDay,
        supportedEnd: JulianDay,
        bodyPlans: [MundaneTimespineForgeBodyPlan],
        validatesP22Boundaries: Bool = false,
        verifiesConstructionRecordCounts: Bool = false,
        verifiesMarkerUniqueness: Bool = true
    ) {
        let bodies = bodyPlans.map { $0.contract.body }
        guard !spanName.isEmpty,
              !astronomicalSource.isEmpty,
              !astronomicalSourceVersion.isEmpty,
              supportedStart.value < supportedEnd.value,
              !bodyPlans.isEmpty,
              Set(bodies).count == bodies.count else { return nil }

        let availableBodies = Set(bodies)
        for bodyPlan in bodyPlans {
            guard bodyPlan.contract.markerBodies.allSatisfy({ availableBodies.contains($0) }) else { return nil }
        }

        self.spanName = spanName
        self.astronomicalSource = astronomicalSource
        self.astronomicalSourceVersion = astronomicalSourceVersion
        self.supportedStart = supportedStart
        self.supportedEnd = supportedEnd
        self.bodyPlans = bodyPlans
        self.validatesP22Boundaries = validatesP22Boundaries
        self.verifiesConstructionRecordCounts = verifiesConstructionRecordCounts
        self.verifiesMarkerUniqueness = verifiesMarkerUniqueness
    }
}

public struct MundaneTimespineForgeProgress: Hashable, Sendable {
    public let completedSegments: Int
    public let totalSegments: Int
    public let currentBody: MundaneBody?

    public var fractionComplete: Double {
        guard totalSegments > 0 else { return 1 }
        return min(1, Double(completedSegments) / Double(totalSegments))
    }
}

public enum MundaneTimespineForgeError: Error, Equatable, CustomStringConvertible {
    case incompleteManufacture
    case malformedPlan
    case malformedState(MundaneBody)
    case p22BoundaryMismatch
    case recordCountMismatch(body: MundaneBody, expected: Int, actual: Int)
    case markerCollision(body: MundaneBody)
    case unsupportedResolution(body: MundaneBody, resolution: Double)

    public var description: String {
        switch self {
        case .incompleteManufacture:
            return "Forge product requested before manufacture completed."
        case .malformedPlan:
            return "Mundane Timespine Forge plan is malformed."
        case let .malformedState(body):
            return "Ephemeris returned a malformed state for \(body.displayName)."
        case .p22BoundaryMismatch:
            return "Stored P22/P23 bounds do not validate as direct Pluto 0 Aries crossings."
        case let .recordCountMismatch(body, expected, actual):
            return "\(body.displayName) forged \(actual) records; expected \(expected)."
        case let .markerCollision(body):
            return "\(body.displayName) companion marker key repeats inside the Forge span."
        case let .unsupportedResolution(body, resolution):
            return "\(body.displayName) Forge resolution \(resolution) cannot produce whole-degree marker cells."
        }
    }
}

/// Native manufacturer for the degree-oriented Mundane Timespine.
///
/// Forge opens astronomical truth and manufactures durable celestial chronology.
/// The chronology is organized by repeating celestial coordinates whose occurrences
/// are bound to civic UT. Regular civic-time knots are deliberately not part of this model.
public enum MundaneTimespineForge {
    public static let astronomicalSource = "Swiss Ephemeris DE441; geocentric tropical apparent ecliptic longitude; UT"

    /// Construction scan cadence is a Forge mechanic, not Timespine anatomy.
    /// These are the proven P22 discovery cadences used to bracket crossings and stations.
    public static let p22ScanStepDays: [MundaneBody: Double] = [
        .sun: 0.20,
        .moon: 0.05,
        .mercury: 0.10,
        .venus: 0.20,
        .mars: 0.25,
        .jupiter: 0.25,
        .saturn: 0.50,
        .uranus: 1.0,
        .neptune: 1.0,
        .pluto: 1.0,
        .trueNorthNode: 0.10,
    ]

    public static func p22Plan(astronomicalSourceVersion: String) -> MundaneTimespineForgePlan {
        let bodyPlans = MundaneTimespineP22.profiles.map { contract in
            MundaneTimespineForgeBodyPlan(
                contract: contract,
                scanStepDays: p22ScanStepDays[contract.body]!
            )!
        }
        return MundaneTimespineForgePlan(
            spanName: MundaneTimespineP22.spanName,
            astronomicalSource: astronomicalSource,
            astronomicalSourceVersion: astronomicalSourceVersion,
            supportedStart: MundaneTimespineP22.startJulianDay,
            supportedEnd: MundaneTimespineP22.endJulianDay,
            bodyPlans: bodyPlans,
            validatesP22Boundaries: true,
            verifiesConstructionRecordCounts: true,
            verifiesMarkerUniqueness: true
        )!
    }

    public static func makeCursor(plan: MundaneTimespineForgePlan) -> Cursor {
        Cursor(plan: plan)
    }

    public static func manufacture(
        plan: MundaneTimespineForgePlan,
        reference: any ForgeEphemerisReference
    ) throws -> MundaneTimespineForgeProduct {
        if plan.validatesP22Boundaries {
            try validateP22Boundaries(reference: reference, plan: plan)
        }
        var cursor = Cursor(plan: plan)
        while !cursor.isComplete {
            _ = try cursor.step(reference: reference, segmentBudget: 4_096)
        }
        return try cursor.product()
    }

    public static func manufactureP22(
        astronomicalSourceVersion: String,
        reference: any ForgeEphemerisReference
    ) throws -> MundaneTimespineForgeProduct {
        try manufacture(
            plan: p22Plan(astronomicalSourceVersion: astronomicalSourceVersion),
            reference: reference
        )
    }

    private static func validateP22Boundaries(
        reference: any ForgeEphemerisReference,
        plan: MundaneTimespineForgePlan
    ) throws {
        guard plan.supportedStart == MundaneTimespineP22.startJulianDay,
              plan.supportedEnd == MundaneTimespineP22.endJulianDay else {
            throw MundaneTimespineForgeError.p22BoundaryMismatch
        }
        let start = try reference.state(of: .pluto, at: plan.supportedStart)
        let end = try reference.state(of: .pluto, at: plan.supportedEnd)
        guard distanceFromZeroAries(start.longitudeDegrees) < 0.0001,
              start.longitudinalSpeedDegreesPerDay > 0,
              distanceFromZeroAries(end.longitudeDegrees) < 0.0001,
              end.longitudinalSpeedDegreesPerDay > 0 else {
            throw MundaneTimespineForgeError.p22BoundaryMismatch
        }
    }

    private static func distanceFromZeroAries(_ longitude: Double) -> Double {
        min(longitude, 360 - longitude)
    }

    public struct Cursor: Sendable {
        public let plan: MundaneTimespineForgePlan

        private struct RawCrossing: Sendable {
            let julianDay: JulianDay
            let tick: Int
            let direction: MundaneCelestialSequenceDirection
        }

        private struct RawBody: Sendable {
            var selected: [RawCrossing] = []
            var stations: [MundaneForgedStation] = []
            var initialState: MundaneForgeState?
            var finalState: MundaneForgeState?
        }

        private var bodyIndex = 0
        private var completedSegments = 0
        private var currentJulianDay: JulianDay?
        private var currentState: MundaneForgeState?
        private var rawByBody: [MundaneBody: RawBody] = [:]

        fileprivate init(plan: MundaneTimespineForgePlan) {
            self.plan = plan
            for bodyPlan in plan.bodyPlans {
                rawByBody[bodyPlan.contract.body] = RawBody()
            }
        }

        public var totalSegments: Int {
            plan.bodyPlans.reduce(0) { total, bodyPlan in
                total + Self.segmentCount(
                    start: plan.supportedStart.value,
                    end: plan.supportedEnd.value,
                    step: bodyPlan.scanStepDays
                )
            }
        }

        public var isComplete: Bool { bodyIndex >= plan.bodyPlans.count }

        public var progress: MundaneTimespineForgeProgress {
            MundaneTimespineForgeProgress(
                completedSegments: completedSegments,
                totalSegments: totalSegments,
                currentBody: isComplete ? nil : plan.bodyPlans[bodyIndex].contract.body
            )
        }

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

        private mutating func beginBody(
            bodyPlan: MundaneTimespineForgeBodyPlan,
            startState: MundaneForgeState
        ) throws {
            let body = bodyPlan.contract.body
            var raw = rawByBody[body] ?? RawBody()
            raw.initialState = startState

            let resolution = bodyPlan.contract.celestialResolutionDegrees
            let scale = Int((1 / resolution).rounded())
            guard scale > 0, abs(Double(scale) * resolution - 1) < 1e-9 else {
                throw MundaneTimespineForgeError.unsupportedResolution(body: body, resolution: resolution)
            }
            let scaled = startState.longitudeDegrees / resolution
            let nearest = Int(scaled.rounded())
            if abs(scaled - Double(nearest)) < 1e-7 {
                raw.selected.append(
                    RawCrossing(
                        julianDay: plan.supportedStart,
                        tick: Self.mod(nearest, 360 * scale),
                        direction: .from(speed: startState.longitudinalSpeedDegreesPerDay)
                    )
                )
            }

            rawByBody[body] = raw
            currentJulianDay = plan.supportedStart
            currentState = startState
        }

        private mutating func finishCurrentBody(finalState: MundaneForgeState) throws {
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

        private mutating func processSegment(
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

        private mutating func emitMonotonicCrossings(
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

        private mutating func appendCrossing(
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

        private func refineStation(
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

        private func refineCrossing(
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

        private func makeWholeDegreeRows() throws -> [MundaneBody: [RawCrossing]] {
            var result: [MundaneBody: [RawCrossing]] = [:]
            for bodyPlan in plan.bodyPlans {
                let contract = bodyPlan.contract
                guard let raw = rawByBody[contract.body] else { throw MundaneTimespineForgeError.malformedPlan }
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

        private struct OccurrenceKey: Hashable {
            let focalTick: Int
            let markerDegrees: [UInt16]
        }

        private static func simultaneousWholeDegreeCells(
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

        private static func cellBeforeFirst(_ rows: [RawCrossing]) -> Int {
            guard let first = rows.first else { return 0 }
            return first.direction == .increasing ? mod(first.tick - 1, 360) : first.tick
        }

        private static func cellAfter(_ crossing: RawCrossing) -> Int {
            crossing.direction == .increasing ? crossing.tick : mod(crossing.tick - 1, 360)
        }

        private static func makeRetrogradePassages(
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

        private static func signedShortestDelta(from a: Double, to b: Double) -> Double {
            var delta = normalize(b) - normalize(a)
            if delta > 180 { delta -= 360 }
            if delta < -180 { delta += 360 }
            return delta
        }

        private static func normalize(_ value: Double) -> Double {
            var result = value.truncatingRemainder(dividingBy: 360)
            if result < 0 { result += 360 }
            return result
        }

        private static func mod(_ value: Int, _ modulus: Int) -> Int {
            let result = value % modulus
            return result >= 0 ? result : result + modulus
        }

        private static func segmentCount(start: Double, end: Double, step: Double) -> Int {
            max(0, Int(ceil((end - start) / step)))
        }
    }
}
