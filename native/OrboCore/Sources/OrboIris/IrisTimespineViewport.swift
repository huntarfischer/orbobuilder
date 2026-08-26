import OrboCore

public enum IrisTimespineViewportError: Error, Equatable, Sendable {
    case sampleCountTooSmall
    case nonIncreasingInterval
}

/// A presentation-owned temporal window resolved entirely through Horae.
///
/// Iris chooses the visible UT interval and sample density. Horae resolve every
/// requested UT back through OrboSpine Locate; Iris performs no celestial
/// interpolation of its own.
public struct IrisTimespineViewport: Hashable, Sendable {
    public let frames: [IrisHoraeFrame]

    public init(
        horae: Horae,
        start: JulianDay,
        end: JulianDay,
        sampleCount: Int
    ) throws {
        guard sampleCount >= 2 else {
            throw IrisTimespineViewportError.sampleCountTooSmall
        }
        guard start.value < end.value else {
            throw IrisTimespineViewportError.nonIncreasingInterval
        }

        let step = (end.value - start.value) / Double(sampleCount - 1)
        var resolved: [IrisHoraeFrame] = []
        resolved.reserveCapacity(sampleCount)

        for index in 0..<sampleCount {
            let value = index == sampleCount - 1
                ? end.value
                : start.value + (Double(index) * step)
            let julianDay = JulianDay(value)!
            resolved.append(
                IrisHoraeFrame(output: try horae.seek(to: julianDay))
            )
        }

        self.frames = resolved
    }

    public var julianDays: [JulianDay] {
        frames.map(\.julianDay)
    }

    public var terraSamples: [TerraMarrowSample] {
        frames.map(\.terra)
    }

    public var scene: IrisScene3D {
        IrisScene3D(
            coordinates: frames.flatMap { $0.output.celestial }
        )
    }
}
