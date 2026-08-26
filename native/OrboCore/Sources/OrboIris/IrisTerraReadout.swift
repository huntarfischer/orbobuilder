import Foundation
import OrboCore

/// Presentation-only readout of one unchanged Terra Marrow sample carried by Horae.
///
/// IX7 intentionally does not derive local Horizon, Ascendant, MC, or any other
/// place-dependent frame from Terra alone. The source sample remains the sole
/// terrestrial truth represented here.
public struct IrisTerraReadout: Hashable, Sendable {
    public let source: TerraMarrowSample

    public init(source: TerraMarrowSample) {
        self.source = source
    }

    public var julianDay: JulianDay {
        source.julianDay
    }

    public var turnDegrees: Double {
        source.turnDegrees
    }

    public var tiltDegrees: Double {
        source.tiltDegrees
    }

    public var displayText: String {
        String(
            format: "Terra turn %.2f° · tilt %.2f°",
            turnDegrees,
            tiltDegrees
        )
    }
}
