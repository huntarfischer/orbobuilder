import OrboCore

/// The narrow seam between Horae and Iris.
///
/// The complete Horae output remains intact. Iris may derive different
/// presentation manifestations from the same unchanged outward signal.
public struct IrisHoraeFrame: Hashable, Sendable {
    public let output: HoraeOutput

    public init(port: IrisPort<HoraeOutput>) {
        self.output = port.signal
    }

    public init(output: HoraeOutput) {
        self.output = output
    }

    public var scene: IrisScene3D {
        IrisScene3D(coordinates: output.celestial)
    }

    public var textReadout: IrisHoraeTextReadout {
        IrisHoraeTextReadout(frame: self)
    }

    public var julianDay: JulianDay {
        output.julianDay
    }

    public var terra: TerraMarrowSample {
        output.terra
    }

    public var terraReadout: IrisTerraReadout {
        IrisTerraReadout(source: output.terra)
    }

    public var controlState: HoraeControlState? {
        output.controlState
    }
}
