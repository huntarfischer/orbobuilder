import Foundation

/// Native manufacturer for a degree-oriented Mundane Timespine span.
///
/// Forge opens astronomical truth and manufactures durable celestial chronology.
/// The generic owner knows how to manufacture any admitted plan. It does not know why
/// a particular span begins or ends; that proof belongs to the span recipe.
public enum MundaneTimespineForge {
    public static func makeCursor(plan: MundaneTimespineForgePlan) -> Cursor {
        Cursor(plan: plan)
    }

    public static func manufacture(
        plan: MundaneTimespineForgePlan,
        reference: any ForgeEphemerisReference
    ) throws -> MundaneTimespineForgeProduct {
        var cursor = Cursor(plan: plan)
        while !cursor.isComplete {
            _ = try cursor.step(reference: reference, segmentBudget: 4_096)
        }
        return try cursor.product()
    }

    public struct Cursor: Sendable {
        public let plan: MundaneTimespineForgePlan

        struct RawCrossing: Sendable {
            let julianDay: JulianDay
            let tick: Int
            let direction: MundaneCelestialSequenceDirection
        }

        struct RawBody: Sendable {
            var selected: [RawCrossing] = []
            var stations: [MundaneForgedStation] = []
            var initialState: MundaneForgeState?
            var finalState: MundaneForgeState?
        }

        var bodyIndex = 0
        var completedSegments = 0
        var currentJulianDay: JulianDay?
        var currentState: MundaneForgeState?
        var rawByBody: [MundaneBody: RawBody] = [:]

        init(plan: MundaneTimespineForgePlan) {
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

        struct OccurrenceKey: Hashable {
            let focalTick: Int
            let markerDegrees: [UInt16]
        }
    }
}
