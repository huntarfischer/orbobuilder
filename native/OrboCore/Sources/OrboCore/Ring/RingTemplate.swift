public struct RingTemplateCell: Hashable, Sendable {
    public let degree: Int
    public let mark: RingMark?

    internal init(degree: Int, mark: RingMark?) {
        self.degree = degree
        self.mark = mark
    }
}

public struct RingTemplateFineMark: Hashable, Sendable {
    public let mark: RingMark
    public let targetArcsecond: Int

    internal init(mark: RingMark, targetArcsecond: Int) {
        self.mark = mark
        self.targetArcsecond = targetArcsecond
    }

    public var dms: RingDMS {
        RingDMS(
            degree: targetArcsecond / Ring.arcsecondsPerDegree,
            minute: (targetArcsecond / 60) % 60,
            second: targetArcsecond % 60
        )
    }
}

public struct RingObjectTemplate: Hashable, Sendable {
    public let gene: AstroDNAGene
    public let source: RingFineState
    public let template: RingTemplate
    public let marks: [RingTemplateFineMark]

    internal init(
        gene: AstroDNAGene,
        source: RingFineState,
        template: RingTemplate,
        marks: [RingTemplateFineMark]
    ) {
        self.gene = gene
        self.source = source
        self.template = template
        self.marks = marks
    }

    public var name: String {
        gene.displayName.split(separator: " ").joined() + "RingTemplate"
    }

    public var motion: Motion {
        source.motion
    }

    public var sourceDMS: RingDMS {
        source.dms
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

    public func exactMarks(for source: RingFineState) -> [RingTemplateFineMark]? {
        guard source.coarseState.degree == sourceDegree else { return nil }
        let offset = source.arcsecond % Ring.arcsecondsPerDegree

        return cells.compactMap { cell in
            guard let mark = cell.mark else { return nil }
            return RingTemplateFineMark(
                mark: mark,
                targetArcsecond: cell.degree * Ring.arcsecondsPerDegree + offset
            )
        }
    }

    public func objectTemplate(
        for gene: AstroDNAGene,
        source: RingFineState
    ) -> RingObjectTemplate? {
        guard let marks = exactMarks(for: source) else { return nil }
        return RingObjectTemplate(
            gene: gene,
            source: source,
            template: self,
            marks: marks
        )
    }
}
