public struct RingTemplate: Hashable, Sendable {
    public let sourceDegree: Int

    public init?(_ sourceDegree: Int) {
        guard (0..<Ring.degrees).contains(sourceDegree) else { return nil }
        self.sourceDegree = sourceDegree
    }

    public var interval: Range<Int> {
        sourceDegree..<(sourceDegree + 1)
    }
}
