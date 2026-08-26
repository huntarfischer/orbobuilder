import OrboCore

/// Iris-owned presentation orders for concentric body lanes.
public enum IrisTrackOrder: Hashable, Sendable {
    /// Native-chart order. Lane zero is reserved for the lawful Ascendant seam.
    case astroDNA

    /// Exact canonical order carried by the mundane Timespine.
    case timespine
}

/// One visual lane. A reserved Ascendant lane is not a fabricated celestial tract.
public enum IrisTrackLane: Hashable, Sendable {
    case reservedAscendant
    case body(MundaneBody)
}

/// Presentation-only radial placement for one unchanged Iris scene point.
public struct IrisTrackPlacement: Hashable, Sendable {
    public let source: IrisScenePoint3D
    public let radius: Double
    public let x: Double
    public let y: Double
    public let z: Double

    public init(source: IrisScenePoint3D, radius: Double) {
        self.source = source
        self.radius = radius
        self.x = source.x * radius
        self.y = source.y * radius
        self.z = source.z
    }
}

/// Radial expression of canonical body identity. Track radius is presentation only.
public enum IrisTrackExpression {
    public static let commonRadius = 1.0
    public static let innermostLaneRadius = 0.65
    public static let laneSpacing = 0.09

    public static let astroDNALanes: [IrisTrackLane] = [
        .reservedAscendant,
        .body(.moon),
        .body(.sun),
        .body(.mercury),
        .body(.venus),
        .body(.mars),
        .body(.jupiter),
        .body(.saturn),
        .body(.uranus),
        .body(.neptune),
        .body(.pluto),
        .body(.trueNorthNode),
    ]

    public static let timespineLanes: [IrisTrackLane] =
        MundaneBody.canonicalOrder.map(IrisTrackLane.body)

    public static func lanes(for order: IrisTrackOrder) -> [IrisTrackLane] {
        switch order {
        case .astroDNA:
            return astroDNALanes
        case .timespine:
            return timespineLanes
        }
    }

    public static func laneIndex(
        for body: MundaneBody,
        order: IrisTrackOrder
    ) -> Int {
        lanes(for: order).firstIndex(of: .body(body))!
    }

    public static func expandedRadius(
        for body: MundaneBody,
        order: IrisTrackOrder
    ) -> Double {
        innermostLaneRadius + (Double(laneIndex(for: body, order: order)) * laneSpacing)
    }

    public static func radius(
        for body: MundaneBody,
        order: IrisTrackOrder,
        expansion: Double
    ) -> Double {
        let t = min(max(expansion, 0.0), 1.0)
        let expanded = expandedRadius(for: body, order: order)
        return commonRadius + ((expanded - commonRadius) * t)
    }

    public static func placement(
        for point: IrisScenePoint3D,
        order: IrisTrackOrder,
        expansion: Double
    ) -> IrisTrackPlacement {
        IrisTrackPlacement(
            source: point,
            radius: radius(
                for: point.source.body,
                order: order,
                expansion: expansion
            )
        )
    }

    public static func maximumRadius(
        order: IrisTrackOrder,
        expansion: Double
    ) -> Double {
        MundaneBody.canonicalOrder
            .map { radius(for: $0, order: order, expansion: expansion) }
            .max() ?? commonRadius
    }
}
