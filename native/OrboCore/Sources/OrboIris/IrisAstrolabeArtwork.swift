import SwiftUI
import ImageIO

/// Decode the existing loose PNG resources directly from Iris's package bundle.
/// The instrument does not depend on an application asset-catalog lookup.
enum IrisAstrolabeArtwork {
    static let logo = image(named: "orbo-logo")
    static let companion = image(named: "orbo")

    private static func image(named name: String) -> Image? {
        guard let url = Bundle.module.url(forResource: name, withExtension: "png"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return Image(decorative: image, scale: 1, orientation: .up)
    }
}
