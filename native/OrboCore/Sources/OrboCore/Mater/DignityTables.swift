internal enum MaterDignityTables {
    private static let egyptianBoundEnds: [[(Planet, Double)]] = [
        [(.jupiter, 6), (.venus, 12), (.mercury, 20), (.mars, 25), (.saturn, 30)],
        [(.venus, 8), (.mercury, 14), (.jupiter, 22), (.saturn, 27), (.mars, 30)],
        [(.mercury, 6), (.jupiter, 12), (.venus, 17), (.mars, 24), (.saturn, 30)],
        [(.mars, 7), (.venus, 13), (.mercury, 19), (.jupiter, 26), (.saturn, 30)],
        [(.jupiter, 6), (.venus, 11), (.saturn, 18), (.mercury, 24), (.mars, 30)],
        [(.mercury, 7), (.venus, 17), (.jupiter, 21), (.mars, 28), (.saturn, 30)],
        [(.saturn, 6), (.mercury, 14), (.jupiter, 21), (.venus, 28), (.mars, 30)],
        [(.mars, 7), (.venus, 11), (.mercury, 19), (.jupiter, 24), (.saturn, 30)],
        [(.jupiter, 12), (.venus, 17), (.mercury, 21), (.saturn, 26), (.mars, 30)],
        [(.mercury, 7), (.jupiter, 14), (.venus, 22), (.saturn, 26), (.mars, 30)],
        [(.mercury, 7), (.venus, 13), (.jupiter, 20), (.mars, 25), (.saturn, 30)],
        [(.venus, 12), (.jupiter, 16), (.mercury, 19), (.mars, 28), (.saturn, 30)],
    ]

    static let egyptianBounds: [[Bound]] = {
        precondition(egyptianBoundEnds.count == Sign.canonicalOrder.count)

        return zip(Sign.canonicalOrder, egyptianBoundEnds).map { sign, row in
            precondition(row.count == 5)

            var start = 0.0
            let bounds = row.map { ruler, endValue -> Bound in
                guard
                    let startBoundary = DegreeBoundaryInSign(start),
                    let endBoundary = DegreeBoundaryInSign(endValue),
                    let bound = Bound(
                        ruler: ruler,
                        sign: sign,
                        start: startBoundary,
                        end: endBoundary,
                        scheme: .egyptian
                    )
                else {
                    preconditionFailure("Invalid Egyptian bound table for \(sign).")
                }

                start = endValue
                return bound
            }

            precondition(start == 30)
            return bounds
        }
    }()

    static let chaldeanOrder: [Planet] = [
        .saturn, .jupiter, .mars, .sun, .venus, .mercury, .moon,
    ]

    static let chaldeanFaces: [Planet] = {
        let marsIndex = chaldeanOrder.firstIndex(of: .mars)!
        return (0..<36).map { index in
            chaldeanOrder[(marsIndex + index) % chaldeanOrder.count]
        }
    }()

    static let dorotheanTriplicities: [Element: Triplicity] = [
        .fire: Triplicity(
            element: .fire,
            dayRuler: .sun,
            nightRuler: .jupiter,
            participatingRuler: .saturn,
            scheme: .dorothean
        ),
        .earth: Triplicity(
            element: .earth,
            dayRuler: .venus,
            nightRuler: .moon,
            participatingRuler: .mars,
            scheme: .dorothean
        ),
        .air: Triplicity(
            element: .air,
            dayRuler: .saturn,
            nightRuler: .mercury,
            participatingRuler: .jupiter,
            scheme: .dorothean
        ),
        .water: Triplicity(
            element: .water,
            dayRuler: .venus,
            nightRuler: .mars,
            participatingRuler: .moon,
            scheme: .dorothean
        ),
    ]
}
