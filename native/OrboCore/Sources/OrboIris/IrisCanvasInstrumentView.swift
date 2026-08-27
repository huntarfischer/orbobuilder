import SwiftUI
import OrboCore

/// A deliberately small native-medium study over one lawful Horae plane.
///
/// This view does not define new Orbo or Iris truth. It asks whether SwiftUI
/// Canvas is a better native instrument surface than Chart3D for the flat,
/// top-down celestial face. All placement, body, track, orientation, and zodiac
/// choices reuse the already-frozen Iris spatial-expression law.
public struct IrisCanvasInstrumentView: View {
    public let plane: IrisHoraePlane
    public let focusedBody: MundaneBody?
    public let orientationMode: IrisOrientationMode
    public let bodySizeMode: IrisBodySizeMode
    public let trackOrder: IrisTrackOrder
    public let trackExpansion: Double

    public init(
        plane: IrisHoraePlane,
        focusedBody: MundaneBody? = nil,
        orientationMode: IrisOrientationMode = .zodiacal,
        bodySizeMode: IrisBodySizeMode = .planetSized,
        trackOrder: IrisTrackOrder = .astroDNA,
        trackExpansion: Double = 0.0
    ) {
        self.plane = plane
        self.focusedBody = focusedBody
        self.orientationMode = orientationMode
        self.bodySizeMode = bodySizeMode
        self.trackOrder = trackOrder
        self.trackExpansion = min(max(trackExpansion, 0.0), 1.0)
    }

    public var body: some View {
        Canvas { context, size in
            let maximumTrackRadius = IrisTrackExpression.maximumRadius(
                order: trackOrder,
                expansion: trackExpansion
            )
            let rimRadius = maximumTrackRadius + 0.14
            let extent = rimRadius + 0.10

            drawTracks(
                in: &context,
                size: size,
                extent: extent
            )
            drawZodiacRim(
                in: &context,
                size: size,
                extent: extent,
                rimRadius: rimRadius
            )
            drawBodies(
                in: &context,
                size: size,
                extent: extent
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityIdentifier("orbo.iris.native-medium.canvas")
    }

    private func drawTracks(
        in context: inout GraphicsContext,
        size: CGSize,
        extent: Double
    ) {
        let radii: [Double]
        if trackExpansion == 0 {
            radii = [IrisTrackExpression.commonRadius]
        } else {
            radii = MundaneBody.canonicalOrder.map {
                IrisTrackExpression.radius(
                    for: $0,
                    order: trackOrder,
                    expansion: trackExpansion
                )
            }
        }

        for radius in radii {
            let rect = circleRect(
                radius: radius,
                size: size,
                extent: extent
            )
            context.stroke(
                Path(ellipseIn: rect),
                with: .foreground,
                lineWidth: 0.6
            )
        }
    }

    private func drawZodiacRim(
        in context: inout GraphicsContext,
        size: CGSize,
        extent: Double,
        rimRadius: Double
    ) {
        for sector in IrisZodiacRimSector.canonical {
            var path = Path()

            for step in 0...30 {
                let longitude = sector.startDegrees + Double(step)
                let point = screenPoint(
                    longitudeDegrees: longitude,
                    radius: rimRadius,
                    size: size,
                    extent: extent
                )
                if step == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }

            context.stroke(
                path,
                with: .color(IrisZodiacPalette.color(for: sector.appearance)),
                lineWidth: 8
            )

            let inner = screenPoint(
                longitudeDegrees: sector.startDegrees,
                radius: rimRadius - 0.07,
                size: size,
                extent: extent
            )
            let outer = screenPoint(
                longitudeDegrees: sector.startDegrees,
                radius: rimRadius + 0.04,
                size: size,
                extent: extent
            )
            var boundary = Path()
            boundary.move(to: inner)
            boundary.addLine(to: outer)
            context.stroke(
                boundary,
                with: .foreground,
                lineWidth: 1
            )
        }
    }

    private func drawBodies(
        in context: inout GraphicsContext,
        size: CGSize,
        extent: Double
    ) {
        let canvasScale = min(size.width, size.height)

        for point in plane.bodyPoints {
            let trackPlacement = IrisTrackExpression.placement(
                for: point,
                order: trackOrder,
                expansion: trackExpansion
            )
            let oriented = IrisOrientationExpression.placement(
                x: trackPlacement.x,
                y: trackPlacement.y,
                mode: orientationMode
            )
            let center = screenPoint(
                x: oriented.x,
                y: oriented.y,
                size: size,
                extent: extent
            )
            let appearance = IrisBodyExpression.appearance(
                for: point.source.body,
                sizeMode: bodySizeMode
            )
            let diameter = max(
                3,
                CGFloat(appearance.symbolSize) * canvasScale
            )
            let rect = CGRect(
                x: center.x - (diameter / 2),
                y: center.y - (diameter / 2),
                width: diameter,
                height: diameter
            )
            let color = IrisZodiacPalette.color(
                for: IrisZodiacPlacement(source: point.source).appearance
            )

            context.fill(
                Path(ellipseIn: rect),
                with: .color(color)
            )

            if point.source.body == focusedBody {
                context.stroke(
                    Path(ellipseIn: rect.insetBy(dx: -4, dy: -4)),
                    with: .foreground,
                    lineWidth: 1.5
                )
            }
        }
    }

    private func circleRect(
        radius: Double,
        size: CGSize,
        extent: Double
    ) -> CGRect {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let scale = min(size.width, size.height) / CGFloat(extent * 2)
        let r = CGFloat(radius) * scale
        return CGRect(
            x: center.x - r,
            y: center.y - r,
            width: r * 2,
            height: r * 2
        )
    }

    private func screenPoint(
        longitudeDegrees: Double,
        radius: Double,
        size: CGSize,
        extent: Double
    ) -> CGPoint {
        let radians = longitudeDegrees * .pi / 180.0
        let x = cos(radians) * radius
        let y = sin(radians) * radius
        let oriented = IrisOrientationExpression.placement(
            x: x,
            y: y,
            mode: orientationMode
        )
        return screenPoint(
            x: oriented.x,
            y: oriented.y,
            size: size,
            extent: extent
        )
    }

    private func screenPoint(
        x: Double,
        y: Double,
        size: CGSize,
        extent: Double
    ) -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let scale = min(size.width, size.height) / CGFloat(extent * 2)
        return CGPoint(
            x: center.x + (CGFloat(x) * scale),
            y: center.y - (CGFloat(y) * scale)
        )
    }
}
