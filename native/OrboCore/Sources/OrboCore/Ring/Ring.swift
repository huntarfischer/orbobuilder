public enum Ring {
    public static let degrees = 360
    public static let states = 720
    public static let arcsecondsPerDegree = 60 * 60
    public static let arcseconds = degrees * arcsecondsPerDegree
    public static let fineStates = arcseconds * 2
    public static let tieRule: RingTieRule = .lower
    public static let marks: [RingMark] = RingMark.allCases

    private static let targetTable: [Int] = {
        var table = Array(repeating: 0, count: degrees * marks.count * 2)
        for degree in 0..<degrees {
            for (markIndex, mark) in marks.enumerated() {
                let base = (degree * marks.count + markIndex) * 2
                table[base] = normalizedIntegerDegrees(degree - mark.rawValue)
                table[base + 1] = normalizedIntegerDegrees(degree + mark.rawValue)
            }
        }
        return table
    }()

    private static let exactMarkAtDirectedSeparation: [RingMark?] = {
        var table = Array<RingMark?>(repeating: nil, count: degrees)
        for mark in marks {
            table[mark.rawValue] = mark
            table[normalizedIntegerDegrees(-mark.rawValue)] = mark
        }
        return table
    }()

    public static func state(of longitude: CelestialLongitude, motion: Motion) -> RingState {
        let degree = Int(longitude.degrees.rounded(.down)) % degrees
        let motionOffset = motion == .retrograde ? degrees : 0
        return RingState(unchecked: degree + motionOffset)
    }

    public static func states(for longitude: CelestialLongitude) -> (direct: RingState, retrograde: RingState) {
        (
            state(of: longitude, motion: .direct),
            state(of: longitude, motion: .retrograde)
        )
    }

    public static func fineState(of longitude: CelestialLongitude, motion: Motion) -> RingFineState {
        let arcsecond = Int((longitude.degrees * Double(arcsecondsPerDegree)).rounded(.down)) % arcseconds
        let motionOffset = motion == .retrograde ? arcseconds : 0
        return RingFineState(unchecked: arcsecond + motionOffset)
    }

    public static func fineStates(for longitude: CelestialLongitude) -> (direct: RingFineState, retrograde: RingFineState) {
        (
            fineState(of: longitude, motion: .direct),
            fineState(of: longitude, motion: .retrograde)
        )
    }

    public static func targetDegree(
        from state: RingState,
        mark: RingMark,
        direction: RingDirection
    ) -> Int {
        let markIndex = marks.firstIndex(of: mark)!
        let base = (state.degree * marks.count + markIndex) * 2
        return targetTable[base + direction.tableOffset]
    }

    public static func target(
        from state: RingState,
        mark: RingMark,
        direction: RingDirection
    ) -> RingTarget {
        RingTarget(degree: targetDegree(from: state, mark: mark, direction: direction))
    }

    public static func row(for state: RingState) -> [RingRowEntry] {
        marks.map { mark in
            RingRowEntry(
                mark: mark,
                minus: target(from: state, mark: mark, direction: .minus),
                plus: target(from: state, mark: mark, direction: .plus)
            )
        }
    }

    public static func relation(between stateA: RingState, and stateB: RingState) -> RingMark? {
        let directed = normalizedIntegerDegrees(stateB.degree - stateA.degree)
        return exactMarkAtDirectedSeparation[directed]
    }

    public static func related(_ stateA: RingState, _ stateB: RingState) -> Bool {
        relation(between: stateA, and: stateB) != nil
    }

    public static func separation(from longitudeA: CelestialLongitude, to longitudeB: CelestialLongitude) -> RingSeparation {
        RingSeparation(unchecked: normalizedDegrees(longitudeB.degrees - longitudeA.degrees))
    }

    public static func arc(of separation: RingSeparation) -> Double {
        separation.degrees <= 180 ? separation.degrees : 360 - separation.degrees
    }

    public static func nearest(to separation: RingSeparation) -> RingNearest {
        let foldedArc = arc(of: separation)
        var bestMark = marks[0]
        var bestResidual = abs(foldedArc - Double(bestMark.rawValue))

        for mark in marks.dropFirst() {
            let residual = abs(foldedArc - Double(mark.rawValue))
            if residual < bestResidual - 1e-12 {
                bestMark = mark
                bestResidual = residual
            }
        }

        return RingNearest(arc: foldedArc, mark: bestMark, residual: bestResidual)
    }

    public static func exact(_ separation: RingSeparation) -> RingMark? {
        let nearest = nearest(to: separation)
        return nearest.residual == 0 ? nearest.mark : nil
    }

    public static func supplement(of mark: RingMark) -> RingMark? {
        RingMark(rawValue: 180 - mark.rawValue)
    }

    internal static var plateSize: Int {
        targetTable.count
    }

    internal static var exactMarkLookupSize: Int {
        exactMarkAtDirectedSeparation.count
    }

    internal static func normalizedDegrees(_ value: Double) -> Double {
        var normalized = value.truncatingRemainder(dividingBy: Double(degrees))
        if normalized < 0 {
            normalized += Double(degrees)
        }
        if normalized == 0 {
            normalized = 0
        }
        return normalized
    }

    private static func normalizedIntegerDegrees(_ value: Int) -> Int {
        let remainder = value % degrees
        return remainder < 0 ? remainder + degrees : remainder
    }
}
