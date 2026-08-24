public extension Arc {
    /// One absolute zodiacal degree contains 7,200 exact Arc output ticks:
    /// 3,600 whole arcseconds × two half-arcsecond states.
    static var outputTicksPerDegree: Int { arcsecondsPerDegree * 2 }

    /// Projects an already-cast Arc field onto the canonical 360 degree windows.
    static func project(_ field: ArcField) -> ArcGrid {
        let intervals = possibleIntervals(for: field)
        let cells = (0..<degrees).map { degree in
            makeDegreeCell(degree: degree, field: field, possibleIntervals: intervals)
        }
        return ArcGrid(field: field, cells: cells)
    }

    /// Convenience projection from one lawful coordinate.
    static func project(_ anchor: ArcCoordinate) -> ArcGrid {
        project(cast(anchor))
    }

    private static func possibleIntervals(for field: ArcField) -> [(lower: Int, upper: Int)] {
        let lower = field.minusPole.rawValue
        let upper = field.plusPole.rawValue

        if lower <= upper {
            return [(lower, upper)]
        }

        return [
            (lower, outputTicks - 1),
            (0, upper),
        ]
    }

    private static func makeDegreeCell(
        degree: Int,
        field: ArcField,
        possibleIntervals: [(lower: Int, upper: Int)]
    ) -> ArcDegreeCell {
        let cellLower = degree * outputTicksPerDegree
        let cellUpper = cellLower + outputTicksPerDegree - 1

        var intersection: (lower: Int, upper: Int)?
        for interval in possibleIntervals {
            let lower = max(cellLower, interval.lower)
            let upper = min(cellUpper, interval.upper)
            if lower <= upper {
                intersection = (lower, upper)
                break
            }
        }

        let coverage: ArcDegreeCoverage
        if let intersection {
            if intersection.lower == cellLower && intersection.upper == cellUpper {
                coverage = .possible
            } else {
                coverage = .partial(
                    ArcTickRange(
                        lower: ArcPosition(unchecked: intersection.lower),
                        upper: ArcPosition(unchecked: intersection.upper)
                    )
                )
            }
        } else {
            coverage = .impossible
        }

        return ArcDegreeCell(
            degree: degree,
            coverage: coverage,
            center: field.center.degree == degree ? field.center : nil,
            minusPole: field.minusPole.degree == degree ? field.minusPole : nil,
            plusPole: field.plusPole.degree == degree ? field.plusPole : nil
        )
    }
}

/// Exact inclusive output-tick range within one canonical degree window.
public struct ArcTickRange: Hashable, Sendable {
    public let lower: ArcPosition
    public let upper: ArcPosition

    internal init(lower: ArcPosition, upper: ArcPosition) {
        precondition(lower.rawValue <= upper.rawValue)
        precondition(lower.degree == upper.degree)
        self.lower = lower
        self.upper = upper
    }

    public var count: Int {
        upper.rawValue - lower.rawValue + 1
    }

    public var lowerOffsetInDegree: Int {
        lower.rawValue % Arc.outputTicksPerDegree
    }

    public var upperOffsetInDegree: Int {
        upper.rawValue % Arc.outputTicksPerDegree
    }

    public func contains(_ position: ArcPosition) -> Bool {
        position.rawValue >= lower.rawValue && position.rawValue <= upper.rawValue
    }
}

public enum ArcDegreeCoverage: Hashable, Sendable {
    /// No Arc output tick in this degree window belongs to the field.
    case impossible

    /// Every Arc output tick in this degree window belongs to the field.
    case possible

    /// Only the exact inclusive subrange belongs to the field.
    case partial(ArcTickRange)
}

/// Arc's statement about one absolute zodiacal degree window [degree, degree+1).
public struct ArcDegreeCell: Hashable, Sendable {
    public let degree: Int
    public let coverage: ArcDegreeCoverage
    public let center: ArcPosition?
    public let minusPole: ArcPosition?
    public let plusPole: ArcPosition?

    internal init(
        degree: Int,
        coverage: ArcDegreeCoverage,
        center: ArcPosition?,
        minusPole: ArcPosition?,
        plusPole: ArcPosition?
    ) {
        precondition((0..<Arc.degrees).contains(degree))
        self.degree = degree
        self.coverage = coverage
        self.center = center
        self.minusPole = minusPole
        self.plusPole = plusPole
    }

    public var possibleTickCount: Int {
        switch coverage {
        case .impossible:
            return 0
        case .possible:
            return Arc.outputTicksPerDegree
        case let .partial(range):
            return range.count
        }
    }

    public var impossibleTickCount: Int {
        Arc.outputTicksPerDegree - possibleTickCount
    }

    public func containsPossible(_ position: ArcPosition) -> Bool {
        guard position.degree == degree else { return false }

        switch coverage {
        case .impossible:
            return false
        case .possible:
            return true
        case let .partial(range):
            return range.contains(position)
        }
    }
}

/// Arc's exact 180° possibility field expressed over the canonical 360
/// absolute degree windows. The grid addresses the field; it does not replace it.
public struct ArcGrid: Hashable, Sendable {
    public let field: ArcField
    public let cells: [ArcDegreeCell]

    internal init(field: ArcField, cells: [ArcDegreeCell]) {
        precondition(cells.count == Arc.degrees)
        precondition(cells.enumerated().allSatisfy { index, cell in cell.degree == index })
        self.field = field
        self.cells = cells
    }

    public subscript(degree: Int) -> ArcDegreeCell? {
        guard (0..<Arc.degrees).contains(degree) else { return nil }
        return cells[degree]
    }

    public var possibleTickCount: Int {
        cells.reduce(0) { $0 + $1.possibleTickCount }
    }

    public var impossibleTickCount: Int {
        cells.reduce(0) { $0 + $1.impossibleTickCount }
    }
}
