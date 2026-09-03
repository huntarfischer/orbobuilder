import CoreGraphics
import OrboCore

public struct IrisPlacementHit: Hashable, Sendable {
    public let kind: AstrolabeChart.Kind
    public let gene: AstroDNAGene
}
public extension IrisAegisGeometry {
    /// Resolves pickup against actual glyph centers, independently of paint order.
    /// A closer natal glyph owns its tap and must not start a sky scrub.
    func placement(at touch: CGPoint, sky: [AstrolabePlacement], natal: [AstrolabePlacement]) -> IrisPlacementHit? {
        let radius = diameter / 2
        let offsets = Self.trackOffsets(sky.filter { $0.gene != .ascendant })
        var best: (hit: IrisPlacementHit, distance: Double)?
        for kind in [AstrolabeChart.Kind.sky, .natal] {
            for placement in kind == .sky ? sky : natal {
                let track: Double
                if kind == .natal { track = radius * 0.60 }
                else if placement.gene == .ascendant { track = radius * 0.99 }
                else { track = radius * 0.75 - (offsets[placement.gene] ?? 0) }
                let center = point(longitude: placement.longitude.degrees, radius: track)
                let distance = Double(hypot(center.x - touch.x, center.y - touch.y))
                guard distance < (kind == .natal ? 20 : 30), best == nil || distance < best!.distance else { continue }
                best = (IrisPlacementHit(kind: kind, gene: placement.gene), distance)
            }
        }
        return best?.hit
    }
}
