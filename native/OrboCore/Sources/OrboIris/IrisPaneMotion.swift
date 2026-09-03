import Foundation

/// Presentation only. Fixed inner integration preserves a release's measured velocity.
public struct IrisPaneSpring: Hashable, Sendable {
    public var position: Double
    public var velocity: Double = 0
    public var target: Double
    public init(position: Double) { self.position = position; self.target = position }
    public mutating func advance(seconds: Double) {
        guard seconds.isFinite else { return }
        var remaining = min(0.1, max(0, seconds))
        while remaining > 0 {
            let h = min(remaining, 1.0 / 240)
            velocity += (-150 * (position - target) - 22 * velocity) * h
            position += velocity * h
            remaining -= h
        }
        if abs(position - target) < 0.1 && abs(velocity) < 0.1 { position = target; velocity = 0 }
    }
    public static func rubber(_ value: Double, lower: Double, upper: Double) -> Double {
        if value < lower { return lower - 46 * (1 - exp((value - lower) / 46)) }
        if value > upper { return upper + 46 * (1 - exp((upper - value) / 46)) }
        return value
    }
    public static func nearest(_ value: Double, velocity: Double, stops: [Double]) -> Double {
        stops.min { abs($0 - value - velocity * 0.17) < abs($1 - value - velocity * 0.17) } ?? value
    }
}
