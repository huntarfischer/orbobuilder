import Foundation

public extension TerraMarrowContract {
    /// Exact Swiss sidereal-model branch boundaries carried by the forged Terra Marrow.
    /// The long-term branch owns each exact seam; the short-term branch is strictly between them.
    static let sourceModelSeamJulianDays: [Double] = [
        2_396_758.5,
        2_469_807.5,
    ]
}
