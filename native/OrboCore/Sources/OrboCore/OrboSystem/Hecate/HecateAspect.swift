/// Explicit aspect tolerance supplied to Hecate.
///
/// Orbo's native/default aspect truth is exact: zero arcminutes. A wider orb
/// is an explicit lens over an unchanged exact angular separation.
public struct HecateAspectOrb: Hashable, Sendable {
    public static let exact = HecateAspectOrb(arcminutes: 0)!

    public let arcminutes: Double

    public init?(arcminutes: Double) {
        guard arcminutes.isFinite, arcminutes >= 0 else { return nil }
        self.arcminutes = arcminutes
    }

    public var degrees: Double {
        arcminutes / 60
    }
}

/// One factual point-to-point RELATE result.
///
/// The exact Ring separation is always retained. `matchedMark` is the aspect
/// admitted by the supplied orb, if any; Hecate supplies no interpretation.
public struct HecateAspect: Hashable, Sendable {
    public let separation: RingSeparation
    public let nearest: RingNearest
    public let matchedMark: RingMark?
    public let orb: HecateAspectOrb

    internal init(
        separation: RingSeparation,
        nearest: RingNearest,
        matchedMark: RingMark?,
        orb: HecateAspectOrb
    ) {
        self.separation = separation
        self.nearest = nearest
        self.matchedMark = matchedMark
        self.orb = orb
    }
}

public extension Hecate {
    /// RELATE at point scale: two celestial points remain themselves and Hecate
    /// reports the exact angular relation between them.
    static func relateAspect(
        _ left: CelestialLongitude,
        _ right: CelestialLongitude,
        orb: HecateAspectOrb = .exact
    ) -> HecateAspect {
        let separation = Ring.separation(from: left, to: right)
        let nearest = Ring.nearest(to: separation)

        let matchedMark: RingMark?
        if orb == .exact {
            matchedMark = Ring.exact(separation)
        } else {
            matchedMark = nearest.residual <= orb.degrees ? nearest.mark : nil
        }

        return HecateAspect(
            separation: separation,
            nearest: nearest,
            matchedMark: matchedMark,
            orb: orb
        )
    }
}
