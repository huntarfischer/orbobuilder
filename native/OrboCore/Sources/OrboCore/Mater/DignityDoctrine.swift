internal enum MaterDoctrineTables {
    static func bounds(for scheme: BoundsScheme) -> [[Bound]] {
        switch scheme {
        case .egyptian:
            MaterDignityTables.egyptianBounds
        }
    }

    static func faces(for scheme: FaceScheme) -> [Planet] {
        switch scheme {
        case .chaldean:
            MaterDignityTables.chaldeanFaces
        }
    }

    static func triplicity(
        for element: Element,
        scheme: TriplicityScheme
    ) -> Triplicity {
        switch scheme {
        case .dorothean:
            guard let triplicity = MaterDignityTables.dorotheanTriplicities[element] else {
                preconditionFailure("Missing Dorothean triplicity for \(element).")
            }
            return triplicity
        }
    }
}
