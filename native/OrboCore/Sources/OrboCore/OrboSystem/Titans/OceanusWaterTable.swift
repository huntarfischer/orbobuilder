/// Whole-degree geometric relation between the Ascendant row and Sun column
/// in Oceanus's frozen 360 × 360 water table.
///
/// This is geometry only. It does not contain or derive Sect truth.
public enum OceanusWaterRelation: String, Sendable, Equatable, CaseIterable {
    case above = "ABOVE"
    case below = "BELOW"
    case tie = "TIE"
}

enum OceanusWaterTable {
    static let width = 360
    static let cellCount = 129_600

    private static let cells: [OceanusWaterRelation] = {
        var table: [OceanusWaterRelation] = []
        table.reserveCapacity(cellCount)

        for ascendant in 0..<width {
            for sun in 0..<width {
                let delta = (sun - ascendant + width) % width

                switch delta {
                case 0, 180:
                    table.append(.tie)
                case 1...179:
                    table.append(.above)
                default:
                    table.append(.below)
                }
            }
        }

        return table
    }()

    static func relation(
        ascendantDegree: Int,
        sunDegree: Int
    ) -> OceanusWaterRelation? {
        guard (0..<width).contains(ascendantDegree),
              (0..<width).contains(sunDegree) else {
            return nil
        }

        return cells[ascendantDegree * width + sunDegree]
    }
}
