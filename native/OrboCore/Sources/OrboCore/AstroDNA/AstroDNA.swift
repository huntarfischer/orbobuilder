public struct AstroDNA: Hashable, Sendable, Codable {
    public static let codec = 3
    public static let geneCount = 12

    private let storage: [RingFineState]

    public init?(sequence: [RingFineState]) {
        guard sequence.count == Self.geneCount else { return nil }

        for gene in AstroDNAGene.canonicalOrder {
            let state = sequence[gene.ordinal]
            switch gene.motionPolicy {
            case .fixedDirect:
                guard !state.isRetrograde else { return nil }
            case .variable:
                break
            case .fixedRetrograde:
                guard state.isRetrograde else { return nil }
            }
        }

        storage = sequence
    }

    public init?(rawSequence: [Int]) {
        guard rawSequence.count == Self.geneCount else { return nil }
        var states: [RingFineState] = []
        states.reserveCapacity(Self.geneCount)

        for rawValue in rawSequence {
            guard let state = RingFineState(rawValue) else { return nil }
            states.append(state)
        }

        self.init(sequence: states)
    }

    public subscript(_ gene: AstroDNAGene) -> RingFineState {
        storage[gene.ordinal]
    }

    public var sequence: [RingFineState] {
        storage
    }

    public var rawSequence: [Int] {
        storage.map(\.rawValue)
    }

    public var sequenceString: String {
        rawSequence.map(String.init).joined(separator: "-")
    }

    /// Codec-2-compatible whole-degree projection. This is a named coarse cut
    /// of the codec-3 genome, not a second identity.
    public var degreeSequence: [RingState] {
        storage.map(\.coarseState)
    }

    public var degreeSequenceString: String {
        degreeSequence.map { String($0.rawValue) }.joined(separator: "-")
    }

    /// Reconstructs the canonical arcsecond longitude from the gene itself.
    /// No independent floating-point longitude is stored in AstroDNA.
    public func longitude(of gene: AstroDNAGene) -> CelestialLongitude {
        let degrees = Double(self[gene].arcsecond) / Double(Ring.arcsecondsPerDegree)
        return CelestialLongitude(degrees)!
    }

    public func sign(of gene: AstroDNAGene) -> Sign {
        longitude(of: gene).sign
    }

    public func degreeInSign(of gene: AstroDNAGene) -> DegreeInSign {
        longitude(of: gene).degreeInSign
    }

    public func motion(of gene: AstroDNAGene) -> Motion {
        self[gene].motion
    }

    /// The mean south node is definitionally opposite the encoded mean north
    /// node and is therefore derived rather than admitted as a thirteenth gene.
    public var meanSouthNodeLongitude: CelestialLongitude {
        CelestialLongitude(longitude(of: .northNode).degrees + 180)!
    }

    private enum CodingKeys: String, CodingKey {
        case codec
        case sequence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let codec = try container.decode(Int.self, forKey: .codec)
        guard codec == Self.codec else {
            throw DecodingError.dataCorruptedError(
                forKey: .codec,
                in: container,
                debugDescription: "AstroDNA requires codec 3."
            )
        }

        let rawSequence = try container.decode([Int].self, forKey: .sequence)
        guard let value = Self(rawSequence: rawSequence) else {
            throw DecodingError.dataCorruptedError(
                forKey: .sequence,
                in: container,
                debugDescription: "AstroDNA requires exactly twelve legal codec-3 Ring fine states in canonical gene order."
            )
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.codec, forKey: .codec)
        try container.encode(rawSequence, forKey: .sequence)
    }
}
