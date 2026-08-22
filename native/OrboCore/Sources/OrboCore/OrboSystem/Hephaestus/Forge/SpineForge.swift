import Foundation

/// Hephaestus's celestial manufacturing apparatus. The Forge obeys a Spine schematic;
/// it owns no product-specific span, body list, support law, or astronomical authority.
public enum SpineForge {
    public static func makeCursor(schematic: SpineSchematic) -> Cursor {
        Cursor(schematic: schematic)
    }

    public static func preflight(
        schematic: SpineSchematic,
        reference: any SpineForgeEphemerisReference
    ) throws {
        for (index, check) in schematic.boundaryChecks.enumerated() {
            let state = try reference.state(of: check.body, at: check.julianDay)
            let distance = angularDistance(state.longitudeDegrees, check.physicalDegrees)
            let motionMatches: Bool
            switch check.motion {
            case .direct:
                motionMatches = state.longitudinalSpeedDegreesPerDay > 0
            case .retrograde:
                motionMatches = state.longitudinalSpeedDegreesPerDay < 0
            }
            guard distance < check.toleranceDegrees, motionMatches else {
                throw SpineForgeError.boundaryMismatch(index: index)
            }
        }
    }

    public static func manufacture(
        schematic: SpineSchematic,
        reference: any SpineForgeEphemerisReference
    ) throws -> SpineForgeProduct {
        try preflight(schematic: schematic, reference: reference)
        var cursor = Cursor(schematic: schematic)
        while !cursor.isComplete {
            _ = try cursor.step(reference: reference, segmentBudget: 4_096)
        }
        return try cursor.product()
    }

    private static func angularDistance(_ lhs: Double, _ rhs: Double) -> Double {
        let a = normalize(lhs)
        let b = normalize(rhs)
        let raw = abs(a - b)
        return min(raw, 360 - raw)
    }

    private static func normalize(_ value: Double) -> Double {
        var result = value.truncatingRemainder(dividingBy: 360)
        if result < 0 { result += 360 }
        return result
    }

    public struct Cursor: Sendable {
        public let schematic: SpineSchematic

        struct RawCrossing: Sendable {
            let julianDay: JulianDay
            let physicalDegrees: Double
            let motion: Motion
        }

        struct RawBody: Sendable {
            var supports: [RawCrossing] = []
            var stations: [OrboSpineStation] = []
        }

        var bodyIndex = 0
        var completedSegments = 0
        var currentJulianDay: JulianDay?
        var currentState: SpineForgeState?
        var rawByBody: [MundaneBody: RawBody] = [:]

        init(schematic: SpineSchematic) {
            self.schematic = schematic
            for bodyPlan in schematic.bodyPlans {
                rawByBody[bodyPlan.body] = RawBody()
            }
        }

        public var totalSegments: Int {
            schematic.bodyPlans.reduce(0) { total, bodyPlan in
                total + Self.segmentCount(
                    start: schematic.bone.start.value,
                    end: schematic.bone.end.value,
                    step: bodyPlan.scanStepDays
                )
            }
        }

        public var isComplete: Bool { bodyIndex >= schematic.bodyPlans.count }

        public var progress: SpineForgeProgress {
            SpineForgeProgress(
                completedSegments: completedSegments,
                totalSegments: totalSegments,
                currentBody: isComplete ? nil : schematic.bodyPlans[bodyIndex].body
            )
        }
    }
}
