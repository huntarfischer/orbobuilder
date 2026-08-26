import OrboCore

/// The narrow seam between Horae and Iris.
///
/// The complete Horae output remains intact. Iris derives only its visual scene
/// from the celestial coordinates Horae carried outward from OrboSpine.
public struct IrisHoraeFrame: Hashable, Sendable {
    public let output: HoraeOutput

    public init(output: HoraeOutput) {
        self.output = output
    }

    public var scene: IrisScene3D {
        IrisScene3D(coordinates: output.celestial)
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
