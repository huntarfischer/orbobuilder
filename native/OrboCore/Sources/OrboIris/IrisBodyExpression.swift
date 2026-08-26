import OrboCore

/// Presentation-only size modes for physical celestial bodies.
public enum IrisBodySizeMode: Hashable, Sendable {
    case equal
    case planetSized
}

/// Iris-owned visual form. This does not alter canonical body identity.
public enum IrisBodyForm: Hashable, Sendable {
    case sphere
    case point
}

/// Presentation-only body form and Chart3D symbol size.
public struct IrisBodyAppearance: Hashable, Sendable {
    public let form: IrisBodyForm
    public let symbolSize: Double

    public init(form: IrisBodyForm, symbolSize: Double) {
        self.form = form
        self.symbolSize = symbolSize
    }
}

/// Stable Iris expression of canonical Orbo body identity.
public enum IrisBodyExpression {
    public static let equalPhysicalSymbolSize = 0.045
    public static let nodeSymbolSize = 0.018

    public static func appearance(
        for body: MundaneBody,
        sizeMode: IrisBodySizeMode
    ) -> IrisBodyAppearance {
        if body == .trueNorthNode {
            return IrisBodyAppearance(form: .point, symbolSize: nodeSymbolSize)
        }

        switch sizeMode {
        case .equal:
            return IrisBodyAppearance(
                form: .sphere,
                symbolSize: equalPhysicalSymbolSize
            )
        case .planetSized:
            return IrisBodyAppearance(
                form: .sphere,
                symbolSize: planetSizedSymbolSize(for: body)
            )
        }
    }

    private static func planetSizedSymbolSize(for body: MundaneBody) -> Double {
        switch body {
        case .sun: return 0.075
        case .moon: return 0.034
        case .mercury: return 0.036
        case .venus: return 0.043
        case .mars: return 0.039
        case .jupiter: return 0.065
        case .saturn: return 0.060
        case .uranus: return 0.052
        case .neptune: return 0.050
        case .pluto: return 0.030
        case .trueNorthNode: return nodeSymbolSize
        }
    }
}
