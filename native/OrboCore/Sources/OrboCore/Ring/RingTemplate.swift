public struct RingTemplateCell: Hashable, Sendable {
    public let degree: Int
    public let mark: RingMark?

    internal init(degree: Int, mark: RingMark?) {
        self.degree = degree
        self.mark = mark
    }
}

public struct RingTemplate: Hashable, Sendable {
    public let sourceDegree: Int
    public let cells: [RingTemplateCell]

    public init?(_ sourceDegree: Int) {
        guard (0..<Ring.degrees).contains(sourceDegree) else { return nil }
        self.sourceDegree = sourceDegree

        let source = RingState(unchecked: sourceDegree)
        self.cells = (0..<Ring.degrees).map { degree in
            RingTemplateCell(
                degree: degree,
                mark: Ring.relation(
                    between: source,
                    and: RingState(unchecked: degree)
                )
            )
        }
    }

    public var interval: Range<Int> {
        sourceDegree..<(sourceDegree + 1)
    }

    public subscript(degree: Int) -> RingTemplateCell? {
        guard (0..<Ring.degrees).contains(degree) else { return nil }
        return cells[degree]
    }
}
